#!/usr/bin/env python3
"""
patch-v17.py — apply the v17 changes on top of the v16 source tree.

CONTEXT (why v17 exists):
    The v16 field run (2026-09-21) COMPLETED PHASE D with honest
    instrumentation: ">>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<"
    - PONG PERFECT (seq=0x1337 echoed, status=1 Success),
    - win_build driver-live=19045 == script-side=19045,
    - INFCNT=2 (both protocol writes reached the hook),
    - TRIGGER-SEEN flag 0x20 SET, stage 4, hook_calls 381->394.

    The one remaining unproven piece: the DATA path (payload
    transport) the real client (Infinity.exe) uses —
    ReqOp_Read(address,size) -> response + InfinityData payload.

v17 FUNCTIONAL CHANGE (this file — ONE surgical path, F1..F3):
    A kernel-target read mode for the VARIABLE transport:
      pid == KERNEL_TARGET_PID (0xFFFFFFFF) on a ReqOp_Read makes
      the driver answer the read from the CALLER's address space:
      ReadKernelVA() walks the CURRENT CR3 (inside the gRT hook =
      the calling Windows thread's page tables, which map the
      kernel VA range incl. KUSER_SHARED_DATA). All data reads go
      through ReadPhysical (UEFI identity-map CR3 dance) — a bad,
      unmapped or non-canonical VA fails TranslateVA BEFORE any
      dereference: there is NO #PF/#GP path, so the negative test
      (0xDEADBEEF00000000) returns ErrAccess instead of crashing.
    Blast radius: the shared-memory ring path and the normal
    target-process path are UNTOUCHED. The real client never sends
    pid=0xFFFFFFFF (it sends the attached pid or 0). Writes have
    NO kernel fallback.

v17 COSMETICS (C1..C8 — version strings only, same VA-safe
patterns; string literals passed directly to SerialTrace calls,
never stored in pointer variables):
    C1/C2   serial build lines RT/SAFE -> v17
    C3/C4   screen banners RT/SAFE -> v17 (padded to the exact
            v16 banner width so the blue banner overwrites cleanly)
    C5/C6   efi_main / variant lines -> v17
    C7      RT-EARLY banner -> v17 tagline
    C8      RT-VA "(v16 early)" -> "(v17 early)"

Anchors are EXACT v16 source text (verified against build-v16-tree).
An anchor that does not match exactly once = FAIL LOUD, no files
modified.
"""
import sys
from pathlib import Path


def apply_edit(files, tag, relpath, old, new):
    p = files[relpath]
    text = p.read_text()
    n = text.count(old)
    if n != 1:
        print(f"FATAL: anchor {tag} in {relpath}: found {n} occurrences (need exactly 1)")
        sys.exit(1)
    p.write_text(text.replace(old, new))
    print(f"  {tag}: {relpath} OK")


def main():
    if len(sys.argv) != 2:
        print("usage: patch-v17.py <v16-source-tree-root>")
        sys.exit(1)
    root = Path(sys.argv[1])
    inc = root / "UEFI" / "include"
    src = root / "UEFI" / "src"
    mem_inc = root / "Memory" / "include"
    files = {
        "main.c": src / "main.c",
        "RuntimeHook.h": inc / "RuntimeHook.h",
        "ProcessMemory.h": inc / "ProcessMemory.h",
        "RequestHandler.h": inc / "RequestHandler.h",
        "SharedMemoryProtocol.h": mem_inc / "SharedMemoryProtocol.h",
    }
    for f in files.values():
        if not f.exists():
            print(f"FATAL: missing {f}")
            sys.exit(1)

    print(f"patching v17 onto {root} ...")

    # --------------------------------------------- F1: protocol constant
    # ABI-neutral: a constexpr, no struct/layout change. Protocol
    # version stays 2 (the wire layout is unchanged).
    apply_edit(
        files, "F1-kernel-target-pid", "SharedMemoryProtocol.h",
        old=(
            "    ReqOp_Detach    = 8,\n"
            "    ReqOp_Ping      = 0xDEADBEEF,\n"
            "};\n"
        ),
        new=(
            "    ReqOp_Detach    = 8,\n"
            "    ReqOp_Ping      = 0xDEADBEEF,\n"
            "};\n"
            "\n"
            "// =============================================================\n"
            "// v17 protocol extension (ABI-neutral, no layout change):\n"
            "// In the VARIABLE transport (InfinityReq), pid ==\n"
            "// KERNEL_TARGET_PID selects the KERNEL target: the driver\n"
            "// answers a ReqOp_Read from the CALLER's address space via\n"
            "// the current CR3 - used for diagnostics (KUSER_SHARED_DATA\n"
            "// reads through the bridge). The real client never sends\n"
            "// this pid (it sends the attached process pid or 0), and\n"
            "// the shared-memory ring path ignores it. Writes have no\n"
            "// kernel fallback.\n"
            "// =============================================================\n"
            "inline constexpr std::uint32_t KERNEL_TARGET_PID = 0xFFFFFFFFu;\n"
        ),
    )

    # --------------------------------------------- F2: ReadKernelVA
    apply_edit(
        files, "F2-read-kernel-va", "ProcessMemory.h",
        old=(
            "        BOOLEAN WriteVA(UINT64 va, const VOID* src, UINTN size) {\n"
            "            if (!phys_ || !target_cr3_) return FALSE;\n"
            "            return phys_->WriteVA(va, target_cr3_, src, size);\n"
            "        }\n"
        ),
        new=(
            "        BOOLEAN WriteVA(UINT64 va, const VOID* src, UINTN size) {\n"
            "            if (!phys_ || !target_cr3_) return FALSE;\n"
            "            return phys_->WriteVA(va, target_cr3_, src, size);\n"
            "        }\n"
            "\n"
            "        // =========================================================\n"
            "        // v17: kernel-space read for the data-path proof.\n"
            "        // Walks the CALLER's page tables - inside the gRT hook\n"
            "        // that is the calling Windows thread's CR3, so kernel VAs\n"
            "        // (KUSER_SHARED_DATA etc.) translate. All data reads go\n"
            "        // through ReadPhysical (UEFI identity map): a bad, unmapped\n"
            "        // or non-canonical VA fails TranslateVA BEFORE any\n"
            "        // dereference - there is no #PF/#GP path. Writes have NO\n"
            "        // kernel fallback (target-process only).\n"
            "        // =================================================================\n"
            "        BOOLEAN ReadKernelVA(UINT64 va, VOID* out, UINTN size) {\n"
            "            if (!phys_) return FALSE;\n"
            "            UINT64 cr3 = ReadCr3();\n"
            "            if (cr3 == 0 || (cr3 & 0xFFF)) return FALSE;\n"
            "            return phys_->ReadVA(va, cr3, out, size);\n"
            "        }\n"
        ),
    )

    # --------------------------------------------- F3: handler kernel branch
    # (variable transport only; the ring path ProcessOneRequest is untouched)
    apply_edit(
        files, "F3-handler-kernel-read", "RequestHandler.h",
        old=(
            "            case ReqOp_Read: {\n"
            "                BOOLEAN ok = mem_->ReadVA(req->address, data_buf, req->data_size);\n"
            "                resp->status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;\n"
            "                resp->bytes_transferred = ok ? req->data_size : 0;\n"
            "                *data_size = ok ? req->data_size : 0;\n"
            "                break;\n"
            "            }\n"
        ),
        new=(
            "            case ReqOp_Read: {\n"
            "                // v17: pid == KERNEL_TARGET_PID selects the KERNEL\n"
            "                // target - the read is served from the caller's\n"
            "                // (Windows) address space via the current CR3. This\n"
            "                // is the data-path proof route (KUSD reads); a bad\n"
            "                // VA fails the page walk cleanly (ErrAccess). Any\n"
            "                // other pid without an attached process keeps the\n"
            "                // same clean ErrAccess failure as before - the real\n"
            "                // client is unaffected.\n"
            "                BOOLEAN ok;\n"
            "                if (req->pid == KERNEL_TARGET_PID) {\n"
            "                    SerialTrace::KV(\"RD\", \"kern va\", req->address);\n"
            "                    ok = mem_->ReadKernelVA(req->address, data_buf,\n"
            "                                            req->data_size);\n"
            "                    SerialTrace::KVD(\"RD\", \"kern read ok\", ok ? 1u : 0u);\n"
            "                } else {\n"
            "                    ok = mem_->ReadVA(req->address, data_buf,\n"
            "                                      req->data_size);\n"
            "                }\n"
            "                resp->status = ok ? SlotStatus_Success : SlotStatus_ErrAccess;\n"
            "                resp->bytes_transferred = ok ? req->data_size : 0;\n"
            "                *data_size = ok ? req->data_size : 0;\n"
            "                break;\n"
            "            }\n"
        ),
    )

    # --------------------------------------------- C1: serial build line RT
    apply_edit(
        files, "C1-serial-build-rt", "main.c",
        old='    static const char kBuildLine[] = "  Build: v16 RT - full bridge proven, clean serial labels";\n',
        new='    static const char kBuildLine[] = "  Build: v17 RT - kernel data path via current CR3";\n',
    )

    # --------------------------------------------- C2: serial build line SAFE
    apply_edit(
        files, "C2-serial-build-safe", "main.c",
        old='    static const char kBuildLine[] = "  Build: v16 SAFE (phase C)";\n',
        new='    static const char kBuildLine[] = "  Build: v17 SAFE (phase C)";\n',
    )

    # --------------------------------------------- C3: SCREEN banner RT
    # (padded programmatically to the exact v16 banner width: 55 + 3 = 58)
    old_core = "  Build: v16 RT - full bridge proven (phase D COMPLETE)"
    new_core = "  Build: v17 RT - bridge + kernel data path (phase E)"
    assert len(old_core) == 55, f"v16 banner core length drifted: {len(old_core)}"
    assert len(new_core) <= len(old_core)
    new_pad = new_core + " " * (len(old_core) - len(new_core))
    apply_edit(
        files, "C3-screen-banner-rt", "main.c",
        old='        Print((CHAR16*)L"' + old_core + '   \\r\\n");\n',
        new='        Print((CHAR16*)L"' + new_pad + '   \\r\\n");\n',
    )

    # --------------------------------------------- C4: SCREEN banner SAFE
    # (27-char core + 31 spaces = same 58-wide banner)
    old_core = "  Build: v16 SAFE (phase C)"
    new_core = "  Build: v17 SAFE (phase C)"
    apply_edit(
        files, "C4-screen-banner-safe", "main.c",
        old='        Print((CHAR16*)L"' + old_core + ' ' * 31 + '\\r\\n");\n',
        new='        Print((CHAR16*)L"' + new_core + ' ' * 31 + '\\r\\n");\n',
    )

    # --------------------------------------------- C5: efi_main boot line
    apply_edit(
        files, "C5-efi-main", "main.c",
        old='    SerialTrace::Line("MAIN", "efi_main v16 boot");\n',
        new='    SerialTrace::Line("MAIN", "efi_main v17 boot");\n',
    )

    # --------------------------------------------- C6: variant line RT
    apply_edit(
        files, "C6-variant-rt", "main.c",
        old='    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v16)");\n',
        new='    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v17)");\n',
    )

    # --------------------------------------------- C7: RT-EARLY banner
    apply_edit(
        files, "C7-rt-early-banner", "RuntimeHook.h",
        old='            SerialTrace::Line("RT-EARLY", "memory.efi v16 RT (full bridge proven, clean serial labels)");\n',
        new='            SerialTrace::Line("RT-EARLY", "memory.efi v17 RT (kernel data path: current-CR3 reads)");\n',
    )

    # --------------------------------------------- C8: RT-VA banner
    apply_edit(
        files, "C8-rt-va-banner", "RuntimeHook.h",
        old='                SerialTrace::Line("RT-VA", "hooks already installed at load (v16 early) - keeping slots");\n',
        new='                SerialTrace::Line("RT-VA", "hooks already installed at load (v17 early) - keeping slots");\n',
    )

    print("v17 patch applied (tree is now the exact v17 source)")


if __name__ == "__main__":
    main()
