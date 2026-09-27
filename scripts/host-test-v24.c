// ===========================================================================
// host-test-v24.c — unit tests for the REAL v24 pure-logic headers
// (KernelExports.h + ProcessWalk.h with the S1+S2 deref chain) against
// synthetic memory. T1..T22 are the v23 suite unchanged (regression).
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
// Build:  g++ -std=c++11 -I<tree>/UEFI/include -o host24 host-test-v24.c
// ============================================================================
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <map>

#define KERNEL_EXPORTS_HOST_TEST
#define KERNEL_WALK_HOST_TEST
#include "KernelExports.h"
#include "ProcessWalk.h"

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

int main() {
    printf("==== host-test-v24: KernelExports.h + ProcessWalk.h (v24 deref chain) ====\n");
    printf("strict mode: ANY out-of-map read aborts the whole test run\n");
    kx_tests();
    kx_field_tests();
    pw_tests();
    chain_tests();
    printf("\n==== RESULT: %d PASS / %d FAIL / %ld hosted reads ====\n",
           g_pass, g_fail, g_reads);
    return g_fail ? 1 : 0;
}
