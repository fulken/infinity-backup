#!/usr/bin/env python3
# ============================================================================
# patch-v25.py — v24 -> v25 driver source transformation
#
# F4: THE PAGE-TABLE WALK (op 12 TranslateVa) — VA -> self-map walk with
# true residency validation. NO CR3 switching (the v17/v19 lesson),
# NO physical reads, NO kernel calls.
#
#   1. NEW PageTableWalk.h (namespace pt):
#      - PTE_BASE discovery, TWO ordered chains:
#        A: nt!MmPteBase .data u64 (RVA candidates 0xCFB358 / 0xCFA358
#           — 19 real 19041/19045 PDBs) + the 512-value structural
#           check. A must pass BEFORE any out-of-image read: a
#           drifted patch level refuses CLEANLY here (VM alive).
#        B (after A): the PFN bootstrap — nt!MmPfnDatabase (5 RVA
#           candidates) -> System CR3 (EPROCESS+0x28, the v24-proven
#           resolve->deref chain + pid==4 gate) -> _MMPFN[pfn].PteAddress
#           (stride 0x30, +0x8 — verified against the actual 19045 PDB)
#           -> s = bits, base = 0xFFFF..|(s<<39) -> the identity
#           PteAddress == base + s*8. A and B must AGREE.
#      - The TWO-WAY PROOF: PML4E[s] (read through the agreed base)
#        must point at the System CR3 frame — the page tables and the
#        EPROCESS validate each other (payload selfOk).
#      - The 4-level walk, parent-present descent (a present parent
#        guarantees the child table page exists — an absent level is a
#        clean not-present answer; nothing below an absent parent is
#        ever touched), 2MB/1GB large pages, budget, fail-closed.
#
#   2. RequestHandler.h:
#      - op-11 payload extended: dtb@1056 (u64, the System
#        DirectoryTableBase, PCID-masked) — payload 1056 -> 1064B.
#      - NEW case 12 (TranslateVa): 80B payload, [PT] serial traces.
#
#   3. Banners v24 -> v25 (main.c x6, RuntimeHook.h x2). The wire
#      contract of every existing op is UNTOUCHED except the op-11
#      payload EXTENSION (additive, at a previously-zero offset).
#
# Provenance of every constant (4+ independent sources each) is
# documented in PageTableWalk.h's header comment.
#
# usage: patch-v25.py <v24-tree>
# ============================================================================
import pathlib
import shutil
import sys

if len(sys.argv) != 2:
    print("usage: patch-v25.py <v24-tree>")
    sys.exit(1)

BASE = pathlib.Path(__file__).resolve().parent
TREE = pathlib.Path(sys.argv[1])


def p(rel):
    return TREE / rel


def must_exist(rel):
    f = p(rel)
    if not f.exists():
        print(f"FATAL: {rel} missing — not a v24 tree?")
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


# ---- [0] tree sanity: the v24 banners ----
mc = must_exist("UEFI/src/main.c")
if "efi_main v24 boot" not in mc.read_text(encoding="utf-8"):
    print("FATAL: not a v24 tree (banner mismatch)")
    sys.exit(1)

# ---- [1] PageTableWalk.h (the new F4 engine) ----
src = BASE / "v25-PageTableWalk.h"
if not src.exists():
    print("FATAL: v25-PageTableWalk.h asset missing next to the patch")
    sys.exit(1)
shutil.copyfile(src, p("UEFI/include/PageTableWalk.h"))
print("[PT-header] OK (PageTableWalk.h installed)")

# ---- [2] RequestHandler.h: include ----
rep("UEFI/include/RequestHandler.h",
    '#include "ProcessWalk.h"\n#include "Diag.h"',
    '#include "ProcessWalk.h"\n#include "PageTableWalk.h"\n#include "Diag.h"',
    "RH-include")

# ---- [3] op-11 payload doc + extension ----
rep("UEFI/include/RequestHandler.h",
    """                    Payload 1056B = entries[32] x 32B
                    {pid, flags(bit0=name echoed), eproc, name[8], pad},
                    then status@1024, count@1028 (total walked),
                    sysEntry@1032 (the DEREF'D System EPROCESS VA —
                    v24: pool, OUTSIDE the image), nameOfs@1040,
                    closed@1044,
                    pages@1048, stored@1052. Status: 1 ok / 7 no-entry
                    / 4 walk refusal / 5 bad args. */: {""",
    """                    Payload 1064B = entries[32] x 32B
                    {pid, flags(bit0=name echoed), eproc, name[8], pad},
                    then status@1024, count@1028 (total walked),
                    sysEntry@1032 (the DEREF'D System EPROCESS VA —
                    v24: pool, OUTSIDE the image), nameOfs@1040,
                    closed@1044,
                    pages@1048, stored@1052, dtb@1056 (u64, v25: the
                    System DirectoryTableBase, EPROCESS+0x28, PCID-
                    masked — the F4 two-way-proof source; 0 when the
                    walk refused). Status: 1 ok / 7 no-entry
                    / 4 walk refusal / 5 bad args. */: {""",
    "RH-op11-doc")

rep("UEFI/include/RequestHandler.h",
    """                // ---- 1056-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 1056; i++) p[i] = 0;""",
    """                // ---- v25: the System DTB echo (the F4 source) —
                //      EPROCESS+0x28 via the pt gates (canonical +
                //      pid==4 + frame sanity), only after a good walk.
                //      The op-12 engine re-derives it independently;
                //      this echo lets the script cross-check both. ----
                pt::u32 pt_reads = 0;
                pt::u64 eproc_dtb = 0;
                if (wr.status == pw::kPwOk)
                    pt::EprocDtb(wr.sys_entry, &pt_reads, &eproc_dtb);

                // ---- 1064-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 1064; i++) p[i] = 0;""",
    "RH-op11-dtb-read")

rep("UEFI/include/RequestHandler.h",
    """                put32(1048, wr.pages);
                put32(1052, wr.stored);
                resp->bytes_transferred = 1056;
                *data_size = 1056;""",
    """                put32(1048, wr.pages);
                put32(1052, wr.stored);
                put64(1056, eproc_dtb & pt::kPtPfnMask);
                resp->bytes_transferred = 1064;
                *data_size = 1064;""",
    "RH-op11-payload")

# ---- [4] NEW case 12 (TranslateVa), right after case 11 ----
rep("UEFI/include/RequestHandler.h",
    """                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
            case ReqOp_Read: {""",
    """                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
            case 12 /* ReqOp_TranslateVa — v25 F4: VA -> page-table
                    walk through the self-map (NO CR3 switching —
                    the v17/v19 lesson; NO physical reads; NO kernel
                    calls). req->address = the target kernel VA
                    (canonical upper half only; user-range and
                    non-canonical -> kPtBadArgs). data_size ignored.
                    PTE_BASE discovery (two ordered chains, see
                    PageTableWalk.h): A = nt!MmPteBase (.data, RVA
                    candidates from 19 real 19041/19045 PDBs) with
                    the 512-value structural check — A gates ALL
                    out-of-image reads; B = the PFN bootstrap
                    (MmPfnDatabase -> CR3 -> _MMPFN.PteAddress ->
                    the s-identity); A and B must agree.
                    Payload 80B: rc@0 (1 ok / 2 no-base / 4
                    not-present / 5 bad args / 6 refused), selfIdx@4
                    (the self-map PML4 index s), pteBase@8, cr3@16
                    (System DTB, EPROCESS+0x28, PCID-masked; 0 = the
                    eproc chain refused — reported, not fatal),
                    pml4e@24, pdpte@32, pde@40, pte@48 (raw entries;
                    0 = the walk stopped above that level), frame@56
                    (phys page base of the translation), presentMask@
                    64 (bit0..3 = level present, bit4 = large page),
                    source@68 (bit0-1 = MmPteBase candidate, bit4 =
                    PFN chain agreed, bit5 = PFN chain missed),
                    selfOk@72 (1 = PML4E[s].frame == CR3.frame —
                    the two-way proof: the page tables and the
                    EPROCESS validate each other), reads@76. Status:
                    1 ok / 1 with rc=4 (not present — a clean
                    answer) / 7 no-base / 5 bad args / 4 refused. */: {
                DiscoverAnchorsOnce();
                UINT64 target = req->address;
                pt::Result tr{};
                if (ka::g_result.state == ka::kAnchorConverged) {
                    kx::Ctx c{ka::g_result.pe_base,
                              ka::g_result.pe_size, 0, 0};
                    tr = pt::Translate(&c, target);
                } else {
                    tr.status = pt::kPtBadArgs;
                }
                SerialTrace::KV("PT", "va", target);
                SerialTrace::KV("PT", "ptebase", tr.pte_base);
                SerialTrace::KVD("PT", "self", tr.self_idx);
                SerialTrace::KVD("PT", "mask", tr.present_mask);
                SerialTrace::KV("PT", "frame", tr.frame);
                SerialTrace::KVD("PT", "selfok", tr.self_ok);

                // ---- 80-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 80; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0,  tr.status);
                put32(4,  tr.self_idx);
                put64(8,  tr.pte_base);
                put64(16, tr.cr3);
                put64(24, tr.pml4e);
                put64(32, tr.pdpte);
                put64(40, tr.pde);
                put64(48, tr.pte);
                put64(56, tr.frame);
                put32(64, tr.present_mask);
                put32(68, tr.source);
                put32(72, tr.self_ok);
                put32(76, tr.reads);
                resp->bytes_transferred = 80;
                *data_size = 80;
                if (tr.status == pt::kPtOk ||
                    tr.status == pt::kPtNotPresent)
                    resp->status = SlotStatus_Success;
                else if (tr.status == pt::kPtBadArgs)
                    resp->status = SlotStatus_ErrInvalid;
                else if (tr.status == pt::kPtNoBase)
                    resp->status = SlotStatus_ErrNotFound;
                else
                    resp->status = SlotStatus_ErrAccess;
                break;
            }
            case ReqOp_Read: {""",
    "RH-op12")

# ---- [5] main.c banners ----
rep("UEFI/src/main.c",
    '    static const char kBuildLine[] = "  Build: v24 RT - anchors + exports + process walk";',
    '    static const char kBuildLine[] = "  Build: v25 RT - anchors + exports + process walk + page tables";',
    "MC-kbuild-rt")
rep("UEFI/src/main.c",
    '    static const char kBuildLine[] = "  Build: v24 SAFE (phase F3)";',
    '    static const char kBuildLine[] = "  Build: v25 SAFE (phase F4)";',
    "MC-kbuild-safe")
rep("UEFI/src/main.c",
    'Print((CHAR16*)L"  Build: v24 RT - anchors + exports + process walk (F3)   \\r\\n");',
    'Print((CHAR16*)L"  Build: v25 RT - anchors + exports + process walk (F4)   \\r\\n");',
    "MC-screen-rt")
rep("UEFI/src/main.c",
    'Print((CHAR16*)L"  Build: v24 SAFE (phase F3)                               \\r\\n");',
    'Print((CHAR16*)L"  Build: v25 SAFE (phase F4)                               \\r\\n");',
    "MC-screen-safe")
rep("UEFI/src/main.c",
    'SerialTrace::Line("MAIN", "efi_main v24 boot");',
    'SerialTrace::Line("MAIN", "efi_main v25 boot");',
    "MC-boot")
rep("UEFI/src/main.c",
    'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v24)");',
    'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v25)");',
    "MC-variant")

# ---- [6] RuntimeHook.h banners ----
rep("UEFI/include/RuntimeHook.h",
    'SerialTrace::Line("RT-EARLY", "memory.efi v24 RT (kernel data path: direct reads + export resolution + process walk)");',
    'SerialTrace::Line("RT-EARLY", "memory.efi v25 RT (kernel data path: direct reads + export resolution + process walk + page tables)");',
    "RH-rt-early")
rep("UEFI/include/RuntimeHook.h",
    'SerialTrace::Line("RT-VA", "hooks already installed at load (v24 early) - keeping slots");',
    'SerialTrace::Line("RT-VA", "hooks already installed at load (v25 early) - keeping slots");',
    "RH-rt-va")

# ---- [7] final verification ----
rh = p("UEFI/include/RequestHandler.h").read_text(encoding="utf-8")
assert '#include "PageTableWalk.h"' in rh, "include missing"
assert "case 12 /* ReqOp_TranslateVa" in rh, "op-12 missing"
assert "put64(1056, eproc_dtb & pt::kPtPfnMask)" in rh, "dtb echo missing"
assert "*data_size = 1064;" in rh, "op-11 payload size missing"
assert '"PT", "ptebase"' in rh, "PT traces missing"
pt = p("UEFI/include/PageTableWalk.h").read_text(encoding="utf-8")
assert "kS1PteBaseRvas" in pt and "0xCFB358" in pt, "S1 candidates missing"
assert "PfnBootstrap" in pt and "kPtMmPfnStride" in pt, "B chain missing"
assert "ValidPteBase" in pt, "structural check missing"
for rel in ("UEFI/src/main.c", "UEFI/include/RuntimeHook.h"):
    t = p(rel).read_text(encoding="utf-8")
    assert "v24" not in t.replace("v24 field run", "").replace("(v31 field run)", ""), \
        f"stale v24 banner survived in {rel}"
print()
print("[patch-v25] ALL EDITS APPLIED - tree is now v25")
print("[patch-v25] changed: RequestHandler.h (op-12 + op-11 dtb + include),")
print("            NEW PageTableWalk.h, main.c banners, RuntimeHook.h banners")
print("[patch-v25] wire untouched except the ADDITIVE op-11 dtb@1056 (1064B)")
