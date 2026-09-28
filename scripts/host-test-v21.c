// ============================================================================
// host-test-v21.c — unit-test the REAL KernelExports.h resolve logic
// (compiled with -DKERNEL_EXPORTS_HOST_TEST -DKERNEL_ANCHOR_HOST_TEST:
// this file provides KX_R8/KX_R16/KX_R32 + AN_R16/AN_R32 backed by a
// synthetic map).
//
// v21 = F2 PROPER: resolve exported symbols of the VALIDATED image by
// name. The parse reads ONLY inside [pe_base, pe_base+pe_size) with
// every rva bounds-checked — the harness counts out-of-map reads and
// the suite asserts ZERO across all cases.
//
// Cases:
//   T1  CONVERGED + RESOLVE DATA SYMBOL — anchors via the real
//       DiscoverCore, then "PsInitialSystemProcess" -> exact VA
//   T2  RESOLVE SECOND DATA SYMBOL      — "NtBuildNumber" -> exact VA
//   T3  RESOLVE TEXT SYMBOL             — "KeBugCheckEx" -> exact VA
//   T4  NOT FOUND                       — absent name -> kXNotFound
//   T5  CASE SENSITIVITY                — "ntbuildnumber" -> not found
//   T6  BAD ARGS — empty / over-long / space / control char / null ->
//                       kXBadName, ZERO reads consumed
//   T7  NOT CONVERGED — fail-closed/not-run anchors -> kXNotConverged,
//                       ZERO memory reads (both states)
//   T8  FORWARDER — func RVA inside the export directory ->
//                       kXForwarder, va=0, not resolved
//   T9a CORRUPT ARRAYS — names-array RVA beyond the image ->
//                       kXCorrupt (fail-closed, no OOB read)
//   T9b CORRUPT STRING — name string matches to the image edge with
//                       no NUL -> kXCorrupt
//   T10 CORRUPT ORDINAL — ordinal >= NumberOfFunctions -> kXCorrupt
//   T11 CORRUPT FUNC RVA — function RVA beyond the image -> kXCorrupt
//   T12 END-TO-END — the v20 containing-walk (nested-PE geometry)
//                       converges with skip, THEN resolve on the same
//                       boot state
//
// Build:
//   g++ -std=c++17 -DKERNEL_EXPORTS_HOST_TEST -DKERNEL_ANCHOR_HOST_TEST
//       -I <tree>/UEFI/include -o host-test-v21 host-test-v21.c
// ============================================================================
#include <cstdint>
#include <cstddef>
#include <cstdio>
#include <cstring>
#include <vector>
#include <string>

#include "KernelAnchor.h"
#include "KernelExports.h"

using namespace UEFIBridge::ka;
using namespace UEFIBridge::kx;

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
namespace UEFIBridge { namespace kx {
std::uint8_t  KX_R8(std::uint64_t va) {
    g_reads++;
    uint8_t* p = map_ptr(va, 1);
    if (!p) { g_outside++; return 0; }
    return *p;
}
std::uint16_t KX_R16(std::uint64_t va) {
    g_reads++;
    uint8_t* p = map_ptr(va, 2);
    if (!p) { g_outside++; return 0; }
    uint16_t v; memcpy(&v, p, 2); return v;
}
std::uint32_t KX_R32(std::uint64_t va) {
    g_reads++;
    uint8_t* p = map_ptr(va, 4);
    if (!p) { g_outside++; return 0; }
    uint32_t v; memcpy(&v, p, 4); return v;
}
}} // namespace

// ---------------------------------------------------------------- builders
static void put16(std::vector<uint8_t>& b, size_t o, uint16_t v) { memcpy(&b[o], &v, 2); }
static void put32(std::vector<uint8_t>& b, size_t o, uint32_t v) { memcpy(&b[o], &v, 4); }

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
        put32(img, s + 12, 0x1000 * (i + 1));  // VirtualAddress
    }
}

static void idt_write(std::vector<uint8_t>& idt, uint32_t vector, uint64_t handler) {
    size_t e = (size_t)vector * 16;
    put16(idt, e + 0, (uint16_t)(handler & 0xFFFF));
    put16(idt, e + 2, 0x0030);
    put16(idt, e + 4, 0x8E00);
    put16(idt, e + 6, (uint16_t)((handler >> 16) & 0xFFFF));
    put32(idt, e + 8, (uint32_t)(handler >> 32));
}

// ---------------------------------------------------------------- export table
// Image layout (RVAs): header 0..0xFFF, export dir 0x2000..0x20FF,
// arrays 0x2100.., strings 0x2600.., exported data 0x3000/0x3100,
// exported "code" 0x5000. Image size 0x20000 (ValidatePEAt minimum).
struct ExpSym { const char* name; uint32_t rva; };
static const uint32_t kExpDir    = 0x2000;
static const uint32_t kArrFuncs = 0x2100;
static const uint32_t kArrNames = 0x2200;
static const uint32_t kArrOrds  = 0x2300;
static const uint32_t kStrings  = 0x2600;

// corrupt_what: 0 = clean, 1 = names-array RVA out of image,
// 3 = KeBugCheckEx ordinal OOB, 4 = ForwardSym -> forwarder RVA,
// 5 = KeBugCheckEx func RVA out of image.
static void exp_write(std::vector<uint8_t>& img, const ExpSym* syms,
                      size_t n, uint32_t corrupt_what) {
    put32(img, kExpDir + 0x10, 1);                    // Base (ordinal base)
    put32(img, kExpDir + 0x14, (uint32_t)n);          // NumberOfFunctions
    put32(img, kExpDir + 0x18, (uint32_t)n);          // NumberOfNames
    put32(img, kExpDir + 0x1C, kArrFuncs);
    put32(img, kExpDir + 0x20,
           corrupt_what == 1 ? 0x1FFFFF0 : kArrNames);
    put32(img, kExpDir + 0x24, kArrOrds);
    size_t pe = 0x80;                                 // e_lfanew
    put32(img, pe + 0x18 + 0x70, kExpDir);            // data dir 0 RVA
    put32(img, pe + 0x18 + 0x74, 0x100);              // data dir 0 size

    uint32_t str_off = 0;
    for (size_t i = 0; i < n; i++) {
        uint32_t fn = syms[i].rva;
        if (corrupt_what == 4 && strcmp(syms[i].name, "ForwardSym") == 0)
            fn = kExpDir + 0x10;                      // forwarder
        if (corrupt_what == 5 && strcmp(syms[i].name, "KeBugCheckEx") == 0)
            fn = 0x1FFFF0;                            // func RVA OOB
        put32(img, kArrFuncs + i * 4, fn);
        put32(img, kArrNames + i * 4, kStrings + str_off);
        uint16_t ord = (uint16_t)i;
        if (corrupt_what == 3 && strcmp(syms[i].name, "KeBugCheckEx") == 0)
            ord = (uint16_t)(n + 5);                  // ordinal OOB
        put16(img, kArrOrds + i * 2, ord);
        size_t len = strlen(syms[i].name);
        memcpy(&img[kStrings + str_off], syms[i].name, len + 1); // + NUL
        str_off += (uint32_t)len + 1;
    }
}

// The canonical symbol set (deliberately unsorted — the linear scan
// must not rely on export-name sortedness).
static const ExpSym kSyms[] = {
    {"ZzFiller",                0x4000},
    {"KeBugCheckEx",            0x5000},
    {"PsInitialSystemProcess",  0x3000},
    {"AaFiller",                0x4100},
    {"NtBuildNumber",           0x3100},
    {"ForwardSym",              0x5200},
};

// ---------------------------------------------------------------- helpers
static int g_fail = 0;
static void check(const char* name, bool cond, const std::string& detail = "") {
    printf("  [%s] %s%s%s\n", cond ? "PASS" : "FAIL", name,
           detail.empty() ? "" : " — ", detail.c_str());
    if (!cond) g_fail++;
}

static std::string hx(uint64_t v) {
    char b[32]; snprintf(b, sizeof b, "%llX", (unsigned long long)v);
    return std::string("0x") + b;
}

static const uint64_t IDT_BASE = 0xFFFF8E8080000000ULL;

// Image + IDT already built: add nothing, run the REAL DiscoverCore
// with in-image anchors, commit g_result.
static Result converge_only(uint64_t base) {
    map_add(IDT_BASE, 0x1000);
    { Region& idt = g_map.back();
      idt_write(idt.bytes, 0x0E, base + 0x6000);      // #PF handler
      idt_write(idt.bytes, 0x03, base + 0x6100); }    // #BP handler
    g_result = Result{};
    Result r{};
    DiscoverCore(&r, IDT_BASE, base + 0x6000, base + 0x6100, base + 0x6200);
    g_result = r;
    return r;
}

// Build image + IDT at the given base, run the REAL DiscoverCore with
// in-image anchors, commit g_result. corrupt_what as in exp_write.
static Result build_and_converge(uint64_t base, uint32_t corrupt_what) {
    map_add(base, 0x20000);
    { Region& img = g_map.back();
      pe_write(img.bytes, 0, 0x20000, 8);
      exp_write(img.bytes, kSyms, 6, corrupt_what); }
    return converge_only(base);
}

static ResolveResult resolve(const char* name) {
    ResolveResult r{};
    ResolveSymbol(name, (uint32_t)strlen(name), &r);
    return r;
}

int main() {
    const uint64_t BASE = 0xFFFFF80700000000ULL;

    printf("T1 CONVERGED + RESOLVE PsInitialSystemProcess\n");
    {
        uint64_t o0 = g_outside;
        Result an = build_and_converge(BASE, 0);
        check("anchors converged", an.state == kAnchorConverged,
              "state=" + std::to_string(an.state) +
              " reason=" + std::to_string(an.reason));
        check("pe_base/pe_size", an.pe_base == BASE && an.pe_size == 0x20000,
              hx(an.pe_base) + " + " + hx(an.pe_size));
        ResolveResult r = resolve("PsInitialSystemProcess");
        check("rc == kXOk", r.rc == kXOk, "rc=" + std::to_string(r.rc));
        check("va == base+0x3000", r.va == BASE + 0x3000, hx(r.va));
        check("name_index == 2", r.name_index == 2,
              std::to_string(r.name_index));
        check("name_len == 22", r.name_len == 22);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T2 RESOLVE NtBuildNumber (second data symbol)\n");
    {
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("NtBuildNumber");
        check("rc == kXOk", r.rc == kXOk, "rc=" + std::to_string(r.rc));
        check("va == base+0x3100", r.va == BASE + 0x3100, hx(r.va));
        check("name_index == 4", r.name_index == 4);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T3 RESOLVE KeBugCheckEx (text symbol)\n");
    {
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("KeBugCheckEx");
        check("rc == kXOk", r.rc == kXOk, "rc=" + std::to_string(r.rc));
        check("va == base+0x5000", r.va == BASE + 0x5000, hx(r.va));
        check("name_index == 1", r.name_index == 1);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T4 NOT FOUND (absent name)\n");
    {
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("NoSuchSymbolV28");
        check("rc == kXNotFound", r.rc == kXNotFound,
              "rc=" + std::to_string(r.rc));
        check("va == 0", r.va == 0);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T5 CASE SENSITIVITY (ntbuildnumber != NtBuildNumber)\n");
    {
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("ntbuildnumber");
        check("rc == kXNotFound", r.rc == kXNotFound,
              "rc=" + std::to_string(r.rc));
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T6 BAD ARGS (empty / over-long / space / control / null)\n");
    {
        uint64_t r0 = g_reads;
        ResolveResult r{};
        ResolveSymbol("", 0, &r);
        check("empty -> kXBadName", r.rc == kXBadName);
        char longname[65]; memset(longname, 'A', 65); longname[64] = 0;
        ResolveSymbol(longname, 65, &r);
        check("over-long -> kXBadName", r.rc == kXBadName);
        ResolveSymbol("Bad Name", 8, &r);
        check("space -> kXBadName", r.rc == kXBadName);
        char ctrl[8]; memcpy(ctrl, "Bad\01Name", 8);
        ResolveSymbol(ctrl, 8, &r);
        check("control char -> kXBadName", r.rc == kXBadName);
        ResolveSymbol(nullptr, 4, &r);
        check("null name -> kXBadName", r.rc == kXBadName);
        check("bad args consumed ZERO reads", g_reads == r0);
    }

    printf("T7 NOT CONVERGED (refuse BEFORE any read, both states)\n");
    {
        g_map.clear();
        map_add(BASE, 0x20000);
        { Region& img = g_map.back();
          pe_write(img.bytes, 0, 0x20000, 8);
          exp_write(img.bytes, kSyms, 6, 0); }
        uint64_t r0 = g_reads;
        g_result = Result{};                          // kAnchorNotRun
        ResolveResult r = resolve("PsInitialSystemProcess");
        check("not-run -> kXNotConverged", r.rc == kXNotConverged,
              "rc=" + std::to_string(r.rc));
        check("va == 0", r.va == 0);
        check("zero memory reads", g_reads == r0);
        g_result.state = kAnchorFailClosed;
        r = resolve("PsInitialSystemProcess");
        check("fail-closed -> kXNotConverged", r.rc == kXNotConverged);
        check("still zero memory reads", g_reads == r0);
    }

    printf("T8 FORWARDER (func RVA inside the export directory)\n");
    {
        g_map.clear();
        Result an = build_and_converge(BASE, 4);
        check("anchors converged (corruption is export-only)",
              an.state == kAnchorConverged);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("ForwardSym");
        check("rc == kXForwarder", r.rc == kXForwarder,
              "rc=" + std::to_string(r.rc));
        check("va == 0 (not resolved)", r.va == 0);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T9a CORRUPT: names-array RVA beyond the image\n");
    {
        g_map.clear();
        Result an = build_and_converge(BASE, 1);
        check("anchors converged (corruption is export-only)",
              an.state == kAnchorConverged);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("PsInitialSystemProcess");
        check("rc == kXCorrupt", r.rc == kXCorrupt,
              "rc=" + std::to_string(r.rc));
        check("va == 0", r.va == 0);
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T9b CORRUPT: name string matches to the image edge, no NUL\n");
    {
        g_map.clear();
        map_add(BASE, 0x20000);
        { Region& img = g_map.back();
          pe_write(img.bytes, 0, 0x20000, 8);
          exp_write(img.bytes, kSyms, 6, 0);
          // names[0] -> the exact target name written so it ENDS at
          // the image edge with NO NUL (the next byte is out of image)
          const char* nm = "PsInitialSystemProcess";   // 22 chars
          put32(img.bytes, kArrNames + 0, 0x20000 - 22);
          memcpy(&img.bytes[0x20000 - 22], nm, 22); }
        Result an = converge_only(BASE);
        check("anchors converged", an.state == kAnchorConverged);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("PsInitialSystemProcess");
        check("rc == kXCorrupt", r.rc == kXCorrupt,
              "rc=" + std::to_string(r.rc));
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T10 CORRUPT: ordinal >= NumberOfFunctions\n");
    {
        g_map.clear();
        Result an = build_and_converge(BASE, 3);
        check("anchors converged (corruption is export-only)",
              an.state == kAnchorConverged);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("KeBugCheckEx");
        check("rc == kXCorrupt", r.rc == kXCorrupt,
              "rc=" + std::to_string(r.rc));
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T11 CORRUPT: function RVA beyond the image\n");
    {
        g_map.clear();
        Result an = build_and_converge(BASE, 5);
        check("anchors converged (corruption is export-only)",
              an.state == kAnchorConverged);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("KeBugCheckEx");
        check("rc == kXCorrupt", r.rc == kXCorrupt,
              "rc=" + std::to_string(r.rc));
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("T12 END-TO-END: containing-walk skips the nested PE, "
           "then resolve\n");
    {
        // the v25/v26 field geometry (scaled to the synthetic image):
        // true image F = [BASE, BASE+0x200000), a structurally-valid
        // nested PE at BASE+0x160000 (size 0x20000) that does NOT
        // contain the anchors; anchors ABOVE it at +0x190000.. — the
        // walk must SKIP the nested PE and converge on F.
        g_map.clear();
        const uint64_t NEST = BASE + 0x160000;
        map_add(BASE, 0x200000);
        { Region& img = g_map.back();
          pe_write(img.bytes, 0, 0x200000, 8);
          exp_write(img.bytes, kSyms, 6, 0);
          pe_write(img.bytes, 0x160000, 0x20000, 4); }  // nested PE
        map_add(IDT_BASE, 0x1000);
        const uint64_t pf = BASE + 0x190000;
        const uint64_t bp = BASE + 0x191000;
        const uint64_t ls = BASE + 0x192000;
        { Region& idt = g_map.back();
          idt_write(idt.bytes, 0x0E, pf);
          idt_write(idt.bytes, 0x03, bp); }
        g_result = Result{};
        Result an{};
        DiscoverCore(&an, IDT_BASE, pf, bp, ls);
        g_result = an;
        check("walk skipped the nested PE (all three)",
              an.v1_skips == 1 && an.v2_skips == 1 && an.v3_skips == 1 &&
              an.v1_last_skip == NEST && an.v2_last_skip == NEST &&
              an.v3_last_skip == NEST,
              "skips=" + std::to_string(an.v1_skips) + "," +
              std::to_string(an.v2_skips) + "," +
              std::to_string(an.v3_skips) + " last=" + hx(an.v1_last_skip));
        check("converged on the true image",
              an.state == kAnchorConverged && an.pe_base == BASE &&
              an.pe_size == 0x200000);
        uint64_t o0 = g_outside;
        ResolveResult r = resolve("PsInitialSystemProcess");
        check("resolve after containing-walk: kXOk",
              r.rc == kXOk, "rc=" + std::to_string(r.rc));
        check("va == base+0x3000", r.va == BASE + 0x3000, hx(r.va));
        check("zero out-of-map reads", g_outside == o0);
    }

    printf("\nchecks failed: %d\n", g_fail);
    printf("total map reads: %llu, out-of-map: %llu\n",
           (unsigned long long)g_reads, (unsigned long long)g_outside);
    if (g_fail == 0 && g_outside == 0) {
        printf("ALL CHECKS PASSED — v21 export resolution is host-proven\n");
        return 0;
    }
    return 1;
}
