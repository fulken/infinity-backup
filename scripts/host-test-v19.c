// ============================================================================
// host-test-v19.c — unit-test the REAL KernelAnchor.h discovery logic
// (compiled with -DKERNEL_ANCHOR_HOST_TEST: this file provides the two
// read primitives backed by a synthetic memory map).
//
// Cases:
//   T1 VALID       — converges; correct base/size; ZERO out-of-map reads
//   T2 WALK BOUND  — LSTAR >32MB below any PE -> WalkBound3 (fail-closed)
//   T3 MISMATCH    — #PF in image X, #BP in image Y -> Mismatch
//   T4 PE INVALID  — corrupt SizeOfImage -> walk REJECTS the candidate
//                    -> WalkBound1 (structural rejection proven)
//   T5 CONTAIN     — LSTAR just above the image end, walks still land on
//                    the image -> converged but containment fails -> Contain
//   T6 IDT INVALID — IDT base 0 -> IdtInvalid
//   T7 ANCHOR BAD  — non-canonical handler VA -> AnchorInvalid
//   T8 NESTED PE   — valid nested PE inside the image -> walks converge on
//                    the NESTED base -> containment backstop fires -> Contain
//
// Build:
//   g++ -std=c++17 -DKERNEL_ANCHOR_HOST_TEST
//       -I <tree>/UEFI/include -o host-test-v19 host-test-v19.c
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
              "v1/v2 landed on their own images");
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

    printf("== T5: LSTAR above image end -> converged but Contain ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100;
        uint64_t ls = X + XSZ + 0x10000;  // one 64KB block above the image
        Result r = run(IDT, pf, bp, ls);
        check("T5-walks-still-converge", r.walk_v3 == X,
              "walk skipped the empty block and landed on X");
        check("T5-fail-closed", r.state == kAnchorFailClosed);
        check("T5-reason-contain", r.reason == kAnReason_Contain,
              "reason=" + std::to_string(r.reason));
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

    printf("== T8: nested PE inside the image -> Contain backstop ==\n");
    {
        g_map.clear(); g_reads = 0; g_outside = 0;
        map_add(X, XSZ); map_add(IDT, 0x1000);
        pe_write(g_map[0].bytes, 0, XSZ, 6);
        // fully-valid nested PE 64KB-aligned inside the image, small size:
        const uint64_t N = X + 0x300000ULL;
        pe_write(g_map[0].bytes, 0x300000, 0x40000u, 6);
        uint64_t pf = X + 0x3F0000, bp = X + 0x3F0100, ls = X + 0x3F0200;
        Result r = run(IDT, pf, bp, ls);
        check("T8-walks-land-on-nested", r.walk_v1 == N && r.walk_v2 == N && r.walk_v3 == N,
              "the nested PE captured all three walks");
        check("T8-fail-closed", r.state == kAnchorFailClosed);
        check("T8-reason-contain", r.reason == kAnReason_Contain,
              "reason=" + std::to_string(r.reason));
    }

    printf("\n%s (%d failures)\n", g_fail == 0 ? "ALL TESTS PASSED" : "TESTS FAILED", g_fail);
    return g_fail == 0 ? 0 : 1;
}
