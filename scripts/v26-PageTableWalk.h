/**
 * PageTableWalk.h  (UEFI side — v26 / F4, the formula fix)
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
 * PTE_BASE DISCOVERY — TWO INDEPENDENT CHAINS, ORDERED SO A BAD
 * LAYOUT CAN NEVER FAULT (the ordering IS the safety property):
 *
 *   A (first, in-image only): nt!MmPteBase — a u64 .data global
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
        kPtS2RvaCount   = 5,      // nt!MmPfnDatabase candidates
    };
    enum : u64 {
        kPtMinKernel    = 0xFFFF800000000000ULL,
        kPtPfnMask      = 0x000FFFFFFFFFF000ULL,   // phys-frame mask
        kPtPresentBit   = 1ULL,
        kPtLargeBit     = (1ULL << 7),
        kPtPteSpaceSize = 0x8000000000ULL,         // 2^39 (512 GB)
        kPtMmPfnStride  = 0x30,                    // sizeof(_MMPFN)
        kPtMmPfnPteOfs  = 0x8,                     // .PteAddress
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
    // nt!MmPfnDatabase observed RVAs (11 x 0xCFC508, 3 x 0xCFC500,
    // 3 x 0xCFC510, 1 x 0xCFB500, 1 x 0xCFB508).
    static const u32 kS2PfnDbRvas[kPtS2RvaCount] = {
        0xCFC508, 0xCFC500, 0xCFC510, 0xCFB500, 0xCFB508,
    };

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
        u32 source;          // bit0-1: A candidate (1/2); bit4: B agreed;
                             // bit5: B missed (unseen RVA world)
        u32 self_ok;         // bit0 = the PTE space is LIVE (the
                             // self-ref slot read succeeded, the entry
                             // is present, its frame is sane); bit1 =
                             // self-ref frame == System CR3 frame (1
                             // only in a System-context caller — see
                             // the header's proof structure)
        u32 reads;           // gated PTE/pool reads used
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
        w->reads++;
        *out = PT_R64(addr);
        return true;
    }

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

    // ================= chain B: the PFN bootstrap ================
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
        u64 self_frame = self_entry & kPtPfnMask;
        if (self_entry & kPtPresentBit) {
            if (self_frame != 0 && self_frame < kPtMaxPhysFrame)
                r.self_ok |= 1;           // the PTE space is LIVE
        }
        if (r.cr3 && self_frame == r.cr3)
            r.self_ok |= 2;   // only true in a System-context caller

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
