// ===========================================================================
// host-test-v26.c — unit tests for the REAL v26 pure-logic headers
// (KernelExports.h + ProcessWalk.h + PageTableWalk.h: the FIXED F4
// engine) against synthetic memory. T1..T23 are the v24 suite unchanged
// (regression, 66 CHECKs); T24..T41 drive the page-table walk.
//
// THE TRUE-SEMANTICS WORLD (the seam-#5 fix): the v25 world was built
// from the same wrong slot formulas as the engine, so 89/89 passed
// while the field VM died (BSOD 0x50 on the first PTE-space read).
// The v26 world is a REAL 4-level hierarchy in simulated PHYSICAL
// memory; PT_R8 is served by hw_walk — an INDEPENDENT hardware-
// semantics walk (pure entry-following from the PML4). The PTE space
// is never mapped by hand: it EMERGES from the self-ref entry
// PML4E[s], exactly as on real hardware. A wrong slot formula reads
// an unresolvable VA -> the strict out-of-map ABORT = the BSOD
// replayed (the class-kill run compiles this test against the v25
// engine and must abort at the self-ref read 0xFFFFD58000000D58).
//
// GROUND TRUTH: T24 pins the engine helpers AND the world to the
// PUBLISHED classic s=0x1ED constants (PDE_BASE 0xFFFFF6FB40000000,
// PPE_BASE 0xFFFFF6FB7DA00000, PXE_BASE 0xFFFFF6FB7DBED000) —
// hard-coded literature values, breaking the world<->engine loop.
//
// Main world: s = 0x1AB, PTE_BASE = 0xFFFFD58000000000. The low-user
// half of the PML4 is EMPTY (every non-wired entry absent) — exactly
// the trigger script's caller context. Chains A/B read .data globals
// at the real observed RVAs (image extended to 0xCFD000).
//
// THE DISCIPLINE (v19 host-test lineage): every raw read goes through
// the hosted KX_R8/PW_R8, which HARD-FAILS on any address outside the
// registered synthetic regions. A test "passes" only if the logic
// under test NEVER strays out of its declared map — the exact safety
// property the VM's life depends on.
//
// v24 ADDS THE CLASS-KILL the v22/v23 harness lacked (the v31 field
// lesson): the harness tested kx::Resolve and pw::WalkCore SEPARATELY
// — the op-11 glue (walk must start at the DEREF'D EPROCESS, not at
// the symbol slot VA) was never exercised, and the missing deref
// shipped (field: [PW] sys=0xFFFFF8071A4FC420 -> walk=0 NotSys).
// v24 hoists the chain into pw::SysEprocessFromSymbol — the SAME
// inline function the driver's op-11 calls — and T23 drives it on a
// REALISTIC world: the symbol resolves to an in-image .data slot,
// the slot's VALUE points to a pool EPROCESS circle OUTSIDE the
// image, and slot+0x440 stays zero (.data garbage). A deref-less
// build can NEVER pass T23 again.
//
// Build:  g++ -std=c++11 -I<tree>/UEFI/include -o host26 host-test-v26.c
// ============================================================================
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <map>

#define KERNEL_EXPORTS_HOST_TEST
#define KERNEL_WALK_HOST_TEST
#define KERNEL_PT_HOST_TEST
#include "KernelExports.h"
#include "ProcessWalk.h"
#include "PageTableWalk.h"

// ==================== synthetic memory ====================
static std::map<std::uint64_t, std::uint8_t*> g_pages; // page -> buffer
static long g_reads = 0;
static bool g_strict = true;   // any out-of-map read aborts

static void map_page(std::uint64_t va) {
    std::uint64_t pg = va & ~0xFFFULL;
    if (g_pages.count(pg)) return;
    g_pages[pg] = (std::uint8_t*)calloc(1, 4096);
}
static void map_region(std::uint64_t va, std::uint64_t span) {
    for (std::uint64_t o = 0; o < span; o += 0x1000)
        map_page(va + o);
}
static void wr8(std::uint64_t va, std::uint8_t v) {
    std::uint64_t pg = va & ~0xFFFull;
    if (!g_pages.count(pg)) { fprintf(stderr, "FATAL: wr8 unmapped 0x%llx\n", (unsigned long long)va); exit(1); }
    g_pages[pg][va & 0xFFF] = v;
}
static void wr32(std::uint64_t va, std::uint32_t v) {
    for (int i = 0; i < 4; i++) wr8(va + i, (std::uint8_t)(v >> (8 * i)));
}
static void wr64(std::uint64_t va, std::uint64_t v) {
    for (int i = 0; i < 8; i++) wr8(va + i, (std::uint8_t)(v >> (8 * i)));
}
static void wrstr(std::uint64_t va, const char* s) {
    while (*s) wr8(va++, (std::uint8_t)*s++);
    wr8(va, 0);
}

// ==================== the pt physical world (v26) ====================
// Simulated physical memory + a REAL 4-level hierarchy. PT_R8 is
// served by hw_walk — the INDEPENDENT hardware-semantics walk. This is
// the seam-#5 fix: the world can no longer share the engine's slot
// formulas, because it does not KNOW them.
static std::map<std::uint64_t, std::uint8_t*> g_phys; // pfn -> frame
static std::uint64_t g_next_phys = 0x00100000ULL;     // alloc pointer
static std::uint64_t PML4_FR;   // the world PML4's phys frame
static std::uint32_t PTS;       // the self-map PML4 index
static std::uint64_t PTB;       // PTE_BASE = 0xFFFF..|(s<<39)

static std::uint8_t* phys(std::uint64_t addr) {
    std::uint64_t pfn = (addr & ~0xFFFull) >> 12;
    if (!g_phys.count(pfn)) {
        fprintf(stderr, "\n*** FATAL: phys() unmapped frame 0x%llx ***\n",
                (unsigned long long)(addr & ~0xFFFull));
        exit(1);
    }
    return g_phys[pfn] + (addr & 0xFFF);
}
static std::uint64_t ensure_frame(std::uint64_t frame) {
    if (frame & 0xFFF) {
        fprintf(stderr, "FATAL: ensure_frame misaligned 0x%llx\n",
                (unsigned long long)frame);
        exit(1);
    }
    if (!g_phys.count(frame >> 12))
        g_phys[frame >> 12] = (std::uint8_t*)calloc(1, 4096);
    return frame;
}
static std::uint64_t alloc_frame() {
    std::uint64_t f = ensure_frame(g_next_phys);
    g_next_phys += 0x1000;
    return f;
}

// THE INDEPENDENT WALK: 4 levels of pure entry-following from the
// PML4. Present bit only; a large page on the descent = the slot
// below does not exist as a page = fault (level 10+). Zero knowledge
// of PTE_BASE or any self-map slot formula.
static std::uint8_t* hw_walk(std::uint64_t va, int* fault_level) {
    static const int shifts[4] = {39, 30, 21, 12};
    std::uint64_t tbl = PML4_FR;
    for (int lvl = 0; lvl < 4; lvl++) {
        std::uint64_t e;
        std::memcpy(&e, phys(tbl) + (((va >> shifts[lvl]) & 0x1FF) * 8), 8);
        if (!(e & 1)) { if (fault_level) *fault_level = lvl; return 0; }
        if (lvl == 3)
            return phys(e & 0x000FFFFFFFFFF000ULL) + (va & 0xFFF);
        if (e & (1ULL << 7)) {
            if (fault_level) *fault_level = 10 + lvl;
            return 0;
        }
        tbl = e & 0x000FFFFFFFFFF000ULL;
    }
    return 0;
}

// wire a 4K data mapping at va (present|RW chain, tables allocated on
// demand). Never for a PTE-space VA (they emerge from the self-ref)
// and never for p4 == PTS (the self-map slot itself).
static void wire_page(std::uint64_t va) {
    static const int shifts[4] = {39, 30, 21, 12};
    std::uint64_t tbl = PML4_FR;
    for (int lvl = 0; lvl < 4; lvl++) {
        std::uint64_t idx = (va >> shifts[lvl]) & 0x1FF;
        if (lvl == 0 && idx == PTS) {
            fprintf(stderr, "FATAL: wire over the self-map slot\n");
            exit(1);
        }
        std::uint64_t e;
        std::memcpy(&e, phys(tbl) + idx * 8, 8);
        std::uint64_t child;
        if (e & 1) {
            if (e & (1ULL << 7)) {
                fprintf(stderr, "FATAL: wire through a large page\n");
                exit(1);
            }
            child = e & 0x000FFFFFFFFFF000ULL;
        } else {
            child = alloc_frame();
            std::uint64_t ne = child | 3ULL;
            std::memcpy(phys(tbl) + idx * 8, &ne, 8);
        }
        tbl = child;
    }
}

// dual-view write: the g_pages view (KX/PW) + the hierarchy view (PT)
static void ptwr64(std::uint64_t va, std::uint64_t v) {
    for (int i = 0; i < 8; i++) {
        std::uint64_t a = va + i;
        bool wrote = false;
        if (g_pages.count(a & ~0xFFFull)) {
            wr8(a, (std::uint8_t)(v >> (8 * i)));
            wrote = true;
        }
        std::uint8_t* p = hw_walk(a, 0);
        if (p) { *p = (std::uint8_t)(v >> (8 * i)); wrote = true; }
        if (!wrote) {
            fprintf(stderr, "FATAL: ptwr64 unmapped 0x%llx\n",
                    (unsigned long long)a);
            exit(1);
        }
    }
}

// the hosted PT_R8: served by the INDEPENDENT hardware walk. Any VA
// the hardware cannot resolve = OUT-OF-MAP = the strict abort = the
// field BSOD (0x50) replayed on the host.
namespace UEFIBridge { namespace pt {
std::uint8_t PT_R8(std::uint64_t va) {
    int lvl = -1;
    std::uint8_t* p = hw_walk(va, &lvl);
    if (!p) {
        fprintf(stderr, "\n*** FATAL: PT_R8 OUT-OF-MAP read at 0x%llx "
                "(hw walk faulted at level %d — the address is NOT "
                "resolvable in the true-semantics world) ***\n",
                (unsigned long long)va, lvl);
        exit(2);
    }
    g_reads++;
    return *p;
} // PT_R8
}} // namespace UEFIBridge::pt

// the hosted primitives: STRICT map checking
namespace UEFIBridge { namespace kx {
std::uint8_t KX_R8(std::uint64_t va) {
    std::uint64_t pg = va & ~0xFFFull;
    if (!g_pages.count(pg)) {
        fprintf(stderr, "\n*** FATAL: KX_R8 OUT-OF-MAP read at 0x%llx ***\n",
                (unsigned long long)va);
        exit(2);
    }
    g_reads++;
    return g_pages[pg][va & 0xFFF];
}} // namespace
namespace pw {
std::uint8_t PW_R8(std::uint64_t va) {
    std::uint64_t pg = va & ~0xFFFull;
    if (!g_pages.count(pg)) {
        fprintf(stderr, "\n*** FATAL: PW_R8 OUT-OF-MAP read at 0x%llx ***\n",
                (unsigned long long)va);
        exit(2);
    }
    g_reads++;
    return g_pages[pg][va & 0xFFF];
}
}} // namespace

static int g_pass = 0, g_fail = 0;
#define CHECK(cond, msg) do { \
    if (cond) { g_pass++; printf("  PASS  %s\n", msg); } \
    else      { g_fail++; printf("  FAIL  %s\n", msg); } \
} while (0)

using namespace UEFIBridge;

// ==================== kx: small synthetic export image (v22 T1..T7) ====================
static const std::uint64_t IMG = 0xFFFFF80700000000ULL;
static const std::uint64_t IMG_SIZE = 0x100000;

static void build_export_image() {
    map_region(IMG, IMG_SIZE);
    wr64(IMG + 0x3C, 0x100);                 // e_lfanew
    wr64(IMG + 0x100 + 0x88, 0x2000);        // DD[0] RVA
    wr64(IMG + 0x100 + 0x8C, 0x1000);        // DD[0] size
    std::uint64_t d = IMG + 0x2000;
    wr64(d + 0x14, 4);                       // nFuncs
    wr64(d + 0x18, 4);                       // nNames
    wr64(d + 0x1C, 0x3000);                  // addrFuncs
    wr64(d + 0x20, 0x3100);                  // addrNames
    wr64(d + 0x24, 0x3200);                  // addrOrds
    wr64(IMG + 0x3000 + 0 * 4, 0x10000);
    wr64(IMG + 0x3000 + 1 * 4, 0x10008);
    wr64(IMG + 0x3000 + 2 * 4, 0x2004);      // FORWARDER (inside dir)
    wr64(IMG + 0x3000 + 3 * 4, 0x10010);
    wr64(IMG + 0x3100 + 0 * 4, 0x4000);
    wr64(IMG + 0x3100 + 1 * 4, 0x4040);
    wr64(IMG + 0x3100 + 2 * 4, 0x4080);
    wr64(IMG + 0x3100 + 3 * 4, 0x40C0);
    wrstr(IMG + 0x4000, "Alpha");
    wrstr(IMG + 0x4040, "BetaGamma");
    wrstr(IMG + 0x4080, "Forwarded");
    wrstr(IMG + 0x40C0, "PsInitialSystemProcess");
    wr8(IMG + 0x3200 + 0, 0); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 2, 1); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 4, 2); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 6, 3); wr8(IMG + 0x3201, 0);
}

static void kx_tests() {
    printf("\n== kx::Resolve (regression T1..T7, small synthetic image) ==\n");
    build_export_image();

    {   kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "BetaGamma", 9);
        CHECK(r.rc == 1, "T1 present symbol resolves (rc=1)");
        CHECK(r.resolved_va == IMG + 0x10008, "T1 exact VA (base+0x10008)");
        CHECK(r.name_index == 1, "T1 name index 1");
    }
    {   kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "PsInitialSystemProcess", 22);
        CHECK(r.rc == 1, "T2 PsInitialSystemProcess resolves");
        CHECK(r.resolved_va == IMG + 0x10010, "T2 exact VA");
        CHECK(r.name_index == 3, "T2 name index 3");
    }
    {   kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NoSuchSymbolV31", 15);
        CHECK(r.rc == 0, "T3 absent symbol -> rc=0 (notfound)");
        CHECK(r.resolved_va == 0, "T3 va=0");
    }
    {   kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Forwarded", 9);
        CHECK(r.rc == 3, "T4 forwarded export -> rc=3 (refused, not followed)");
        CHECK(r.resolved_va == 0, "T4 forwarded va=0");
    }
    {   wr64(IMG + 0x3C, 0x5000);
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T5 bad e_lfanew -> rc=4 (gate refused)");
        wr64(IMG + 0x3C, 0x100);
    }
    {   wr64(IMG + 0x100 + 0x88, 0);
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T6 no export dir -> rc=4");
        wr64(IMG + 0x100 + 0x88, 0x2000);
    }
    {   kx::Ctx c{IMG, 0x30, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T7 undersized image -> rc=4");
    }
}

// ==================== kx: REALISTIC ntoskrnl-19045 image (THE CLASS-KILL) ====================
// Mirrors the actual field shape the v30 run faced:
//   image size 0x1046000, e_lfanew 0x118, ~2400 names,
//   export dir size 0x12000 (> 0x10000: trips the v22 bug, passes v23),
//   targets at the REAL field name indices: NtBuildNumber@1508,
//   PsInitialSystemProcess@1855 (the exact v28/v29 field values).
static const std::uint64_t KI = 0xFFFFF80719800000ULL;   // the real field pe_base
static const std::uint64_t KI_SIZE = 0x1046000;          // the real field pe_size
static const std::uint32_t KI_LFANEW = 0x118;            // the real field e_lfanew
static const std::uint32_t KI_EXP_RVA = 0x172000;
static const std::uint32_t KI_EXP_SIZE = 0x12000;        // 73728 B > 0x10000
static const int KI_NNAMES = 2400;
static const int KI_NFUNCS = 2600;
// in-dir layout: funcs@+0x1000, names@+0x4000, ords@+0x7000, strings@+0x9000
static const int IDX_NTBUILD = 1508;
static const int IDX_PSINIT = 1855;


static void wr16le(std::uint64_t va, std::uint16_t v);

static void build_realistic_kernel() {
    map_region(KI, KI_SIZE);
    wr64(KI + 0x3C, KI_LFANEW);
    wr64(KI + KI_LFANEW + 0x88, KI_EXP_RVA);
    wr64(KI + KI_LFANEW + 0x8C, KI_EXP_SIZE);
    std::uint64_t d = KI + KI_EXP_RVA;
    wr64(d + 0x14, KI_NFUNCS);
    wr64(d + 0x18, KI_NNAMES);
    wr64(d + 0x1C, KI_EXP_RVA + 0x1000);   // addrFuncs (RVA)
    wr64(d + 0x20, KI_EXP_RVA + 0x4000);   // addrNames (RVA)
    wr64(d + 0x24, KI_EXP_RVA + 0x7000);   // addrOrds (RVA)
    // functions array: distinct body RVAs (fake .text)
    for (int i = 0; i < KI_NFUNCS; i++)
        wr32(KI + KI_EXP_RVA + 0x1000 + 4ULL * i, 0x990000 + 8 * i);
    // names + ordinals + strings
    std::uint64_t str_rva = KI_EXP_RVA + 0x9000;
    for (int i = 0; i < KI_NNAMES; i++) {
        char nm[32];
        if (i == IDX_NTBUILD)      snprintf(nm, sizeof(nm), "NtBuildNumber");
        else if (i == IDX_PSINIT)  snprintf(nm, sizeof(nm), "PsInitialSystemProcess");
        else                       snprintf(nm, sizeof(nm), "ZzSysSym%06d", i);
        wr32(KI + KI_EXP_RVA + 0x4000 + 4ULL * i, (std::uint32_t)str_rva);
        wr16le(KI + KI_EXP_RVA + 0x7000 + 2ULL * i, (std::uint16_t)i);
        wrstr(KI + str_rva, nm);
        str_rva += strlen(nm) + 1;
    }
    CHECK(str_rva < KI_EXP_RVA + KI_EXP_SIZE, "T20-build strings fit inside the dir");
}
static void wr16le(std::uint64_t va, std::uint16_t v) {
    wr8(va, (std::uint8_t)(v & 0xFF));
    wr8(va + 1, (std::uint8_t)(v >> 8));
}

static void kx_field_tests() {
    printf("\n== kx::Resolve (T20..T22: the REALISTIC ntoskrnl-shaped image) ==\n");
    build_realistic_kernel();

    // T20: THE CLASS-KILL — resolve at the real field indices on a
    // >64 KiB export directory. v22 (0x10000 bound) FAILS this; v23 passes.
    {
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "PsInitialSystemProcess", 22);
        CHECK(r.rc == 1, "T20a PsInitialSystemProcess on realistic dir (rc=1; v22 refused)");
        CHECK(r.name_index == (std::uint32_t)IDX_PSINIT, "T20b name index 1855 (the field value)");
        CHECK(r.resolved_va == KI + 0x990000 + 8ULL * IDX_PSINIT, "T20c exact VA (base+funcRVA)");
    }
    {
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NtBuildNumber", 13);
        CHECK(r.rc == 1, "T20d NtBuildNumber on realistic dir (rc=1)");
        CHECK(r.name_index == (std::uint32_t)IDX_NTBUILD, "T20e name index 1508 (the field value)");
    }
    {
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NoSuchSymbolV31", 15);
        CHECK(r.rc == 0, "T20f absent name -> rc=0 notfound (NOT rc=4: the v30 signature)");
    }
    {
        // budget sanity: the full 2400-name walk stays far under 1 MiB
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::Resolve(&c, "NoSuchSymbolV31", 15);
        CHECK(c.budget > 0 && c.budget < 1000000ull, "T20g walk budget sane (< 1 MiB)");
        CHECK(c.err == 0, "T20h sticky error still clear after full walk");
    }
    // T21: the corrected upper bound still refuses absurd sizes
    {
        wr64(KI + KI_LFANEW + 0x8C, 0x100001);   // > 0x100000
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NtBuildNumber", 13);
        CHECK(r.rc == 4, "T21 dir size 0x100001 -> rc=4 (upper bound enforced)");
        wr64(KI + KI_LFANEW + 0x8C, KI_EXP_SIZE);
    }
    // T22: boundary documented — v23 accepts up to 0xFFFFF and refuses
    // exactly 0x100000 (one value stricter than the v21 binary, which
    // accepted it; fail-closed direction, immaterial in the field).
    {
        wr64(KI + KI_LFANEW + 0x8C, 0x100000);
        kx::Ctx c{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NtBuildNumber", 13);
        CHECK(r.rc == 4, "T22 dir size exactly 0x100000 -> rc=4 (documented stricter-by-one)");
        wr64(KI + KI_LFANEW + 0x8C, KI_EXP_SIZE);
        kx::Ctx c2{KI, KI_SIZE, 0, 0};
        kx::ResolveResult r2 = kx::Resolve(&c2, "NtBuildNumber", 13);
        CHECK(r2.rc == 1, "T22b restore -> resolves again");
    }
}

// ==================== pw: synthetic process list (v22 T8..T19) ====================
static const std::uint64_t SYS = 0xFFFFF8071A000000ULL;

static void eproc(std::uint64_t base, std::uint32_t pid, const char* name) {
    map_region(base, 0x1000);
    wr64(base + 0x440, pid);
    if (name) {
        map_region(base + 0x5A0, 0x1000);
        wrstr(base + 0x5A8, name);
    }
}
static void link(std::uint64_t from, std::uint64_t to) {
    wr64(from + 0x448, to + 0x448);
    wr64(to + 0x448 + 8, from + 0x448);
}

static void pw_tests() {
    printf("\n== pw::WalkCore (regression T8..T19, synthetic process list) ==\n");
    {   g_pages.clear();
        const int N = 5;
        std::uint64_t e[N];
        const char* names[N] = {"System", "smss.exe", "csrss.exe",
                                "wininit.exe", "services.exe"};
        std::uint32_t pids[N] = {4, 316, 448, 512, 596};
        for (int i = 0; i < N; i++)
            e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], pids[i], names[i]);
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwOk, "T8 healthy walk: status Ok");
        CHECK(r.count == 5, "T8 count = 5");
        CHECK(r.closed == 1, "T8 circle closed");
        CHECK(r.stored == 5, "T8 stored = 5");
        CHECK(out[0].pid == 4 && out[0].eproc == SYS,
              "T8 entries[0] = System pid 4 at S1");
        CHECK(out[1].pid == 316 && out[1].eproc == e[1],
              "T8 entries[1] = smss (pid 316)");
        bool names_ok = true;
        for (int i = 0; i < N; i++)
            if (!(out[i].flags & 1)) names_ok = false;
        CHECK(names_ok, "T8 all names echoed (flags bit0)");
        CHECK(out[0].name[0]=='S' && out[0].name[1]=='y' &&
              out[0].name[2]=='s', "T8 System name bytes");
        CHECK(r.name_ofs == 0x5A8, "T8 name slot discovered = 0x5A8");
        CHECK(r.pages > 0 && r.pages <= pw::kPwMaxPages, "T8 budget sane");
    }
    {   g_pages.clear();
        std::uint64_t e[3];
        for (int i = 0; i < 3; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < 3; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(100 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        wr64(e[1] + 0x448, 0x0000123400000000ULL);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBrokenLink, "T9 corrupt Flink -> BrokenLink");
        CHECK(r.count == 0 && r.stored == 0, "T9 partial results discarded");
    }
    {   g_pages.clear();
        std::uint64_t e[3];
        for (int i = 0; i < 3; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < 3; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(200 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        wr64(e[1] + 0x448 + 8, 0xFFFFF807DEAD0000ULL);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBrokenLink, "T10 Blink(next)!=cur -> BrokenLink");
    }
    {   g_pages.clear();
        eproc(SYS, 1337, nullptr);
        wr64(SYS + 0x448, SYS + 0x448);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwNotSys, "T11 pid@S1 != 4 -> NotSys");
    }
    {   g_pages.clear();
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(0x0000123400000000ULL, out, 32, &bud);
        CHECK(r.status == pw::kPwBadEntry, "T12 S1 non-canonical -> BadEntry");
    }
    {   pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        CHECK(pw::WalkCore(SYS, out, 0,  &bud).status == pw::kPwBadArgs,
              "T13a out_n=0 -> BadArgs");
        CHECK(pw::WalkCore(SYS, out, 33, &bud).status == pw::kPwBadArgs,
              "T13b out_n=33 -> BadArgs");
        CHECK(pw::WalkCore(SYS, nullptr, 8, &bud).status == pw::kPwBadArgs,
              "T13c null out -> BadArgs");
    }
    {   g_pages.clear();
        std::uint64_t far = SYS + 0x200000000ULL;
        eproc(SYS, 4, nullptr);
        eproc(far, 500, nullptr);
        wr64(SYS + 0x448, far + 0x448);
        wr64(far + 0x448 + 8, SYS + 0x448);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwWindowRefused,
              "T14 link 8GB away -> WindowRefused (before any read there)");
    }
    {   g_pages.clear();
        std::uint64_t e[3];
        for (int i = 0; i < 3; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < 3; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(300 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        pw::Entry out[32];
        pw::Budget bud{0, 1};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBudget, "T15 budget=1 page -> Budget refuse");
    }
    {   g_pages.clear();
        eproc(SYS, 4, "System");
        wr64(SYS + 0x448, SYS + 0x448);
        wr64(SYS + 0x448 + 8, SYS + 0x448);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 1 && r.closed == 1,
              "T16 one-process list: Ok, count=1, closed");
    }
    {   g_pages.clear();
        std::uint64_t e[3];
        for (int i = 0; i < 3; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < 3; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(400 + i), nullptr);
        for (int i = 0; i < 3; i++) link(e[i], e[(i + 1) % 3]);
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 3,
              "T17a no names: walk still Ok, count=3");
        CHECK(r.name_ofs == 0, "T17b name_ofs = 0 (none discovered)");
        CHECK(!(out[0].flags & 1), "T17c flags bit0 = 0");
        bool zero = true;
        for (int k = 0; k < 8; k++) if (out[0].name[k]) zero = false;
        CHECK(zero, "T17d names zeroed");
    }
    {   g_pages.clear();
        const int N = 8;
        std::uint64_t e[8];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(600 + i), nullptr);
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
        pw::Entry out[4];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 4, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 8 && r.stored == 4,
              "T18 count=8 total, stored=4 (capped by out_n)");
    }
    {   g_pages.clear();
        const int N = 100;
        for (int i = 0; i < N; i++) {
            std::uint64_t b = SYS + (std::uint64_t)i * 0x10000ULL;
            eproc(b, i == 0 ? 4u : (std::uint32_t)(700 + i), nullptr);
        }
        for (int i = 0; i < N; i++) {
            std::uint64_t a = SYS + (std::uint64_t)i * 0x10000ULL;
            std::uint64_t b = SYS + (std::uint64_t)((i + 1) % N) * 0x10000ULL;
            wr64(a + 0x448, b + 0x448);
            wr64(b + 0x448 + 8, a + 0x448);
        }
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwOk, "T19a 100-proc list: status Ok (capped)");
        CHECK(r.count == pw::kPwMaxEntries, "T19b count capped at 64");
        CHECK(r.closed == 0, "T19c closed=0 (cap hit first)");
        CHECK(r.pages <= pw::kPwMaxPages, "T19d page budget respected");
    }
}

// ==================== the v24 chain: resolve -> DEREF -> walk ===============
// The pool world mirrors the field: EPROCESSes live OUTSIDE the image
// (0xFFFF8Exx... pool range, like the true KPCR 0xFFFF8E808758B000).
static const std::uint64_t POOL = 0xFFFF8E8000000000ULL;

static void chain_tests() {
    printf("\n== pw::SysEprocessFromSymbol (T23: the v24 resolve->deref->walk chain) ==\n");
    {   // the realistic world: image + pool circle + the pointer slot
        g_pages.clear();
        build_export_image();
        const int N = 5;
        std::uint64_t e[N];
        const char* names[N] = {"System", "smss.exe", "csrss.exe",
                                "wininit.exe", "services.exe"};
        std::uint32_t pids[N] = {4, 316, 448, 512, 596};
        for (int i = 0; i < N; i++)
            e[i] = POOL + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], pids[i], names[i]);
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
        wr64(IMG + 0x10010, e[0]);       // THE POINTER SLOT (in-image)
        // NOTE: IMG+0x10010+0x440 stays ZERO - the .data garbage that
        // produced the v31 field refusal. This is deliberate.

        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        std::uint64_t sym = 0, eproc_va = 0;
        bool ok = pw::SysEprocessFromSymbol(&c, "PsInitialSystemProcess", 22,
                                            &sym, &eproc_va);
        CHECK(ok, "T23a chain: resolve + deref succeed");
        CHECK(sym == IMG + 0x10010, "T23b symbol VA echoed (the .data slot)");
        CHECK(eproc_va == e[0], "T23c THE DEREF: slot VALUE = the pool EPROCESS");

        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(eproc_va, out, 32, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 5 && r.closed == 1,
              "T23d walk from the DEREF'd EPROCESS: Ok, 5, closed");
        CHECK(out[0].pid == 4 && out[0].eproc == e[0],
              "T23e entries[0] = System pid 4 at the pool VA");
        CHECK(r.sys_entry == e[0], "T23f payload sysEntry = the EPROCESS");
        CHECK(r.name_ofs == 0x5A8 && (out[0].flags & 1),
              "T23g names discovered at 0x5A8, echoed");

        // THE CLASS-KILL: what v23's op-11 actually did — walk from the
        // SYMBOL VA. On this realistic world it MUST fail with the EXACT
        // v31 field signature (NotSys, count 0, pages 0).
        pw::Budget bud2{0, pw::kPwMaxPages};
        pw::Result r2 = pw::WalkCore(sym, out, 32, &bud2);
        CHECK(r2.status == pw::kPwNotSys && r2.count == 0 && r2.pages == 0,
              "T23h CLASS-KILL: walk from the symbol VA -> NotSys (the v31 signature)");
    }
    {   // deref refused: the slot's high dword crosses the image end
        g_pages.clear();
        build_export_image();
        // size cut to 0x10016: the resolve still walks (everything it
        // needs is < 0x40D7), the lo read (rva 0x10010, needs >= 0x10014)
        // passes, the hi read (rva 0x10014, needs >= 0x10018) is REFUSED
        // by the RVA gate — fail-closed, no out-of-image read possible.
        kx::Ctx c{IMG, 0x10016, 0, 0};
        std::uint64_t sym = 0, eproc_va = 1;
        bool ok = pw::SysEprocessFromSymbol(&c, "PsInitialSystemProcess", 22,
                                            &sym, &eproc_va);
        CHECK(!ok && eproc_va == 1,
              "T23i slot crossing the image end -> chain refused");
    }
    {   // the target is NOT trusted: a garbage slot value passes the
        // (in-image) deref and is refused by WalkCore's own W1 gate
        g_pages.clear();
        build_export_image();
        wr64(IMG + 0x10010, 0x0000123400000000ULL);
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        std::uint64_t sym = 0, eproc_va = 0;
        bool ok = pw::SysEprocessFromSymbol(&c, "PsInitialSystemProcess", 22,
                                            &sym, &eproc_va);
        CHECK(ok && eproc_va == 0x0000123400000000ULL,
              "T23j chain returns the raw value (untrusted)");
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(eproc_va, out, 32, &bud);
        CHECK(r.status == pw::kPwBadEntry,
              "T23k non-canonical EPROCESS -> BadEntry (target validated)");
    }
}

// ==================== pt: the F4 TRUE-SEMANTICS world ================
static const std::uint64_t PFNDB = 0xFFFFE00000000000ULL;  // MmPfnDatabase
static const std::uint64_t EPROC = 0xFFFF8E00BAD00000ULL;  // pool object
static const std::uint64_t PTIMG_SIZE = 0xCFD000ULL;       // covers .data

// build the world: hierarchy + self-ref at s + the image globals +
// the EPROCESS (dual view) + the _MMPFN mirror. eproc_dtb: 0 = the
// EPROCESS records the world PML4 (the one-PML4 world, selfOk==3);
// nonzero = the EPROCESS records ANOTHER valid frame (the CALLER-
// CONTEXT world — the live PML4 is the caller's own, System's is a
// different page: selfOk bit0 only, the expected field semantics).
static void pt_world_create(std::uint32_t s, std::uint32_t s1_slot,
                            std::uint64_t eproc_dtb) {
    g_pages.clear();
    for (std::map<std::uint64_t, std::uint8_t*>::iterator it = g_phys.begin();
         it != g_phys.end(); ++it) free(it->second);
    g_phys.clear();
    g_next_phys = 0x00100000ULL;
    PTS = s;
    PTB = 0xFFFF000000000000ULL | ((std::uint64_t)s << 39);
    PML4_FR = alloc_frame();
    // the self-ref entry: PML4E[s] -> the PML4 itself (present|RW|a)
    std::uint64_t self = PML4_FR | 0x23ULL;
    std::memcpy(phys(PML4_FR) + (std::uint64_t)PTS * 8, &self, 8);
    // every other PML4E stays 0 = ABSENT: the low-user tree is EMPTY,
    // exactly the trigger script's caller context (the world never
    // wires a user-half VA — the v25 formulas' low-user reads CANNOT
    // resolve here; that is the class-kill)
    build_export_image();
    map_region(IMG, PTIMG_SIZE);                 // the KX view
    // chain A: MmPteBase candidates at the real observed RVAs
    std::uint64_t good = PTB;
    std::uint64_t garbage = 0xFFFFF80714863000ULL;   // kernel VA shape
    wr64(IMG + 0xCFB358, s1_slot == 0 ? good : garbage);
    wr64(IMG + 0xCFA358, s1_slot == 0 ? garbage : good);
    // the symbol slot -> the pool EPROCESS (the v24 deref chain)
    wr64(IMG + 0x10010, EPROC);
    // the System EPROCESS (DUAL view: g_pages for PW, hierarchy for PT)
    map_region(EPROC, 0x1000);
    wire_page(EPROC);
    std::uint64_t dtb = eproc_dtb ? eproc_dtb : (PML4_FR | 0x81ULL);
    ptwr64(EPROC + 0x440, 4);                    // pid
    ptwr64(EPROC + 0x28, dtb);                   // DirectoryTableBase
    // chain B: MmPfnDatabase + the _MMPFN.PteAddress mirror. The
    // value is the TRUE identity: the PML4's own PTE-space slot =
    // PXE_BASE + s*8 (what a real OS stores for the System PML4's
    // PFN — the same VA for every process's own PML4).
    wr64(IMG + 0xCFC508, PFNDB);
    std::uint64_t cr3_frame = (eproc_dtb ? eproc_dtb : PML4_FR)
                              & 0x000FFFFFFFFFF000ULL;
    std::uint64_t slot = PFNDB + ((cr3_frame >> 12) * 0x30) + 8;
    wire_page(slot & ~0xFFFull);                 // the PT view only
    std::uint64_t pxe = PTB + ((std::uint64_t)s << 30)
                      + ((std::uint64_t)s << 21)
                      + ((std::uint64_t)s << 12);
    ptwr64(slot, pxe + (std::uint64_t)s * 8);
}

// wire the target's table chain with HAND-CRAFTED entries (the values
// the engine must echo). A zero entry = that level is absent. Frames
// are ensured so hw_walk can follow them. The entries are what a real
// OS would have built for the target's mapping.
static void pt_wire_leaf(std::uint64_t va, std::uint64_t pml4e,
                         std::uint64_t pdpte, std::uint64_t pde,
                         std::uint64_t pte) {
    std::uint64_t p4 = (va >> 39) & 0x1FF;
    std::uint64_t p3 = (va >> 30) & 0x1FF;
    std::uint64_t p2 = (va >> 21) & 0x1FF;
    std::uint64_t p1 = (va >> 12) & 0x1FF;
    const std::uint64_t M = 0x000FFFFFFFFFF000ULL;
    if (p4 == PTS) {
        fprintf(stderr, "FATAL: pt_wire_leaf over the self-map\n");
        exit(1);
    }
    if (pml4e) {
        if (!(pml4e & 1)) { fprintf(stderr, "FATAL: absent pml4e\n"); exit(1); }
        ensure_frame(pml4e & M);
        std::memcpy(phys(PML4_FR) + p4 * 8, &pml4e, 8);
    }
    if (pdpte) {
        if (!(pdpte & 1)) { fprintf(stderr, "FATAL: absent pdpte\n"); exit(1); }
        if (!(pdpte & (1ULL << 7))) ensure_frame(pdpte & M);
        std::memcpy(phys(pml4e & M) + p3 * 8, &pdpte, 8);
    }
    if (pde) {
        if (!(pde & 1)) { fprintf(stderr, "FATAL: absent pde\n"); exit(1); }
        if (!(pde & (1ULL << 7))) ensure_frame(pde & M);
        std::memcpy(phys(pdpte & M) + p2 * 8, &pde, 8);
    }
    if (pte) {
        if (!(pte & 1)) { fprintf(stderr, "FATAL: absent pte\n"); exit(1); }
        ensure_frame(pte & M);
        std::memcpy(phys(pde & M) + p1 * 8, &pte, 8);
    }
}

static void pt_tests() {
    printf("\n== pt::Translate (F4 v26, T24..T41 — the true-semantics world) ==\n");
    const std::uint64_t TGT = 0xFFFFF80712345678ULL; // a kernel VA
    const std::uint32_t  MAIN_S = 0x1AB;             // the main world s
    {   // T24: THE QUARTET — engine helpers + world vs the PUBLISHED
        //     classic pre-1607 s=0x1ED constants (literature values,
        //     hard-coded — the circularity breaker).
        const std::uint64_t PTB_ED = 0xFFFFF68000000000ULL;   // PTE_BASE
        const std::uint64_t PDE_ED = 0xFFFFF6FB40000000ULL;   // PDE_BASE
        const std::uint64_t PPE_ED = 0xFFFFF6FB7DA00000ULL;   // PPE_BASE
        const std::uint64_t PXE_ED = 0xFFFFF6FB7DBED000ULL;   // PXE_BASE
        CHECK(pt::PdeBaseOf(PTB_ED, 0x1ED) == PDE_ED,
              "T24a PdeBaseOf reproduces the published PDE_BASE");
        CHECK(pt::PpeBaseOf(PTB_ED, 0x1ED) == PPE_ED,
              "T24b PpeBaseOf reproduces the published PPE_BASE");
        CHECK(pt::PxeBaseOf(PTB_ED, 0x1ED) == PXE_ED,
              "T24c PxeBaseOf reproduces the published PXE_BASE");
        // the WORLD at the published addresses: hw_walk must resolve
        // the self-ref slot AT the published PXE_BASE and serve the
        // self entry — the hardware-semantics anchor
        pt_world_create(0x1ED, 0, 0);
        int lvl = -1;
        std::uint8_t* p = hw_walk(PXE_ED + (std::uint64_t)0x1ED * 8, &lvl);
        CHECK(p != 0, "T24d hw_walk resolves the published PXE self slot");
        if (p) {
            std::uint64_t e = 0;
            for (int i = 0; i < 8; i++)
                e |= (std::uint64_t)p[i] << (8 * i);
            CHECK(e == (PML4_FR | 0x23ULL),
                  "T24e the published PXE self slot serves PML4E[s] "
                  "(the world is the literature world)");
        }
        // the PDE-space self slot: the PDE of the PXE region — index
        // (s<<18)|(s<<9)|s; it serves PML4E[s] through the all-s
        // descent. NOTE: PDE_BASE + ((s<<18)|(s<<9)|s)*8 ==
        // PPE_BASE + ((s<<9)|s)*8 — the cross-level identity that
        // demonstrates PPE_BASE == PDE_BASE + (s<<21) itself.
        CHECK(hw_walk(PDE_ED + (((std::uint64_t)0x1ED << 18)
                                | ((std::uint64_t)0x1ED << 9)
                                | 0x1EDULL) * 8, &lvl) != 0,
              "T24f hw_walk resolves the published PDE self slot "
              "(the composite index)");
        CHECK(hw_walk(PPE_ED + (((std::uint64_t)0x1ED << 9) | 0x1EDULL) * 8,
                      &lvl) != 0,
              "T24g hw_walk resolves the published PPE self slot "
              "(== the PDE form — the cross-level identity)");
    }
    {   // T25 (v25-T24): the full happy path — A cand#1 + B agree +
        //     selfOk==3 (bit0 live + bit1 system frame: one-PML4 world)
        pt_world_create(MAIN_S, 0, 0);
        pt_wire_leaf(TGT, 0x0000000AAA000025ULL, 0x0000000BBB000025ULL,
                     0x0000000CCC000025ULL, 0x0000000DDD000025ULL);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F,
              "T25a 4KB walk: Ok, all levels present");
        CHECK(r.pte_base == PTB && r.self_idx == MAIN_S,
              "T25b pte_base + self index discovered");
        CHECK(r.source == (1u | 0x10u),
              "T25c source = A cand#1 + B agreed (two chains, one base)");
        CHECK(r.self_ok == 3 && r.cr3 == PML4_FR,
              "T25d selfOk bit0 (PTE space LIVE) + bit1 (self-ref frame "
              "== System CR3 — the one-PML4 world)");
        CHECK(r.frame == 0xDDD000000ULL && r.pml4e == 0x0000000AAA000025ULL
              && r.pdpte == 0x0000000BBB000025ULL
              && r.pde == 0x0000000CCC000025ULL
              && r.pte == 0x0000000DDD000025ULL,
              "T25e raw entries + frame echoed through the self-map");
    }
    {   // T26 (v25-T25): the good value at candidate #2 (0xCFA358)
        pt_world_create(MAIN_S, 1, 0);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && (r.source & 3) == 2,
              "T26 A candidate #2 accepted (source low bits = 2)");
    }
    {   // T27 (v25-T26): DRIFTED WORLD — garbage at both A slots. The
        //     strict harness itself is the proof: NO hierarchy was
        //     built (hw_walk cannot even start — PML4_FR never set),
        //     so ANY PTE-space/pool read aborts. It must refuse
        //     cleanly instead (the VM-alive property).
        g_pages.clear();
        build_export_image();
        map_region(IMG, PTIMG_SIZE);
        wr64(IMG + 0xCFB358, 0xFFFFF80714863000ULL);  // kernel VA
        wr64(IMG + 0xCFA358, 0x0000000000000100ULL);  // small int
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNoBase && r.pte_base == 0,
              "T27 CLASS-KILL: drifted layout -> clean kPtNoBase, "
              "ZERO out-of-image reads (harness alive = proof)");
    }
    {   // T28 (v25-T27): A and B DISAGREE — the mirror holds the
        //     s'=0x1AC identity (a valid OTHER self-map world). Must
        //     refuse (fail-closed), VM alive.
        pt_world_create(MAIN_S, 0, 0);
        std::uint64_t slot = PFNDB + ((PML4_FR >> 12) * 0x30) + 8;
        std::uint64_t base2 = 0xFFFF000000000000ULL | (0x1ACULL << 39);
        std::uint64_t pxe2 = base2 + ((std::uint64_t)0x1AC << 30)
                           + ((std::uint64_t)0x1AC << 21)
                           + ((std::uint64_t)0x1AC << 12);
        ptwr64(slot, pxe2 + 0x1ACULL * 8);   // a valid s'-identity
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNoBase,
              "T28 A/B disagreement -> refusal (never trust one chain)");
    }
    {   // T29 (v25-T28): B MISS (the MmPfnDatabase pointer garbage) —
        //     A proceeds alone, source bit5, the PTE space still LIVE.
        pt_world_create(MAIN_S, 0, 0);
        wr64(IMG + 0xCFC508, 0x123456789ULL);            // non-canonical
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && (r.source & 0x20)
              && (r.self_ok & 1),
              "T29 B miss tolerated: A-only proceed, source bit5, "
              "selfOk bit0 still set");
    }
    {   // T30 (v25-T29): 2MB large page (PDE.PS)
        pt_world_create(MAIN_S, 0, 0);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x0000000CCC000085ULL, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x17
              && r.frame == 0xCCC000000ULL + (TGT & 0x1FFFFF),
              "T30 2MB large page: mask 0x17 + frame+offset");
    }
    {   // T31 (v25-T30): 1GB large page (PDPTE.PS)
        pt_world_create(MAIN_S, 0, 0);
        pt_wire_leaf(TGT, 0x25, 0x0000000C00000085ULL, 0, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x13
              && r.frame == 0xC00000000ULL + (TGT & 0x3FFFFFFF),
              "T31 1GB large page: mask 0x13 + frame+offset");
    }
    {   // T32 (v25-T31): PTE not present — clean answer, levels above
        //     echoed. The PT page exists (wired) so the a4 slot
        //     RESOLVES and serves the absent entry — a true not-
        //     present answer, not a fault.
        pt_world_create(MAIN_S, 0, 0);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNotPresent && r.present_mask == 0x7
              && r.frame == 0 && r.pte == 0 && r.pde != 0,
              "T32 absent PTE: not-present, mask 0x7, no frame");
    }
    {   // T33 (v25-T32): ABSENT PML4E — THE PARENT-PRESENT SAFETY
        //     PROOF, now structural: the target chain is NOT wired,
        //     so the a2/a3/a4 slots are UNRESOLVABLE in the true
        //     world (their walks descend the absent PML4E[p4]). Any
        //     read below the absent entry would ABORT the harness. It
        //     must stop at level 0 instead.
        pt_world_create(MAIN_S, 0, 0);
        // (PML4E[p4] stays 0 = absent — nothing wired for TGT)
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtNotPresent && r.present_mask == 0
              && r.pdpte == 0 && r.pde == 0 && r.pte == 0,
              "T33 CLASS-KILL: absent PML4E -> nothing below is ever "
              "read (harness alive = proof)");
    }
    {   // T34 (v25-T33): non-canonical target
        pt_world_create(MAIN_S, 0, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, 0x0000800000000000ULL);
        CHECK(r.status == pt::kPtBadArgs, "T34 non-canonical -> BadArgs");
    }
    {   // T35 (v25-T34): user-range target (kernel-data op by design)
        pt_world_create(MAIN_S, 0, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, 0x00007FF000000000ULL);
        CHECK(r.status == pt::kPtBadArgs, "T35 user-range VA -> BadArgs");
    }
    {   // T36 (v25-T35): ValidPteBase unit spots (the 512-value universe)
        std::uint32_t s = 0;
        CHECK(pt::ValidPteBase(0xFFFF000000000000ULL | (0x100ULL << 39), &s)
              && s == 0x100, "T36a the lowest valid base (s=0x100)");
        CHECK(!pt::ValidPteBase(0x0000000000000000ULL, &s)
              && !pt::ValidPteBase(0xFFFF800000000001ULL, &s)
              && !pt::ValidPteBase(0xFFFFF80714863000ULL, &s)
              && !pt::ValidPteBase(0xFFFF000000000000ULL | (0xFFULL << 39), &s),
              "T36b null/misaligned/kernel-VA/low-index all rejected");
    }
    {   // T37 (v25-T36): EprocDtb direct — gates + the raw PCID value
        pt_world_create(MAIN_S, 0, 0);
        pt::u32 reads = 0; pt::u64 dtb = 0;
        CHECK(pt::EprocDtb(EPROC, &reads, &dtb) && dtb == (PML4_FR | 0x81ULL),
              "T37a EprocDtb returns the RAW DTB (PCID bits kept)");
        ptwr64(EPROC + 0x440, 7);
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T37b pid != 4 -> refused");
        ptwr64(EPROC + 0x440, 4);
        ptwr64(EPROC + 0x28, 0xFFFF000000000000ULL);  // absurd frame
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T37c absurd DTB frame -> refused");
        CHECK(!pt::EprocDtb(0x0000123400000000ULL, &reads, &dtb),
              "T37d non-canonical EPROCESS -> refused");
    }
    {   // T38 (v25-T37): budget exhaustion — a saturated read counter
        //     refuses cleanly
        pt_world_create(MAIN_S, 0, 0);
        pt::u32 reads = pt::kPtMaxReads; pt::u64 dtb = 0;
        CHECK(!pt::EprocDtb(EPROC, &reads, &dtb),
              "T38 saturated budget -> refused cleanly");
    }
    {   // T39 (NEW — the v26 semantics): THE CALLER-CONTEXT WORLD.
        //     The EPROCESS records System's DTB = ANOTHER valid frame
        //     (the trigger script's process runs on ITS OWN PML4 —
        //     the live one). The self-ref slot still opens (bit0),
        //     but its frame is the CALLER's, not System's (bit1 = 0)
        //     — the EXPECTED honest field value. B still agrees: the
        //     _MMPFN mirror sits at the System pfn and stores the
        //     SAME process-independent slot VA.
        std::uint64_t other = 0x0000000001234000ULL;  // System's PML4
        pt_world_create(MAIN_S, 0, other | 0x81ULL);
        ensure_frame(other);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F,
              "T39a the caller-context walk is FULLY green");
        CHECK(r.self_ok == 1 && r.cr3 == other,
              "T39b selfOk bit0 only (PTE space live, self frame = the "
              "CALLER's PML4 != System CR3) — the field semantics");
        CHECK(r.source == (1u | 0x10u),
              "T39c B still agrees (the mirror is process-independent)");
    }
    {   // T40 (v25-T40): SysEprocessCr3 — the full chain end-to-end
        pt_world_create(MAIN_S, 0, 0);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        std::uint64_t sym = 0, ep = 0, dtb = 0; pt::u32 reads = 0;
        bool ok = pt::SysEprocessCr3(&c, &sym, &ep, &dtb, &reads);
        CHECK(ok && sym == IMG + 0x10010 && ep == EPROC
              && (dtb & pt::kPtPfnMask) == PML4_FR,
              "T40 resolve -> deref -> EprocDtb: the whole chain");
    }
    {   // T41 (NEW): THE RANGE INVARIANT — for EVERY valid self-map
        //     index, all four level bases and every reachable slot
        //     stay inside [PTE_BASE, PTE_BASE + 2^39). WRAP-FREE form
        //     (addr - b < 2^39): at s = 0x1FF the naive b + 2^39
        //     overflows u64 to 0 — the exact edge where the ORIGINAL
        //     PtRd64 gate (v25/v26-first-build) wrapped and refused
        //     everything; T41 caught it and the engine now uses the
        //     subtraction form. This test pins the edge forever.
        bool ok = true;
        for (std::uint32_t s = 0x100; s <= 0x1FF; s++) {
            std::uint64_t b = 0xFFFF000000000000ULL
                              | ((std::uint64_t)s << 39);
            std::uint64_t pde = pt::PdeBaseOf(b, s);
            std::uint64_t ppe = pt::PpeBaseOf(b, s);
            std::uint64_t pxe = pt::PxeBaseOf(b, s);
            const std::uint64_t SZ = 0x8000000000ULL;  // 2^39
            if (!(b <= pde && pde < ppe && ppe < pxe)) ok = false;
            // the farthest reachable slots, wrap-free:
            if (!((pxe - b) < SZ)) ok = false;                       // pxe
            if (!((pxe + 511 * 8 - b) < SZ)) ok = false;             // a1 max
            if (!((ppe + 0x3FFFFULL * 8 - b) < SZ)) ok = false;      // a2 max
            if (!((pde + 0x7FFFFFFULL * 8 - b) < SZ)) ok = false;    // a3 max
            if (!((b + 0xFFFFFFFFFULL * 8 - b) < SZ)) ok = false;    // a4 max
            if (!((pxe + (std::uint64_t)s * 8 - b) < SZ)) ok = false; // self
        }
        CHECK(ok, "T41 all 512 self-map indices: bases ordered, every "
              "slot inside the 2^39 PTE-space window WRAP-FREE "
              "(incl. the s=0x1FF edge that broke the naive gate)");
        // and the engine actually WALKS in the s=0x1FF world (the
        // overflow would have refused everything — the T41 catch):
        pt_world_create(0x1FF, 0, 0);
        pt_wire_leaf(TGT, 0x25, 0x25, 0x25, 0x25);
        kx::Ctx c{IMG, PTIMG_SIZE, 0, 0};
        pt::Result r = pt::Translate(&c, TGT);
        CHECK(r.status == pt::kPtOk && r.present_mask == 0x1F
              && (r.self_ok & 1),
              "T41b the s=0x1FF world: the walk is FULLY green "
              "(the naive gate would have refused everything here)");
    }
}

int main() {
    printf("==== host-test-v26: KernelExports.h + ProcessWalk.h + PageTableWalk.h (v26 F4 FIXED) ====\n");
    printf("strict mode: ANY out-of-map read aborts the whole test run\n");
    kx_tests();
    kx_field_tests();
    pw_tests();
    chain_tests();
    pt_tests();
    printf("\n==== RESULT: %d PASS / %d FAIL / %ld hosted reads ====\n",
           g_pass, g_fail, g_reads);
    return g_fail ? 1 : 0;
}
