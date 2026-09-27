#!/usr/bin/env python3
# ============================================================================
# patch-v23.py — v22 -> v23 driver source transformation
#
# THE ONE FIX (F2/F3 field regression, v30 run, root-caused from the
# disassembly of the field-proven patches/v21-memory-RT.efi):
#
#   KernelExports.h export-size gate:
#       exp_size >= 0x10000   ->   exp_size >= 0x100000
#
#   v21 binary proof (op-10 walk @10ed2):
#       10fbb:  lea edx,[rax-0x28]      ; edx = exp_size - 0x28
#       10fbe:  cmp edx,0xfffd8         ; 0x100000 - 0x28 - 1
#       10fc4:  ja  refuse
#   => the TRUE v21 upper bound is 0x100000 (1 MiB). The f3-design
#   hand-RE dropped a zero ("0x10000") and v22 coded it. ntoskrnl
#   19045's export directory is ~0x11000-0x13000 bytes (~2350 names):
#   it trips 0x10000 and passes 0x100000, so v22 refused EVERY
#   resolve in the field (M1..M4 rc=4 + W1/W5 resolve-failed) while
#   failing CLOSED exactly as designed (VM never at risk, negatives
#   clean, F1 + gate + J matrix all green on the same binary).
#
# Everything else is banner-only (v22 -> v23). The wire contract, the
# walk, the anchors, the ring path: UNTOUCHED.
#
# Usage: python3 scripts/patch-v23.py <v22-tree>
# ============================================================================
import pathlib
import sys


def main():
    if len(sys.argv) != 2:
        print("usage: patch-v23.py <v22-tree>")
        sys.exit(1)
    tree = pathlib.Path(sys.argv[1])

    def p(rel):
        f = tree / rel
        if not f.exists():
            print(f"FATAL: missing {rel} - not a v22 tree?")
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

    # ---- sanity: it must be a v22 tree ----
    mc = p("UEFI/src/main.c")
    if "efi_main v22 boot" not in mc.read_text(encoding="utf-8"):
        print("FATAL: not a v22 tree (banner mismatch)")
        sys.exit(1)

    # ---- THE FIX: export-size gate 0x10000 -> 0x100000 ----
    rep("UEFI/include/KernelExports.h",
        "        if (exp_size < 0x28 || exp_size >= 0x10000) { c->err = 4; r.rc = kXResolve_Refused; return r; }",
        "        // v23 FIX (field-proven bound): the v21 binary gates exp_size to\n"
        "        // [0x28, 0x100000) - see 10fbb lea edx,[rax-0x28]; cmp edx,0xfffd8\n"
        "        // (= 0x100000-0x28-1) in patches/v21-memory-RT.efi. v22 wrongly used\n"
        "        // 0x10000 (a dropped zero in the hand-RE); ntoskrnl 19045's export\n"
        "        // directory is ~0x11000-0x13000 bytes and tripped it in the v30 run.\n"
        "        if (exp_size < 0x28 || exp_size >= 0x100000) { c->err = 4; r.rc = kXResolve_Refused; return r; }",
        "FIX-exp-size-0x100000")

    # ---- KernelExports.h: version tag + provenance note ----
    rep("UEFI/include/KernelExports.h",
        " * KernelExports.h  (UEFI side — v21 F2 re-derived / v22)",
        " * KernelExports.h  (UEFI side — v21 F2 re-derived / v22 / v23 fix)",
        "KX-title")
    rep("UEFI/include/KernelExports.h",
        " * THE GATE (Rd32): every export-directory access is an RVA relative",
        " * v23 FIX NOTE: the export-size gate upper bound is corrected to\n"
        " * 0x100000 per the v21 binary disassembly (the v30 field run refused\n"
        " * every resolve under the wrong 0x10000 bound - fail-closed, no\n"
        " * crash; see the v30-report worklog entry for the full evidence).\n"
        " *\n"
        " * THE GATE (Rd32): every export-directory access is an RVA relative",
        "KX-v23-note")

    # ---- ProcessWalk.h: version tag ----
    rep("UEFI/include/ProcessWalk.h",
        " * ProcessWalk.h  (UEFI side — v22 / F3)",
        " * ProcessWalk.h  (UEFI side — v22/v23 / F3)",
        "PW-title")

    # ---- RequestHandler.h: op-11 comment tag ----
    rep("UEFI/include/RequestHandler.h",
        "            case 11 /* ReqOp_ProcessWalk — v22 F3: the EPROCESS walk.",
        "            case 11 /* ReqOp_ProcessWalk — v23 F3: the EPROCESS walk.",
        "RH-op11")

    # ---- main.c banners ----
    rep("UEFI/src/main.c",
        '    static const char kBuildLine[] = "  Build: v22 RT - anchors + exports + process walk";',
        '    static const char kBuildLine[] = "  Build: v23 RT - anchors + exports + process walk";',
        "MC-kbuild-rt")
    rep("UEFI/src/main.c",
        '    static const char kBuildLine[] = "  Build: v22 SAFE (phase F3)";',
        '    static const char kBuildLine[] = "  Build: v23 SAFE (phase F3)";',
        "MC-kbuild-safe")
    rep("UEFI/src/main.c",
        'Print((CHAR16*)L"  Build: v22 RT - anchors + exports + process walk (F3)   \\r\\n");',
        'Print((CHAR16*)L"  Build: v23 RT - anchors + exports + process walk (F3)   \\r\\n");',
        "MC-screen-rt")
    rep("UEFI/src/main.c",
        'Print((CHAR16*)L"  Build: v22 SAFE (phase F3)                               \\r\\n");',
        'Print((CHAR16*)L"  Build: v23 SAFE (phase F3)                               \\r\\n");',
        "MC-screen-safe")
    rep("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "efi_main v22 boot");',
        'SerialTrace::Line("MAIN", "efi_main v23 boot");',
        "MC-boot")
    rep("UEFI/src/main.c",
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v22)");',
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v23)");',
        "MC-variant")

    # ---- RuntimeHook.h banners ----
    rep("UEFI/include/RuntimeHook.h",
        'SerialTrace::Line("RT-EARLY", "memory.efi v22 RT (kernel data path: direct reads + export resolution + process walk)");',
        'SerialTrace::Line("RT-EARLY", "memory.efi v23 RT (kernel data path: direct reads + export resolution + process walk)");',
        "RH-rt-early")
    rep("UEFI/include/RuntimeHook.h",
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v22 early) - keeping slots");',
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v23 early) - keeping slots");',
        "RH-rt-va")

    # ---- final verification ----
    kx = p("UEFI/include/KernelExports.h").read_text(encoding="utf-8")
    assert "exp_size >= 0x100000" in kx, "fix missing"
    assert "exp_size >= 0x10000) " not in kx.replace("0x100000", ""), "old bound survived"
    for rel, allow in (
        ("UEFI/src/main.c", 0),
        ("UEFI/include/RuntimeHook.h", 0),
        ("UEFI/include/RequestHandler.h", 0),
    ):
        left = p(rel).read_text(encoding="utf-8").count("v22")
        if left != allow:
            print(f"[CHECK] FATAL: {rel} still has {left} 'v22' strings")
            sys.exit(1)
        print(f"[CHECK] {rel}: no stale v22 banners")
    # KernelExports.h keeps exactly the historical provenance mentions
    n = kx.count("v22")
    if n < 2:
        print(f"[CHECK] FATAL: KernelExports.h v22 mentions = {n} (provenance notes expected)")
        sys.exit(1)
    print(f"[CHECK] KernelExports.h: {n} historical v22 mentions (provenance - OK)")
    print()
    print("[patch-v23] ALL EDITS APPLIED - tree is now v23")
    print("[patch-v23] the fix: KernelExports.h export-size gate 0x10000 -> 0x100000")
    print("[patch-v23] banners: v22 -> v23 everywhere (wire contract untouched)")


if __name__ == "__main__":
    main()
