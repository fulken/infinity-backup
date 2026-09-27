// ============================================================================
// host-test-v22.c — unit tests for the REAL v22 pure-logic headers
// (KernelExports.h + ProcessWalk.h) against synthetic memory.
//
// THE DISCIPLINE (v19 host-test lineage): every raw read goes through
// the hosted KX_R8/PW_R8, which HARD-FAILS on any address outside the
// registered synthetic regions. A test "passes" only if the logic
// under test NEVER strays out of its declared map — the exact safety
// property the VM's life depends on.
//
// Build:  gcc -DKERNEL_EXPORTS_HOST_TEST -DKERNEL_WALK_HOST_TEST \
//            -std=c++11 -I<tree>/UEFI/include -o host22 host-test-v22.c -lstdc++
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
    std::uint64_t pg = va & ~0xFFFULL;
    if (!g_pages.count(pg)) { fprintf(stderr, "FATAL: wr8 unmapped 0x%llx\n", (unsigned long long)va); exit(1); }
    g_pages[pg][va & 0xFFF] = v;
}
static void wr64(std::uint64_t va, std::uint64_t v) {
    for (int i = 0; i < 8; i++) wr8(va + i, (std::uint8_t)(v >> (8 * i)));
}
static void wrstr(std::uint64_t va, const char* s) {
    while (*s) wr8(va++, (std::uint8_t)*s++);
    wr8(va, 0);
}

// the hosted primitives: STRICT map checking (defined in the
// matching namespaces, the v19 host-test discipline)
namespace UEFIBridge { namespace kx {
std::uint8_t KX_R8(std::uint64_t va) {
    std::uint64_t pg = va & ~0xFFFULL;
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
    std::uint64_t pg = va & ~0xFFFULL;
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

// ==================== kx: synthetic export image ====================
static const std::uint64_t IMG = 0xFFFFF80700000000ULL;
static const std::uint64_t IMG_SIZE = 0x100000;

static void build_export_image() {
    map_region(IMG, IMG_SIZE);
    // DOS header: e_lfanew at +0x3C = 0x100
    wr64(IMG + 0x3C, 0x100);
    // DataDirectory[0] at PE+0x88: export RVA = 0x2000, size = 0x1000
    wr64(IMG + 0x100 + 0x88, 0x2000);
    wr64(IMG + 0x100 + 0x8C, 0x1000);
    // export dir @ RVA 0x2000:
    //   +0x14 nFuncs, +0x18 nNames, +0x1C addrFuncs, +0x20 addrNames,
    //   +0x24 addrOrds
    std::uint64_t d = IMG + 0x2000;
    wr64(d + 0x14, 4);        // 4 functions
    wr64(d + 0x18, 4);        // 4 names
    wr64(d + 0x1C, 0x3000);   // funcs array RVA
    wr64(d + 0x20, 0x3100);   // names array RVA
    wr64(d + 0x24, 0x3200);   // ords array RVA
    // funcs: real code RVAs (+0x10000..), one FORWARDER (inside the dir)
    wr64(IMG + 0x3000 + 0 * 4, 0x10000);  // symbol0 body (u32 array!)
    wr64(IMG + 0x3000 + 1 * 4, 0x10008);  // symbol1 body
    wr64(IMG + 0x3000 + 2 * 4, 0x2004);   // symbol2 = FORWARDER (in dir)
    wr64(IMG + 0x3000 + 3 * 4, 0x10010);  // symbol3 body
    // names (u32 array — 4-byte stride)
    wr64(IMG + 0x3100 + 0 * 4, 0x4000);
    wr64(IMG + 0x3100 + 1 * 4, 0x4040);
    wr64(IMG + 0x3100 + 2 * 4, 0x4080);
    wr64(IMG + 0x3100 + 3 * 4, 0x40C0);
    wrstr(IMG + 0x4000, "Alpha");
    wrstr(IMG + 0x4040, "BetaGamma");       // 8 chars + NUL
    wrstr(IMG + 0x4080, "Forwarded");
    wrstr(IMG + 0x40C0, "PsInitialSystemProcess");
    // ords (u16): name i -> func index
    wr8(IMG + 0x3200 + 0, 0); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 2, 1); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 4, 2); wr8(IMG + 0x3201, 0);
    wr8(IMG + 0x3200 + 6, 3); wr8(IMG + 0x3201, 0);
}

static void kx_tests() {
    printf("\n== kx::Resolve (the REAL header, synthetic export image) ==\n");
    build_export_image();

    // T1: present symbol
    {
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "BetaGamma", 9);
        CHECK(r.rc == 1, "T1 present symbol resolves (rc=1)");
        CHECK(r.resolved_va == IMG + 0x10008, "T1 exact VA (base+0x10008)");
        CHECK(r.name_index == 1, "T1 name index 1");
    }
    // T2: the F3 entry symbol
    {
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "PsInitialSystemProcess", 22);
        CHECK(r.rc == 1, "T2 PsInitialSystemProcess resolves");
        CHECK(r.resolved_va == IMG + 0x10010, "T2 exact VA");
        CHECK(r.name_index == 3, "T2 name index 3");
    }
    // T3: absent symbol
    {
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "NoSuchSymbolV30", 15);
        CHECK(r.rc == 0, "T3 absent symbol -> rc=0 (notfound)");
        CHECK(r.resolved_va == 0, "T3 va=0");
    }
    // T4: forwarded export refused
    {
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Forwarded", 9);
        CHECK(r.rc == 3, "T4 forwarded export -> rc=3 (refused, not followed)");
        CHECK(r.resolved_va == 0, "T4 forwarded va=0");
    }
    // T5: corrupt e_lfanew -> gate refused
    {
        wr64(IMG + 0x3C, 0x5000);              // out of [0x40,0x1000)
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T5 bad e_lfanew -> rc=4 (gate refused)");
        wr64(IMG + 0x3C, 0x100);               // restore
    }
    // T6: no export table (RVA 0)
    {
        wr64(IMG + 0x100 + 0x88, 0);
        kx::Ctx c{IMG, IMG_SIZE, 0, 0};
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T6 no export dir -> rc=4");
        wr64(IMG + 0x100 + 0x88, 0x2000);      // restore
    }
    // T7: budget sticky-error propagation (tiny image size -> range gate)
    {
        kx::Ctx c{IMG, 0x30, 0, 0};            // size < 0x40
        kx::ResolveResult r = kx::Resolve(&c, "Alpha", 5);
        CHECK(r.rc == 4, "T7 undersized image -> rc=4");
    }
}

// ==================== pw: synthetic process list ====================
static const std::uint64_t SYS = 0xFFFFF8071A000000ULL;   // System EPROCESS

static void eproc(std::uint64_t base, std::uint32_t pid, const char* name) {
    map_region(base, 0x1000);                  // the EPROCESS head page
    wr64(base + 0x440, pid);                   // UniqueProcessId
    if (name) {
        map_region(base + 0x5A0, 0x1000);      // name slot page
        wrstr(base + 0x5A8, name);
    }
}
static void link(std::uint64_t from, std::uint64_t to) {
    // from's Flink = to + 0x448 ; to's Blink = from + 0x448
    wr64(from + 0x448, to + 0x448);
    wr64(to + 0x448 + 8, from + 0x448);
}

static void pw_tests() {
    printf("\n== pw::WalkCore (the REAL header, synthetic process list) ==\n");
    // ------- T8: healthy 5-process circle -------
    // 5 entries, 0x100000 apart (same pool cluster), circular
    {
        g_pages.clear();
        const int N = 5;
        std::uint64_t e[N];
        const char* names[N] = {"System", "smss.exe", "csrss.exe",
                                "wininit.exe", "services.exe"};
        std::uint32_t pids[N] = {4, 316, 448, 512, 596};
        for (int i = 0; i < N; i++)
            e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], pids[i], names[i]);
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
        // complete the circle: last's flink already -> System; System's
        // blink -> last (link() wrote both directions for each pair)
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
    // ------- T9: corrupted Flink (garbage non-canonical) -------
    {
        g_pages.clear();
        const int N = 3;
        std::uint64_t e[3];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(100 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        wr64(e[1] + 0x448, 0x0000123400000000ULL);   // corrupt: non-canonical
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBrokenLink, "T9 corrupt Flink -> BrokenLink");
        CHECK(r.count == 0 && r.stored == 0, "T9 partial results discarded");
    }
    // ------- T10: forward-consistency violation (Blink(next) != cur) -------
    {
        g_pages.clear();
        const int N = 3;
        std::uint64_t e[3];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(200 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        wr64(e[1] + 0x448 + 8, 0xFFFFF807DEAD0000ULL);  // Blink lies
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBrokenLink, "T10 Blink(next)!=cur -> BrokenLink");
    }
    // ------- T11: pid@S1 != 4 -------
    {
        g_pages.clear();
        eproc(SYS, 1337, nullptr);
        wr64(SYS + 0x448, SYS + 0x448);       // self-link
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwNotSys, "T11 pid@S1 != 4 -> NotSys");
    }
    // ------- T12: S1 non-canonical -------
    {
        g_pages.clear();
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(0x0000123400000000ULL, out, 32, &bud);
        CHECK(r.status == pw::kPwBadEntry, "T12 S1 non-canonical -> BadEntry");
    }
    // ------- T13: out_n invalid -------
    {
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        CHECK(pw::WalkCore(SYS, out, 0,  &bud).status == pw::kPwBadArgs,
              "T13a out_n=0 -> BadArgs");
        CHECK(pw::WalkCore(SYS, out, 33, &bud).status == pw::kPwBadArgs,
              "T13b out_n=33 -> BadArgs");
        CHECK(pw::WalkCore(SYS, nullptr, 8, &bud).status == pw::kPwBadArgs,
              "T13c null out -> BadArgs");
    }
    // ------- T14: window violation (link points 8 GB away) -------
    {
        g_pages.clear();
        std::uint64_t far = SYS + 0x200000000ULL;   // 8 GB away
        eproc(SYS, 4, nullptr);
        eproc(far, 500, nullptr);
        wr64(SYS + 0x448, far + 0x448);             // System -> far entry
        wr64(far + 0x448 + 8, SYS + 0x448);         // far Blink ok (consistent!)
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwWindowRefused,
              "T14 link 8GB away -> WindowRefused (before any read there)");
    }
    // ------- T15: budget exhaustion -------
    {
        g_pages.clear();
        const int N = 3;
        std::uint64_t e[3];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(300 + i), nullptr);
        link(e[0], e[1]); link(e[1], e[2]); link(e[2], e[0]);
        pw::Entry out[32];
        pw::Budget bud{0, 1};                       // only ONE page allowed
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwBudget, "T15 budget=1 page -> Budget refuse");
    }
    // ------- T16: one-process list (System alone) -------
    {
        g_pages.clear();
        eproc(SYS, 4, "System");
        wr64(SYS + 0x448, SYS + 0x448);       // flink -> self (alone)
        wr64(SYS + 0x448 + 8, SYS + 0x448);   // blink -> self
        pw::Entry out[32];
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 32, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 1 && r.closed == 1,
              "T16 one-process list: Ok, count=1, closed");
    }
    // ------- T17: name slot absent -> names zeroed, walk still Ok -------
    {
        g_pages.clear();
        const int N = 3;
        std::uint64_t e[3];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(400 + i), nullptr);  // NO names
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
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
    // ------- T18: more processes than out_n -> stored capped, count full ---
    {
        g_pages.clear();
        const int N = 8;
        std::uint64_t e[8];
        for (int i = 0; i < N; i++) e[i] = SYS + (std::uint64_t)i * 0x100000ULL;
        for (int i = 0; i < N; i++) eproc(e[i], i == 0 ? 4u : (std::uint32_t)(600 + i), nullptr);
        for (int i = 0; i < N; i++) link(e[i], e[(i + 1) % N]);
        pw::Entry out[4];                       // out_n = 4 < 8
        pw::Budget bud{0, pw::kPwMaxPages};
        pw::Result r = pw::WalkCore(SYS, out, 4, &bud);
        CHECK(r.status == pw::kPwOk && r.count == 8 && r.stored == 4,
              "T18 count=8 total, stored=4 (capped by out_n)");
    }
    // ------- T19: 64-cap (100 processes; stopping = success) -------
    {
        g_pages.clear();
        const int N = 100;
        for (int i = 0; i < N; i++) {
            std::uint64_t b = SYS + (std::uint64_t)i * 0x10000ULL; // tight cluster
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

int main() {
    printf("==== host-test-v22: the REAL KernelExports.h + ProcessWalk.h ====\n");
    printf("strict mode: ANY out-of-map read aborts the whole test run\n");
    kx_tests();
    pw_tests();
    printf("\n==== RESULT: %d PASS / %d FAIL / %ld hosted reads ====\n",
           g_pass, g_fail, g_reads);
    return g_fail ? 1 : 0;
}
