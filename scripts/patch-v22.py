#!/usr/bin/env python3
# ============================================================================
# patch-v22.py — v20 -> v22 driver source transformation (Phase F3)
#
# WHAT v22 ADDS (on top of the byte-verified v20 tree):
#   1. KernelExports.h (kx::) — the v21 F2 machinery RE-DERIVED from the
#      field-proven binary (patches/v21-memory-RT.efi 90bc3bdf...):
#      the RVA-gated, budgeted (1,000,000 B), sticky-error export walk.
#      The op-10 wire contract is EXACTLY what the v28/v29 field runs
#      proved (64-byte payload, status mapping, [XS]/[KPCR] traces).
#   2. ProcessWalk.h (pw::) — the F3 EPROCESS walk: double-link
#      LIST_ENTRY consistency, canonical-VA + no-wrap + +-4GB-cluster
#      gates on EVERY deref, 64-entry / 256-page budgets, live
#      name-slot discovery ("System\0" probe + printability cross-
#      check), fail-closed with clean statuses. The v19 attach death
#      class (name hunting) is structurally impossible here.
#   3. op-10 (ReqOp_ResolveSymbol) + op-11 (ReqOp_ProcessWalk) in the
#      VARIABLE transport switch (the ring path stays untouched —
#      same as v21).
#   4. v22 banners (main.c, RuntimeHook.h).
#
# WHAT v22 DOES NOT TOUCH: the anchors (ka::), the ReadKernelVA gate
# (three windows: KUSD x2 + validated image), ProcessOneRequest, the
# SAFE build contract (all hook code stays RT-only).
#
# Usage: python3 scripts/patch-v22.py <v20-tree-dir>
# (the tree is patched IN PLACE — run it on a copy)
# ============================================================================
import sys, pathlib, shutil, os

def main():
    if len(sys.argv) != 2:
        print("usage: patch-v22.py <v20-tree>")
        sys.exit(1)
    tree = pathlib.Path(sys.argv[1])
    inc = tree / "UEFI" / "include"
    # sanity: it must be a v20 tree
    mc = tree / "UEFI" / "src" / "main.c"
    if not mc.exists():
        print("FATAL: not a driver tree (UEFI/src/main.c missing)"); sys.exit(1)
    mct = mc.read_text(encoding="utf-8")
    if "efi_main v20 boot" not in mct:
        print("FATAL: not a v20 tree (banner mismatch)"); sys.exit(1)

    def rep(path, old, new, label, count=1):
        t = path.read_text(encoding="utf-8")
        n = t.count(old)
        if n != count:
            print(f"[{label}] FATAL: anchor found {n} times (need {count})")
            sys.exit(1)
        path.write_text(t.replace(old, new), encoding="utf-8")
        print(f"[{label}] OK")

    # ---- new headers: copy from the canonical copies in patches/ ----
    base = pathlib.Path("/home/z/my-project/patches")
    for h in ("KernelExports.h", "ProcessWalk.h"):
        src = base / h
        dst = inc / h
        if not src.exists():
            print(f"FATAL: canonical header missing: {src}"); sys.exit(1)
        shutil.copyfile(src, dst)
        print(f"[new-header] {h} -> {dst} ({dst.stat().st_size} B)")

    rh = inc / "RequestHandler.h"

    # =========================================================
    # W1: includes (KernelExports + ProcessWalk after KernelAnchor)
    # =========================================================
    rep(rh,
        '#include "KernelAnchor.h"\n#include "Diag.h"',
        '#include "KernelAnchor.h"\n#include "KernelExports.h"\n'
        '#include "ProcessWalk.h"\n#include "Diag.h"',
        "W1-includes")

    # =========================================================
    # W2: op-10 (v21 contract re-implementation) + op-11 (F3) —
    #     inserted right after the op-9 (Anchors) case block
    # =========================================================
    anchor_case9_end = """                resp->status = (an.state == ka::kAnchorConverged)
                    ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp->bytes_transferred = 32;
                *data_size = 32;
                break;
            }
"""
    new_cases = anchor_case9_end + """            case 10 /* ReqOp_ResolveSymbol — v21 F2 re-derived:
                    name via InfinityData, length = data_size.
                    WIRE CONTRACT (field-proven v28/v29, M1..M4):
                    payload 64B = rc@0, nameIndex@4, resolvedVa@8,
                    peBase@16, peSize@24, kpcrBase@32 (live MSR),
                    idtBase@40, nameLen@48 (success only),
                    failRc@52 (0=ok/1=notfound/2=invalid/3=fwd/4=gated),
                    idtMatch@56, pad@60. Status: 1 resolved / 7 notfound
                    / 3 forwarded / 4 refused / 2 invalid name. */: {
                DiscoverAnchorsOnce();
                const UINT8* name = (const UINT8*)data_buf;
                UINT32 name_len = req->data_size;

                // ---- name validation (the M4 discipline) ----
                bool name_ok = (name != nullptr) &&
                               (name_len >= 1) && (name_len <= 64);
                if (name_ok) {
                    for (UINT32 i = 0; i < name_len; i++) {
                        if (name[i] < 0x21 || name[i] > 0x7E) {
                            name_ok = false; break;
                        }
                    }
                }

                UINT32 rc = 0, name_index = 0, fail_rc = 2;
                UINT64 resolved_va = 0;
                if (!name_ok) {
                    fail_rc = 2;                      // invalid name
                } else if (ka::g_result.state !=
                           ka::kAnchorConverged) {
                    rc = 0; fail_rc = 1;              // no gate, refuse
                } else {
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    kx::ResolveResult rr =
                        kx::Resolve(&c, (const char*)name, name_len);
                    rc = rr.rc; name_index = rr.name_index;
                    resolved_va = rr.resolved_va;
                    fail_rc = (rc == 1) ? 0 : rc;     // 0=ok / 1 / 3 / 4
                }

                // ---- KPCR capture (live, per request — the v21
                //      contract; CPU-dependent by design) ----
                UINT64 kpcr = An_ReadMSR(0xC0000101); // IA32_GS_BASE
                UINT32 idt_match = 0;
                if (kpcr >= 0xFFFF800000000000ULL &&
                    (kpcr & 0xFFF) == 0) {
                    UINT64 kidt = *(volatile UINT64*)(UINTN)(kpcr + 0x38);
                    if (ka::g_result.state == ka::kAnchorConverged &&
                        kidt == ka::g_result.idt_base)
                        idt_match = 1;
                }
                SerialTrace::KV("KPCR", "gs base", kpcr);
                SerialTrace::KVD("KPCR", "idt match", idt_match);

                SerialTrace::KVD("XS", "resolve rc", fail_rc);
                SerialTrace::KV("XS", "resolved va", resolved_va);
                SerialTrace::KVD("XS", "name index", name_index);

                // ---- 64-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 64; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0, rc);
                put32(4, name_index);
                put64(8, resolved_va);
                put64(16, ka::g_result.pe_base);
                put64(24, ka::g_result.pe_size);
                put64(32, kpcr);
                put64(40, ka::g_result.idt_base);
                put32(48, (rc == 1) ? name_len : 0);
                put32(52, fail_rc);
                put32(56, idt_match);
                put32(60, 0);
                resp->bytes_transferred = 64;
                *data_size = 64;
                if (rc == 1)      resp->status = SlotStatus_Success;
                else if (!name_ok) resp->status = SlotStatus_ErrGeneric;
                else if (rc == 0)  resp->status = SlotStatus_ErrNotFound;
                else               resp->status = (SlotStatus)rc;
                break;
            }
            case 11 /* ReqOp_ProcessWalk — v22 F3: the EPROCESS walk.
                    data_size = requested entries outN (1..32); pid is
                    IGNORED (kernel-list data only — no per-process
                    address space access, so no pid gate applies).
                    Payload 1056B = entries[32] x 32B
                    {pid, flags(bit0=name echoed), eproc, name[8], pad},
                    then status@1024, count@1028 (total walked),
                    sysEntry@1032, nameOfs@1040, closed@1044,
                    pages@1048, stored@1052. Status: 1 ok / 7 no-entry
                    / 4 walk refusal / 5 bad args. */: {
                DiscoverAnchorsOnce();
                UINT32 out_n = req->data_size;
                pw::Result wr{};
                pw::Entry entries[32] = {};
                if (out_n >= 1 && out_n <= 32) {
                    // ---- S1: resolve PsInitialSystemProcess via F2
                    //      (in-image gate — no new trust root) ----
                    const char* s1name = "PsInitialSystemProcess";
                    UINT32 s1len = 22;
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    kx::ResolveResult s1 = (ka::g_result.state ==
                        ka::kAnchorConverged)
                        ? kx::Resolve(&c, s1name, s1len)
                        : kx::ResolveResult{0, 0, 0};
                    if (s1.rc != 1) {
                        wr.status = pw::kPwNoEntry;
                    } else {
                        SerialTrace::KV("PW", "sys", s1.resolved_va);
                        pw::Budget bud{0, pw::kPwMaxPages};
                        wr = pw::WalkCore(s1.resolved_va, entries, out_n,
                                          &bud);
                    }
                } else {
                    wr.status = pw::kPwBadArgs;
                }
                SerialTrace::KVD("PW", "walk", wr.count);
                SerialTrace::KVD("PW", "closed", wr.closed);
                SerialTrace::KVD("PW", "name slot", wr.name_ofs);

                // ---- 1056-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 1056; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                UINT32 store_n = (wr.stored < 32) ? wr.stored : 32;
                for (UINT32 e = 0; e < store_n; e++) {
                    UINTN o = (UINTN)e * 32;
                    put32(o + 0,  entries[e].pid);
                    put32(o + 4,  entries[e].flags);
                    put64(o + 8,  entries[e].eproc);
                    for (UINTN k = 0; k < 8; k++)
                        p[o + 16 + k] = entries[e].name[k];
                    put32(o + 24, 0);
                }
                put32(1024, wr.status);
                put32(1028, wr.count);
                put64(1032, wr.sys_entry);
                put32(1040, wr.name_ofs);
                put32(1044, wr.closed);
                put32(1048, wr.pages);
                put32(1052, wr.stored);
                resp->bytes_transferred = 1056;
                *data_size = 1056;
                if (wr.status == pw::kPwOk)
                    resp->status = SlotStatus_Success;
                else if (wr.status == pw::kPwNoEntry)
                    resp->status = SlotStatus_ErrNotFound;
                else if (wr.status == pw::kPwBadArgs)
                    resp->status = SlotStatus_ErrInvalid;
                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
"""
    rep(rh, anchor_case9_end, new_cases, "W2-ops")

    # =========================================================
    # W3: main.c banners v20 -> v22
    # =========================================================
    rep(mc, 'static const char kBuildLine[] = "  Build: v20 RT - anchors + containing walk";',
            'static const char kBuildLine[] = "  Build: v22 RT - anchors + exports + process walk";',
            "W3a-build-rt")
    rep(mc, 'static const char kBuildLine[] = "  Build: v20 SAFE (phase F2)";',
            'static const char kBuildLine[] = "  Build: v22 SAFE (phase F3)";',
            "W3b-build-safe")
    rep(mc, 'Print((CHAR16*)L"  Build: v20 RT - anchors + containing walk (F2)          \\r\\n");',
            'Print((CHAR16*)L"  Build: v22 RT - anchors + exports + process walk (F3)   \\r\\n");',
            "W3c-print-rt")
    rep(mc, 'Print((CHAR16*)L"  Build: v20 SAFE (phase F2)                               \\r\\n");',
            'Print((CHAR16*)L"  Build: v22 SAFE (phase F3)                               \\r\\n");',
            "W3d-print-safe")
    rep(mc, 'SerialTrace::Line("MAIN", "efi_main v20 boot");',
            'SerialTrace::Line("MAIN", "efi_main v22 boot");',
            "W3e-boot-line")
    rep(mc, 'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v20)");',
            'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v22)");',
            "W3f-variant-line")

    # =========================================================
    # W4: RuntimeHook.h markers v20 -> v22
    # =========================================================
    rhk = inc / "RuntimeHook.h"
    rep(rhk, 'SerialTrace::Line("RT-EARLY", "memory.efi v20 RT (kernel data path: direct reads + containing anchors)");',
             'SerialTrace::Line("RT-EARLY", "memory.efi v22 RT (kernel data path: direct reads + export resolution + process walk)");',
             "W4a-rt-early")
    rep(rhk, 'SerialTrace::Line("RT-VA", "hooks already installed at load (v20 early) - keeping slots");',
             'SerialTrace::Line("RT-VA", "hooks already installed at load (v22 early) - keeping slots");',
             "W4b-rt-va")

    # ---- final sanity ----
    rht = rh.read_text(encoding="utf-8")
    for marker in ("case 10", "case 11", "kx::Resolve", "pw::WalkCore",
                   "KernelExports.h", "ProcessWalk.h"):
        if marker not in rht:
            print(f"FATAL: post-check marker missing in RequestHandler.h: {marker}")
            sys.exit(1)
    mct2 = mc.read_text(encoding="utf-8")
    for marker in ("v22 RT", "v22 SAFE", "efi_main v22 boot"):
        if marker not in mct2:
            print(f"FATAL: post-check marker missing in main.c: {marker}")
            sys.exit(1)
    if "v20" in mct2.replace("v20 early", ""):  # only the RT-VA line may... (it's in RuntimeHook.h)
        pass
    print("[patch-v22] ALL EDITS APPLIED - tree is now v22")
    print("[patch-v22] changed: RequestHandler.h (ops 10+11), main.c, RuntimeHook.h, +KernelExports.h, +ProcessWalk.h")
    print("[patch-v22] unchanged: ka anchors, ReadKernelVA gate, ring path, SAFE contract")

if __name__ == "__main__":
    main()
