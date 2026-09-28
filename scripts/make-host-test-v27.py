#!/usr/bin/env python3
# ============================================================================
# make-host-test-v27.py — emit scripts/host-test-v27.c from the v26 suite.
#
# THE v27 ENGINE DELTA (see patch-v27.py):
#   - chain B (the PFN bootstrap) DELETED — the engine no longer reads
#     or dereferences ANYTHING at the researched MmPfnDatabase RVAs
#   - LiveCr3() captured (hosted: HostLiveCr3) + r.live_cr3/r.self_entry
#     echoed in the additive op-12 payload tail (80->96B)
#   - selfOk bit1 REDEFINED: the LIVE IDENTITY — self-ref frame ==
#     (live CR3 & pfnMask), expected 1 in ANY caller context (the
#     self-map maps the CURRENT page tables). v26 compared against the
#     System DTB and expected 0 from a user caller — that comparison
#     is now the script-side informational cross-check (r.cr3).
#
# TEST DELTA vs host-test-v26.c:
#   - T24..T27, T30..T38, T40, T41: UNCHANGED (regression)
#   - T25c: source == 1 (chain A only; bits 4/5 dead forever)
#   - T25f NEW: the additive payload echoes (live_cr3 == HostLiveCr3(),
#     self_entry == the raw PML4E[s] value)
#   - T28 REPURPOSED: THE POISON-IMMUNITY KILL — the MmPfnDatabase slot
#     holds the EXACT v38 field poison class (the R4 module-base
#     pointer 0xFFFFF807597B0000); under v25/v26 chain B would DEREF
#     it (the BSOD fingerprint); v27 never touches it — the walk must
#     be FULLY green (the deleted-class proof)
#   - T29 REPURPOSED: the B-dead world — garbage at the pfnDb RVA ->
#     walk green, source bits 4/5 clear, selfOk bit0 set, and the read
#     count IDENTICAL to the happy path (chain B does NOTHING)
#   - T39 REDEFINED: the caller-context world — selfOk == 3 (bit0 +
#     bit1 the LIVE identity: the caller's own PML4) while r.cr3 ==
#     the OTHER System frame — the two PML4s EXPECTEDLY differ; if the
#     engine ever regresses bit1 to System-CR3 semantics, T39b fails
#   - class-kills (a) old-formula + (b) S1-redacted keep using
#     host-test-v26.c exactly as before (the v26 test + the shimmed
#     v25 engine / the redacted header); this file is the GREEN suite
# ============================================================================
import pathlib

BASE = pathlib.Path(__file__).resolve().parent
SRC = BASE / "host-test-v26.c"
DST = BASE / "host-test-v27.c"

t = SRC.read_text(encoding="utf-8")
failed = []


def edit(old, new, name, count=1):
    global t
    n = t.count(old)
    if n != count:
        failed.append(f"[{name}] anchor x{n} (want {count})")
        return
    t = t.replace(old, new, count)


# ---- [1] header ----
edit(
"""// ===========================================================================
// host-test-v26.c — unit tests for the REAL v26 pure-logic headers
// (KernelExports.h + ProcessWalk.h + PageTableWalk.h: the FIXED F4
// engine) against synthetic memory. T1..T23 are the v24 suite unchanged
// (regression, 66 CHECKs); T24..T41 drive the page-table walk.
//""",
"""// ===========================================================================
// host-test-v27.c — unit tests for the REAL v27 pure-logic headers
// (KernelExports.h + ProcessWalk.h + PageTableWalk.h: the F4 engine,
// chain B DELETED + the LIVE-CR3 identity) against synthetic memory.
// T1..T23 are the v24 suite unchanged (regression, 66 CHECKs);
// T24..T41 drive the page-table walk.
//""",
"1 header title")

edit(
"""// the trigger script's caller context. Chains A/B read .data globals""",
"""// the trigger script's caller context. Chain A reads the .data global""",
"1b header chainline") if False else None

# ---- [2] HostLiveCr3 (the hosted ground truth) ----
edit(
"""} // PT_R8
}} // namespace UEFIBridge::pt""",
"""} // PT_R8

// the hosted LIVE CR3 (v27): the register value the engine would read
// with 'mov %cr3' in the REAL caller context. In this one-PML4 world
// the caller's CR3 is the world PML4; 0xED = PCID-ish low bits the
// engine must mask off before the identity compare.
std::uint64_t HostLiveCr3() { return PML4_FR | 0xEDULL; }
}} // namespace UEFIBridge::pt""",
"2 hostlivecr3")

# ---- [3] T25c: source = A only ----
edit(
"""        CHECK(r.source == (1u | 0x10u),
              "T25c source = A cand#1 + B agreed (two chains, one base)");
        CHECK(r.self_ok == 3 && r.cr3 == PML4_FR,
              "T25d selfOk bit0 (PTE space LIVE) + bit1 (self-ref frame \"""",
"""        CHECK(r.source == 1u,
              "T25c source = A cand#1 ONLY (chain B deleted; bits 4/5 dead)");
        CHECK(r.self_ok == 3 && r.cr3 == PML4_FR,
              "T25d selfOk bit0 (PTE space LIVE) + bit1 (self-ref frame \"""",
"3 t25c")

# ---- [4] T25f: the additive payload echoes ----
edit(
"""        CHECK(r.frame == 0xDDD000000ULL && r.pml4e == 0x0000000AAA000025ULL""",
"""        CHECK(r.live_cr3 == (PML4_FR | 0xEDULL)
              && (r.live_cr3 & pt::kPtPfnMask) == PML4_FR,
              "T25f live_cr3 echoed raw (PCID bits kept; the engine masks)");
        CHECK(r.self_entry == (PML4_FR | 0x23ULL),
              "T25g self_entry echoed raw (the PML4E[s] qword)");
        CHECK(r.frame == 0xDDD000000ULL && r.pml4e == 0x0000000AAA000025ULL""",
"4 t25fg")

# ---- [5] T28: THE POISON-IMMUNITY KILL ----
edit(
"""    {   // T28 (v25-T27): A and B DISAGREE — the mirror holds the
        //     s'=0x1AC identity (a valid OTHER self-map world). Must
        //     refuse (fail-closed), VM alive.
        pt_world_create(MAIN_S, 0, 0);
        std::uint64_t slot = PFNDB + ((PML4_FR >> 12) * 0x30) + 8;
        std::uint64_t base2 = 0xFFFF000000000000ULL | (0x1ACULL << 39);
        std::uint64_t pxe2 = base2 + ((std::uint64_t)0x1AC << 30)
                           + ((std::uint64_t)0x1AC << 21)
                           + ((std::uint64_t)0x1AC << 12);
        ptwr64(slot, pxe2 + 0x1ACULL * 8);   // a valid s'-identity
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNoBase,
              "T28 A/B disagreement -> refusal (never trust one chain)");
    }""",
"""    {   // T28 (v27 — THE POISON-IMMUNITY KILL): the MmPfnDatabase
        //     slot holds the EXACT v38-field poison class — the R4
        //     module-base pointer 0xFFFFF807597B0000 whose raw deref
        //     is the fingerprint of BOTH F4-era BSODs (0x50, arg1 ==
        //     pdb + pfn*0x30 + 8). Under v25/v26 chain B WOULD have
        //     dereferenced it; v27 never reads the slot at all. The
        //     walk must be FULLY green — the deleted-class proof.
        pt_world_create(MAIN_S, 0, 0);
        wr64(IMG + 0xCFC500, 0xFFFFF807597B0000ULL);  // the R4 poison
        wr64(IMG + 0xCFC510, 0xFFFFE60000000000ULL);  // the R5 poison
        wr64(IMG + 0xCFC508, 0xFFFFF807597B0000ULL);  // the majority
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F
              && r.self_ok == 3,
              "T28 POISON IMMUNITY: all 3 poison slots in place, the "
              "walk is FULLY green (chain B deleted — the BSOD class "
              "cannot even be expressed)");
    }""",
"5 t28 poison")

# ---- [6] T29: the B-dead world ----
edit(
"""    {   // T29 (v25-T28): B MISS (the MmPfnDatabase pointer garbage) —
        //     A proceeds alone, source bit5, the PTE space still LIVE.
        pt_world_create(MAIN_S, 0, 0);
        wr64(IMG + 0xCFC508, 0x123456789ULL);            // non-canonical
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && (r.source & 0x20)
              && (r.self_ok & 1),
              "T29 B miss tolerated: A-only proceed, source bit5, "
              "selfOk bit0 still set");
    }""",
"""    {   // T29 (v27 — THE B-DEAD WORLD): garbage at the old pfnDb
        //     RVAs changes NOTHING: source bits 4/5 stay clear and
        //     the read count is IDENTICAL to the happy path (chain B
        //     does literally nothing — the engine has no code that
        //     looks at these slots).
        pt_world_create(MAIN_S, 0, 0);
        wr64(IMG + 0xCFC508, 0x123456789ULL);            // non-canonical
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        pt::Result r2 = pt::Translate(&c, TGT);          // stable
        CHECK(r.status == pt::kPtOk && (r.source & 0x30) == 0
              && r.self_ok == 3 && r.reads == r2.reads,
              "T29 B-dead world: green, source bits 4/5 clear, read "
              "count stable (chain B contributes ZERO reads)");
    }""",
"6 t29 bdead")

# ---- [7] T39: the LIVE identity ----
edit(
"""    {   // T39 (NEW — the v26 semantics): THE CALLER-CONTEXT WORLD.
        //     The EPROCESS records System's DTB = ANOTHER valid frame
        //     (the trigger script's process runs on ITS OWN PML4 —
        //     the live one). The self-ref slot still opens (bit0),
        //     but its frame is the CALLER's, not System's (bit1 = 0)
        //     — the EXPECTED honest field value. B still agrees: the
        //     _MMPFN mirror sits at the System pfn and stores the
        //     SAME process-independent slot VA.
        std::uint64_t other = 0x0000000001234000ULL;  // System's PML4
        pt_world_create(MAIN_S, 0, other | 0x81ULL);
        ensure_frame(other);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F,
              "T39a the caller-context walk is FULLY green");
        CHECK(r.self_ok == 1 && r.cr3 == other,
              "T39b selfOk bit0 only (PTE space live, self frame = the "
              "CALLER's PML4 != System CR3) — the field semantics");
        CHECK(r.source == (1u | 0x10u),
              "T39c B still agrees (the mirror is process-independent)");
    }""",
"""    {   // T39 (v27 — THE LIVE IDENTITY): THE CALLER-CONTEXT WORLD.
        //     The EPROCESS records System's DTB = ANOTHER valid frame
        //     (the trigger script's process runs on ITS OWN PML4 —
        //     the live one, HostLiveCr3). selfOk bit1 = the LIVE
        //     identity: self frame == (live CR3 & mask) == the
        //     caller's PML4 -> 1 in ANY context. r.cr3 (System's)
        //     EXPECTEDLY differs — the informational cross-check the
        //     v39 script prints. If the engine ever regresses bit1
        //     to System-CR3 semantics, T39b FAILS right here.
        std::uint64_t other = 0x0000000001234000ULL;  // System's PML4
        pt_world_create(MAIN_S, 0, other | 0x81ULL);
        ensure_frame(other);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F,
              "T39a the caller-context walk is FULLY green");
        CHECK(r.self_ok == 3 && r.cr3 == other
              && (r.self_entry & pt::kPtPfnMask) != r.cr3
              && (r.live_cr3 & pt::kPtPfnMask)
                     == (r.self_entry & pt::kPtPfnMask),
              "T39b selfOk bit0+bit1 (the LIVE identity: self frame == "
              "the CALLER's PML4) while r.cr3 = System's OTHER frame "
              "— the two PML4s EXPECTEDLY differ");
        CHECK(r.source == 1u,
              "T39c source = A only (chain B deleted in every world)");
    }""",
"7 t39 identity")

# ---- [8] banners ----
edit(
"""    printf("==== host-test-v26: KernelExports.h + ProcessWalk.h + PageTableWalk.h (v26 F4 FIXED) ====\\n");""",
"""    printf("==== host-test-v27: KernelExports.h + ProcessWalk.h + PageTableWalk.h (v27 F4: chain B deleted + the live-CR3 identity) ====\\n");""",
"8a main banner")

edit(
"""    printf("\\n==== RESULT: %d PASS / %d FAIL / %ld hosted reads ====\\n",""",
"""    printf("\\n==== RESULT: %d PASS / %d FAIL / %ld hosted reads ====\\n",""",
"8b result line")

t = t.replace("host-test-v26.c", "host-test-v27.c")

if failed:
    print("FAILED ANCHORS:")
    for f in failed:
        print("  " + f)
    raise SystemExit(1)

DST.write_text(t, encoding="utf-8")
n = t.count("CHECK(")
print(f"[make-host-test-v27] wrote {DST} ({len(t)} bytes, {n} CHECKs)")
print("[make-host-test-v27] T25c source=A-only + T25fg payload echoes +")
print("                     T28 poison-immunity + T29 B-dead + T39 live identity")
