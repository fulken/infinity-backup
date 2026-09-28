#!/usr/bin/env python3
# ============================================================================
# patch-v26.py — v25 -> v26 driver source transformation
#
# THE FORMULA FIX (the v33 field post-mortem, BSOD 0x50 root cause):
# v25's upper-level PTE-space slot formulas (PML4E/PDPTE/PDE at
# PTE_BASE + shifted-vpn*8) addressed LOW-USER PTE slots; the first
# PTE-space read (the self-ref read at PTE_BASE + s*8) faulted in the
# trigger script's caller context -> PAGE_FAULT_IN_NONPAGED_AREA.
#
#   1. PageTableWalk.h REPLACED with the corrected engine:
#      - the self-map level bases: PDE_BASE = PTE_BASE + (s<<30),
#        PPE_BASE = PDE_BASE + (s<<21), PXE_BASE = PPE_BASE +
#        (s<<12) — ground-truthed against the published classic
#        s=0x1ED quartet (0xFFFFF6FB40000000 / 0xFFFFF6FB7DA00000 /
#        0xFFFFF6FB7DBED000, EXACT).
#      - self-ref read at PXE_BASE + s*8 (was PTE_BASE + s*8 = the
#        read that killed the VM).
#      - a1 = PXE_BASE + p4*8, a2 = PPE_BASE + (p4<<9|p3)*8,
#        a3 = PDE_BASE + (p4<<18|p3<<9|p2)*8, a4 unchanged (the
#        MiGetPteAddress slot was right).
#      - chain-B identity -> PteAddress == PXE_BASE(s) + s*8 (the
#        _MMPFN[PML4].PteAddress slot; v25 compared PTE_BASE + s*8,
#        so B could never agree in the field).
#      - selfOk becomes a bitmask: bit0 = the PTE space is LIVE
#        (self-ref present + sane frame); bit1 = self-ref frame ==
#        System CR3 frame (1 only in a System-context caller — the
#        trigger script's caller is a user process, so bit1=0 is the
#        EXPECTED honest field value; v25's unconditional == CR3
#        claim was wrong for the caller context).
#      - Parent-present descent SURVIVES the fix by construction:
#        every corrected slot address walks only the s-self-ref
#        chain + parents already proven present.
#      - WIRE CONTRACT UNTOUCHED: same ops, same payload layouts
#        (80B op-12 / 1064B op-11), same status codes.
#
#   2. RequestHandler.h: op-12 doc comment (selfOk bit semantics +
#      the v26 case marker) — comments only, zero code changes.
#      main.c + RuntimeHook.h banners v25 -> v26.
#
# usage: patch-v26.py <v25-tree>
# ============================================================================
import pathlib
import shutil
import sys

if len(sys.argv) != 2:
    print("usage: patch-v26.py <v25-tree>")
    sys.exit(1)

BASE = pathlib.Path(__file__).resolve().parent
TREE = pathlib.Path(sys.argv[1])


def p(rel):
    return TREE / rel


def must_exist(rel):
    f = p(rel)
    if not f.exists():
        print(f"FATAL: {rel} missing — not a v25 tree?")
        sys.exit(1)
    return f


def rep(rel, old, new, tag, count=1):
    f = must_exist(rel)
    t = f.read_text(encoding="utf-8")
    n = t.count(old)
    if n != count:
        print(f"FATAL [{tag}]: anchor x{n} (want {count}) in {rel}")
        sys.exit(1)
    f.write_text(t.replace(old, new), encoding="utf-8")
    print(f"[{tag}] OK")


# ---- [0] tree sanity: the v25 banners ----
mc = must_exist("UEFI/src/main.c")
if "efi_main v25 boot" not in mc.read_text(encoding="utf-8"):
    print("FATAL: not a v25 tree (banner mismatch)")
    sys.exit(1)

# ---- [1] PageTableWalk.h: the corrected F4 engine ----
src = BASE / "v26-PageTableWalk.h"
if not src.exists():
    print("FATAL: v26-PageTableWalk.h asset missing next to the patch")
    sys.exit(1)
shutil.copyfile(src, p("UEFI/include/PageTableWalk.h"))
print("[PT-header] OK (the corrected v26 PageTableWalk.h installed)")

# ---- [2] RequestHandler.h: op-12 doc — the selfOk bit semantics ----
rep("UEFI/include/RequestHandler.h",
    """                    selfOk@72 (1 = PML4E[s].frame == CR3.frame —
                    the two-way proof: the page tables and the
                    EPROCESS validate each other), reads@76.""",
    """                    selfOk@72 (bit0 = the PTE space is LIVE:
                    the self-ref slot read succeeded, the entry is
                    present, its frame is sane; bit1 = the self-ref
                    frame == the System CR3 frame — set only in a
                    System-context caller, 0 is the EXPECTED value
                    in the trigger script's caller process; v26
                    semantics, the v25 == CR3 claim corrected),
                    reads@76.""",
    "RH-op12-selfok-doc")

rep("UEFI/include/RequestHandler.h",
    """            case 12 /* ReqOp_TranslateVa — v25 F4: VA -> page-table
                    walk through the self-map (NO CR3 switching —""",
    """            case 12 /* ReqOp_TranslateVa — v26 F4: VA -> page-table
                    walk through the self-map (v26: the level-base
                    formula fix — see PageTableWalk.h's header; NO
                    CR3 switching —""",
    "RH-op12-case-marker")

# ---- [3] main.c banners ----
rep("UEFI/src/main.c",
    '    static const char kBuildLine[] = "  Build: v25 RT - anchors + exports + process walk + page tables";',
    '    static const char kBuildLine[] = "  Build: v26 RT - anchors + exports + process walk + page tables";',
    "MC-kbuild-rt")
rep("UEFI/src/main.c",
    '    static const char kBuildLine[] = "  Build: v25 SAFE (phase F4)";',
    '    static const char kBuildLine[] = "  Build: v26 SAFE (phase F4)";',
    "MC-kbuild-safe")
rep("UEFI/src/main.c",
    'Print((CHAR16*)L"  Build: v25 RT - anchors + exports + process walk (F4)   \\r\\n");',
    'Print((CHAR16*)L"  Build: v26 RT - anchors + exports + process walk (F4)   \\r\\n");',
    "MC-screen-rt")
rep("UEFI/src/main.c",
    'Print((CHAR16*)L"  Build: v25 SAFE (phase F4)                               \\r\\n");',
    'Print((CHAR16*)L"  Build: v26 SAFE (phase F4)                               \\r\\n");',
    "MC-screen-safe")
rep("UEFI/src/main.c",
    'SerialTrace::Line("MAIN", "efi_main v25 boot");',
    'SerialTrace::Line("MAIN", "efi_main v26 boot");',
    "MC-boot")
rep("UEFI/src/main.c",
    'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v25)");',
    'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v26)");',
    "MC-variant")

# ---- [4] RuntimeHook.h banners ----
rep("UEFI/include/RuntimeHook.h",
    'SerialTrace::Line("RT-EARLY", "memory.efi v25 RT (kernel data path: direct reads + export resolution + process walk + page tables)");',
    'SerialTrace::Line("RT-EARLY", "memory.efi v26 RT (kernel data path: direct reads + export resolution + process walk + page tables)");',
    "RH-rt-early")
rep("UEFI/include/RuntimeHook.h",
    'SerialTrace::Line("RT-VA", "hooks already installed at load (v25 early) - keeping slots");',
    'SerialTrace::Line("RT-VA", "hooks already installed at load (v26 early) - keeping slots");',
    "RH-rt-va")

# ---- [5] final verification ----
rh = p("UEFI/include/RequestHandler.h").read_text(encoding="utf-8")
assert "bit0 = the PTE space is LIVE" in rh, "selfOk doc missing"
assert "v26 F4" in rh, "op-12 case marker missing"
assert "put64(1056, eproc_dtb & pt::kPtPfnMask)" in rh, "dtb echo missing"
assert "*data_size = 1064;" in rh, "op-11 payload size missing"
assert '"PT", "ptebase"' in rh, "PT traces missing"
assert "*data_size = 80;" in rh, "op-12 payload size missing"
pt = p("UEFI/include/PageTableWalk.h").read_text(encoding="utf-8")
assert "PxeBaseOf" in pt and "PdeBaseOf" in pt and "PpeBaseOf" in pt, \
    "level-base helpers missing"
assert "PxeBaseOf(pte_a, s) + (u64)s * 8" in pt, "fixed self-ref read missing"
assert "PxeBaseOf(base, s) + ((u64)s * 8)" in pt, "fixed B identity missing"
assert "pte_a + vpn * 8" in pt, "a4 (unchanged) missing"
assert "0xCFB358" in pt and "PfnBootstrap" in pt, "constants/B chain damaged"
# the OLD formulas must be GONE from the engine code:
assert "pte_a + ((vpn >> 27) & 0x1FF) * 8" not in pt, "old a1 survived!"
assert "pte_a + ((vpn >> 18) & 0x3FFFF) * 8" not in pt, "old a2 survived!"
assert "pte_a + ((vpn >> 9) & 0x7FFFFFF) * 8" not in pt, "old a3 survived!"
assert "pte_a + (u64)s * 8" not in pt, "old self-ref read survived!"
for rel in ("UEFI/src/main.c", "UEFI/include/RuntimeHook.h"):
    t = p(rel).read_text(encoding="utf-8")
    assert "v25" not in t, f"stale v25 banner survived in {rel}"
print()
print("[patch-v26] ALL EDITS APPLIED - tree is now v26")
print("[patch-v26] changed: PageTableWalk.h (the formula fix),")
print("            RequestHandler.h (comments only), banners v26")
print("[patch-v26] wire contract: UNTOUCHED (op layouts + status codes)")
