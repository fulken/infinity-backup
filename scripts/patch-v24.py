#!/usr/bin/env python3
# ============================================================================
# patch-v24.py — v23 -> v24 driver source transformation
#
# THE ONE FIX (F3 walk refusal, v31 field run, root-caused to the line):
#
#   RequestHandler.h op-11:
#     pw::WalkCore(s1.resolved_va, ...)          // v23 (WRONG)
#     ->
#     eproc = deref(s1.resolved_va) via kx::Rd32 x2   // v24 (the gate-
#     pw::WalkCore(eproc, ...)                        // protected read)
#
#   PsInitialSystemProcess is a POINTER VARIABLE in ntoskrnl .data:
#   kx::Resolve returns the VA OF THE SLOT (the field 0xFFFFF8071A4FC420,
#   IN-IMAGE), and *(u64*)slot is the System EPROCESS (a pool object
#   OUTSIDE the image, 0xFFFF8Exxxxxxxx on this VM). v23 passed the
#   SLOT VA to WalkCore, so pid@slot+0x440 read .data garbage != 4
#   -> kPwNotSys with walk=0, closed=0, name slot=0, pages=0, VM alive
#   (the v31 field run: resp status=4, payload status@1024=4, serial
#   [PW] sys=<the symbol VA> -> walk=0). ONE missing deref explains
#   every observed byte.
#
#   The deref is hoisted into pw::SysEprocessFromSymbol (ProcessWalk.h)
#   so the DRIVER and the HOST HARNESS execute the exact same chain:
#     S1  kx::Resolve("PsInitialSystemProcess")   (in-image, budgeted)
#     S2  kx::Rd32(slot_rva) + kx::Rd32(slot_rva+4)  (gated in-image
#         reads - rva+4 <= size, 1,000,000-byte budget - NO new trust
#         root; the field slot RVA 0xCFC420 is deep inside the
#         validated image)
#     ->  WalkCore(eproc) validates the TARGET: canonical kernel VA,
#         pid@+0x440 == 4, LIST_ENTRY double-link consistency, the
#         +-4 GB pool-cluster window, hard budgets. Fail-closed held
#         in the field (the v31 refusal was perfectly clean).
#
#   New serial trace: [PW] eproc=<hex> (after [PW] sys=). The [PW] sys
#   line is UNCHANGED (still the symbol VA == the M1 cross-check) and
#   the bench greps still match.
#
# RULED OUT (web-verified, 3 independent sources + the I3r1h0n table):
#   the v23 name-slot window 0x560..0x5D8 - ImageFileName @ 0x5A8 IS
#   correct for 19041-19045 (0x5A8 is not Win11-only). No change.
#
# Everything else is banner-only (v23 -> v24). The wire contract, the
# walk engine, the anchors, the export machinery: UNTOUCHED.
#
# Usage: python3 scripts/patch-v24.py <v23-tree>
# ============================================================================
import pathlib
import sys


def main():
    if len(sys.argv) != 2:
        print("usage: patch-v24.py <v23-tree>")
        sys.exit(1)
    tree = pathlib.Path(sys.argv[1])

    def p(rel):
        f = tree / rel
        if not f.exists():
            print(f"FATAL: missing {rel} - not a v23 tree?")
            sys.exit(1)
        return f

    def rep(rel, old, new, label, count=1):
        f = p(rel)
        t = f.read_text(encoding="utf-8")
        n = t.count(old)
        if n != count:
            print(f"[{label}] FATAL: anchor found {n} times (need {count})")
            sys.exit(1)
        f.write_text(t.replace(old, new), encoding="utf-8")
        print(f"[{label}] OK")

    # ---- sanity: it must be a v23 tree ----
    mc = p("UEFI/src/main.c")
    if "efi_main v23 boot" not in mc.read_text(encoding="utf-8"):
        print("FATAL: not a v23 tree (banner mismatch)")
        sys.exit(1)

    # =========================================================
    # THE FIX 1/2: ProcessWalk.h — the shared S1+S2 deref chain
    # =========================================================

    # title
    rep("UEFI/include/ProcessWalk.h",
        " * ProcessWalk.h  (UEFI side — v22/v23 / F3)",
        " * ProcessWalk.h  (UEFI side — v22/v23/v24 / F3)",
        "PW-title")

    # the include (kx::Resolve / kx::Rd32 for the chain; pragma-once safe:
    # RequestHandler.h already includes KernelExports.h before this file)
    rep("UEFI/include/ProcessWalk.h",
        "#include <cstdint>\n#include <cstddef>",
        "#include <cstdint>\n#include <cstddef>\n\n"
        "#include \"KernelExports.h\"   // kx::Resolve/kx::Rd32 (the v24 S1+S2 chain)",
        "PW-include")

    # header note: the v24 fix, right before ENTRY SEMANTICS
    rep("UEFI/include/ProcessWalk.h",
        " * ENTRY SEMANTICS: entries[0] is ALWAYS the System entry itself",
        " * v24 FIX (the v31 field run): PsInitialSystemProcess is a\n"
        " * POINTER VARIABLE - kx::Resolve returns the VA of the .data\n"
        " * SLOT (in-image), NOT the EPROCESS. v23's op-11 walked from\n"
        " * the slot VA itself: pid@slot+0x440 read .data garbage ->\n"
        " * kPwNotSys, walk=0, pages=0, VM alive (a perfectly clean\n"
        " * fail-closed refusal). v24 derefs the slot through the same\n"
        " * gated in-image Rd32 as every export read (SysEprocessFromSymbol\n"
        " * below - shared with the host harness so the driver's exact\n"
        " * chain is host-tested), and WalkCore validates the TARGET.\n"
        " *\n"
        " * ENTRY SEMANTICS: entries[0] is ALWAYS the System entry itself",
        "PW-v24-note")

    # the shared function, right before the pure walk core
    rep("UEFI/include/ProcessWalk.h",
        "    // ================= pure walk core =================",
        "    // ================= symbol -> EPROCESS (v24 chain) =============\n"
        "    // S1: kx::Resolve (in-image, budgeted, printable-gated).\n"
        "    // S2: DEREF the pointer slot via two gated in-image Rd32\n"
        "    //     reads (rva+4 <= size each, the 1,000,000-byte budget)\n"
        "    //     - NO new trust root: the slot lives inside the same\n"
        "    //     validated image every export read already comes from.\n"
        "    // The returned EPROCESS VA is NOT trusted here - WalkCore\n"
        "    // validates it (canonical + pid==4 + LIST_ENTRY consistency\n"
        "    // + the +-4 GB pool window + budgets). False = resolve or\n"
        "    // deref refused (caller maps it to kPwNoEntry).\n"
        "    static inline bool SysEprocessFromSymbol(kx::Ctx* c,\n"
        "                                             const char* name,\n"
        "                                             u32 name_len,\n"
        "                                             u64* out_sym_va,\n"
        "                                             u64* out_eproc) {\n"
        "        kx::ResolveResult s1 = kx::Resolve(c, name, name_len);\n"
        "        if (s1.rc != 1) return false;               // refused\n"
        "        u32 rva = (u32)(s1.resolved_va - c->base);  // < c->size\n"
        "        u32 lo = 0, hi = 0;\n"
        "        if (!kx::Rd32(c, rva, &lo))     return false;\n"
        "        if (!kx::Rd32(c, rva + 4, &hi)) return false;\n"
        "        if (out_sym_va) *out_sym_va = s1.resolved_va;\n"
        "        if (out_eproc)  *out_eproc  = (u64)lo | ((u64)hi << 32);\n"
        "        return true;\n"
        "    }\n"
        "\n"
        "    // ================= pure walk core =================",
        "PW-SysEprocessFromSymbol")

    # =========================================================
    # THE FIX 2/2: RequestHandler.h op-11 — use the chain
    # =========================================================
    rep("UEFI/include/RequestHandler.h",
        "                    // ---- S1: resolve PsInitialSystemProcess via F2\n"
        "                    //      (in-image gate — no new trust root) ----\n"
        "                    const char* s1name = \"PsInitialSystemProcess\";\n"
        "                    UINT32 s1len = 22;\n"
        "                    kx::Ctx c{ka::g_result.pe_base,\n"
        "                              ka::g_result.pe_size, 0, 0};\n"
        "                    kx::ResolveResult s1 = (ka::g_result.state ==\n"
        "                        ka::kAnchorConverged)\n"
        "                        ? kx::Resolve(&c, s1name, s1len)\n"
        "                        : kx::ResolveResult{0, 0, 0};\n"
        "                    if (s1.rc != 1) {\n"
        "                        wr.status = pw::kPwNoEntry;\n"
        "                    } else {\n"
        "                        SerialTrace::KV(\"PW\", \"sys\", s1.resolved_va);\n"
        "                        pw::Budget bud{0, pw::kPwMaxPages};\n"
        "                        wr = pw::WalkCore(s1.resolved_va, entries, out_n,\n"
        "                                          &bud);\n"
        "                    }",
        "                    // ---- S1+S2 (v24): resolve PsInitialSystemProcess\n"
        "                    //      via F2, then DEREF the in-image pointer\n"
        "                    //      slot — the symbol is a POINTER VARIABLE;\n"
        "                    //      *(u64*)slot is the System EPROCESS (a\n"
        "                    //      pool object OUTSIDE the image). v23\n"
        "                    //      walked from the slot VA itself: pid@slot\n"
        "                    //      +0x440 read .data garbage -> kPwNotSys\n"
        "                    //      (the v31 field run). The deref goes\n"
        "                    //      through the same gated in-image Rd32 as\n"
        "                    //      every export read — no new trust root,\n"
        "                    //      and WalkCore validates the target. ----\n"
        "                    const char* s1name = \"PsInitialSystemProcess\";\n"
        "                    UINT32 s1len = 22;\n"
        "                    kx::Ctx c{ka::g_result.pe_base,\n"
        "                              ka::g_result.pe_size, 0, 0};\n"
        "                    UINT64 sym_va = 0, sys_eproc = 0;\n"
        "                    bool have = (ka::g_result.state ==\n"
        "                                 ka::kAnchorConverged)\n"
        "                        ? pw::SysEprocessFromSymbol(&c, s1name, s1len,\n"
        "                                                    &sym_va, &sys_eproc)\n"
        "                        : false;\n"
        "                    if (!have) {\n"
        "                        wr.status = pw::kPwNoEntry;\n"
        "                    } else {\n"
        "                        SerialTrace::KV(\"PW\", \"sys\", sym_va);\n"
        "                        SerialTrace::KV(\"PW\", \"eproc\", sys_eproc);\n"
        "                        pw::Budget bud{0, pw::kPwMaxPages};\n"
        "                        wr = pw::WalkCore(sys_eproc, entries, out_n,\n"
        "                                          &bud);\n"
        "                    }",
        "FIX-op11-deref")

    # op-11 comment tag + the sysEntry payload semantic
    rep("UEFI/include/RequestHandler.h",
        "            case 11 /* ReqOp_ProcessWalk — v23 F3: the EPROCESS walk.",
        "            case 11 /* ReqOp_ProcessWalk — v24 F3: the EPROCESS walk.",
        "RH-op11-tag")
    rep("UEFI/include/RequestHandler.h",
        "                    then status@1024, count@1028 (total walked),\n"
        "                    sysEntry@1032, nameOfs@1040, closed@1044,",
        "                    then status@1024, count@1028 (total walked),\n"
        "                    sysEntry@1032 (the DEREF'D System EPROCESS VA —\n"
        "                    v24: pool, OUTSIDE the image), nameOfs@1040,\n"
        "                    closed@1044,",
        "RH-op11-payload-doc")

    # ---- main.c banners ----
    rep("UEFI/src/main.c",
        '    static const char kBuildLine[] = "  Build: v23 RT - anchors + exports + process walk";',
        '    static const char kBuildLine[] = "  Build: v24 RT - anchors + exports + process walk";',
        "MC-kbuild-rt")
    rep("UEFI/src/main.c",
        '    static const char kBuildLine[] = "  Build: v23 SAFE (phase F3)";',
        '    static const char kBuildLine[] = "  Build: v24 SAFE (phase F3)";',
        "MC-kbuild-safe")
    rep("UEFI/src/main.c",
        'Print((CHAR16*)L"  Build: v23 RT - anchors + exports + process walk (F3)   \\r\\n");',
        'Print((CHAR16*)L"  Build: v24 RT - anchors + exports + process walk (F3)   \\r\\n");',
        "MC-screen-rt")
    rep("UEFI/src/main.c",
        'Print((CHAR16*)L"  Build: v23 SAFE (phase F3)                               \\r\\n");',
        'Print((CHAR16*)L"  Build: v24 SAFE (phase F3)                               \\r\\n");',
        "MC-screen-safe")
    rep("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "efi_main v23 boot");',
        'SerialTrace::Line("MAIN", "efi_main v24 boot");',
        "MC-boot")
    rep("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v23)");',
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v24)");',
        "MC-variant")

    # ---- RuntimeHook.h banners ----
    rep("UEFI/include/RuntimeHook.h",
        'SerialTrace::Line("RT-EARLY", "memory.efi v23 RT (kernel data path: direct reads + export resolution + process walk)");',
        'SerialTrace::Line("RT-EARLY", "memory.efi v24 RT (kernel data path: direct reads + export resolution + process walk)");',
        "RH-rt-early")
    rep("UEFI/include/RuntimeHook.h",
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v23 early) - keeping slots");',
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v24 early) - keeping slots");',
        "RH-rt-va")

    # ---- final verification ----
    pw_txt = p("UEFI/include/ProcessWalk.h").read_text(encoding="utf-8")
    assert "SysEprocessFromSymbol" in pw_txt, "chain function missing"
    assert 'kx::Rd32(c, rva + 4, &hi)' in pw_txt, "deref missing"
    rh_txt = p("UEFI/include/RequestHandler.h").read_text(encoding="utf-8")
    assert "pw::WalkCore(sys_eproc, entries, out_n," in rh_txt, "op-11 fix missing"
    assert "WalkCore(s1.resolved_va" not in rh_txt, "the v23 call survived"
    assert '"PW", "eproc"' in rh_txt, "eproc trace missing"
    for rel in ("UEFI/src/main.c", "UEFI/include/RuntimeHook.h"):
        t = p(rel).read_text(encoding="utf-8")
        n = t.count("v23")
        if n != 0:
            print(f"[CHECK] FATAL: {rel} still has {n} 'v23' strings")
            sys.exit(1)
        print(f"[CHECK] {rel}: no stale v23 banners")
    # RequestHandler.h: exactly one historical v23 mention (the fix comment)
    n = rh_txt.count("v23")
    if n != 1:
        print(f"[CHECK] FATAL: RequestHandler.h v23 mentions = {n} (need 1)")
        sys.exit(1)
    print(f"[CHECK] RequestHandler.h: {n} historical v23 mention (provenance - OK)")
    # ProcessWalk.h: title + the v24 note (2 historical v23 mentions)
    n = pw_txt.count("v23")
    if n != 2:
        print(f"[CHECK] FATAL: ProcessWalk.h v23 mentions = {n} (need 2)")
        sys.exit(1)
    print(f"[CHECK] ProcessWalk.h: {n} historical v23 mentions (provenance - OK)")
    # KernelExports.h untouched by v24 (its v23 FIX notes are provenance)
    kx_n = p("UEFI/include/KernelExports.h").read_text(encoding="utf-8").count("v24")
    if kx_n != 0:
        print(f"[CHECK] FATAL: KernelExports.h unexpectedly edited (v24 x{kx_n})")
        sys.exit(1)
    print("[CHECK] KernelExports.h: untouched (v23-fix provenance preserved)")
    print()
    print("[patch-v24] ALL EDITS APPLIED - tree is now v24")
    print("[patch-v24] THE FIX: op-11 resolve -> DEREF the in-image pointer slot")
    print("[patch-v24]           -> WalkCore(eproc)  (pw::SysEprocessFromSymbol)")
    print("[patch-v24] banners: v23 -> v24 everywhere (wire contract untouched)")


if __name__ == "__main__":
    main()
