#!/usr/bin/env python3
# ============================================================================
# make-host-test-v25.py — emit scripts/host-test-v25.c from the v24 suite:
# the full regression (T1..T23, 66 CHECKs) + the NEW pt section (T24..T40)
# for PageTableWalk.h — the F4 engine.
#
# The synthetic PT world (VA-pure): the self-map means the engine only ever
# reads PTE-space slot VAs computed from the VPN — so the "tables" are just
# mapped regions of PTE space we fill directly. The B-chain's _MMPFN slot,
# the EPROCESS pool object, and the .data globals complete the world.
#
# THE SAFETY PROOFS BAKED IN:
#   - drifted-layout world (T26): the strict harness itself proves NO
#     out-of-image/out-of-map read happens when chain A fails (any read
#     of the unmapped PTE space would ABORT the run)
#   - absent-parent world (T32): only the PML4 region is mapped — a read
#     below the absent entry would ABORT (parent-present descent proven)
# ============================================================================
import pathlib

BASE = pathlib.Path(__file__).resolve().parent
SRC = BASE / "host-test-v24.c"
DST = BASE / "host-test-v25.c"

t = SRC.read_text(encoding="utf-8")

# ---- [1] header comment ----
t = t.replace(
"""// ===========================================================================
// host-test-v24.c — unit tests for the REAL v24 pure-logic headers
// (KernelExports.h + ProcessWalk.h with the S1+S2 deref chain) against
// synthetic memory. T1..T22 are the v23 suite unchanged (regression).
""",
"""// ===========================================================================
// host-test-v25.c — unit tests for the REAL v25 pure-logic headers
// (KernelExports.h + ProcessWalk.h + PageTableWalk.h: the F4 engine)
// against synthetic memory. T1..T23 are the v24 suite unchanged
// (regression, 66 CHECKs); T24..T40 drive the page-table walk.
//
// F4 WORLD: PTE_BASE = 0xFFFFD58000000000 (s = 0x1AB). Because the
// engine reads the tables ONLY through self-map slot VAs computed from
// the VPN, the synthetic tables are simply mapped/filled regions of
// PTE space. Chain B adds the _MMPFN mirror; chains A/B read the .data
// globals we place at the real observed RVAs (image extended to
// 0xCFD000 to cover them).
""")

# ---- [2] defines + include ----
t = t.replace(
"""#define KERNEL_EXPORTS_HOST_TEST
#define KERNEL_WALK_HOST_TEST
#include "KernelExports.h"
#include "ProcessWalk.h"
""",
"""#define KERNEL_EXPORTS_HOST_TEST
#define KERNEL_WALK_HOST_TEST
#define KERNEL_PT_HOST_TEST
#include "KernelExports.h"
#include "ProcessWalk.h"
#include "PageTableWalk.h"
""")

# ---- [3] hosted PT_R8 (global scope, fully qualified — the v24
#     harness's namespace layout is subtle; this is bulletproof) ----
t = t.replace(
"""// the hosted primitives: STRICT map checking
""",
"""// the hosted PT_R8: STRICT map checking (global scope, fully qualified)
namespace UEFIBridge { namespace pt {
std::uint8_t PT_R8(std::uint64_t va) {
    std::uint64_t pg = va & ~0xFFFull;
    if (!g_pages.count(pg)) {
        fprintf(stderr, "\\n*** FATAL: PT_R8 OUT-OF-MAP read at 0x%llx ***\\n",
                (unsigned long long)va);
        exit(2);
    }
    g_reads++;
    return g_pages[pg][va & 0xFFF];
} // PT_R8
}} // namespace UEFIBridge::pt

// the hosted primitives: STRICT map checking
""")

# ---- [4] the pt test section + main wiring ----
PT_SECTION = r"""
// ==================== pt: the F4 synthetic world ====================
static const std::uint64_t PTB   = 0xFFFFD58000000000ULL; // PTE_BASE
static const std::uint32_t PTS   = 0x1AB;                  // self index
static const std::uint64_t PFNDB = 0xFFFFE00000000000ULL;  // MmPfnDatabase VA
static const std::uint64_t EPROC = 0xFFFF8E00BAD00000ULL;  // pool object
static const std::uint64_t CR3RW = 0x0000000123456781ULL;  // PCID bits set
static const std::uint64_t CR3FR = 0x0000000123456000ULL;  // masked frame
static const std::uint64_t PTIMG_SIZE = 0xCFD000ULL;       // covers .data

static void pt_world_a_good(std::uint32_t s1_slot /* 0 or 1 */) {
    g_pages.clear();
    build_export_image();
    map_region(IMG, PTIMG_SIZE);
    // chain A: the good MmPteBase at slot 0 or 1; the other = garbage
    std::uint64_t good = PTB;
    std::uint64_t garbage = 0xFFFFF80714863000ULL;   // a kernel VA shape
    wr64(IMG + 0xCFB358, s1_slot == 0 ? good : garbage);
    wr64(IMG + 0xCFA358, s1_slot == 0 ? garbage : good);
    // THE SYMBOL SLOT: the resolved PsInitialSystemProcess slot's
    // VALUE is the pool EPROCESS (the v24 chain derefs it)
    wr64(IMG + 0x10010, EPROC);
    // the System EPROCESS (the v24-proven chain target)
    map_region(EPROC, 0x1000);
    wr64(EPROC + 0x440, 4);
    wr64(EPROC + 0x28, CR3RW);
    // chain B: MmPfnDatabase pointer + the _MMPFN.PteAddress mirror
    wr64(IMG + 0xCFC508, PFNDB);
    std::uint64_t slot = PFNDB + ((CR3FR >> 12) * 0x30) + 8;
    map_region(slot & ~0xFFFull, 0x1000);
    wr64(slot, PTB + (std::uint64_t)PTS * 8);   // the s-identity
    // the PML4 (self-map region 0) + the self-ref entry
    map_region(PTB, 0x1000);
    wr64(PTB + PTS * 8, CR3FR | 0x23);          // self -> CR3 frame
}

// map the 4 table regions for a target VA and set the leaf chain
static void pt_map_leaf(std::uint64_t va, std::uint64_t pml4e,
                        std::uint64_t pdpte, std::uint64_t pde,
                        std::uint64_t pte) {
    std::uint64_t vpn = (va >> 12) & 0xFFFFFFFFFULL;   // 36-bit, as the engine masks
    map_region(PTB, 0x1000);                                   // PML4
    map_region(PTB + ((vpn >> 18) & 0x3FFFF) * 8 & ~0xFFFull, 0x1000); // PDPT
    map_region(PTB + ((vpn >> 9) & 0x7FFFFFF) * 8 & ~0xFFFull, 0x1000); // PD
    map_region(PTB + vpn * 8 & ~0xFFFull, 0x1000);             // PT
    wr64(PTB + ((vpn >> 27) & 0x1FF) * 8, pml4e);
    wr64(PTB + ((vpn >> 18) & 0x3FFFF) * 8, pdpte);
    wr64(PTB + ((vpn >> 9) & 0x7FFFFFF) * 8, pde);
    wr64(PTB + vpn * 8, pte);
}

static void pt_tests() {
    printf("\n== pt::Translate (F4, T24..T40) ==\n");
    const std::uint64_t TGT = 0xFFFFF80712345678ULL; // a kernel VA
    {   // T24: the full happy path — A cand#1 + B agree + two-way ok
        pt_world_a_good(0);
        pt_map_leaf(TGT, 0x0000000AAA000025ULL, 0x0000000BBB000025ULL,
                    0x0000000CCC000025ULL, 0x0000000DDD000025ULL);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F,
              "T24a 4KB walk: Ok, all levels present");
        CHECK(r.pte_base == PTB && r.self_idx == PTS,
              "T24b pte_base + self index discovered");
        CHECK(r.source == (1u | 0x10u),
              "T24c source = A cand#1 + B agreed");
        CHECK(r.self_ok == 1 && r.cr3 == CR3FR,
              "T24d the two-way proof: PML4E[s] -> CR3 frame");
        CHECK(r.frame == 0xDDD000000ULL && r.pml4e == 0x0000000AAA000025ULL
              && r.pdpte == 0x0000000BBB000025ULL
              && r.pde == 0x0000000CCC000025ULL
              && r.pte == 0x0000000DDD000025ULL,
              "T24e raw entries + frame echoed");
    }
    {   // T25: the good value at candidate #2 (the 0xCFA358 world)
        pt_world_a_good(1);
        pt_map_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && (r.source & 3) == 2,
              "T25 A candidate #2 accepted (source low bits = 2)");
    }
    {   // T26: DRIFTED WORLD — garbage at both A slots. The strict
        //     harness itself is the proof: the PTE space / pool /
        //     PFN-DB pages were NEVER mapped, so ANY out-of-image
        //     read would have aborted the run. It must refuse
        //     cleanly instead (the VM-alive property).
        g_pages.clear();
        build_export_image();
        map_region(IMG, PTIMG_SIZE);
        wr64(IMG + 0xCFB358, 0xFFFFF80714863000ULL);  // kernel VA
        wr64(IMG + 0xCFA358, 0x0000000000000100ULL);  // small int
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNoBase && r.pte_base == 0,
              "T26 CLASS-KILL: drifted layout -> clean kPtNoBase, "
              "ZERO out-of-image reads (harness alive = proof)");
    }
    {   // T27: A and B DISAGREE — B derives a different valid base.
        //     Must refuse (fail-closed), VM alive.
        pt_world_a_good(0);
        std::uint64_t slot = PFNDB + ((CR3FR >> 12) * 0x30) + 8;
        std::uint64_t base2 = 0xFFFF000000000000ULL | (0x1ACULL << 39);
        wr64(slot, base2 + 0x1ACULL * 8);   // a valid s'-identity
        pt_map_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNoBase,
              "T27 A/B disagreement -> refusal (never trust one chain)");
    }
    {   // T28: B MISS (all MmPfnDatabase slots garbage) — A proceeds
        //     alone, source bit5 set, self_ok still verified.
        pt_world_a_good(0);
        wr64(IMG + 0xCFC508, 0x123456789ULL);            // non-canonical
        pt_map_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && (r.source & 0x20) && r.self_ok == 1,
              "T28 B miss tolerated: A-only proceed, source bit5");
    }
    {   // T29: 2MB large page (PDE.PS)
        pt_world_a_good(0);
        pt_map_leaf(TGT, 0x25, 0x25, 0x0000000CCC000085ULL, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x17
              && r.frame == 0xCCC000000ULL + (TGT & 0x1FFFFF),
              "T29 2MB large page: mask 0x17 + frame+offset");
    }
    {   // T30: 1GB large page (PDPTE.PS)
        pt_world_a_good(0);
        pt_map_leaf(TGT, 0x25, 0x0000000C00000085ULL, 0, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x13
              && r.frame == 0xC00000000ULL + (TGT & 0x3FFFFFFF),
              "T30 1GB large page: mask 0x13 + frame+offset");
    }
    {   // T31: PTE not present — clean answer, entries above echoed
        pt_world_a_good(0);
        pt_map_leaf(TGT, 0x25, 0x25, 0x25, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNotPresent && r.present_mask == 0x7
              && r.frame == 0 && r.pte == 0 && r.pde != 0,
              "T31 absent PTE: not-present, mask 0x7, no frame");
    }
    {   // T32: ABSENT PML4E — THE PARENT-PRESENT SAFETY PROOF.
        //     Only the PML4 region is mapped: any read of the deeper
        //     slot regions would ABORT the strict harness. It must
        //     stop at level 0 instead.
        pt_world_a_good(0);
        map_region(PTB, 0x1000);                    // PML4 only
        std::uint64_t vpn = (TGT >> 12) & 0xFFFFFFFFFULL;
        wr64(PTB + ((vpn >> 27) & 0x1FF) * 8, 0);   // absent
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNotPresent && r.present_mask == 0
              && r.pdpte == 0 && r.pde == 0 && r.pte == 0,
              "T32 CLASS-KILL: absent PML4E -> nothing below is "
              "ever read (harness alive = proof)");
    }
    {   // T33: non-canonical target
        pt_world_a_good(0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, 0x0000800000000000ULL);
        CHECK(r.status == pt::kPtBadArgs, "T33 non-canonical -> BadArgs");
    }
    {   // T34: user-range target (kernel-data op by design)
        pt_world_a_good(0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, 0x00007FF000000000ULL);
        CHECK(r.status == pt::kPtBadArgs, "T34 user-range VA -> BadArgs");
    }
    {   // T35: ValidPteBase unit spots (the 512-value universe)
        std::uint32_t s = 0;
        CHECK(pt::ValidPteBase(0xFFFF000000000000ULL | (0x100ULL << 39), &s)
              && s == 0x100, "T35a the lowest valid base (s=0x100)");
        CHECK(!pt::ValidPteBase(0x0000000000000000ULL, &s)
              && !pt::ValidPteBase(0xFFFF800000000001ULL, &s)
              && !pt::ValidPteBase(0xFFFFF80714863000ULL, &s)
              && !pt::ValidPteBase(0xFFFF000000000000ULL | (0xFFULL << 39), &s),
              "T35b null/misaligned/kernel-VA/low-index all rejected");
    }
    {   // T36: EprocDtb direct — gates + the raw PCID value
        map_region(EPROC, 0x1000);
        wr64(EPROC + 0x440, 4);
        wr64(EPROC + 0x28, CR3RW);
        pt::u32 reads = 0; pt::u64 dtb = 0;
        CHECK(pt::EprocDtb(EPROC, &reads, &dtb) && dtb == CR3RW,
              "T36a EprocDtb returns the RAW DTB (PCID bits kept)");
        wr64(EPROC + 0x440, 7);
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T36b pid != 4 -> refused");
        wr64(EPROC + 0x440, 4);
        wr64(EPROC + 0x28, 0xFFFF000000000000ULL);  // absurd frame
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T36c absurd DTB frame -> refused");
        CHECK(!pt::EprocDtb(0x0000123400000000ULL, &reads, &dtb),
              "T36d non-canonical EPROCESS -> refused");
    }
    {   // T37: budget exhaustion — a saturated read counter refuses
        pt_world_a_good(0);
        pt_map_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::u32 reads = pt::kPtMaxReads; pt::u64 dtb = 0;
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T37 saturated budget -> refused cleanly");
    }
    {   // T40: SysEprocessCr3 — the full chain end-to-end
        pt_world_a_good(0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        std::uint64_t sym = 0, ep = 0, dtb = 0; pt::u32 reads = 0;
        bool ok = pt::SysEprocessCr3(&c, &sym, &ep, &dtb, &reads);
        CHECK(ok && sym == IMG + 0x10010 && ep == EPROC
              && (dtb & pt::kPtPfnMask) == CR3FR,
              "T40 resolve -> deref -> EprocDtb: the whole chain");
    }
}
"""

t = t.replace(
"""int main() {
    printf("==== host-test-v24: KernelExports.h + ProcessWalk.h (v24 deref chain) ====\\n");
    printf("strict mode: ANY out-of-map read aborts the whole test run\\n");
    kx_tests();
    kx_field_tests();
    pw_tests();
    chain_tests();
""",
"""int main() {
    printf("==== host-test-v25: KernelExports.h + ProcessWalk.h + PageTableWalk.h (v25 F4) ====\\n");
    printf("strict mode: ANY out-of-map read aborts the whole test run\\n");
    kx_tests();
    kx_field_tests();
    pw_tests();
    chain_tests();
    pt_tests();
""")

# insert the pt section before main()
t = t.replace("\nint main() {", PT_SECTION + "\nint main() {", 1)

DST.write_text(t, encoding="utf-8")
print(f"wrote {DST}: {len(t.splitlines())} lines")
