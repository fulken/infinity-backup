#!/usr/bin/env python3
# ============================================================================
# patch-v19.py — v18 -> v19 driver source transformation (Phase F1)
#
# F1 = SIDT + anchor stack + 4 converging validators, fail-closed.
#
# WHAT v19 ADDS (surgical; everything else byte-equivalent strategy):
#   NEW  UEFI/include/KernelAnchor.h — the anchor machinery, PURE logic
#        (no EFI types, no serial, no pointers) so the REAL code can be
#        unit-tested on the host against synthetic images
#        (-DKERNEL_ANCHOR_HOST_TEST provides the 2 read primitives).
#        A0 SIDT (register read) -> A1 IDT #PF/#BP handler VAs (the IDT
#        is non-paged resident memory) -> A2 IA32_LSTAR MSR (register
#        read) -> A3 walk-back to the image base (64 KB steps, 32 MB
#        hard bound, 'MZ' 2-byte probes, every candidate fully
#        PE-validated). V1/V2/V3 = the three independent walk-backs
#        must AGREE; V4 = full structural PE validation + containment
#        of all three anchor VAs inside [base, base+SizeOfImage).
#        ANY failure = fail-closed (cached for the boot, gate unchanged).
#   EDIT RequestHandler.h — op 9 (ReqOp_Anchors) in the VARIABLE
#        transport: idempotent discovery + 32-byte payload
#        (state, reason, pe_base, pe_size, idt_base) + [AN] serial
#        traces + INFDIAG flag 0x40 on convergence.
#   EDIT ProcessMemory.h — ReadKernelVA gate gains the THIRD range:
#        the validated kernel image [pe_base, +pe_size) when (and only
#        when) anchors converged. KUSD windows unchanged (always on).
#   EDIT main.c / RuntimeHook.h — v19 banners/markers.
#
# Usage: python3 scripts/patch-v19.py <v18-tree>
# ============================================================================
import sys, pathlib

NEW_FILE_REL = "UEFI/include/KernelAnchor.h"

NEW_FILE = r'''/**
 * KernelAnchor.h  (UEFI side — NEW in v19 / Phase F1)
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
 *                       PE header found at the candidate base
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
    // are fully PE-validated before acceptance. No valid PE inside the
    // bound => 0 (the caller fails closed).
    static inline u64 WalkBackToPE(u64 text_va) {
        u64 page = text_va & ~0xFFFFULL;
        for (u32 i = 0; i < 512u; i++, page -= 0x10000ULL) {
            if (AN_R16(page) != 0x5A4Du) continue;
            PEInfo p = ValidatePEAt(page);
            if (p.ok) return p.base;
        }
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
        r->walk_v1 = WalkBackToPE(pf_va);                  // V1: IDT #PF
        if (!r->walk_v1) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_WalkBound1;
            return;
        }
        r->walk_v2 = WalkBackToPE(bp_va);                  // V2: IDT #BP
        if (!r->walk_v2) {
            r->state = kAnchorFailClosed; r->reason = kAnReason_WalkBound2;
            return;
        }
        r->walk_v3 = WalkBackToPE(lstar_va);               // V3: LSTAR
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
'''


def main():
    if len(sys.argv) != 2:
        print("usage: patch-v19.py <v18-tree>")
        sys.exit(1)
    tree = pathlib.Path(sys.argv[1])
    pm = tree / "UEFI/include/ProcessMemory.h"
    rh = tree / "UEFI/include/RequestHandler.h"
    mc = tree / "UEFI/src/main.c"
    hk = tree / "UEFI/include/RuntimeHook.h"
    ka = tree / NEW_FILE_REL
    for p in (pm, rh, mc, hk):
        if not p.exists():
            print(f"FATAL: not a v18 tree ({p} missing)")
            sys.exit(1)
    if ka.exists():
        print("FATAL: KernelAnchor.h already exists - tree already v19?")
        sys.exit(1)

    def sub(path, old, new, tag, count=1):
        t = path.read_text(encoding="utf-8")
        if t.count(old) != count:
            print(f"  FAIL {tag}: anchor found {t.count(old)}x (want {count}) in {path.name}")
            sys.exit(1)
        path.write_text(t.replace(old, new), encoding="utf-8")
        print(f"  {tag}: {path.name} OK")

    # ------------------------------------------------------------------
    # N1: KernelAnchor.h — the new pure-logic anchor machinery
    # ------------------------------------------------------------------
    ka.write_text(NEW_FILE, encoding="utf-8")
    print(f"  N1: {NEW_FILE_REL} written ({len(NEW_FILE)} bytes)")

    # ------------------------------------------------------------------
    # E1: ProcessMemory.h — include + the THIRD gate range
    # ------------------------------------------------------------------
    sub(pm,
        '#include "PhysicalMemory.h"\n#include "Diag.h"\n',
        '#include "PhysicalMemory.h"\n#include "Diag.h"\n#include "KernelAnchor.h"\n',
        "E1a-include")
    sub(pm,
        """            BOOLEAN in_kern =
                (va >= 0xFFFFF78000000000ULL) &&
                (end <= 0xFFFFF7800000FFFFULL);
            if (!in_user && !in_kern) return FALSE;
""",
        """            BOOLEAN in_kern =
                (va >= 0xFFFFF78000000000ULL) &&
                (end <= 0xFFFFF7800000FFFFULL);
            // v19 (F1): the THIRD gate — the VALIDATED kernel-image
            // range [pe_base, pe_base+pe_size), unlocked ONLY while the
            // anchor stack is CONVERGED (SIDT + 3 independent walk-backs
            // + full PE structural validation + containment — all
            // fail-closed in KernelAnchor.h). Anything else: exactly
            // the v18 behavior.
            BOOLEAN in_validated = FALSE;
            if (ka::g_result.state == ka::kAnchorConverged) {
                UINT64 vb = ka::g_result.pe_base;
                UINT64 ve = vb + ka::g_result.pe_size - 1;
                if (va >= vb && end <= ve) in_validated = TRUE;
            }
            if (!in_user && !in_kern && !in_validated) return FALSE;
""",
        "E1b-gate")

    # ------------------------------------------------------------------
    # E2: RequestHandler.h — include + discovery wrapper + op 9
    # ------------------------------------------------------------------
    sub(rh,
        '#include "ProcessMemory.h"\n#include "ProcessFinder.h"\n',
        '#include "ProcessMemory.h"\n#include "ProcessFinder.h"\n#include "KernelAnchor.h"\n',
        "E2a-include")
    sub(rh,
        """namespace UEFIBridge {

    class RequestHandler {
""",
        """namespace UEFIBridge {

    // =========================================================
    // v19 (F1): anchor discovery — register reads + serial traces.
    // The discovery LOGIC (walks, validation, reasons) lives in
    // KernelAnchor.h: pure, host-testable, fail-closed.
    // =========================================================
    static inline std::uint64_t An_ReadMSR(std::uint32_t msr) {
        std::uint32_t lo, hi;
        __asm__ __volatile__("rdmsr" : "=a"(lo), "=d"(hi) : "c"(msr));
        return ((std::uint64_t)hi << 32) | lo;
    }

    struct An_IDTR { std::uint16_t limit; std::uint64_t base; }
        __attribute__((packed));

    static inline An_IDTR An_SIDT() {
        An_IDTR d;
        __asm__ __volatile__("sidt %0" : "=m"(d) :: "memory");
        return d;
    }

    // Idempotent + fail-closed: at most one attempt per boot; a failed
    // discovery is cached as failed (never retried; gate stays v18).
    static void DiscoverAnchorsOnce() {
        if (ka::g_result.state != ka::kAnchorNotRun) return;
        ka::Result r{};
        An_IDTR idtr = An_SIDT();
        SerialTrace::KV("AN", "sidt base", idtr.base);
        if (idtr.limit < 0xFFu) {  // need >= 16 entries for vector 0x0E
            r.idt_base = idtr.base;
            r.state  = ka::kAnchorFailClosed;
            r.reason = ka::kAnReason_IdtInvalid;
            SerialTrace::KVD("AN", "FAIL-CLOSED reason", r.reason);
            ka::g_result = r;
            return;
        }
        std::uint64_t pf = ka::IdtHandlerVA(idtr.base, 0x0E);  // #PF
        std::uint64_t bp = ka::IdtHandlerVA(idtr.base, 0x03);  // #BP
        std::uint64_t ls = An_ReadMSR(0xC0000082);             // IA32_LSTAR
        SerialTrace::KV("AN", "idt pf", pf);
        SerialTrace::KV("AN", "idt bp", bp);
        SerialTrace::KV("AN", "lstar", ls);
        ka::DiscoverCore(&r, idtr.base, pf, bp, ls);
        SerialTrace::KV("AN", "walk v1", r.walk_v1);
        SerialTrace::KV("AN", "walk v2", r.walk_v2);
        SerialTrace::KV("AN", "walk v3", r.walk_v3);
        if (r.state == ka::kAnchorConverged) {
            SerialTrace::KV("AN", "CONVERGED base", r.pe_base);
            SerialTrace::KV("AN", "CONVERGED size", r.pe_size);
            DiagSetFlag(0x40);  // 'anchors converged' — in every INFDIAG
        } else {
            SerialTrace::KVD("AN", "FAIL-CLOSED reason", r.reason);
        }
        ka::g_result = r;
    }

    class RequestHandler {
""",
        "E2b-wrapper")
    sub(rh,
        "            switch ((ReqOp)req->op) {\n",
        """            switch ((ReqOp)req->op) {
            case 9 /* ReqOp_Anchors — v19 F1 (op 9 was free in the
                    Windows-side enum; the variable transport carries
                    raw op values) */: {
                DiscoverAnchorsOnce();
                const ka::Result& an = ka::g_result;
                // 32-byte payload (the InfinityData view):
                //   +0 u32 state, +4 u32 reason, +8 u64 pe_base,
                //  +16 u64 pe_size, +24 u64 idt_base
                UINT8* p = (UINT8*)data_buf;
                for (UINTN i = 0; i < 32; i++) p[i] = 0;
                auto put32 = [&p](UINTN off, UINT32 v) {
                    for (UINTN i = 0; i < 4; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                auto put64 = [&p](UINTN off, UINT64 v) {
                    for (UINTN i = 0; i < 8; i++)
                        p[off + i] = (UINT8)(v >> (8 * i));
                };
                put32(0,  an.state);
                put32(4,  an.reason);
                put64(8,  an.pe_base);
                put64(16, an.pe_size);
                put64(24, an.idt_base);
                resp->status = (an.state == ka::kAnchorConverged)
                    ? SlotStatus_Success : SlotStatus_ErrAccess;
                resp->bytes_transferred = 32;
                *data_size = 32;
                break;
            }
""",
        "E2c-op9")

    # ------------------------------------------------------------------
    # E3: main.c — v19 banners
    # ------------------------------------------------------------------
    sub(mc,
        'static const char kBuildLine[] = "  Build: v18 RT - direct KUSD reads";',
        'static const char kBuildLine[] = "  Build: v19 RT - anchors + validated image reads";',
        "E3a-build-rt")
    sub(mc,
        'static const char kBuildLine[] = "  Build: v18 SAFE (phase C)";',
        'static const char kBuildLine[] = "  Build: v19 SAFE (phase F1)";',
        "E3b-build-safe")
    sub(mc,
        'Print((CHAR16*)L"  Build: v18 RT - bridge + direct KUSD reads (phase E)    \\r\\n");',
        'Print((CHAR16*)L"  Build: v19 RT - anchors + validated image reads (F1)    \\r\\n");',
        "E3c-print-rt")
    sub(mc,
        'Print((CHAR16*)L"  Build: v18 SAFE (phase C)                               \\r\\n");',
        'Print((CHAR16*)L"  Build: v19 SAFE (phase F1)                               \\r\\n");',
        "E3d-print-safe")
    sub(mc,
        'SerialTrace::Line("MAIN", "efi_main v18 boot");',
        'SerialTrace::Line("MAIN", "efi_main v19 boot");',
        "E3e-boot-line")
    sub(mc,
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v18)");',
        'SerialTrace::Line("MAIN", "variant: RT (EARLY gRT hooks - v19)");',
        "E3f-variant-line")

    # ------------------------------------------------------------------
    # E4: RuntimeHook.h — v19 markers
    # ------------------------------------------------------------------
    sub(hk,
        'SerialTrace::Line("RT-EARLY", "memory.efi v18 RT (kernel data path: direct KUSD reads)");',
        'SerialTrace::Line("RT-EARLY", "memory.efi v19 RT (kernel data path: direct reads + anchors)");',
        "E4a-rt-early")
    sub(hk,
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v18 early) - keeping slots");',
        'SerialTrace::Line("RT-VA", "hooks already installed at load (v19 early) - keeping slots");',
        "E4b-rt-va")

    # ------------------------------------------------------------------
    # sanity: the tree must now be exactly v19
    # ------------------------------------------------------------------
    kat = ka.read_text(encoding="utf-8")
    for good in ["kAnchorConverged", "WalkBackToPE", "ValidatePEAt",
                 "512u", "0x5A4Du", "0x00004550u", "kAnReason_Contain"]:
        if good not in kat:
            print(f"  FAIL sanity: '{good}' missing from KernelAnchor.h")
            sys.exit(1)
    for bad in ["SerialTrace", "efi.h", "gBS"]:
        if bad in kat:
            print(f"  FAIL sanity: '{bad}' must NOT be in KernelAnchor.h (purity)")
            sys.exit(1)
    pmt = pm.read_text(encoding="utf-8")
    for good in ["in_validated", "ka::kAnchorConverged", "0x7FFE0000ULL",
                 "0xFFFFF78000000000ULL"]:
        if good not in pmt:
            print(f"  FAIL sanity: '{good}' missing from ProcessMemory.h")
            sys.exit(1)
    rht = rh.read_text(encoding="utf-8")
    for good in ["case 9", "DiscoverAnchorsOnce", "rdmsr", "sidt",
                 '#include "KernelAnchor.h"', "put64(24, an.idt_base)"]:
        if good not in rht:
            print(f"  FAIL sanity: '{good}' missing from RequestHandler.h")
            sys.exit(1)
    mct = mc.read_text(encoding="utf-8")
    assert "v19" in mct and "v18" not in mct, "main.c banners incomplete"
    hkt = hk.read_text(encoding="utf-8")
    assert "v19 RT" in hkt and "v18 early" not in hkt, "RuntimeHook.h markers incomplete"
    print("[patch-v19] ALL EDITS APPLIED - tree is now v19")
    print("[patch-v19] changed: +KernelAnchor.h, RequestHandler.h, ProcessMemory.h, main.c, RuntimeHook.h")
    print("[patch-v19] next: host logic test, then make (SAFE) and make RT=1")


if __name__ == "__main__":
    main()
