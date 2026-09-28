/**
 * ProcessWalk.h  (UEFI side — v22/v23/v24 / F3)
 * =================================================================
 * The EPROCESS walk: process discovery OUTSIDE the kernel image.
 *
 * WHY: F1 proved the validated-image window, F2 proved export-
 * resolved symbols. The F2-resolved PsInitialSystemProcess (field
 * value 0xFFFFF8071A4FC420 on build 19045) is a POINTER to the
 * System process's EPROCESS — a DYNAMIC POOL object OUTSIDE
 * [pe_base, pe_base+pe_size). F3 walks the ActiveProcessLinks list
 * from there: the first reads of arbitrary (non-image) kernel data.
 *
 * THE v19 LESSON, HONORED IN FULL: the v19 attach (op 7) walked the
 * process list HUNTING HARDCODED EMULATOR EXE NAMES — an unvalidated
 * pointer chase that killed the VM (2026-09-21, 0x1E, filmed). This
 * walk shares NOTHING with that pattern:
 *   1. NO name hunting — the walk validates STRUCTURE, not strings.
 *      (The ONLY string read is the "System\0" name-slot PROBE at
 *      the trusted first entry — discovery, not a chase.)
 *   2. EVERY deref address is gated: canonical kernel VA + no-wrap
 *      + a +-4 GB pool-cluster window around the System entry
 *      (free on healthy systems — the field S1 sits +0x2FC420 above
 *      the kernel base and boot-time pool clusters tightly — but it
 *      kills the absurd-but-canonical garbage-pointer class BEFORE
 *      that pointer is ever dereferenced).
 *   3. DOUBLE-LINK LIST_ENTRY consistency: Blink(cur) == the link we
 *      came from (backward) AND Blink(next) == cur (forward, before
 *      the walk advances past it). A corrupt list dies at the first
 *      inconsistent hop — as a clean status, never a wild chase.
 *   4. Hard bounds: <= 64 entries (stopping = success), <= 256
 *      gated page-reads — a corrupt list can not become unbounded.
 *   5. Fail-closed: every refusal is a clean status; partial walks
 *      are DISCARDED (the F1/F2 contract: no partial trust); the VM
 *      stays alive (the M4 discipline: refuse, never crash).
 *
 * OFFSETS: pid @ 0x440 and ActiveProcessLinks @ 0x448 are constant
 * across Win10 19041..19045 (22H2) — the only build family this
 * project targets (the build is proven at KUSD J1 before anything
 * else; the v30 script asserts 19045 before sending op-11). Even
 * so, the pair is VALIDATED at the first hop: pid@S1 must equal 4
 * and the first Blink consistency must hold, or the walk refuses.
 * The NAME offset (0x5A8 on 19045) is NOT assumed: it is DISCOVERED
 * live (16 aligned candidates 0x560..0x5D8, "System\0" probe,
 * printability cross-check on the first entries) — derive, never
 * trust. Name-slot failure degrades to names-absent (flags bit 0
 * stays 0); the walk itself remains valid.
 *
 * v24 FIX (the v31 field run): PsInitialSystemProcess is a
 * POINTER VARIABLE - kx::Resolve returns the VA of the .data
 * SLOT (in-image), NOT the EPROCESS. v23's op-11 walked from
 * the slot VA itself: pid@slot+0x440 read .data garbage ->
 * kPwNotSys, walk=0, pages=0, VM alive (a perfectly clean
 * fail-closed refusal). v24 derefs the slot through the same
 * gated in-image Rd32 as every export read (SysEprocessFromSymbol
 * below - shared with the host harness so the driver's exact
 * chain is host-tested), and WalkCore validates the TARGET.
 *
 * ENTRY SEMANTICS: entries[0] is ALWAYS the System entry itself
 * (pid 4, the S1 VA). The walk then follows Flink order. count =
 * TOTAL entries walked (may exceed the number stored when the
 * system has more processes than out_n); closed = 1 when the circle
 * returned to the System link before the 64-entry cap; stored =
 * entries actually filled (<= out_n, <= 32).
 *
 * HOST TESTING: pure logic over PW_R8 (-DKERNEL_WALK_HOST_TEST):
 * synthetic process lists — healthy circle, corrupted Flink,
 * corrupted Blink, wrong pid offset, one-entry list, name-slot
 * variants, window violations, budget exhaustion. Every failure
 * class must refuse cleanly and NEVER read outside the gate.
 * =================================================================
 */
#pragma once

#include <cstdint>
#include <cstddef>

#include "KernelExports.h"   // kx::Resolve/kx::Rd32 (the v24 S1+S2 chain)

namespace UEFIBridge {
namespace pw {

    typedef std::uint8_t  u8;
    typedef std::uint16_t u16;
    typedef std::uint32_t u32;
    typedef std::uint64_t u64;

    // ================= the ONLY raw access =================
#ifdef KERNEL_WALK_HOST_TEST
    u8 PW_R8(u64 va);                 // provided by the host test
#else
    static inline u8 PW_R8(u64 va) {
        return *(volatile u8*)(std::size_t)va;
    }
#endif

    static inline u64 PW_R64(u64 va) {
        u64 v = 0;
        for (u32 i = 0; i < 8; i++)
            v |= (u64)PW_R8(va + i) << (8 * i);
        return v;
    }

    // ================= constants =================
    enum : u32 {
        kPwMaxEntries = 64,    // step cap (stopping = success)
        kPwMaxPages   = 256,   // gated page-read budget (64 entries
                               // x ~3 read-groups + name discovery)
        kPwNameCands  = 16,    // name-slot scan width
        kPwMaxOut     = 32,    // stored entries cap (payload)
    };
    enum : u64 {
        kPwMinKernel  = 0xFFFF800000000000ULL,
        kPwMaxKernel  = 0xFFFFFFFFFFFFFFFFULL, // canonical top
        // NOTE: 0xFFFF7FFFFFFFFFFF is the BELOW-kernel boundary of the
        // v21 idiom (va > it == canonical kernel) — never an upper
        // bound. Upper checks below are pure no-wrap guards.
        kPwSysPid     = 4,                      // System, always
        kPwWindow     = 0x100000000ULL,         // +-4 GB pool cluster
    };
    // EPROCESS 19041..19045 — the ONLY offsets assumed, validated
    // at the first hop anyway (see above):
    static const u32 kPwOfsPid   = 0x440;
    static const u32 kPwOfsLinks = 0x448;

    // ================= walk status =================
    enum : u32 {
        kPwOk         = 0,   // walked, count >= 1 (closed or capped)
        kPwBadArgs    = 1,   // malformed request (out_n invalid)
        kPwNoEntry    = 2,   // PsInitialSystemProcess resolve failed
        kPwBadEntry   = 3,   // S1 not canonical kernel (refuse)
        kPwNotSys     = 4,   // pid@S1 != 4 — not the System EPROCESS
        kPwBrokenLink = 5,   // LIST_ENTRY consistency failed
        kPwWindowRefused = 6, // a link left the +-4 GB cluster (refuse)
        kPwBudget     = 7,   // read budget exhausted (refuse)
    };

    // ================= budget =================
    struct Budget {
        u32 pages;             // page-reads spent so far
        u32 max_pages;         // cap (kPwMaxPages)
    };
    static inline bool SpendPage(Budget* b) {
        if (b->pages >= b->max_pages) return false;
        b->pages++;
        return true;
    }

    // ================= result =================
    // Entry wire layout — EXACTLY 32 bytes:
    //   +0 u32 pid, +4 u32 flags (bit0 = name echoed),
    //   +8 u64 eproc, +16 u8 name[8] (first 8 bytes of the 15-byte
    //   ImageFileName, no NUL guaranteed), +24 u32 pad (0)
    struct Entry {
        u32 pid;
        u32 flags;
        u64 eproc;
        u8  name[8];
        u32 pad;
    };

    struct Result {
        u32 status;        // kPw*
        u32 count;         // TOTAL entries walked (1..64)
        u64 sys_entry;     // the S1 EPROCESS VA (payload cross-check)
        u32 name_ofs;      // discovered name slot (0 = none)
        u32 closed;        // 1 = the circle closed before the cap
        u32 pages;         // page-reads spent (budget evidence)
        u32 stored;        // entries actually stored (<= out_n)
    };

    static inline void ClearEntries(Entry* out, u32 out_n) {
        for (u32 i = 0; i < out_n; i++) {
            out[i].pid = 0; out[i].flags = 0; out[i].eproc = 0;
            for (u32 k = 0; k < 8; k++) out[i].name[k] = 0;
            out[i].pad = 0;
        }
    }

    // ================= symbol -> EPROCESS (v24 chain) =============
    // S1: kx::Resolve (in-image, budgeted, printable-gated).
    // S2: DEREF the pointer slot via two gated in-image Rd32
    //     reads (rva+4 <= size each, the 1,000,000-byte budget)
    //     - NO new trust root: the slot lives inside the same
    //     validated image every export read already comes from.
    // The returned EPROCESS VA is NOT trusted here - WalkCore
    // validates it (canonical + pid==4 + LIST_ENTRY consistency
    // + the +-4 GB pool window + budgets). False = resolve or
    // deref refused (caller maps it to kPwNoEntry).
    static inline bool SysEprocessFromSymbol(kx::Ctx* c,
                                             const char* name,
                                             u32 name_len,
                                             u64* out_sym_va,
                                             u64* out_eproc) {
        kx::ResolveResult s1 = kx::Resolve(c, name, name_len);
        if (s1.rc != 1) return false;               // refused
        u32 rva = (u32)(s1.resolved_va - c->base);  // < c->size
        u32 lo = 0, hi = 0;
        if (!kx::Rd32(c, rva, &lo))     return false;
        if (!kx::Rd32(c, rva + 4, &hi)) return false;
        if (out_sym_va) *out_sym_va = s1.resolved_va;
        if (out_eproc)  *out_eproc  = (u64)lo | ((u64)hi << 32);
        return true;
    }

    // ================= pure walk core =================
    // sys_eproc: the kx-resolved PsInitialSystemProcess value
    // (op-11 resolves it fresh; the [PW] sys trace must equal the
    // M1 field value — the built-in cross-check).
    static inline Result WalkCore(u64 sys_eproc, Entry* out, u32 out_n,
                                  Budget* bud) {
        Result r{};
        r.status = kPwBadArgs;
        if (!out || !bud || out_n == 0 || out_n > kPwMaxOut) return r;
        ClearEntries(out, out_n);

        // ---- W1: the System entry itself ----
        r.status = kPwBadEntry;
        if (sys_eproc < kPwMinKernel ||
            sys_eproc > kPwMaxKernel - 0x800ULL)
            return r;                               // canonical + head room
        u64 pid_va   = sys_eproc + kPwOfsPid;
        u64 links_va = sys_eproc + kPwOfsLinks;

        if (!SpendPage(bud)) { r.status = kPwBudget; return r; }
        r.status = kPwNotSys;
        if (PW_R64(pid_va) != kPwSysPid) return r;  // pid@S1 must be 4

        out[0].pid = (u32)kPwSysPid;                // entries[0] = System
        out[0].eproc = sys_eproc;
        r.sys_entry = sys_eproc;
        r.stored = 1;
        r.count  = 1;

        // ---- W2: the bounded circular walk ----
        u64 cur = links_va;              // the link field we leave
        u64 prev = 0;                    // the link field we came from
        u32 n = 1;
        u32 fail = 0;                    // 0 = healthy so far
        while (n < kPwMaxEntries) {
            // {Flink, Blink} at cur — cur is always a gated link VA
            if (cur < kPwMinKernel || cur > kPwMaxKernel - 16) {
                fail = kPwBrokenLink; break;
            }
            if (!SpendPage(bud)) { fail = kPwBudget; break; }
            u64 flink = PW_R64(cur);
            u64 blink = PW_R64(cur + 8);
            if (flink < kPwMinKernel + kPwOfsLinks ||
                flink > kPwMaxKernel - 16) {
                fail = kPwBrokenLink; break;        // non-canonical next
            }
            if (prev != 0 && blink != prev) {
                fail = kPwBrokenLink; break;        // backward consistency
            }
            u64 next_link  = flink;
            u64 next_entry = next_link - kPwOfsLinks;
            // pool-cluster window (free on healthy, kills wild chases)
            u64 d = (next_entry > sys_eproc) ? next_entry - sys_eproc
                                             : sys_eproc - next_entry;
            if (d > kPwWindow) { fail = kPwWindowRefused; break; }
            if (next_link == links_va) { r.closed = 1; break; }  // circle
            // forward consistency: Blink(next) == cur, BEFORE advancing
            if (!SpendPage(bud)) { fail = kPwBudget; break; }
            if (PW_R64(next_link + 8) != cur) {
                fail = kPwBrokenLink; break;
            }
            if (!SpendPage(bud)) { fail = kPwBudget; break; }
            u64 npid = PW_R64(next_entry + kPwOfsPid);
            if (r.stored < out_n) {
                out[r.stored].pid = (u32)npid;
                out[r.stored].eproc = next_entry;
                r.stored++;
            }
            n++;
            prev = cur;
            cur = next_link;
        }
        if (fail != 0) {
            // mid-walk refusal: partial results are NOT trusted
            ClearEntries(out, out_n);
            r.count = 0; r.stored = 0; r.closed = 0;
            r.status = fail;
            r.pages = bud->pages;
            return r;
        }
        r.status = kPwOk;
        r.count  = n;
        r.pages  = bud->pages;

        // ---- W3: name slot discovery (failure = no names, walk OK) ----
        r.name_ofs = 0;
        u32 best_ofs = 0;
        for (u32 c = 0; c < kPwNameCands; c++) {
            u32 ofs = 0x560 + c * 8;
            u64 nva = sys_eproc + ofs;
            if (nva > kPwMaxKernel - 8) break;
            if (!SpendPage(bud)) break;             // stop probing, no names
            if (PW_R8(nva + 0) == 'S' && PW_R8(nva + 1) == 'y' &&
                PW_R8(nva + 2) == 's' && PW_R8(nva + 3) == 't' &&
                PW_R8(nva + 4) == 'e' && PW_R8(nva + 5) == 'm' &&
                PW_R8(nva + 6) == 0) { best_ofs = ofs; break; }
        }
        if (best_ofs) {
            // printability cross-check on the first stored entries
            u32 printable = 0;
            u32 check_n = (r.stored < 4) ? r.stored : 4;
            for (u32 e = 0; e < check_n; e++) {
                u64 nva = out[e].eproc + best_ofs;
                if (nva > kPwMaxKernel - 8) break;
                if (!SpendPage(bud)) break;
                bool pr = false;
                for (u32 k = 0; k < 8; k++) {
                    u8 ch = PW_R8(nva + k);
                    out[e].name[k] = ch;
                    if (ch >= 0x20 && ch < 0x7F) { pr = true; }
                    else break;
                }
                if (pr) printable++;
            }
            if (printable >= 2) {
                r.name_ofs = best_ofs;
                for (u32 e = 0; e < r.stored; e++) {
                    u64 nva = out[e].eproc + best_ofs;
                    if (nva > kPwMaxKernel - 8) break;
                    if (!SpendPage(bud)) break;
                    for (u32 k = 0; k < 8; k++)
                        out[e].name[k] = PW_R8(nva + k);
                    out[e].flags = 1;
                }
            } else {
                for (u32 e = 0; e < r.stored; e++)
                    for (u32 k = 0; k < 8; k++) out[e].name[k] = 0;
            }
        }
        r.pages = bud->pages;
        return r;
    }

} // namespace pw
} // namespace UEFIBridge
