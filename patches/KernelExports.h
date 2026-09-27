/**
 * KernelExports.h  (UEFI side — v21 F2 re-derived / v22)
 * =================================================================
 * Export-table symbol resolution INSIDE the validated kernel image.
 *
 * WHY: F1 (KernelAnchor.h) opens [pe_base, pe_base+pe_size) after
 * four converging validators. F2 answers "which VA is symbol X?"
 * WITHOUT per-build offset tables: the kernel image answers for
 * itself through its export directory — discovered at runtime,
 * parsed only through a budgeted, fail-closed RVA gate.
 *
 * v22 PROVENANCE NOTE: the v21 driver shipped this machinery in the
 * field (v28/v29 runs: M1..M4 all green). The v21 SOURCE was lost to
 * a sandbox rollback; this file is the RE-DERIVATION from the
 * field-proven binary (patches/v21-memory-RT.efi, sha256 90bc3bdf...,
 * kx::Rd32 @c8d0 + the op-10 handler @10090, decoded to the byte
 * 2026-09-27). The WIRE CONTRACT (request fields, 64-byte payload,
 * status codes, serial traces) is kept EXACTLY as the v29 script
 * already speaks it; the v30 field test re-proves the whole chain
 * against this code.
 *
 * THE GATE (Rd32): every export-directory access is an RVA relative
 * to the VALIDATED base — never an absolute VA. Sticky error: the
 * first out-of-range read refuses AND pins err for the rest of the
 * resolve. Hard budget: 1,000,000 bytes of total parsing per resolve
 * (the v21 field value) — a corrupt directory can not turn the
 * parser into an unbounded walker.
 *
 * THE RESOLVE: the standard PE export walk (true field layout):
 *   e_lfanew@image+0x3C in [0x40,0x1000)
 *   DataDirectory[0] at PE+0x88/+0x8C  (RVA, size)
 *   export dir: nFuncs@+0x14, nNames@+0x18,
 *               addrFuncs@+0x1C, addrNames@+0x20, addrOrds@+0x24
 *   linear name scan (NUL-terminated, budget-charged per byte),
 *   u16 ordinal -> u32 function RVA; FORWARDED exports (funcRVA
 *   inside the export dir range) are detected and REFUSED cleanly —
 *   never followed.
 *
 * HOST TESTING: pure logic over the KX_R8 primitive. Compile with
 * -DKERNEL_EXPORTS_HOST_TEST and provide KX_R8 at the host to unit-
 * test the REAL walk against synthetic export tables (found /
 * not-found / forwarded / every bound class).
 * =================================================================
 */
#pragma once

#include <cstdint>
#include <cstddef>

namespace UEFIBridge {
namespace kx {

    typedef std::uint8_t  u8;
    typedef std::uint16_t u16;
    typedef std::uint32_t u32;
    typedef std::uint64_t u64;

    // ================= the ONLY raw access =================
    // Single-byte volatile reads — the v21 access class (a u32 is
    // assembled from 4 byte reads, never a wide load).
#ifdef KERNEL_EXPORTS_HOST_TEST
    u8 KX_R8(u64 va);                 // provided by the host test
#else
    static inline u8 KX_R8(u64 va) {
        return *(volatile u8*)(std::size_t)va;
    }
#endif

    // ================= resolve status (payload rc) =================
    enum : u32 {
        kXResolve_NotFound  = 0,   // name absent
        kXResolve_Resolved  = 1,
        kXResolve_Forwarded = 3,   // export forwards elsewhere — refused
        kXResolve_Refused   = 4,   // structural/budget gate refusal
    };

    // Budgeted, sticky-error RVA gate (the v21 contract).
    struct Ctx {
        u64 base;      // validated image base (from ka::g_result)
        u64 size;      // validated image size
        u64 budget;    // bytes charged so far
        u32 err;       // 0 = ok, 4 = refused (sticky)
    };

    static inline u32 Rd32(Ctx* c, u32 rva, u32* out) {
        if (c->err) return 0;
        u64 r = (u64)rva;                        // zero-extended
        if (c->size < r + 4) { c->err = 4; return 0; }
        u64 nb = c->budget + 4;
        if (nb > 1000000ull) { c->err = 4; return 0; }
        u64 va = c->base + r;
        u32 v = 0;
        for (u32 i = 0; i < 4; i++)
            v |= (u32)KX_R8(va + i) << (8 * i);
        c->budget = nb;
        *out = v;
        return 1;
    }

    struct ResolveResult {
        u32 rc;           // kXResolve_*
        u32 name_index;   // i where the name matched (0 otherwise)
        u64 resolved_va;  // base + funcRVA (0 otherwise)
    };

    // Full name -> VA resolution. The caller has ALREADY validated:
    //   name_len in [1,64], all bytes in [0x21,0x7E] (printable),
    //   ka::g_result.state == kAnchorConverged.
    // Memory-pure: everything goes through KX_R8 / Rd32 with the
    // same gates and budget accounting as the v21 binary.
    static inline ResolveResult Resolve(Ctx* c, const char* name,
                                        u32 name_len) {
        ResolveResult r{0, 0, 0};
        u64 base = c->base, size = c->size;

        // ---- PE header: manual gated reads (v21 form) ----
        if (size <= 0x3F) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        u32 lfanew = 0;
        for (u32 i = 0; i < 4; i++)
            lfanew |= (u32)KX_R8(base + 0x3C + i) << (8 * i);
        if (lfanew < 0x40 || lfanew >= 0x1000) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        if (size < (u64)lfanew + 0x88 + 4) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        u32 exp_rva = 0;
        for (u32 i = 0; i < 4; i++)
            exp_rva |= (u32)KX_R8(base + lfanew + 0x88 + i) << (8 * i);
        if (size < (u64)lfanew + 0x8C + 4) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        u32 exp_size = 0;
        for (u32 i = 0; i < 4; i++)
            exp_size |= (u32)KX_R8(base + lfanew + 0x8C + i) << (8 * i);
        if (!exp_rva) { c->err = 4; r.rc = kXResolve_Refused; return r; }          // no exports
        if (exp_size < 0x28 || exp_size >= 0x10000) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        u64 end = (u64)exp_rva + exp_size;
        if (end > size) { c->err = 4; r.rc = kXResolve_Refused; return r; }        // dir inside image
        if (end < (u64)exp_rva + 0x14 + 4) { c->err = 4; r.rc = kXResolve_Refused; return r; }
        u32 n_funcs = 0;
        for (u32 i = 0; i < 4; i++)
            n_funcs |= (u32)KX_R8(base + exp_rva + 0x14 + i) << (8 * i);

        // ---- export directory fields via Rd32 (budget starts at
        //      16: the four manual u32 header reads above) ----
        c->budget = 16;
        u32 n_names = 0, addr_funcs = 0, addr_names = 0, addr_ords = 0;
        if (!Rd32(c, exp_rva + 0x18, &n_names))
            { r.rc = kXResolve_Refused; return r; }
        if (!Rd32(c, exp_rva + 0x1C, &addr_funcs))
            { r.rc = kXResolve_Refused; return r; }
        if (!Rd32(c, exp_rva + 0x20, &addr_names))
            { r.rc = kXResolve_Refused; return r; }
        if (!Rd32(c, exp_rva + 0x24, &addr_ords))
            { r.rc = kXResolve_Refused; return r; }

        // ---- linear name scan (budget charged per compared byte,
        //      exactly the v21 accounting) ----
        for (u32 i = 0; i < n_names; i++) {
            u32 name_rva;
            if (!Rd32(c, addr_names + 4 * i, &name_rva))
                { r.rc = kXResolve_Refused; return r; }
            if (!name_rva) continue;
            if ((u64)name_rva >= size) continue;
            if (size < (u64)name_rva + 1) continue;
            u64 nva = base + name_rva;
            u32 j = 0;
            while (j < name_len) {
                if (c->budget + 1 > 1000000ull) { c->err = 4; r.rc = kXResolve_Refused; return r; }
                if (KX_R8(nva + j) != (u8)name[j]) break;
                c->budget += 1;
                j++;
                if ((u64)name_rva + j >= size) break;   // room for NUL?
            }
            if (j == name_len) {
                if ((u64)name_rva + name_len >= size) { c->err = 4; r.rc = kXResolve_Refused; return r; }
                if (KX_R8(nva + name_len) != 0) continue;  // not terminated
                // ---- matched: u16 ordinal (manual, gated) ----
                u32 ord_ofs = (u64)addr_ords + 2ull * i;
                if (c->size < (u64)ord_ofs + 2) { c->err = 4; r.rc = kXResolve_Refused; return r; }
                u32 ord_index = (u32)KX_R8(base + ord_ofs)
                              | ((u32)KX_R8(base + ord_ofs + 1) << 8);
                if (ord_index >= n_funcs) { c->err = 4; r.rc = kXResolve_Refused; return r; }
                u32 func_rva;
                if (!Rd32(c, addr_funcs + 4 * ord_index, &func_rva))
                { r.rc = kXResolve_Refused; return r; }
                if (size < (u64)func_rva + 1) { c->err = 4; r.rc = kXResolve_Refused; return r; }
                if ((u64)func_rva >= (u64)exp_rva && (u64)func_rva < end) {
                    r.rc = kXResolve_Forwarded;   // refused, not followed
                    return r;
                }
                r.rc = kXResolve_Resolved;
                r.name_index = i;
                r.resolved_va = base + func_rva;
                return r;
            }
            // mismatch: keep scanning (scan reads already charged)
        }
        r.rc = kXResolve_NotFound;
        return r;
    }

} // namespace kx
} // namespace UEFIBridge
