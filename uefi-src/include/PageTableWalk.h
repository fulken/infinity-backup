/**
 * PageTableWalk.h  (UEFI side — v27 / F4, chain B deleted)
 * =================================================================
 * VA -> page-table translation + residency validation. The walk
 * reads the page tables THEMSELVES through their self-map: no CR3
 * switching (the v17/v19 lesson: under Windows, switching to the
 * boot-time firmware tables kills the VM), no physical reads, no
 * kernel calls. Every read is either an in-image gated kx::Rd32
 * (the F1/F2 trust root, field-proven since v28) or a COMPUTED slot
 * inside [pte_base, pte_base + 2^39) — the self-map window the OS
 * itself maps.
 *
 * THE SELF-MAP (x64, v26 — THE CORRECTED LAYOUT). The PML4 contains
 * one entry PML4E[s] that points at the PML4 itself ("self-reference
 * entry"; 0x1ED static on Win7, RANDOMIZED per boot since 1607).
 * Through it the page tables are visible at FOUR level bases built
 * from PTE_BASE = 0xFFFF000000000000 | (s << 39):
 *   PTE_BASE  = 0xFFFF000000000000 | (s << 39)   (PTE slots)
 *   PDE_BASE  = PTE_BASE + (s << 30)             (PDE slots)
 *   PPE_BASE  = PDE_BASE + (s << 21)             (PDPTE slots)
 *   PXE_BASE  = PPE_BASE + (s << 12)             (PML4E slots)
 *   PML4E(V)  @ PXE_BASE + ((V >> 39) & 0x1FF) * 8
 *   PDPTE(V)  @ PPE_BASE + ((V >> 30) & 0x3FFFF) * 8
 *   PDE(V)    @ PDE_BASE + ((V >> 21) & 0x7FFFFFF) * 8
 *   PTE(V)    @ PTE_BASE + vpn * 8      (vpn = V >> 12, 36-bit —
 *                                       MiGetPteAddress, unchanged)
 * GROUND TRUTH (classic pre-1607, s = 0x1ED — published constants):
 *   PTE_BASE  0xFFFFF68000000000
 *   PDE_BASE  0xFFFFF6FB40000000
 *   PPE_BASE  0xFFFFF6FB7DA00000
 *   PXE_BASE  0xFFFFF6FB7DBED000
 * these four formulas reproduce all four values EXACTLY.
 *
 * THE v25 BUG (field 2026-09-28, the first F4-era BSOD — root-caused
 * walk-level in the v33 report entry): v25 addressed the upper three
 * levels as PTE_BASE + shifted-vpn*8 — those are PTE-space slots of
 * LOW-USER VAs (PTE_BASE + i*8 serves the PTE of user VA i*4096, and
 * its own walk descends PML4E[0] of the CURRENT process). In the
 * trigger script's caller context the low-user tree is absent, so the
 * FIRST PTE-space read (the self-ref read at PTE_BASE + s*8) faulted:
 * BSOD 0x50 PAGE_FAULT_IN_NONPAGED_AREA. The v26 formulas above read
 * ONLY slots whose own walk descends the s-self-ref chain plus
 * parents already proven present — inherently fault-free.
 *
 * The PML4's own _MMPFN.PteAddress == PXE_BASE + s*8 (the PTE-space
 * slot of the PML4 page itself IS the self-ref entry's address — the
 * identity that anchors the B-chain below).
 *
 * PTE_BASE DISCOVERY — v27: CHAIN A ALONE (chain B DELETED).
 * The v38 field run + the offline ALMOSTRO analysis (Task 41) closed
 * the question: chain A's slot 0xCFB358 is PINNED (dump == live ==
 * pte-space-shaped on the real 19045), and ALL FIVE researched
 * MmPfnDatabase RVAs are WRONG for this build — 3 dead slots + 2
 * poison values whose raw deref is EXACTLY the fingerprint of both
 * F4-era BSODs (0x50, pdb + pfn*0x30 + 8). Chain B was the only
 * consumer of those RVAs; deleting it deletes the entire BSOD class
 * from the binary. Chain A needs no second opinion:
 *
 *   A (in-image only): nt!MmPteBase — a u64 .data global
 *     holding the live PTE_BASE (the kernel randomizes the index
 *     at boot and caches the base here; MmIsAddressValid and
 *     friends read it). RVAs observed across 19 real 19041/19045
 *     PDBs: 0xCFB358 (17 builds) and 0xCFA358 (2). Every candidate
 *     must pass the STRUCTURAL check — PTE_BASE == 0xFFFF000000000000
 *     | (s << 39) for some s in [0x100,0x1FF]: 512 valid shapes in
 *     the whole 2^64 universe. A drifted RVA reads garbage; garbage
 *     passing this shape is ~2^-55. **No out-of-image read happens
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
 *
 * THE WALK (parent-present descent — inherently fault-safe, and the
 * property SURVIVES the v26 formula fix by construction): every
 * corrected slot address a1/a2/a3/a4 traverses ONLY the s-self-ref
 * chain plus parent entries already proven present —
 *   a1 = PXE_BASE + p4*8        (walks s,s,s,s -> the PML4 page)
 *   a2 = PPE_BASE + (p4<<9|p3)*8 (walks s,s,s -> PML4E[p4] present)
 *   a3 = PDE_BASE + (p4<<18|p3<<9|p2)*8 (s,s -> PML4E[p4], PDPTE[p3]
 *                                    present)
 *   a4 = PTE_BASE + vpn*8       (s -> PML4E[p4], PDPTE[p3], PDE[p2]
 *                                    present)
 * A present parent guarantees the child table page exists, and the
 * self-map maps exactly the existing tables. An absent level stops
 * the walk as a clean not-present answer; no slot below an absent
 * parent is ever touched (host-tested against a TRUE-SEMANTICS
 * world: a real 4-level hierarchy served by an independent hardware
 * walk — see the host-test header).
 *
 * FAIL-CLOSED CONTRACT (the v19/M4 discipline): every refusal is a
 * clean status — kPtNoBase / kPtNotPresent / kPtBadArgs / kPtRefused
 * (budget). No partial trust: a refused translation returns zeroed
 * entries. The VM stays alive.
 *
 * HOST TESTING (v26 — the seam-#5 fix): the v25 synthetic world was
 * built from the SAME wrong slot formulas as the engine, so world
 * and engine shared one self-consistent misconception and 89/89
 * passed while the field VM died. v26's world is a REAL 4-level
 * hierarchy in simulated physical memory; PT_R8 is served by an
 * INDEPENDENT hardware-semantics walk (follow present entries from
 * the PML4; any fault = the out-of-map abort = the BSOD replayed).
 * The PTE space is never mapped by hand — it EMERGES from the
 * self-ref entry. The world is anchored to the PUBLISHED classic
 * s=0x1ED quartet, and the v25 formulas are CLASS-KILLED by the
 * same harness (their first PTE-space read faults exactly like the
 * field).
 * =================================================================
 */
#pragma once

#include <cstdint>
#include <cstddef>

#include "KernelExports.h"    // kx::Resolve / kx::Rd32 (chain A + gates)
#include "ProcessWalk.h"      // pw::SysEprocessFromSymbol (the proven
                              // v24 resolve->deref chain for the CR3)
#ifndef KERNEL_PT_HOST_TEST
#include "SerialTrace.h"      // the [PT]-before-read traces (v27)
#endif

namespace UEFIBridge {
namespace pt {

    typedef std::uint8_t  u8;
    typedef std::uint16_t u16;
    typedef std::uint32_t u32;
    typedef std::uint64_t u64;

    // ================= the ONLY raw access =================
    // (PTE-space slots + the EPROCESS pool fields — the same trust
    //  level as PW_R8; every address reaching it is gated below)
#ifdef KERNEL_PT_HOST_TEST
    u8 PT_R8(u64 va);                  // provided by the host test
#else
    static inline u8 PT_R8(u64 va) {
        return *(volatile u8*)(std::size_t)va;
    }
#endif

    static inline u64 PT_R64(u64 va) {
        u64 v = 0;
        for (u32 i = 0; i < 8; i++)
            v |= (u64)PT_R8(va + i) << (8 * i);
        return v;
    }

    // ================= constants =================
    enum : u32 {
        kPtMaxReads     = 128,    // PTE/pool gated-read budget per op-12
        kPtS1RvaCount   = 2,      // nt!MmPteBase candidates
    };
    enum : u64 {
        kPtMinKernel    = 0xFFFF800000000000ULL,
        kPtPfnMask      = 0x000FFFFFFFFFF000ULL,   // phys-frame mask
        kPtPresentBit   = 1ULL,
        kPtLargeBit     = (1ULL << 7),
        kPtPteSpaceSize = 0x8000000000ULL,         // 2^39 (512 GB)
        kPtEprocPidOfs  = 0x440,                   // == pw (validated live)
        kPtEprocDtbOfs  = 0x28,     // _KPROCESS.DirectoryTableBase
        kPtSysPid       = 4,
        kPtMaxPhysFrame = 0x400000000ULL,          // 16 GB sanity bound
    };
    // nt!MmPteBase observed RVAs (19 real 19041/19045-family PDBs:
    // 17 x 0xCFB358, 2 x 0xCFA358 — see the file header).
    static const u32 kS1PteBaseRvas[kPtS1RvaCount] = {
        0xCFB358, 0xCFA358,
    };
    // (v27: the nt!MmPfnDatabase candidate table is DELETED — the
    //  v38 field analysis proved all five RVAs wrong for this build:
    //  3 dead + 2 poison whose deref fingerprinted BOTH F4-era BSODs.
    //  Chain B no longer exists; chain A's pinned slot + the 512-value
    //  structural check carry op-12 alone.)

    // status codes (op-12 rc)
    enum : u32 {
        kPtOk          = 1,   // translated (all touched levels present)
        kPtNoBase      = 2,   // PTE_BASE discovery failed / disagreed
        kPtNotPresent  = 4,   // clean answer: an intermediate entry
                              // is absent (present_mask says which)
        kPtBadArgs     = 5,   // non-canonical / user-range target /
                              // gate not converged
        kPtRefused     = 6,   // budget / range gate inside the walk
    };

    struct Result {
        u32 status;
        u32 self_idx;        // s (the self-map PML4 index)
        u64 pte_base;
        u64 cr3;             // System DTB (phys, PCID-masked); 0 = the
                             // eproc chain refused (reported, not fatal)
        u64 pml4e, pdpte, pde, pte;   // raw entries; 0 = level not read
        u64 frame;           // phys page base of the translation
        u32 present_mask;    // bit0..3 = level present, bit4 = large
        u32 source;          // bit0-1: A candidate (1/2). v27: bits 4/5
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
    };

    // ============ the self-map level bases (v26 — THE FIX) ======
    // Ground truth (classic pre-1607 s=0x1ED): these formulas give
    // PDE_BASE 0xFFFFF6FB40000000, PPE_BASE 0xFFFFF6FB7DA00000,
    // PXE_BASE 0xFFFFF6FB7DBED000 — the published constants, exact.
    // v25 addressed the upper levels at PTE_BASE + shifted-vpn*8 =
    // low-USER PTE slots -> the first PTE-space read faulted in the
    // field (BSOD 0x50, 2026-09-28). See the file header.
    static inline u64 PdeBaseOf(u64 pte_base, u32 s) {
        return pte_base + ((u64)s << 30);
    }
    static inline u64 PpeBaseOf(u64 pte_base, u32 s) {
        return PdeBaseOf(pte_base, s) + ((u64)s << 21);
    }
    static inline u64 PxeBaseOf(u64 pte_base, u32 s) {
        return PpeBaseOf(pte_base, s) + ((u64)s << 12);
    }

    // ================= in-image 64-bit read (chain A/B input) ==
    // Same trust root as every export read: the F1 validated-image
    // window, through the budgeted kx::Rd32.
    static inline bool ReadImage64(kx::Ctx* c, u32 rva, u64* out) {
        u32 lo = 0, hi = 0;
        if ((u64)rva + 8 > (u64)c->size) return false;
        if (!kx::Rd32(c, rva, &lo))     return false;
        if (!kx::Rd32(c, rva + 4, &hi)) return false;
        *out = (u64)lo | ((u64)hi << 32);
        return true;
    }

    // ================= structural PTE_BASE check ================
    // 512 valid values in the universe: 0xFFFF000000000000|(s<<39),
    // s in [0x100,0x1FF] (upper half so the base is canonical).
    static inline bool ValidPteBase(u64 v, u32* s_out) {
        if (v < kPtMinKernel) return false;
        if (v & 0x0000007FFFFFFFFFULL) return false;   // bits 38:0 == 0
        u32 s = (u32)((v >> 39) & 0x1FF);
        if (s < 0x100) return false;                    // upper half
        if (v != (0xFFFF000000000000ULL | ((u64)s << 39)))
            return false;
        if (s_out) *s_out = s;
        return true;
    }

    // ================= gated PTE-space read =====================
    struct Walk {
        u64 base;      // the agreed PTE_BASE
        u32 reads;
    };
    // WRAP-FREE range gate (the T41 catch): for s = 0x1FF (a valid
    // field value — the top of the randomization universe) the base
    // 0xFFFFFF8000000000 + 2^39 OVERFLOWS u64 to 0, and a naive
    // "addr >= base + size" gate would refuse EVERYTHING. The
    // subtraction form has the same semantics for every non-wrapping
    // base and is exact at the edge (addr < base underflows to a
    // huge unsigned value -> refused, exactly as intended).
    static inline bool PtRd64(Walk* w, u64 addr, u64* out) {
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
#endif

    // ================= EPROCESS -> CR3 =========================
    // Minimal W1-style gates on the already-proven chain output:
    // canonical + pid==4 (the same first-hop validation WalkCore
    // applies), then +0x28 (PCID bits kept, masked by callers).
    static inline bool EprocDtb(u64 eproc, u32* reads, u64* out) {
        if (eproc < kPtMinKernel) return false;
        if (eproc > 0xFFFFFFFFFFFFF000ULL) return false;   // no-wrap
        if (*reads >= kPtMaxReads) return false;
        (*reads)++;
        u64 pid = PT_R64(eproc + kPtEprocPidOfs);
        if (pid != kPtSysPid) return false;
        if (*reads >= kPtMaxReads) return false;
        (*reads)++;
        u64 dtb = PT_R64(eproc + kPtEprocDtbOfs);
        u64 frame = dtb & kPtPfnMask;
        if (frame == 0 || frame >= kPtMaxPhysFrame) return false;
        *out = dtb;                       // raw (PCID bits included)
        return true;
    }

    // resolve -> deref -> EprocDtb (the full v24-proven chain)
    static inline bool SysEprocessCr3(kx::Ctx* c, u64* sym_out,
                                      u64* eproc_out, u64* dtb_out,
                                      u32* reads) {
        u64 sym = 0, eproc = 0;
        if (!pw::SysEprocessFromSymbol(c, "PsInitialSystemProcess", 22,
                                       &sym, &eproc))
            return false;
        u64 dtb = 0;
        if (!EprocDtb(eproc, reads, &dtb)) return false;
        if (sym_out)   *sym_out = sym;
        if (eproc_out) *eproc_out = eproc;
        if (dtb_out)   *dtb_out = dtb;
        return true;
    }

    // (v27: chain B — the PFN bootstrap — is DELETED. It was the
    //  only code that dereferenced a value read from the researched
    //  MmPfnDatabase RVAs, and the v38 field analysis proved all five
    //  RVAs wrong for this build (3 dead, 2 poison — the poison class
    //  whose deref fingerprinted BOTH F4-era BSODs as 0x50 with arg1
    //  == pdb + pfn*0x30 + 8). No consumer of kS2PfnDbRvas remains;
    //  the entire class is gone from the binary.)

    // ================= the op-12 engine =========================
    static inline Result Translate(kx::Ctx* c, u64 va) {
        Result r{};
        r.status = kPtBadArgs;
        u32 reads = 0;

        // ---- target validation: canonical kernel VA only ----
        if (va < kPtMinKernel) return r;
        if ((va >> 47) != 0x1FFFFULL) return r;   // bits 63:47 all 1

        // ---- chain A: MmPteBase candidates (in-image only) ----
        u64 pte_a = 0; u32 a_cand = 0; u32 s = 0;
        for (u32 i = 0; i < kPtS1RvaCount; i++) {
            u64 v = 0;
            if (!ReadImage64(c, kS1PteBaseRvas[i], &v)) continue;
            u32 cand_s = 0;
            if (ValidPteBase(v, &cand_s)) {
                pte_a = v; a_cand = i + 1; s = cand_s;
                break;
            }
        }
        if (!a_cand) { r.status = kPtNoBase; return r; }

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

        // ---- the self-ref entry (PTE space opens HERE, 1 slot) --
        // v26: PML4E[s] lives at PXE_BASE + s*8 — the PTE-space
        // slot of the PML4 page itself. Its own walk descends the
        // s-self-ref chain four times, so it is mapped whenever the
        // self-map entry exists (i.e. whenever A's base is the live
        // one). v25 read PTE_BASE + s*8 — a low-user PTE slot —
        // the read that killed the field VM.
        Walk w{pte_a, reads};
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

        // ---- the 4-level descent (parent-present) ----
        // v26 slot addresses (see the header): every walk to a1..a4
        // descends the s-self-ref chain plus parents proven present
        // below — nothing below an absent parent is ever touched.
        u64 vpn = (va >> 12) & 0xFFFFFFFFFULL;
        u64 pml4_idx = (vpn >> 27) & 0x1FF;
        u64 pdpt_idx = (vpn >> 18) & 0x1FF;
        u64 pd_idx   = (vpn >> 9) & 0x1FF;
        u64 pde_base = PdeBaseOf(pte_a, s);
        u64 ppe_base = PpeBaseOf(pte_a, s);
        u64 pxe_base = PxeBaseOf(pte_a, s);
        u64 a1 = pxe_base + pml4_idx * 8;
        u64 a2 = ppe_base + ((pml4_idx << 9) | pdpt_idx) * 8;
        u64 a3 = pde_base + ((pml4_idx << 18) | (pdpt_idx << 9)
                             | pd_idx) * 8;
        u64 a4 = pte_a + vpn * 8;   // MiGetPteAddress — was right in
                                    // v25 and is unchanged

        if (!PtRd64(&w, a1, &r.pml4e)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        if (!(r.pml4e & kPtPresentBit)) {
            r.reads = w.reads; r.present_mask = 0;
            r.status = kPtNotPresent; return r;
        }
        if (!PtRd64(&w, a2, &r.pdpte)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        if (!(r.pdpte & kPtPresentBit)) {
            r.reads = w.reads; r.present_mask = 0x1;
            r.status = kPtNotPresent; return r;
        }
        if (r.pdpte & kPtLargeBit) {          // 1 GB page
            r.present_mask = 0x13;
            r.frame = (r.pdpte & kPtPfnMask) + (va & 0x3FFFFFFFULL);
            r.reads = w.reads; r.status = kPtOk; return r;
        }
        if (!PtRd64(&w, a3, &r.pde)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        if (!(r.pde & kPtPresentBit)) {
            r.reads = w.reads; r.present_mask = 0x3;
            r.status = kPtNotPresent; return r;
        }
        if (r.pde & kPtLargeBit) {            // 2 MB page
            r.present_mask = 0x17;
            r.frame = (r.pde & kPtPfnMask) + (va & 0x1FFFFFULL);
            r.reads = w.reads; r.status = kPtOk; return r;
        }
        if (!PtRd64(&w, a4, &r.pte)) {
            r.reads = w.reads; r.status = kPtRefused; return r;
        }
        if (!(r.pte & kPtPresentBit)) {
            r.reads = w.reads; r.present_mask = 0x7;
            r.status = kPtNotPresent; return r;
        }
        r.present_mask = 0x1F;
        r.frame = r.pte & kPtPfnMask;
        r.reads = w.reads;
        r.status = kPtOk;
        return r;
    }

} // namespace pt
} // namespace UEFIBridge
