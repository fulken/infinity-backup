// ============================================================================
// host-test-v20.c — unit-test the REAL KernelAnchor.h discovery logic
// (compiled with -DKERNEL_ANCHOR_HOST_TEST: this file provides the two
// read primitives backed by a synthetic memory map).
//
// v20 = THE CONTAINING-WALK: a walk candidate is accepted only if the
// image CONTAINS the anchor it was walked from; valid-but-not-containing
// PEs are skipped + counted (Result vN_skips / vN_last_skip).
//
// Cases (delta vs host-test-v19 in CAPS):
//   T1 VALID       — converges; correct base/size; ZERO out-of-map reads
//   T2 WALK BOUND  — LSTAR >32MB below any PE -> WalkBound3 (fail-closed)
//   T3 MISMATCH    — #PF in image X, #BP in image Y -> Mismatch
//                    (containing-walk still lands each walk on its OWN
//                    containing image — mismatch semantics preserved)
//   T4 PE INVALID  — corrupt SizeOfImage -> walk REJECTS the candidate
//                    -> WalkBound1 (structural rejection proven)
//   T5 ANCHOR ABOVE IMAGE END — WAS Contain(6); NOW: the image does not
//                    CONTAIN LSTAR so it is SKIPPED (skips=1, last=X)
//                    and the walk runs to the bound -> WalkBound3
//   T6 IDT INVALID — IDT base 0 -> IdtInvalid
//   T7 ANCHOR BAD  — non-canonical handler VA -> AnchorInvalid
//   T8 NESTED PE   — WAS Contain(6) (the v25 FIELD TRAP); NOW: the
//                    nested PE is SKIPPED and the walks converge on the
//                    TRUE containing image -> CONVERGED on X
//   T9 FIELD REPLAY — the EXACT v25 field geometry (real VAs from the
//                    2026-09-26 run): true base below a nested valid PE
//                    at 0xFFFFF8046BD60000, anchors at
//                    0xFFFFF8046C00B540/DF00/11C00 -> CONVERGED on the
//                    true base, one skip per walk, zero stray reads
//   T10 COVERING NEST — documented corner: a nested PE whose range
//                    COVERS all anchors is accepted (first-hit-wins).
//                    Still a fully-validated PE containing every anchor
//                    (safe-subset contract); outermost preference needs
//                    F4 page-table validation (probe-safety), not a
//                    walk rule.
//
// Build:
//   g++ -std=c++17 -DKERNEL_ANCHOR_HOST_TEST
//       -I <tree>/UEFI/include -o host-test-v20 host-test-v20.c
// ============================================================================
#include <cstdint>
#include <cstddef>
#include <cstdio>
#include <cstring>
#include <vector>
#include <string>

#include "KernelAnchor.h"

using namespace UEFIBridge::ka;

// ---------------------------------------------------------------- synthetic map
struct Region { uint64_t base; std::vector<uint8_t> bytes; };
static std::vector<Region> g_map;
static uint64_t g_reads = 0, g_outside = 0;

static void map_add(uint64_t base, size_t size) {
    g_map.push_back({base, std::vector<uint8_t>(size, 0)});
}
static uint8_t* map_ptr(uint64_t va, size_t len) {
    for (auto& r : g_map)
        if (va >= r.base && va - r.base + len <= r.bytes.size())
            return &r.bytes[va - r.base];
    return nullptr;
}

namespace UEFIBridge { namespace ka {
std::uint16_t AN_R16(std::uint64_t va) {
    g_reads++;
    uint8_t* p = map_ptr(va, 2);
    if (!p) { g_outside++; return 0; }
    uint16_t v; memcpy(&v, p, 2); return v;
}
std::uint32_t AN_R32(std::uint64_t va) {
    g_reads++;
    uint8_t* p = map_ptr(va, 4);
    if (!p) { g_outside++; return 0; }
    uint32_t v; memcpy(&v, p, 4); return v;
}
}} // namespace

// ---------------------------------------------------------------- builders
static void put16(std::vector<uint8_t>& b, size_t o, uint16_t v) { memcpy(&b[o], &v, 2); }
static void put32(std::vector<uint8_t>& b, size_t o, uint32_t v) { memcpy(&b[o], &v, 4); }

// Write a FULLY valid PE32+ header at img offset `off` (must be 64KB-aligned).
static void pe_write(std::vector<uint8_t>& img, size_t off,
                     uint32_t size_img, uint32_t nsec) {
    put16(img, off + 0x00, 0x5A4D);            // 'MZ'
    put32(img, off + 0x3C, 0x80);              // e_lfanew
    size_t pe = off + 0x80;
    put32(img, pe + 0x00, 0x00004550);         // 'PE\0\0'
    put16(img, pe + 0x04, 0x8664);             // AMD64
    put16(img, pe + 0x06, (uint16_t)nsec);     // NumberOfSections
    put16(img, pe + 0x14, 0x00F0);             // SizeOfOptionalHeader
    put16(img, pe + 0x18, 0x020B);             // PE32+ magic
    put32(img, pe + 0x28, 0x1000);             // AddressOfEntryPoint
    put32(img, pe + 0x50, size_img);           // SizeOfImage
    put32(img, pe + 0x54, 0x400);              // SizeOfHeaders
    size_t sec0 = pe + 0x18 + 0xF0;
    for (uint32_t i = 0; i < nsec; i++) {
        size_t s = sec0 + (size_t)i * 40;
        put32(img, s + 8,  0x1000);            // VirtualSize
        put32(img, s + 12, 0x1000 * (i + 1));  // VirtualAddress (page aligned, ascending)
    }
}

// 16-byte x64 IDT gate for `handler`.
static void idt_write(std::vector<uint8_t>& idt, uint32_t vector, uint64_t handler) {
    size_t e = (size_t)vector * 16;
    put16(idt, e + 0, (uint16_t)(handler & 0xFFFF));
    put16(idt, e + 2, 0x0030);                          // selector (not validated)
    put16(idt, e + 4, 0x8E00);                          // ist/attr (not validated)
    put16(idt, e + 6, (uint16_t)((handler >> 16) & 0xFFFF));
    put32(idt, e + 8, (uint32_t)(handler >> 32));
}

static Result run(uint64_t idt_base, uint64_t pf, uint64_t bp, uint64_t lstar) {
    g_result = Result{};          // reset boot state between cases
    Result r{};
    DiscoverCore(&r, idt_base, pf, bp, lstar);
    return r;
}

static int g_fail = 0;
static void check(const char* name, bool cond, const std::string& detail = "") {
    printf("  [%s] %s%s%s\n", cond ? "PASS" : "FAIL", name,
           detail.empty() ? "" : " — ", detail.c_str());
    if (!cond) g_fail++;
}

int main() {
    const uint64_t X = 0xFFFFF80000100000ULL;   // "ntoskrnl" base
    const uint64_t Y = 0xFFFFF80001000000ULL;   // second image
    const uint64_t IDT = 0xFFFFF8000F000000ULL; // IDT page
    const uint32_t  XSZ = 0x400000u;            // 4 MB image
    const uint32_t  YSZ = 0x40000u;             // 256 KB image

    printf("== T1: valid image, all anchors inside ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(Y, YSZ); map_add(IDT, 0x1000);
        auto& img = g_map[0].bytes;
        pe_write(img, 0, XSZ, 6);
        pe_write(g_map[1].bytes, 0, YSZ, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100, ls = X + 0x1000;
        idt_write(g_map[2].bytes, 0x0E, pf);
        idt_write(g_map[2].bytes, 0x03, bp);
        // parse path exercised through IdtHandlerVA:
        uint64_t pf2 = IdtHandlerVA(IDT, 0x0E), bp2 = IdtHandlerVA(IDT, 0x03);
        check("T1-idt-parse-pf", pf2 == pf, "idt->handler round trip");
        check("T1-idt-parse-bp", bp2 == bp, "idt->handler round trip");
        Result r = run(IDT, pf2, bp2, ls);
        check("T1-converged", r.state == kAnchorConverged,
              "state=" + std::to_string(r.state) + " reason=" + std::to_string(r.reason));
        check("T1-base", r.pe_base == X);
        check("T1-size", r.pe_size == XSZ);
        check("T1-walks-equal", r.walk_v1 == X && r.walk_v2 == X && r.walk_v3 == X);
        check("T1-zero-skips", r.v1_skips == 0 && r.v2_skips == 0 && r.v3_skips == 0,
              "clean image walk skips nothing");
        check("T1-no-stray-reads", g_outside == 0,
              "out-of-map reads: " + std::to_string(g_outside));
    }

    printf("== T2: LSTAR 32+MB below any PE -> WalkBound3 ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100;
        uint64_t ls = X - 0x3000000ULL;   // 48MB below X, nothing beneath
        idt_write(g_map[1].bytes, 0x0E, pf);
        idt_write(g_map[1].bytes, 0x03, bp);
        Result r = run(IDT, IdtHandlerVA(IDT, 0x0E), IdtHandlerVA(IDT, 0x03), ls);
        check("T2-fail-closed", r.state == kAnchorFailClosed);
        check("T2-reason-walkbound3", r.reason == kAnReason_WalkBound3,
              "reason=" + std::to_string(r.reason));
        check("T2-bounded-probes", g_outside <= 512,
              "out-of-map probes: " + std::to_string(g_outside));
    }

    printf("== T3: anchors in two different images -> Mismatch ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(Y, YSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        pe_write(g_map[1].bytes, 0, YSZ, 6);
        uint64_t pf = X + 0x3F0000;       // walks to X
        uint64_t bp = Y + 0x30000;        // walks to Y
        uint64_t ls = X + 0x1000;         // walks to X
        Result r = run(IDT, pf, bp, ls);
        check("T3-fail-closed", r.state == kAnchorFailClosed);
        check("T3-reason-mismatch", r.reason == kAnReason_Mismatch,
              "reason=" + std::to_string(r.reason));
        check("T3-walk-results", r.walk_v1 == X && r.walk_v2 == Y,
              "v1/v2 landed on their own images (containing-walk)");
    }

    printf("== T4: corrupt PE (SizeOfImage not aligned) -> rejected ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        put32(g_map[0].bytes, 0x80 + 0x50, XSZ + 0x123);   // corrupt: not page-aligned
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100, ls = X + 0x1000;
        Result r = run(IDT, pf, bp, ls);
        check("T4-walk-rejected-candidate", r.walk_v1 == 0,
              "walk did not accept the corrupt image");
        check("T4-fail-closed", r.state == kAnchorFailClosed);
        check("T4-reason-walkbound1", r.reason == kAnReason_WalkBound1,
              "reason=" + std::to_string(r.reason));
    }

    printf("== T5: LSTAR above image end -> skipped -> WalkBound3 (v20) ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100;
        uint64_t ls = X + XSZ + 0x10000;  // one 64KB block above the image
        Result r = run(IDT, pf, bp, ls);
        check("T5-walk3-bounded", r.walk_v3 == 0,
              "no image CONTAINS the out-of-image anchor -> 0");
        check("T5-skip-counted", r.v3_skips == 1 && r.v3_last_skip == X,
              "the image itself was the skipped candidate");
        check("T5-fail-closed", r.state == kAnchorFailClosed);
        check("T5-reason-walkbound3", r.reason == kAnReason_WalkBound3,
              "reason=" + std::to_string(r.reason) +
              " (was Contain in v19 — semantics documented)");
    }

    printf("== T6: IDT base 0 -> IdtInvalid ==\n");
    {
        Result r = run(0, X + 0x3F0000, X + 0x3F0100, X + 0x1000);
        check("T6-fail-closed", r.state == kAnchorFailClosed);
        check("T6-reason-idt", r.reason == kAnReason_IdtInvalid);
    }

    printf("== T7: non-canonical anchor VA -> AnchorInvalid ==\n");
    {
        Result r = run(IDT, 0x41410000ULL, X + 0x3F0100, X + 0x1000);
        check("T7-fail-closed", r.state == kAnchorFailClosed);
        check("T7-reason-anchor", r.reason == kAnReason_AnchorInvalid);
    }

    printf("== T8: nested PE inside the image -> SKIPPED, converge on TRUE (v20) ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        // fully-valid nested PE 64KB-aligned inside the image, small size:
        const uint64_t N = X + 0x300000ULL;
        pe_write(g_map[0].bytes, 0x300000, 0x40000u, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100, ls = X + 0x3F0200;
        Result r = run(IDT, pf, bp, ls);
        check("T8-converged-on-true", r.state == kAnchorConverged,
              "the v25 field trap is now SOLVED, not just caught");
        check("T8-base", r.pe_base == X && r.pe_size == XSZ);
        check("T8-walks-equal", r.walk_v1 == X && r.walk_v2 == X && r.walk_v3 == X);
        check("T8-nested-skipped", r.v1_skips == 1 && r.v1_last_skip == N &&
                                   r.v2_skips == 1 && r.v3_skips == 1,
              "each walk skipped exactly the nested PE");
        check("T8-no-stray-reads", g_outside == 0,
              "the skip path stayed inside the true image");
    }

    printf("== T9: FIELD REPLAY — the exact v25 run geometry (2026-09-26) ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        // the REAL field values from serial [AN]:
        const uint64_t F  = 0xFFFFF8046BD20000ULL;   // plausible true base
        const uint32_t FSZ = 0x440000u;              // ~4.4MB (ntoskrnl)
        const uint64_t NEST = 0xFFFFF8046BD60000ULL; // the FALSE converged base
        const uint64_t pf = 0xFFFFF8046C00DF00ULL;   // idt pf  (field)
        const uint64_t bp = 0xFFFFF8046C00B540ULL;   // idt bp  (field)
        const uint64_t ls = 0xFFFFF8046C011C00ULL;   // lstar   (field)
        const uint64_t IDT2 = 0xFFFFF8047246C000ULL; // sidt    (field)
        map_add(F, FSZ);                             // the true image
        map_add(IDT2, 0x1000);                       // IDT (not read here)
        pe_write(g_map[0].bytes, 0, FSZ, 6);
        // the nested valid PE sits INSIDE the true image (offset 0x40000):
        pe_write(g_map[0].bytes, 0x40000, 0x20000u, 6);
        check("T9-geometry", NEST == F + 0x40000,
              "nested PE at the exact field false base");
        Result r = run(IDT2, pf, bp, ls);
        check("T9-converged", r.state == kAnchorConverged,
              "state=" + std::to_string(r.state) + " reason=" + std::to_string(r.reason));
        check("T9-true-base", r.pe_base == F && r.pe_size == FSZ);
        check("T9-walks-all-true", r.walk_v1 == F && r.walk_v2 == F && r.walk_v3 == F);
        check("T9-skips-nested", r.v1_skips == 1 && r.v1_last_skip == NEST &&
                                  r.v2_skips == 1 && r.v2_last_skip == NEST &&
                                  r.v3_skips == 1 && r.v3_last_skip == NEST,
              "all three walks skipped exactly the field false base");
        check("T9-no-stray-reads", g_outside == 0,
              "every probe stayed inside the true image (probe-safety)");
    }

    printf("== T10: covering nested PE — documented corner (first-hit-wins) ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        // nested PE whose range COVERS the anchors (X+0x100000..X+0x400000):
        const uint64_t N = X + 0x100000ULL;
        pe_write(g_map[0].bytes, 0x100000, 0x300000u, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100, ls = X + 0x3F0200;
        Result r = run(IDT, pf, bp, ls);
        check("T10-converged-on-covering", r.state == kAnchorConverged &&
              r.pe_base == N && r.pe_size == 0x300000u,
              "KNOWN CORNER: first-hit-wins accepts the covering image");
        check("T10-safe-subset", r.walk_v1 == N && r.walk_v2 == N && r.walk_v3 == N &&
              pf >= N && bp >= N && ls >= N && ls < N + 0x300000u,
              "opened range is still a valid PE containing all anchors");
        check("T10-zero-skips", r.v1_skips == 0,
              "nothing skipped on the way");
    }

    printf("\n%s (%d failures)\n", g_fail == 0 ? "ALL TESTS PASSED" : "TESTS FAILED", g_fail);
    return g_fail == 0 ? 0 : 1;
}
