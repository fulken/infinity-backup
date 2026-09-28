/**
 * KernelAnchor.h  (UEFI side — v19 / F1; containing-walk v20 / F2)
 * =================================================================
 * SIDT + anchor stack + 4 converging validators, fail-closed.
 *
 * WHY: v18's read gate only accepts the two fixed KUSER_SHARED_DATA
 * windows. Reading anything else SAFELY requires knowing where the
 * kernel actually lives — discovered at runtime, never hardcoded, and
 * trusted only when multiple independent derivations AGREE.
 *
 * THE ANCHOR STACK (each step touches only memory that is guaranteed
 * present on a healthy boot — same access class as the field-proven
 * v18 KUSD reads):
 *   A0  SIDT          — register read, zero memory risk      -> IDT base
 *   A1  IDT entries   — the IDT is non-paged and resident; the
 *                       vector 0x0E (#PF) and 0x03 (#BP) handlers are
 *                       kernel-text VAs of the OS image
 *   A2  IA32_LSTAR    — MSR read (0xC0000082), zero memory risk;
 *                       the syscall entry is also OS-image text
 *   A3  walk-back     — from each anchor VA, step DOWN in 64 KB units
 *                       (module bases are 64 KB aligned), at most 512
 *                       steps (32 MB), probing a single 2-byte 'MZ'
 *                       per candidate page, then FULLY validating the
 *                       PE header found at the candidate base.
 *                       v20: the candidate is accepted only if the
 *                       image CONTAINS the anchor (the containing-walk
 *                       — nested/in-between PEs are skipped + counted;
 *                       the v25 field run proved the first-valid-PE
 *                       rule stops at the wrong image)
 *
 * THE 4 CONVERGING VALIDATORS (ALL must pass; ANY failure = closed):
 *   V1  walk-back from the IDT #PF handler          -> base1
 *   V2  walk-back from the IDT #BP handler          -> base2 (== base1)
 *   V3  walk-back from LSTAR                        -> base3 (== base1)
 *   V4  structural PE validation at the converged base + containment
 *       of ALL three anchor VAs inside [base, base + SizeOfImage)
 *
 * FAIL-CLOSED CONTRACT: on any failure the state caches as FAILED for
 * the rest of the boot and the read gate stays EXACTLY as v18 (the two
 * KUSD windows only). No partial trust, ever.
 *
 * HOST TESTING: the whole core is pure logic over the AN_R16/AN_R32
 * primitives. Compile with -DKERNEL_ANCHOR_HOST_TEST and provide the
 * primitives to unit-test the REAL code against synthetic images
 * (valid case + every failure class: bound, mismatch, bad PE,
 * containment, invalid IDT/anchors).
 * =================================================================
 */
#pragma once

#include <cstdint>
#include <cstddef>

namespace UEFIBridge {
namespace ka {

    typedef std::uint16_t u16;
    typedef std::uint32_t u32;
    typedef std::uint64_t u64;

    // ================= the ONLY raw memory accesses =================
    // Small (2/4-byte) volatile reads at computed, bounds-checked
    // addresses — the field-proven v18 KUSD access class.
#ifdef KERNEL_ANCHOR_HOST_TEST
    u16 AN_R16(u64 va);              // provided by the host test
    u32 AN_R32(u64 va);              // provided by the host test
#else
    static inline u16 AN_R16(u64 va) {
        return *(volatile u16*)(std::size_t)va;
    }
    static inline u32 AN_R32(u64 va) {
        return *(volatile u32*)(std::size_t)va;
    }
#endif

    // ================= state / reason =================
    enum : u32 {
        kAnchorNotRun     = 0,
        kAnchorConverged  = 1,
        kAnchorFailClosed = 2,
    };

    enum : u32 {
        kAnReason_Ok            = 0,
        kAnReason_WalkBound1    = 1,  // #PF walk found no valid PE in 32 MB
        kAnReason_WalkBound2    = 2,  // #BP walk
        kAnReason_WalkBound3    = 3,  // LSTAR walk
        kAnReason_Mismatch      = 4,  // walk results disagree
        kAnReason_PEInvalid     = 5,  // V4 structural validation failed
        kAnReason_Contain       = 6,  // an anchor VA outside the image
        kAnReason_IdtInvalid    = 7,  // IDTR not canonical kernel / short
        kAnReason_AnchorInvalid = 8,  // a handler/LSTAR not canonical kernel
    };

    struct Result {
        u32 state;                   // kAnchor*
        u32 reason;                  // kAnReason*
        u64 idt_base;
        u64 lstar;
        u64 walk_v1, walk_v2, walk_v3;
        u64 pe_base, pe_size;
        u32 v1_skips, v2_skips, v3_skips;         // v20: skipped
        u64 v1_last_skip, v2_last_skip, v3_last_skip; // candidates
    };

    // THE boot-lifetime anchor state. Pure data (no pointers), so it
    // needs no SetVirtualAddressMap conversion. Fail-closed: a failed
    // discovery is cached as failed for the rest of the boot.
    inline Result g_result = {};

    // ================= IDT entry parse (x64) =================
    // 16-byte gate at idt_base + vector*16:
    //   +0 u16 offset_lo, +2 u16 selector, +4 u16 ist/attr,
    //   +6 u16 offset_mid, +8 u32 offset_hi, +12 u32 reserved
    static inline u64 IdtHandlerVA(u64 idt_base, u32 vector) {
        u64 e = idt_base + (u64)(vector & 0xFFu) * 16u;
        u32 lo  = AN_R32(e + 0);
        u32 mid = AN_R32(e + 4);
        u32 hi  = AN_R32(e + 8);
        return (u64)(lo & 0xFFFFu)
             | ((u64)(mid >> 16) << 16)
             | ((u64)hi << 32);
    }

    // ================= PE validation (V4) =================
    struct PEInfo { bool ok; u64 base; u32 size_image; };

    static inline PEInfo ValidatePEAt(u64 base) {
        PEInfo r{};
        if (AN_R16(base) != 0x5A4Du) return r;              // 'MZ'
        u32 lfanew = AN_R32(base + 0x3C);
        if (lfanew < 0x40u || lfanew > 0x1000u) return r;   // header-page local
        u64 pe = base + lfanew;
        if (AN_R32(pe) != 0x00004550u) return r;            // 'PE\0\0'
        if (AN_R16(pe + 4) != 0x8664u) return r;            // machine AMD64
        u32 nsec = AN_R16(pe + 6);
        if (nsec == 0u || nsec > 96u) return r;
        if (AN_R16(pe + 0x14) != 0xF0u) return r;           // PE32+ optional hdr size
        if (AN_R16(pe + 0x18) != 0x020Bu) return r;         // PE32+ magic
        u32 size_img = AN_R32(pe + 0x50);
        if (size_img < 0x20000u || size_img > 0x4000000u) return r;  // 128KB..64MB
        if (size_img & 0xFFFu) return r;                    // page-aligned
        if (AN_R32(pe + 0x28) >= size_img) return r;        // entry point inside
        u32 size_hdr = AN_R32(pe + 0x54);
        if (size_hdr == 0u || size_hdr > size_img) return r;
        // section table: page-aligned, ascending, non-overlapping,
        // all inside the image (reads stay on the header pages)
        u64 sec0 = pe + 0x18 + 0xF0;
        u32 prev_end = 0;
        for (u32 i = 0; i < nsec; i++) {
            u64 s = sec0 + (u64)i * 40u;
            u32 vsize = AN_R32(s + 8);
            u32 vaddr = AN_R32(s + 12);
            if (vaddr & 0xFFFu) return r;                   // section VA aligned
            u32 vend = vaddr + ((vsize + 0xFFFu) & ~0xFFFu);
            if (vaddr >= size_img || vend > size_img) return r;
            if (i != 0 && vaddr < prev_end) return r;       // ascending
            prev_end = vend;
        }
        r.ok = true; r.base = base; r.size_image = size_img;
        return r;
    }

    // ================= the walk (V1/V2/V3 core) =================
    // From a trusted kernel-text VA, step DOWN in 64 KB units at most
    // 512 steps (32 MB). Each probe reads ONE 2-byte 'MZ'; candidates
    // are fully PE-validated before acceptance.
    //
    // v20 (F2) CONTAINING-WALK: a candidate is accepted ONLY if the
    // image range [base, base+SizeOfImage) CONTAINS the anchor VA it
    // was walked from. Structurally-valid PEs that do NOT contain the
    // anchor (nested PEs / unrelated images between the anchor and the
    // true base — the exact trap the v25 field run hit) are SKIPPED,
    // counted, and the walk continues DOWN. No containing PE inside
    // the bound => 0 (the caller fails closed).
    //   KNOWN CORNER: a nested PE whose range covers the anchor is
    //   accepted (first-hit-wins). The accepted range is still a fully
    //   validated PE containing the anchor — the safe-subset contract
    //   holds. (Outermost-preference would require probing below an
    //   accepted base, which can exit mapped memory: #PF risk. That
    //   needs F4 page-table validation, not a walk rule.)
    //   PROBE SAFETY: every probe page on the path lies inside the
    //   anchor's own mapped image (the containing base terminates the
    //   walk); skips only continue inside the same containing image.
    static inline u64 WalkBackToPE(u64 text_va, u32* skips, u64* last_skip) {
        u64 page = text_va & ~0xFFFFULL;
        u32 n = 0;
        u64 last = 0;
        for (u32 i = 0; i < 512u; i++, page -= 0x10000ULL) {
            if (AN_R16(page) != 0x5A4Du) continue;
            PEInfo p = ValidatePEAt(page);
            if (p.ok) {
                if (text_va >= p.base &&
                    text_va <  p.base + p.size_image) {
                    if (skips) *skips = n;
                    if (last_skip) *last_skip = last;
                    return p.base;              // the containing image
                }
                n++;                            // valid, not containing
                last = p.base;                  // (nested / in-between)
            }
        }
        if (skips) *skips = n;
        if (last_skip) *last_skip = last;
        return 0;
    }

    // ================= discovery core (pure, host-testable) =================
    static inline void DiscoverCore(Result* r, u64 idt_base,
                                    u64 pf_va, u64 bp_va, u64 lstar_va) {
        r->idt_base = idt_base;
        r->lstar    = lstar_va;
        const u64 kMinKernel = 0xFFFF800000000000ULL;
        if (idt_base < kMinKernel) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_IdtInvalid;
            return;
        }
        if (pf_va < kMinKernel || bp_va < kMinKernel || lstar_va < kMinKernel) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_AnchorInvalid;
            return;
        }
        r->walk_v1 = WalkBackToPE(pf_va, &r->v1_skips,      // V1: IDT #PF
                                  &r->v1_last_skip);
        if (!r->walk_v1) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_WalkBound1;
            return;
        }
        r->walk_v2 = WalkBackToPE(bp_va, &r->v2_skips,      // V2: IDT #BP
                                  &r->v2_last_skip);
        if (!r->walk_v2) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_WalkBound2;
            return;
        }
        r->walk_v3 = WalkBackToPE(lstar_va, &r->v3_skips,   // V3: LSTAR
                                  &r->v3_last_skip);
        if (!r->walk_v3) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_WalkBound3;
            return;
        }
        if (r->walk_v1 != r->walk_v2 || r->walk_v2 != r->walk_v3) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_Mismatch;
            return;
        }
        PEInfo p = ValidatePEAt(r->walk_v1);               // V4: structural
        if (!p.ok) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_PEInvalid;
            return;
        }
        u64 end = p.base + p.size_image;  // no wrap: kernel base + <=64MB
        if (pf_va < p.base || pf_va >= end ||
            bp_va < p.base || bp_va >= end ||
            lstar_va < p.base || lstar_va >= end) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_Contain;
            return;
        }
        r->pe_base = p.base;
        r->pe_size = p.size_image;
        r->state   = kAnchorConverged;
        r->reason  = kAnReason_Ok;
    }

} // namespace ka
} // namespace UEFIBridge
