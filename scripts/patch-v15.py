#!/usr/bin/env python3
"""
patch-v15.py — apply the v15 changes on top of the v14 source tree.

WHY v15 EXISTS (the v14 BSOD, root-caused by disassembly):
    The v14 run BOOTED and the GUID fixes WORKED (3 "S OURVAR delete"
    traces + the RAM serve fired: "G INFDIAG live"), but the machine
    BSOD'd (KMODE_EXCEPTION_NOT_HANDLED, 60%) on the script's step A —
    the first INFDIAG read. The serial log truncates EXACTLY mid-hex:

        [INF][HOOK] G INFDIAG live
        [INF][BLD] live KUSD read implausible =0x      <- truncated

    ROOT CAUSE (proven in the v14 RT binary's disassembly):
        SerialTrace::Hex64/Hex32 used
            static const char* k = "0123456789ABCDEF";
        The compiler materialized k as a POINTER SLOT in .data.rel.ro
        (disassembly: mov r8,QWORD PTR [rip+0x10b05] # ...Hex64()::k,
        then movzx eax,BYTE PTR [r8+rax]). The slot holds the LOAD-TIME
        (physical) address; nobody converted it at SetVirtualAddressMap
        (it is not in the ConvertGraph list). After Windows boots, the
        kernel page tables map EFI runtime code ONLY at the converted
        VAs -> the stale pointer is UNMAPPED -> the very first hex
        print from the Windows kernel context page-faults.

        Every trace that worked post-VA so far ("G call#320 VIRT",
        "S OURVAR delete", "G INFDIAG live", the "[BLD]" prefix and
        "=0x" of the KV) is Begin/Puts/Putc/Dec — string literals are
        rip-relative LEAs, no pointer slots. The [BLD] KV was the FIRST
        Hex64 call EVER from the Windows context. Same shape as the
        v12 crash (log truncated mid "flags=0x" — the v12 BSOD was
        this SAME bug, not the orig-SetVariable-in-dispatch theory;
        v13's 3 accidental chains + v14's 5 chains (3 deletes matched
        + 2 unmatched) all proved orig-chaining safe).

    SECONDARY bug (non-fatal, broke the feature): the live KUSD read
    returned an IMPLAUSIBLE value — KUSD+0x308 does NOT contain
    NtBuildNumber on the live Windows 10 19045 x64. The base-repo
    "#111 fix" comment ("0x308 authoritative for 1607+") is wrong.
    0x260 is the classic x64 offset. v15 probes BOTH and traces the
    raw values so the next report settles it with ground truth.

v15 = v14 + three surgical changes (mechanism otherwise unchanged):
  V1  SerialTrace hex tables: pointer -> ARRAY (rip-relative, needs
      no conversion in any address space). THE crasher fix.
  V2  KUSD build probe: candidates {0x260, 0x308}, plausibility
      helper, raw-value forensics trace (hex prints safe now).
  V3  Shared CaptureLiveWindowsBuild(): runs once per boot, VA-gated
      (boot contexts can not touch the OS KUSD mapping), used by both
      the INFDIAG serve path and HandleOurSetVariable.
  V4  Banners v14 -> v15 (RT-EARLY, RT-VA, main.c Build line).
  Diag.h comment revision: v12 BSOD attribution corrected.

EXPECTED v15 RUN SIGNATURES (with the crasher fixed):
  serial : "[BLD] kusd raw 0x260=0x...." + "kusd raw 0x308=0x...."
           then "live windows build (ofs 0x2xx) <build>" (one of them)
           step A/B: hook_calls MOVING, INFCNT live, S OURVAR traces
           step E PING -> ProcessSingleVariableRequest (RAM-only op)
           step F: InfinityResp SERVED from RAM -> FULL BRIDGE
  verdict: full bridge / reads-only / both-bypassed — REAL this time.

Anchors are EXACT v14 source text (verified against build-v14-tree).
An anchor that does not match exactly once = FAIL LOUD, no files
modified.
"""
import sys
from pathlib import Path

MARKER = "memory.efi v15"


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
        print("usage: patch-v15.py <v14-source-tree-root>")
        sys.exit(1)
    root = Path(sys.argv[1])
    inc = root / "UEFI" / "include"
    src = root / "UEFI" / "src"
    files = {
        "SerialTrace.h": inc / "SerialTrace.h",
        "WindowsOffsets.h": inc / "WindowsOffsets.h",
        "Diag.h": inc / "Diag.h",
        "RuntimeHook.h": inc / "RuntimeHook.h",
        "main.c": src / "main.c",
    }
    for f in files.values():
        if not f.exists():
            print(f"FATAL: missing {f}")
            sys.exit(1)

    print(f"patching v15 onto {root} ...")

    # ------------------------------------------------ V1a: Hex64 array
    apply_edit(
        files, "V1a-hex64-array", "SerialTrace.h",
        old=(
            "    static void Hex64(uint64_t v) {\n"
            "        static const char* k = \"0123456789ABCDEF\";\n"
            "        for (int nib = 60; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);\n"
            "    }\n"
        ),
        new=(
            "    // v15: this used to be 'static const char* k = \"...\"' — the\n"
            "    // compiler materialized it as a POINTER SLOT in .data.rel.ro\n"
            "    // holding the load-time (physical) address, which nobody\n"
            "    // converted at SetVirtualAddressMap. The first hex print from\n"
            "    // the Windows kernel context dereferenced that stale address\n"
            "    // and page-faulted — THAT was the v12 and the v14 BSOD (both\n"
            "    // logs truncate mid \"=0x\"). An ARRAY is addressed rip-relative\n"
            "    // and needs no conversion in any address space.\n"
            "    static void Hex64(uint64_t v) {\n"
            "        static const char k[] = \"0123456789ABCDEF\";\n"
            "        for (int nib = 60; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);\n"
            "    }\n"
        ),
    )

    # ------------------------------------------------ V1b: Hex32 array
    apply_edit(
        files, "V1b-hex32-array", "SerialTrace.h",
        old=(
            "    static void Hex32(uint32_t v) {\n"
            "        static const char* k = \"0123456789ABCDEF\";\n"
            "        for (int nib = 28; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);\n"
            "    }\n"
        ),
        new=(
            "    static void Hex32(uint32_t v) {\n"
            "        static const char k[] = \"0123456789ABCDEF\";\n"
            "        for (int nib = 28; nib >= 0; nib -= 4) Putc(k[(v >> nib) & 0xF]);\n"
            "    }\n"
        ),
    )

    # ------------------------------------------------ V2a: KUSD candidates
    apply_edit(
        files, "V2a-kusd-candidates", "WindowsOffsets.h",
        old=(
            "    // =========================================================\n"
            "    // KUSER_SHARED_DATA — always at fixed virtual address.\n"
            "    // Contains build number.\n"
            "    // #111 fix: use ONE authoritative offset.\n"
            "    // On Windows 10 1607+ (build 14393+), NtBuildNumber is at 0x308.\n"
            "    // On older builds it was at 0x260. We support 1809+ (17763+),\n"
            "    // where 0x308 is correct.\n"
            "    // =========================================================\n"
            "    constexpr UINT64 KUSER_SHARED_DATA_VA = 0xFFFFF78000000000ULL;\n"
            "    constexpr UINT32 KUSD_OFS_NtBuildNumber  = 0x308;  // authoritative for Win10 1809+\n"
        ),
        new=(
            "    // =========================================================\n"
            "    // KUSER_SHARED_DATA — always at fixed virtual address.\n"
            "    // Contains build number.\n"
            "    // v15 fix: the base-repo claim \"#111: 0x308 for 1607+\" was\n"
            "    // DISPROVED empirically — the v14 run read an implausible\n"
            "    // value at +0x308 on a live Windows 10 19045 x64. 0x260 is\n"
            "    // the classic x64 NtBuildNumber offset. v15 probes BOTH and\n"
            "    // traces the raw values, so the next report settles it with\n"
            "    // ground truth instead of a guessed constant.\n"
            "    // =========================================================\n"
            "    constexpr UINT64 KUSER_SHARED_DATA_VA = 0xFFFFF78000000000ULL;\n"
            "    constexpr UINT32 KUSD_OFS_BUILD_CANDIDATES[2] = { 0x260, 0x308 };\n"
            "    inline bool KusdBuildPlausible(UINT32 b) {\n"
            "        return b >= 15000 && b < 99999;\n"
            "    }\n"
        ),
    )

    # ------------------------------------------------ V2b: DetectWindowsBuildNumber
    apply_edit(
        files, "V2b-detect-multi-probe", "WindowsOffsets.h",
        old=(
            "    inline UINT32 DetectWindowsBuildNumber(class PhysicalMemory* pm, UINT64 os_cr3) {\n"
            "        // Read NtBuildNumber from KUSER_SHARED_DATA.\n"
            "        // This is always at the fixed VA above and the OS keeps it mapped.\n"
            "        UINT32 build = 0;\n"
            "        if (!pm->ReadVA(KUSER_SHARED_DATA_VA + KUSD_OFS_NtBuildNumber,\n"
            "                        os_cr3, &build, sizeof(build))) {\n"
            "            return 0;\n"
            "        }\n"
            "        // High bit is sometimes set; mask it off.\n"
            "        return build & 0x7FFFFFFF;\n"
            "    }\n"
        ),
        new=(
            "    inline UINT32 DetectWindowsBuildNumber(class PhysicalMemory* pm, UINT64 os_cr3) {\n"
            "        // v15: probe BOTH candidate offsets; return the first\n"
            "        // plausible build (0 if none / not readable).\n"
            "        UINT32 build = 0;\n"
            "        for (int i = 0; i < 2; i++) {\n"
            "            if (!pm->ReadVA(KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[i],\n"
            "                            os_cr3, &build, sizeof(build))) {\n"
            "                continue;\n"
            "            }\n"
            "            build &= 0x7FFFFFFF;  // high bit is the checked-build flag\n"
            "            if (KusdBuildPlausible(build)) return build;\n"
            "        }\n"
            "        return 0;\n"
            "    }\n"
        ),
    )

    # ------------------------------------------------ V3a: g_kusd_probe_done
    apply_edit(
        files, "V3a-probe-flag", "Diag.h",
        old=(
            "inline UINT32 g_diag_req_count = 0;\n"
        ),
        new=(
            "inline UINT32 g_diag_req_count = 0;\n"
            "\n"
            "// v15: one-shot KUSD build probe (both candidate offsets are\n"
            "// traced once per boot; see RuntimeHook CaptureLiveWindowsBuild).\n"
            "inline UINT32 g_kusd_probe_done = 0;\n"
        ),
    )

    # ------------------------------------------------ V3b: v12 comment revision
    apply_edit(
        files, "V3b-v12-comment-fix", "Diag.h",
        old=(
            "// data). RAM-ONLY on purpose — no NVRAM mirror, because calling\n"
            "// the original SetVariable from inside a hook at runtime is what\n"
            "// crashed the kernel in v12 (KMODE_EXCEPTION, 2026-09-20). The\n"
            "// counter is observable through the RAM-served INFCNT read.\n"
        ),
        new=(
            "// data). RAM-ONLY observability. (v15 revision: the v12 BSOD\n"
            "// was finally root-caused to SerialTrace's stale hex-table\n"
            "// pointer — NOT to chaining orig SetVariable, which the v13\n"
            "// and v14 runs proved safe 8 times. The counter stays\n"
            "// RAM-mirrored by design.) The counter is observable through\n"
            "// the RAM-served INFCNT read.\n"
        ),
    )

    # ------------------------------------------------ V4a: shared helper
    apply_edit(
        files, "V4a-capture-helper", "RuntimeHook.h",
        old=(
            "        return ~crc;\n"
            "    }\n"
            "\n"
            "    // EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE GUID\n"
        ),
        new=(
            "        return ~crc;\n"
            "    }\n"
            "\n"
            "    // v15: live KUSD build capture, shared by the INFDIAG serve\n"
            "    // path and HandleOurSetVariable. Runs ONCE per boot: probes\n"
            "    // both candidate NtBuildNumber offsets, traces the RAW values\n"
            "    // (hex prints are VA-safe now — v15 fixed the SerialTrace hex\n"
            "    // table), and takes the first plausible one. VA-gated: boot\n"
            "    // contexts run on firmware page tables which do not map the\n"
            "    // high-canonical KUSD VA.\n"
            "    static void CaptureLiveWindowsBuild() {\n"
            "        if (!g_diag_va_done) return;\n"
            "        if (g_diag_win_build || g_kusd_probe_done) return;\n"
            "        g_kusd_probe_done = 1;\n"
            "        UINT32 p260 = *(volatile UINT32*)\n"
            "            (KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[0])\n"
            "            & 0x7FFFFFFF;\n"
            "        UINT32 p308 = *(volatile UINT32*)\n"
            "            (KUSER_SHARED_DATA_VA + KUSD_OFS_BUILD_CANDIDATES[1])\n"
            "            & 0x7FFFFFFF;\n"
            "        SerialTrace::KV(\"BLD\", \"kusd raw 0x260=0x\", p260);\n"
            "        SerialTrace::KV(\"BLD\", \"kusd raw 0x308=0x\", p308);\n"
            "        if (KusdBuildPlausible(p260)) {\n"
            "            g_diag_win_build = p260;\n"
            "            SerialTrace::KVD(\"BLD\", \"live windows build (ofs 0x260) \",\n"
            "                            (UINT64)p260);\n"
            "        } else if (KusdBuildPlausible(p308)) {\n"
            "            g_diag_win_build = p308;\n"
            "            SerialTrace::KVD(\"BLD\", \"live windows build (ofs 0x308) \",\n"
            "                            (UINT64)p308);\n"
            "        } else {\n"
            "            SerialTrace::Line(\"BLD\",\n"
            "                \"kusd both implausible - build stays 0 \"\n"
            "                \"(script side authoritative)\");\n"
            "        }\n"
            "    }\n"
            "\n"
            "    // EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE GUID\n"
        ),
    )

    # ------------------------------------------------ V4b: F2a -> helper
    apply_edit(
        files, "V4b-serve-path-probe", "RuntimeHook.h",
        old=(
            "                    // v14 F2: desktop-time live build capture. We\n"
            "                    // are inside the kernel's GetVariable dispatch\n"
            "                    // — KUSER_SHARED_DATA is a global page mapped\n"
            "                    // in EVERY address space, so a direct read\n"
            "                    // needs no page walk and cannot fault. The\n"
            "                    // EBS-time capture always read 0 because at\n"
            "                    // ExitBootServices the CPU still runs on the\n"
            "                    // FIRMWARE page tables (EBS CR3 == UEFI CR3\n"
            "                    // in every serial log since v6) which do not\n"
            "                    // map the high-canonical KUSD VA.\n"
            "                    if (!g_diag_win_build) {\n"
            "                        UINT32 live = *(volatile UINT32*)\n"
            "                            (KUSER_SHARED_DATA_VA + KUSD_OFS_NtBuildNumber)\n"
            "                            & 0x7FFFFFFF;\n"
            "                        if (live >= 15000 && live < 99999) {\n"
            "                            g_diag_win_build = live;\n"
            "                            SerialTrace::KV(\"BLD\", \"live windows build \",\n"
            "                                            (UINT64)live);\n"
            "                        } else {\n"
            "                            SerialTrace::KV(\"BLD\",\n"
            "                                \"live KUSD read implausible \",\n"
            "                                            (UINT64)live);\n"
            "                        }\n"
            "                    }\n"
        ),
        new=(
            "                    // v15: shared once-per-boot probe (VA-gated,\n"
            "                    // both candidate offsets, raw forensics trace).\n"
            "                    CaptureLiveWindowsBuild();\n"
        ),
    )

    # ------------------------------------------------ V4c: F2b -> helper
    apply_edit(
        files, "V4c-write-path-probe", "RuntimeHook.h",
        old=(
            "            // v14 F2: same live build capture on the write path\n"
            "            // (desktop kernel context, KUSD globally mapped) so\n"
            "            // request processing has correct offsets even if no\n"
            "            // INFDIAG read happened first.\n"
            "            if (!g_diag_win_build) {\n"
            "                UINT32 live = *(volatile UINT32*)\n"
            "                    (KUSER_SHARED_DATA_VA + KUSD_OFS_NtBuildNumber)\n"
            "                    & 0x7FFFFFFF;\n"
            "                if (live >= 15000 && live < 99999) {\n"
            "                    g_diag_win_build = live;\n"
            "                    SerialTrace::KV(\"BLD\", \"live windows build \",\n"
            "                                    (UINT64)live);\n"
            "                }\n"
            "            }\n"
        ),
        new=(
            "            // v15: same shared probe (VA-gated internally, so\n"
            "            // boot-time our-var writes can not touch the OS KUSD\n"
            "            // mapping either).\n"
            "            CaptureLiveWindowsBuild();\n"
        ),
    )

    # ------------------------------------------------ V4d: RT-EARLY banner
    apply_edit(
        files, "V4d-rt-banner", "RuntimeHook.h",
        old=(
            "            SerialTrace::Line(\"RT-EARLY\", \"memory.efi v14 RT (guid fix + live build)\");\n"
        ),
        new=(
            "            SerialTrace::Line(\"RT-EARLY\", \"memory.efi v15 RT (hex-safe serial + kusd probe)\");\n"
        ),
    )

    # ------------------------------------------------ V4e: RT-VA banner
    apply_edit(
        files, "V4e-rtva-banner", "RuntimeHook.h",
        old=(
            "                SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v14 early) - keeping slots\");\n"
        ),
        new=(
            "                SerialTrace::Line(\"RT-VA\", \"hooks already installed at load (v15 early) - keeping slots\");\n"
        ),
    )

    # ------------------------------------------------ V5: main.c build line
    apply_edit(
        files, "V5-build-line", "main.c",
        old=(
            "    static const char kBuildLine[] = \"  Build: v7 RT - EARLY gRT hooks (phase D2)\";\n"
        ),
        new=(
            "    static const char kBuildLine[] = \"  Build: v15 RT - hex-safe serial + kusd probe\";\n"
        ),
    )

    # ------------------------------------------------ sanity: marker present
    rh = files["RuntimeHook.h"].read_text()
    if MARKER not in rh:
        print(f"FATAL: marker {MARKER!r} missing from RuntimeHook.h after patch")
        sys.exit(1)
    st = files["SerialTrace.h"].read_text()
    import re as _re
    if _re.search(r'^\s*static const char\* k\s*=', st, _re.M):
        print("FATAL: a code-level 'static const char* k =' survived in SerialTrace.h")
        sys.exit(1)
    print(f"  sanity: {MARKER!r} present, no pointer-slot hex tables remain (comment mentions are fine)")

    print("v15 patch applied cleanly.")


if __name__ == "__main__":
    main()
