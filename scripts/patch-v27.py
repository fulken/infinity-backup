#!/usr/bin/env python3
# ============================================================================
# patch-v27.py — v26 -> v27 driver source transformation
#
# F4 ATTEMPT 6 (the walk itself). The v38 field run captured + echo-verified
# the ALMOSTRO ground truth; the offline analysis (Task 41,
# analyze-v38-almostro.py) PINNED the F4 constants:
#   - MmPteBase slot RVA 0xCFB358, live value 0xFFFFE20000000000 (s=0x1C4),
#     dump == live == pte-space-shaped. CHAIN A VINDICATED.
#   - ALL FIVE researched MmPfnDatabase RVAs WRONG for this build
#     (3 dead + 2 poison: 0xCFC500/0xCFC510 are pte-space/module-base
#     poison whose raw deref is EXACTLY the fingerprint of both F4-era
#     BSODs). CHAIN B IS UNRECOVERABLE BY RVA GUESSING — AND UNNECESSARY.
#
# v27 changes (surgical, wire-compatible except ONE additive extension):
#
#   1. CHAIN B DELETED (the BSOD class ceases to exist at the binary
#      level): PfnBootstrap, the kS2PfnDbRvas table, the _MMPFN stride
#      constants, and the A/B agreement logic are REMOVED. op-12 now
#      trusts chain A alone (the field-pinned 0xCFB358 slot + the
#      512-value structural shape check, ~2^-55 against garbage).
#
#   2. [PT] TRACES BEFORE ANY READ (the v33 death record had ZERO [PT]
#      lines because v25/v26 traced only AFTER pt::Translate returned):
#      every gated PTE-space read (PtRd64) now emits 'PT rd <addr>' on
#      serial BEFORE the volatile deref. If the VM ever dies inside the
#      walk again, the LAST [PT] line names the exact killer read.
#
#   3. THE SELF-ENTRY GROUND TRUTH (the Task-41 D5 design, CORRECTED
#      for the caller context): op-12 captures the LIVE CR3 register
#      (UEFIBridge::ReadCr3 — the caller's page tables, whatever they
#      are: PowerShell's kernel PML4, KPTI kernel CR3, or System) and
#      reports it + the raw self-ref entry in the ADDITIVE payload tail
#      (80B -> 96B: liveCr3@80, selfEntry@88; every existing field
#      untouched — the v25 op-11 additive pattern).
#      selfOk bit1 REDEFINED to the LIVE IDENTITY: bit1 = self-ref
#      frame == (live CR3 & pfnMask). The self-map ALWAYS maps the
#      CURRENT PML4, so bit1 = 1 is now the EXPECTED value in ANY
#      caller context — the read and the register are two independent
#      derivations of the same PML4; their agreement PROVES the level
#      formulas + the base with zero extra assumptions. (v26's bit1
#      compared against the System DTB and expected 0 from a user
#      caller — that comparison moves to the script as an
#      informational line; the System DTB stays in cr3@16.)
#
#   4. Banners v26 -> v27 (main.c, RuntimeHook.h, headers).
#
# Wire contract: op-11 payload + status codes UNTOUCHED; op-12 fields
# 0..79 byte-identical semantics; op-12 payload SIZE grows 80 -> 96B
# (additive tail only — old parsers keep working, v39 reads the tail).
#
# usage: patch-v27.py <v26-tree>
# ============================================================================
import pathlib
import shutil
import sys

if len(sys.argv) != 2:
    print("usage: patch-v27.py <v26-tree>")
    sys.exit(1)

TREE = pathlib.Path(sys.argv[1])
INC = TREE / "UEFI" / "include"
SRC = TREE / "UEFI" / "src"

edits_applied = []
failed = []


def edit(path, old, new, name, count=1):
    """Anchored replace; fails loudly if the anchor moved."""
    p = pathlib.Path(path)
    t = p.read_text()
    n = t.count(old)
    if n != count:
        failed.append(f"[{name}] anchor x{n} (want {count}) in {p.name}")
        return
    p.write_text(t.replace(old, new, count))
    edits_applied.append(name)


def replace_asset(src, dst, name):
    """Copy a NEW/REPLACED asset next to the tree."""
    shutil.copyfile(pathlib.Path(src), pathlib.Path(dst))
    edits_applied.append(name + " (asset)")


# ============================================================================
# 1. PageTableWalk.h — the engine edits
# ============================================================================
PTW = INC / "PageTableWalk.h"

# --- [E1] file header: v26 -> v27 story -----------------------------------
edit(PTW,
""" * PageTableWalk.h  (UEFI side — v26 / F4, the formula fix)
 * =================================================================
 * VA -> page-table translation + residency validation. The walk""",
""" * PageTableWalk.h  (UEFI side — v27 / F4, chain B deleted)
 * =================================================================
 * VA -> page-table translation + residency validation. The walk""",
"E1a header title")

edit(PTW,
""" * PTE_BASE DISCOVERY — TWO INDEPENDENT CHAINS, ORDERED SO A BAD
 * LAYOUT CAN NEVER FAULT (the ordering IS the safety property):
 *
 *   A (first, in-image only): nt!MmPteBase — a u64 .data global""",
""" * PTE_BASE DISCOVERY — v27: CHAIN A ALONE (chain B DELETED).
 * The v38 field run + the offline ALMOSTRO analysis (Task 41) closed
 * the question: chain A's slot 0xCFB358 is PINNED (dump == live ==
 * pte-space-shaped on the real 19045), and ALL FIVE researched
 * MmPfnDatabase RVAs are WRONG for this build — 3 dead slots + 2
 * poison values whose raw deref is EXACTLY the fingerprint of both
 * F4-era BSODs (0x50, pdb + pfn*0x30 + 8). Chain B was the only
 * consumer of those RVAs; deleting it deletes the entire BSOD class
 * from the binary. Chain A needs no second opinion:
 *
 *   A (in-image only): nt!MmPteBase — a u64 .data global""",
"E1b chain A intro")

edit(PTW,
""" *     passing this shape is ~2^-55. **No out-of-image read happens
 *     until A passes** — a drifted build refuses CLEANLY here.
 *
 *   B (only after A passes): the PFN-DB bootstrap — derive the
 *     base from the page tables themselves:
 *       nt!MmPfnDatabase (a pointer .data global; 5 RVAs observed:
 *       0xCFC508 x11, 0xCFC500 x3, 0xCFC510 x3, 0xCFB500, 0xCFB508)
 *       -> System CR3 (EPROCESS+0x28 _KPROCESS.DirectoryTableBase —
 *          4 verified sources; PCID bits masked)
 *       -> pfn = CR3 >> 12
 *       -> _MMPFN[pfn] (stride 0x30, PteAddress @ +0x8 — verified
 *          against the real 19045 PDB) . PteAddress
 *       -> s = (PteAddress >> 3) & 0x1FF; base = 0xFFFF...| (s<<39)
 *       -> IDENTITY: PteAddress == PXE_BASE(s) + s*8 (bits 63:48
 *          all 1, five 9-bit fields all == s, bits 2:0 == 0 — a
 *          ~1/2^55 shape; v25 compared against the WRONG slot
 *          PTE_BASE + s*8, so B always "missed" harmlessly)
 *     A and B must AGREE (both true => same base; disagreement =>
 *     kPtNoBase refusal, VM alive). B-miss (a 6th unseen RVA) is
 *     tolerated — A's shape check stands alone as the gate.
 *
 *   THE PROOF STRUCTURE (v26, corrected): A and B are two
 *     INDEPENDENT derivations of the base — the kernel's own .data
 *     global vs. the PFN-database metadata of the System PML4 —
 *     and they must agree (source bit4). The first PTE-space read
 *     (the self-ref slot at PXE_BASE + s*8) then proves the space
 *     is LIVE: present entry, sane frame (selfOk bit0). v25's
 *     claim "PML4E[s].frame == System CR3.frame" is CORRECTED to
 *     selfOk bit1: PML4E[s] read in the CURRENT page-table context
 *     points at the CURRENT PML4 — the CALLER's, not System's.
 *     The trigger script's caller is a user process (PowerShell),
 *     so bit1 = 0 is the EXPECTED honest field value; bit1 = 1
 *     only when the caller context itself is the System process.
 *     The op-11/op-12 CR3 cross-check (both derive the System DTB
 *     through the proven EPROCESS chain) is unaffected.
 *""",
""" *     passing this shape is ~2^-55. **No out-of-image read happens
 *     until A passes** — a drifted build refuses CLEANLY here.
 *
 *   THE PROOF STRUCTURE (v27 — the self-entry ground truth): the
 *     first PTE-space read (the self-ref slot at PXE_BASE + s*8)
 *     proves the space is LIVE (present entry, sane frame — selfOk
 *     bit0). THE GROUND TRUTH: the self-map ALWAYS maps the CURRENT
 *     page tables, so PML4E[s].frame must equal the LIVE CR3
 *     register's frame (captured at op-12 time, in THIS caller
 *     context) — selfOk bit1. The read and the register are two
 *     INDEPENDENT derivations of the same PML4 (one through the
 *     translated self-map slot, one straight from the hardware
 *     register); their agreement proves the level-base formulas
 *     AND the base value with ZERO extra assumptions. bit1 = 1 is
 *     the EXPECTED value in ANY caller context (user process with
 *     or without KPTI, or System). The System DTB (cr3@16, via the
 *     proven EPROCESS chain) stays in the payload as the
 *     informational cross-check: from a user-process caller it is
 *     EXPECTED to differ from the self frame (a different PML4);
 *     the v39 script reports both honestly.
 *
 *   [PT] TRACES BEFORE ANY READ (v27): every gated PTE-space read
 *     emits 'PT rd <addr>' on serial BEFORE the volatile deref
 *     (v25/v26 traced only AFTER the engine returned — the v33
 *     death record had ZERO [PT] lines). If the walk ever kills
 *     the VM again, the LAST [PT] line names the killer read.
 *""",
"E1c proof structure")

# --- [E2] constants: delete the chain-B table + stride --------------------
edit(PTW,
"""    enum : u32 {
        kPtMaxReads     = 128,    // PTE/pool gated-read budget per op-12
        kPtS1RvaCount   = 2,      // nt!MmPteBase candidates
        kPtS2RvaCount   = 5,      // nt!MmPfnDatabase candidates
    };""",
"""    enum : u32 {
        kPtMaxReads     = 128,    // PTE/pool gated-read budget per op-12
        kPtS1RvaCount   = 2,      // nt!MmPteBase candidates
    };""",
"E2a enum")

edit(PTW,
"""        kPtPresentBit   = 1ULL,
        kPtLargeBit     = (1ULL << 7),
        kPtPteSpaceSize = 0x8000000000ULL,         // 2^39 (512 GB)
        kPtMmPfnStride  = 0x30,                    // sizeof(_MMPFN)
        kPtMmPfnPteOfs  = 0x8,                     // .PteAddress
        kPtEprocPidOfs  = 0x440,                   // == pw (validated live)""",
"""        kPtPresentBit   = 1ULL,
        kPtLargeBit     = (1ULL << 7),
        kPtPteSpaceSize = 0x8000000000ULL,         // 2^39 (512 GB)
        kPtEprocPidOfs  = 0x440,                   // == pw (validated live)""",
"E2b stride consts")

edit(PTW,
"""    // nt!MmPfnDatabase observed RVAs (11 x 0xCFC508, 3 x 0xCFC500,
    // 3 x 0xCFC510, 1 x 0xCFB500, 1 x 0xCFB508).
    static const u32 kS2PfnDbRvas[kPtS2RvaCount] = {
        0xCFC508, 0xCFC500, 0xCFC510, 0xCFB500, 0xCFB508,
    };
""",
"""    // (v27: the nt!MmPfnDatabase candidate table is DELETED — the
    //  v38 field analysis proved all five RVAs wrong for this build:
    //  3 dead + 2 poison whose deref fingerprinted BOTH F4-era BSODs.
    //  Chain B no longer exists; chain A's pinned slot + the 512-value
    //  structural check carry op-12 alone.)
""",
"E2c pfn table deleted")

# --- [E3] Result struct: additive tail + bit1 semantics --------------------
edit(PTW,
"""        u32 source;          // bit0-1: A candidate (1/2); bit4: B agreed;
                             // bit5: B missed (unseen RVA world)
        u32 self_ok;         // bit0 = the PTE space is LIVE (the
                             // self-ref slot read succeeded, the entry
                             // is present, its frame is sane); bit1 =
                             // self-ref frame == System CR3 frame (1
                             // only in a System-context caller — see
                             // the header's proof structure)
        u32 reads;           // gated PTE/pool reads used
    };""",
"""        u32 source;          // bit0-1: A candidate (1/2). v27: bits 4/5
                             // are DEAD (chain B deleted; always 0)
        u32 self_ok;         // bit0 = the PTE space is LIVE (the
                             // self-ref slot read succeeded, the entry
                             // is present, its frame is sane); bit1 =
                             // self-ref frame == LIVE CR3 frame (the
                             // register captured in THIS caller context
                             // — the identity that proves the formulas;
                             // 1 is the expected value in ANY context)
        u32 reads;           // gated PTE/pool reads used
        u64 live_cr3;        // v27 additive @80: the CR3 register at
                             // op-12 time (raw, PCID bits included)
        u64 self_entry;      // v27 additive @88: the raw PML4E[s] qword
    };""",
"E3 result tail")

# --- [E4] PtRd64: the [PT]-before-read trace -------------------------------
edit(PTW,
"""    static inline bool PtRd64(Walk* w, u64 addr, u64* out) {
        if (addr - w->base >= kPtPteSpaceSize) return false;
        if (addr & 7) return false;
        if (w->reads >= kPtMaxReads) return false;
        w->reads++;
        *out = PT_R64(addr);
        return true;
    }""",
"""    static inline bool PtRd64(Walk* w, u64 addr, u64* out) {
        if (addr - w->base >= kPtPteSpaceSize) return false;
        if (addr & 7) return false;
        if (w->reads >= kPtMaxReads) return false;
#ifndef KERNEL_PT_HOST_TEST
        // v27: trace BEFORE the deref — if the VM dies on this read,
        // this serial line names the killer (the v33 death record had
        // zero [PT] lines because v25/v26 traced only after return).
        SerialTrace::KV("PT", "rd ", addr);
#endif
        w->reads++;
        *out = PT_R64(addr);
        return true;
    }

    // ================= live CR3 (the ground truth) ==============
    // The CR3 register AT WALK TIME, in the CURRENT caller context.
    // The self-map maps the CURRENT page tables, so PML4E[s].frame
    // must equal (LiveCr3() & kPtPfnMask) — the identity that proves
    // the level formulas + the base with zero extra assumptions
    // (Task-41 D5, corrected for the caller context).
#ifdef KERNEL_PT_HOST_TEST
    u64 HostLiveCr3();                  // provided by the host test
    static inline u64 LiveCr3() { return HostLiveCr3(); }
#else
    static inline u64 LiveCr3() {
        u64 c;
        __asm__ __volatile__("mov %%cr3, %0" : "=r"(c));
        return c;
    }
#endif""",
"E4 ptrd64 trace + livecr3")

# --- [E5] SerialTrace include (driver build only) ---------------------------
edit(PTW,
"""#include "KernelExports.h"    // kx::Resolve / kx::Rd32 (chain A + gates)
#include "ProcessWalk.h"      // pw::SysEprocessFromSymbol (the proven
                              // v24 resolve->deref chain for the CR3)
""",
"""#include "KernelExports.h"    // kx::Resolve / kx::Rd32 (chain A + gates)
#include "ProcessWalk.h"      // pw::SysEprocessFromSymbol (the proven
                              // v24 resolve->deref chain for the CR3)
#ifndef KERNEL_PT_HOST_TEST
#include "SerialTrace.h"      // the [PT]-before-read traces (v27)
#endif
""",
"E5 serial include")

# --- [E6] chain B function DELETED -----------------------------------------
edit(PTW,
"""    // ================= chain B: the PFN bootstrap ================
    // Returns 0 = miss, 1 = derived (out_base), 2 = derived but
    // DISAGREES with A (caller must refuse). Only called AFTER A
    // passed (the ordering that keeps drifted builds fault-free).
    static inline u32 PfnBootstrap(kx::Ctx* c, u64 cr3_raw,
                                   u32* reads, u64* out_base) {
        if (!cr3_raw) return 0;                 // no CR3 anchor
        u64 cr3 = cr3_raw & kPtPfnMask;
        u64 pfn = cr3 >> 12;
        if (pfn == 0 || pfn >= 0x200000) return 0;   // 8 GB sanity
        for (u32 i = 0; i < kPtS2RvaCount; i++) {
            u64 pdb = 0;
            if (!ReadImage64(c, kS2PfnDbRvas[i], &pdb)) continue;
            if (pdb < kPtMinKernel) continue;         // canonical
            if (pdb & 0xFFF) continue;                // page-aligned
            u64 slot = pdb + pfn * kPtMmPfnStride + kPtMmPfnPteOfs;
            if (slot < pdb || slot >= pdb + 0x6000000ULL) continue;
            if (*reads >= kPtMaxReads) return 0;
            (*reads)++;
            u64 pte_addr = PT_R64(slot);   // the ONE out-of-image read
            u32 s = (u32)((pte_addr >> 3) & 0x1FF);
            u64 base = 0xFFFF000000000000ULL | ((u64)s << 39);
            // v26 identity: the PML4's own PTE slot is the self-ref
            // entry's address, PXE_BASE + s*8 (== what a real OS
            // stores in _MMPFN[CR3>>12].PteAddress). v25 compared
            // against PTE_BASE + s*8 — a low-user PTE slot — so B
            // could never agree in the field.
            if (pte_addr != PxeBaseOf(base, s) + ((u64)s * 8))
                continue;                              // identity
            if (out_base) *out_base = base;
            return 1;
        }
        return 0;
    }
""",
"""    // (v27: chain B — the PFN bootstrap — is DELETED. It was the
    //  only code that dereferenced a value read from the researched
    //  MmPfnDatabase RVAs, and the v38 field analysis proved all five
    //  RVAs wrong for this build (3 dead, 2 poison — the poison class
    //  whose deref fingerprinted BOTH F4-era BSODs as 0x50 with arg1
    //  == pdb + pfn*0x30 + 8). No consumer of kS2PfnDbRvas remains;
    //  the entire class is gone from the binary.)
""",
"E6 pfnbootstrap deleted")

# --- [E7] Translate: B call gone, live_cr3 + self_entry + bit1 ------------
edit(PTW,
"""        if (!a_cand) { r.status = kPtNoBase; return r; }
        // (from here the .data layout MATCHES our PDB set — the
        //  only world in which B's out-of-image read may happen)

        // ---- the System CR3 (the proven eproc chain) ----
        u64 sym = 0, eproc = 0, dtb_raw = 0;
        if (SysEprocessCr3(c, &sym, &eproc, &dtb_raw, &reads))
            r.cr3 = dtb_raw & kPtPfnMask;

        // ---- chain B: the PFN bootstrap (after A) ----
        u64 pte_b = 0;
        u32 b = PfnBootstrap(c, dtb_raw, &reads, &pte_b);
        if (b == 1 && pte_b != pte_a) {
            // two independent worlds disagree — refuse, VM alive
            r.reads = reads; r.status = kPtNoBase; return r;
        }

        r.pte_base = pte_a;
        r.self_idx = s;
        r.source = a_cand | (b == 1 ? 0x10 : 0x20);
""",
"""        if (!a_cand) { r.status = kPtNoBase; return r; }

        // ---- the System CR3 (the proven eproc chain; the
        //      informational cross-check — NOT a gate anymore) ----
        u64 sym = 0, eproc = 0, dtb_raw = 0;
        if (SysEprocessCr3(c, &sym, &eproc, &dtb_raw, &reads))
            r.cr3 = dtb_raw & kPtPfnMask;

        // ---- v27: the LIVE CR3 (the ground truth) — captured in
        //      THIS caller context, before any PTE-space read ----
        u64 live = LiveCr3();
        r.live_cr3 = live;

        r.pte_base = pte_a;
        r.self_idx = s;
        r.source = a_cand;    // v27: bits 4/5 dead (chain B deleted)
""",
"E7 translate chainA only")

edit(PTW,
"""        Walk w{pte_a, reads};
        u64 self_entry = 0;
        if (!PtRd64(&w, PxeBaseOf(pte_a, s) + (u64)s * 8, &self_entry)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        u64 self_frame = self_entry & kPtPfnMask;
        if (self_entry & kPtPresentBit) {
            if (self_frame != 0 && self_frame < kPtMaxPhysFrame)
                r.self_ok |= 1;           // the PTE space is LIVE
        }
        if (r.cr3 && self_frame == r.cr3)
            r.self_ok |= 2;   // only true in a System-context caller
""",
"""        Walk w{pte_a, reads};
        u64 self_entry = 0;
        if (!PtRd64(&w, PxeBaseOf(pte_a, s) + (u64)s * 8, &self_entry)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        r.self_entry = self_entry;   // v27: raw, for the payload tail
        u64 self_frame = self_entry & kPtPfnMask;
        if (self_entry & kPtPresentBit) {
            if (self_frame != 0 && self_frame < kPtMaxPhysFrame)
                r.self_ok |= 1;           // the PTE space is LIVE
        }
        // v27 THE IDENTITY: the self-map maps the CURRENT page tables,
        // so the self-ref frame == the LIVE CR3 frame — in ANY caller
        // context. Read + register: two independent derivations of the
        // same PML4. (The System-DTB comparison lives in the script;
        // from a user caller it EXPECTEDLY differs — different PML4.)
        if (self_frame == (live & kPtPfnMask))
            r.self_ok |= 2;
""",
"E8 self-entry identity")

# ============================================================================
# 2. RequestHandler.h — op-12 comment + payload tail + traces
# ============================================================================
RH = INC / "RequestHandler.h"

edit(RH,
"""            case 12 /* ReqOp_TranslateVa — v26 F4: VA -> page-table
                    walk through the self-map (v26: the level-base
                    formula fix — see PageTableWalk.h's header; NO
                    CR3 switching —
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
                    selfOk@72 (bit0 = the PTE space is LIVE:
                    the self-ref slot read succeeded, the entry is
                    present, its frame is sane; bit1 = the self-ref
                    frame == the System CR3 frame — set only in a
                    System-context caller, 0 is the EXPECTED value
                    in the trigger script's caller process; v26
                    semantics, the v25 == CR3 claim corrected),
                    reads@76. Status:
                    1 ok / 1 with rc=4 (not present — a clean
                    answer) / 7 no-base / 5 bad args / 4 refused. */: {""",
"""            case 12 /* ReqOp_TranslateVa — v27 F4: VA -> page-table
                    walk through the self-map (v26: the level-base
                    formula fix; v27: chain B DELETED — the v38 field
                    analysis proved all 5 MmPfnDatabase RVAs wrong
                    (3 dead + 2 poison, the BSOD fingerprint class);
                    NO CR3 switching — the v17/v19 lesson; NO
                    physical reads; NO kernel calls; [PT] serial
                    traces fire BEFORE every PTE-space read — the
                    last line names any killer). req->address = the
                    target kernel VA (canonical upper half only;
                    user-range and non-canonical -> kPtBadArgs).
                    data_size ignored. PTE_BASE discovery: chain A =
                    nt!MmPteBase (.data, RVA candidates from 19 real
                    19041/19045 PDBs; slot 0xCFB358 FIELD-PINNED by
                    the v38 ALMOSTRO dump) with the 512-value
                    structural check — A gates ALL PTE-space reads.
                    Payload 96B: rc@0 (1 ok / 2 no-base / 4
                    not-present / 5 bad args / 6 refused), selfIdx@4
                    (the self-map PML4 index s), pteBase@8, cr3@16
                    (System DTB, EPROCESS+0x28, PCID-masked; 0 = the
                    eproc chain refused — reported, not fatal),
                    pml4e@24, pdpte@32, pde@40, pte@48 (raw entries;
                    0 = the walk stopped above that level), frame@56
                    (phys page base of the translation), presentMask@
                    64 (bit0..3 = level present, bit4 = large page),
                    source@68 (bit0-1 = MmPteBase candidate; v27:
                    bits 4/5 dead — chain B deleted, always 0),
                    selfOk@72 (bit0 = the PTE space is LIVE: the
                    self-ref slot read succeeded, the entry is
                    present, its frame is sane; bit1 = THE IDENTITY:
                    self-ref frame == the LIVE CR3 frame captured in
                    THIS caller context — 1 is the EXPECTED value in
                    ANY context, the read + the register prove the
                    formulas together), reads@76, liveCr3@80 (v27
                    additive: the CR3 register at op-12 time, raw),
                    selfEntry@88 (v27 additive: the raw PML4E[s]
                    qword). Status:
                    1 ok / 1 with rc=4 (not present — a clean
                    answer) / 7 no-base / 5 bad args / 4 refused. */: {""",
"R1 op12 comment")

edit(RH,
"""                SerialTrace::KV("PT", "va", target);
                SerialTrace::KV("PT", "ptebase", tr.pte_base);
                SerialTrace::KVD("PT", "self", tr.self_idx);
                SerialTrace::KVD("PT", "mask", tr.present_mask);
                SerialTrace::KV("PT", "frame", tr.frame);
                SerialTrace::KVD("PT", "selfok", tr.self_ok);
""",
"""                SerialTrace::KV("PT", "va", target);
                SerialTrace::KV("PT", "ptebase", tr.pte_base);
                SerialTrace::KVD("PT", "self", tr.self_idx);
                SerialTrace::KVD("PT", "mask", tr.present_mask);
                SerialTrace::KV("PT", "frame", tr.frame);
                SerialTrace::KVD("PT", "selfok", tr.self_ok);
                SerialTrace::KV("PT", "cr3live", tr.live_cr3);
                SerialTrace::KV("PT", "selfent", tr.self_entry);
""",
"R2 pt traces")

edit(RH,
"""                // ---- 80-byte payload ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 80; i++) p[i] = 0;""",
"""                // ---- 96-byte payload (v27: +liveCr3@80,
                //      +selfEntry@88 — additive tail, fields 0..79
                //      byte-identical to the v26 contract) ----
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 96; i++) p[i] = 0;""",
"R3 payload size")

edit(RH,
"""                put32(72, tr.self_ok);
                put32(76, tr.reads);
                resp->bytes_transferred = 80;
                *data_size = 80;
                if (tr.status == pt::kPtOk ||""",
"""                put32(72, tr.self_ok);
                put32(76, tr.reads);
                put64(80, tr.live_cr3);
                put64(88, tr.self_entry);
                resp->bytes_transferred = 96;
                *data_size = 96;
                if (tr.status == pt::kPtOk ||""",
"R4 payload tail")

# ============================================================================
# 3. main.c + RuntimeHook.h banners
# ============================================================================
MC = SRC / "main.c"
edit(MC,
'    static const char kBuildLine[] = "  Build: v26 RT - anchors + exports + process walk + page tables";',
'    static const char kBuildLine[] = "  Build: v27 RT - anchors + exports + walk + pte-space (chain A)";',
"M1 rt buildline")

edit(MC,
'    static const char kBuildLine[] = "  Build: v26 SAFE (phase F4)";',
'    static const char kBuildLine[] = "  Build: v27 SAFE (phase F4)";',
"M2 safe buildline")

edit(MC,
'        Print((CHAR16*)L"  Build: v26 RT - anchors + exports + process walk (F4)   \\r\\n");',
'        Print((CHAR16*)L"  Build: v27 RT - anchors + walk + pte-space (F4)          \\r\\n");',
"M3 rt screen")

edit(MC,
'        Print((CHAR16*)L"  Build: v26 SAFE (phase F4)                               \\r\\n");',
'        Print((CHAR16*)L"  Build: v27 SAFE (phase F4)                               \\r\\n");',
"M4 safe screen")

edit(MC,
'    SerialTrace::Line("MAIN", "efi_main v26 boot");',
'    SerialTrace::Line("MAIN", "efi_main v27 boot");',
"M5 boot trace")

edit(MC,
'    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v26)");',
'    SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v27)");',
"M6 variant trace")

RTH = INC / "RuntimeHook.h"
edit(RTH,
'            SerialTrace::Line("RT-EARLY", "memory.efi v26 RT (kernel data path: direct reads + export resolution + process walk + page tables)");',
'            SerialTrace::Line("RT-EARLY", "memory.efi v27 RT (kernel data path: direct reads + exports + walk + pte-space chain A)");',
"H1 rt-early")

edit(RTH,
'                SerialTrace::Line("RT-VA", "hooks already installed at load (v26 early) - keeping slots");',
'                SerialTrace::Line("RT-VA", "hooks already installed at load (v27 early) - keeping slots");',
"H2 rt-va")

# ============================================================================
# report + sanity
# ============================================================================
print()
if failed:
    print("FAILED ANCHORS:")
    for f in failed:
        print("  " + f)
    sys.exit(1)

print("[patch-v27] ALL EDITS APPLIED - tree is now v27")
print("[patch-v27] changed: PageTableWalk.h, RequestHandler.h, main.c,")
print("            RuntimeHook.h")
print("[patch-v27] deleted: chain B (PfnBootstrap + kS2PfnDbRvas + the")
print("            _MMPFN constants) - the BSOD class is gone from the binary")
print("[patch-v27] added:   [PT]-before-read traces, LiveCr3() capture,")
print("            selfOk bit1 = the LIVE identity, payload 96B (additive)")
print("[patch-v27] wire:    op-11 untouched; op-12 fields 0..79 identical;")
print("            payload tail 80->96B additive; status codes unchanged")

# sanity: chain B is REALLY gone, chain A intact, new pieces present
t = PTW.read_text()
checks = [
    ("PfnBootstrap gone", "PfnBootstrap" not in t),
    ("kS2PfnDbRvas decl gone", "static const u32 kS2PfnDbRvas" not in t),
    ("kS2PfnDbRvas use gone", "kS2PfnDbRvas[" not in t),
    ("kPtMmPfnStride gone", "kPtMmPfnStride" not in t),
    ("kPtS2RvaCount gone", "kPtS2RvaCount" not in t),
    ("chain A slot kept", "0xCFB358, 0xCFA358" in t),
    ("ValidPteBase kept", "ValidPteBase" in t),
    ("level bases kept", "PxeBaseOf(u64 pte_base, u32 s)" in t),
    ("LiveCr3 added", "LiveCr3" in t),
    ("PT trace added", 'SerialTrace::KV("PT", "rd ", addr)' in t),
    ("identity added", "live & kPtPfnMask" in t),
    ("self_entry stored", "r.self_entry = self_entry;" in t),
    ("budget kept", "kPtMaxReads" in t),
]
bad = [n for n, ok in checks if not ok]
if bad:
    print("SANITY FAIL: " + ", ".join(bad))
    sys.exit(1)
print("[patch-v27] sanity: 12/12 structural checks PASS")

rt = RH.read_text()
checks2 = [
    ("payload 96", "i < 96; i++" in rt),
    ("liveCr3 put", "put64(80, tr.live_cr3)" in rt),
    ("selfEntry put", "put64(88, tr.self_entry)" in rt),
    ("96 transferred", "bytes_transferred = 96" in rt),
    ("op-11 dtb echo kept", "put64(1056, eproc_dtb & pt::kPtPfnMask)" in rt),
    ("cr3live trace", 'KV("PT", "cr3live"' in rt),
    ("op12 case kept", "case 12" in rt),
]
bad2 = [n for n, ok in checks2 if not ok]
if bad2:
    print("REQUESTHANDLER SANITY FAIL: " + ", ".join(bad2))
    sys.exit(1)
print("[patch-v27] sanity: 7/7 RequestHandler checks PASS")

m = MC.read_text()
if "v27" not in m or "v26 RT" in m:
    print("MAIN.C BANNER FAIL")
    sys.exit(1)
h = RTH.read_text()
if "v27" not in h or "v26 RT" in h:
    print("RUNTIMEHOOK BANNER FAIL")
    sys.exit(1)
print("[patch-v27] sanity: banners v26 -> v27 clean in main.c + RuntimeHook.h")
