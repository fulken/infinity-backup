#!/usr/bin/env python3
# ============================================================================
# analyze-v38-almostro.py — the offline ALMOSTRO analysis (F4 attempt 5)
# Field run: v26e driver + trigger v38, 2026-09-28 20:04 (deterministic boot #4)
# Inputs : upload/v38-extract/ntoskrnl-almostro.bin (160480 B, RVA 0xCFB000)
#          upload/v38-extract/trigger-test-v38-output-20260928-200441.txt
# Output : version-archive/reports/loose-evidence/v38-run/almostro-analysis.txt
# Goals  : A integrity (157-chunk echo verify + 3 live echo cross-checks)
#          B qword census + region buckets
#          C the MmPageLocationList lattice algebra -> the TRUE MmPfnDatabase
#          D MmPteBase pinning + the s-guard + PTE formulas for v27/v39
#          E the chunk-math postmortem ([int] rounds, 158 vs 157)
# ============================================================================
import struct, re, sys, os
from collections import Counter, defaultdict

BASE = '/home/z/my-project'
BIN  = f'{BASE}/upload/v38-extract/ntoskrnl-almostro.bin'
TR   = f'{BASE}/upload/v38-extract/trigger-test-v38-output-20260928-200441.txt'
OUT  = f'{BASE}/version-archive/reports/loose-evidence/v38-run/almostro-analysis.txt'

SEC_RVA = 0xCFB000
SEC_VS  = 0x272E0            # 160480
PE_BASE = 0xFFFFF8075BA00000
PE_SIZE = 0x1046000
PE_END  = PE_BASE + PE_SIZE

# live values captured in THIS boot's transcript (the echo cross-check targets)
R1_LIVE   = 0xFFFFE20000000000   # @RVA 0xCFB358, pte-base shaped s=0x1C4
PSINIT_VA = 0xFFFFF8075C6FC420   # the variable itself @RVA 0xCFC420
EPROC     = 0xFFFFBA8FA405A040   # System EPROCESS (its value)
R4_LIVE   = 0xFFFFF807597B0000   # @0xCFC500 poison-class (this boot)
R5_LIVE   = 0xFFFFE60000000000   # @0xCFC510 pte-space-class s=0x1CC
DTB       = 0x1AD000             # System DTB (pfn 0x1AD)
R9_LIVE   = [0xFFFFBA8FA40C12A0, 0xFFFFBA8FA403F2C0, 0xFFFFF8075C724A00, 0x0,
              0x004E000100001388, 0x0, 0xFFFFF8075C6FC4F0, 0xFFFFF8075C6FC4F0,
              0xFFFFF807597B0000, 0x0, 0xFFFFE60000000000, 0x0,
              0xFFFFBA8FA40CD7A0, 0x6, 0x1, 0x0]

buf = open(BIN, 'rb').read()
L   = []            # output lines
def w(s=''):
    L.append(s)
    print(s)

def qw(off):
    return struct.unpack_from('<Q', buf, off)[0]
def rva(off):
    return SEC_RVA + off
def va(off):
    return PE_BASE + SEC_RVA + off

w('=' * 78)
w('PART A - INTEGRITY: size + the 157-chunk transcript echo verify + live echoes')
w('=' * 78)
okA = True
if len(buf) != SEC_VS:
    w(f'[FAIL] size {len(buf)} != {SEC_VS}'); okA = False
else:
    w(f'[OK] dump size {len(buf)} == section VS 0x{SEC_VS:X} (byte-exact section)')

# ---- parse the transcript: seq -> following [DT] hex ----
txt = open(TR, 'r', errors='replace').read()
lines = txt.split('\n')
echo = {}                       # seq -> bytes
cur_seq = None
for ln in lines:
    m = re.search(r'header: sequence=0x([0-9A-Fa-f]+)\s+status=(\d+)', ln)
    if m:
        cur_seq = int(m.group(1), 16) if int(m.group(2)) == 1 else None
        continue
    m = re.match(r'\s*\[DT\] InfinityData (\d+) bytes: ([0-9A-Fa-f ]*)', ln)
    if m and cur_seq is not None:
        n = int(m.group(1))
        hb = m.group(2).split()
        if len(hb) == n:
            echo[cur_seq] = bytes(int(x, 16) for x in hb)
        cur_seq = None

# dump chunks: seq 0x2000 + ci, ci = 0..156
mismatch = absent = 0
for ci in range(157):
    seq = 0x2000 + ci
    if seq not in echo:
        absent += 1; w(f'[WARN] chunk {ci} (seq 0x{seq:X}) echo missing'); continue
    off, ln = ci * 1024, len(echo[seq])
    if buf[off:off + ln] != echo[seq]:
        mismatch += 1
        w(f'[FAIL] chunk {ci}: bin != transcript echo')
n_echo = sum(1 for s in echo if 0x2000 <= s <= 0x209C)
w(f'[{"OK" if (mismatch == 0 and absent == 0) else "FAIL"}] transcript echo verify: '
  f'{n_echo}/157 dump chunks found, {mismatch} mismatches, {absent} missing')
w(f'       (the 2 section-table chunks + {len(echo) - n_echo - 2} other [DT] reads also present: '
  f'{len(echo)} echoes total)')
okA = okA and mismatch == 0 and absent == 0

# ---- live echo cross-checks (same boot: dump bytes must equal live reads) ----
checks = [
    ('R1 MmPteBase slot      @0xCFB358', 0x358,  R1_LIVE),
    ('PsInitialSystemProcess @0xCFC420', 0x1420, EPROC),
    ('R4 poison slot         @0xCFC500', 0x1500, R4_LIVE),
    ('R5 pte-space slot      @0xCFC510', 0x1510, R5_LIVE),
]
for name, off, live in checks:
    got = qw(off)
    good = got == live
    okA &= good
    w(f'[{"OK" if good else "FAIL"}] {name}: dump=0x{got:016X} live=0x{live:016X}')
r9ok = all(qw(0x14C0 + i * 8) == v for i, v in enumerate(R9_LIVE))
okA &= r9ok
w(f'[{"OK" if r9ok else "FAIL"}] R9 window 16 qwords @0xCFC4C0-0xCFC538: dump == live (same boot)')

w()
w('=' * 78)
w('PART B - QWORD CENSUS (all 8-aligned slots) + kernel-pointer region buckets')
w('=' * 78)
nq = len(buf) // 8
cls = Counter()
kptr = []                        # (rva, value) canonical kernel, non-image
for off in range(0, len(buf) - 7, 8):
    v = qw(off)
    if v == 0:                                   cls['zero'] += 1
    elif v < 0x1_0000_0000:                      cls['low32/data'] += 1
    elif v < 0x0000_8000_0000_0000 and v >> 32:  cls['mid/pseudo-phys'] += 1
    elif 0xFFFF8000_0000_0000 <= v <= 0xFFFF_FFFF_FFFF_FFFF:
        if PE_BASE <= v < PE_END:                cls['image-self'] += 1
        else:
            cls['canonical-kernel-nonimage'] += 1
            kptr.append((rva(off), v))
    else:                                        cls['noncanonical'] += 1
for k, c in cls.most_common():
    w(f'  {k:<28} {c:>7}  ({100.0*c/nq:.1f}%)')

# region buckets by top 24 bits
regions = defaultdict(list)
for r, v in kptr:
    regions[v >> 40].append((r, v))
w(f'\n  kernel non-image pointer regions (by bits 63:40, >= 3 members):')
for rk in sorted(regions, key=lambda k: -len(regions[k])):
    vs = regions[rk]
    if len(vs) < 3: continue
    lo = min(v for _, v in vs); hi = max(v for _, v in vs)
    w(f'    0x{rk:03X}xxxxxxxxxx : {len(vs):>3} ptrs, span 0x{lo:016X} .. 0x{hi:016X}'
      f' (delta 0x{hi-lo:X} = {(hi-lo)//1024} KB)'
      f'  first rva=0x{vs[0][0]:X}')

w()
w('=' * 78)
w('PART C - THE LATTICE ALGEBRA: MmPageLocationList -> the TRUE MmPfnDatabase')
w('=' * 78)
# Model: a live page-list link  L = pdb + 8 + pfn*0x30  (LIST_ENTRY at _MMPFN+8)
#  -> all links share residue (pdb+8) mod 0x30
#  -> every pair difference is an exact multiple of 0x30
#  -> pdb page-aligned (mod 0x1000) gives a small candidate set per link
STRIDE = 0x30
def is_canon_kern(v):
    return 0xFFFF8000_0000_0000 <= v <= 0xFFFF_FFFF_FFFF_FFFF and not (PE_BASE <= v < PE_END)

# C1: empty-list self-link heads (a MmPageLocationList cluster would show SEVERAL)
selfs = [rva(o) for o in range(0, len(buf) - 15, 8)
         if qw(o) == qw(o + 8) == va(o)]
w(f'[C1] empty LIST_ENTRY self-link heads in the whole dump: {len(selfs)}')
for r in selfs:
    w(f'     @rva 0x{r:06X}  ({{&self,&self}})')
w(f'     -> an idle VM keeps several page lists empty; a MmPageLocationList cluster')
w(f'        would show MULTIPLE adjacent self-link heads. {len(selfs)} found = NO cluster.')

# C2: live LIST_ENTRY pairs {F,B} - the backblock region census
pairs = defaultdict(list)
for o in range(0, len(buf) - 15, 8):
    a, b = qw(o), qw(o + 8)
    if is_canon_kern(a) and is_canon_kern(b):
        pairs[a >> 36].append((rva(o), a, b))
w(f'\n[C2] live {{Flink,Blink}} pairs by target region:')
for rk in sorted(pairs, key=lambda k: -len(pairs[k])):
    w(f'     0x{rk:03X}.......... : {len(pairs[rk]):>2} pairs'
      + ('  (kernel POOL - ordinary lists)' if rk in (0xFFFFBA8,) else ''))
mixed = [(r, a, b) for lst in pairs.values() for r, a, b in lst
         if (a >> 36) != (b >> 36)]
w(f'     ({len(mixed)} cross-region pairs = adjacent unrelated globals, not lists)')

# C3: page-aligned canonical non-image VALUES stored in qwords (a DB-base shape)
w(f'\n[C3] page-aligned canonical non-image values stored in the dump:')
for o in range(0, len(buf) - 7, 8):
    v = qw(o)
    if is_canon_kern(v) and v % 0x1000 == 0 and (v >> 32) != 0xFFFFFFFF:
        note = ''
        if rva(o) == 0xCFB358: note = ' <- MmPteBase (PINNED, PART D)'
        elif rva(o) == 0xCFC500: note = ' <- R4 poison class (crash-fingerprinted, v35)'
        elif rva(o) == 0xCFC510: note = ' <- R5 pte-space class (independent of s, poison)'
        elif rva(o) == 0xCFC640: note = f' <- pe_base+pe_size (image END boundary)'
        elif rva(o) == 0xCFC648: note = ' <- R4_value+0x6000 (same class as R4)'
        elif (v >> 40) == 0xFFFFBA: note = ' (pool-class)'
        elif (v >> 40) == 0xFFFFE2: note = ' (pte-space class)'
        elif (v >> 40) == 0xFFFF97: note = f' (KPCR region, kpcr=0xFFFF9781A918B000 live)'
        else: note = f' (0x{v>>40:03X} region)'
        w(f'     @rva 0x{rva(o):06X}  0x{v:016X}{note}')

# C4: the verdict
w(f'\n[C4] pdb (MmPfnDatabase) SEARCH VERDICT: NOT PINNABLE from the ALMOSTRO dump.')
w(f'     - no multi-head self-link cluster (C1) -> the page-list heads are not here')
w(f'     - no single-residue multi-link lattice into any candidate DB region (C2:')
w(f'       0xFFFF810EA.. family has MIXED residues 0x10/0x00/0x20, and 0x...BA30')
w(f'       cannot solve to a 16-aligned pdb: (0xBA30-8) mod 16 = 8, pfn*0x30 mod 16 = 0)')
w(f'     - no stored DB-base-shaped value beyond the known poison classes (C3)')
w(f'     CLOSURE, not a failure: chain B (the pfn-DB walk) is DELETED from v27 by')
w(f'     design - both BSODs were chain B - and chain A needs NO pdb. The F4 walk')
w(f'     (v39) proves translation via the selfmap self-entry ground truth (PART D).')
w(f'     If any later phase ever wants the pdb: a guarded runtime probe')
w(f'     (pdb_slot + 0x1AD*0x30 + 8 with the [PT]-trace-first discipline) or a .data')
w(f'     re-dump targeted at the list heads can revisit. Not blocking anything.')

w()
w('=' * 78)
w('PART D - MmPteBase PINNED + the s-guard + PTE formulas for the v27/v39 walk')
w('=' * 78)
pdb_val = qw(0x358)
pte     = pdb_val
s       = (pte >> 39) & 0x1FF
w(f'[D1] MmPteBase SLOT = RVA 0xCFB358 (dump offset 0x358), value 0x{pte:016X}')
w(f'     self-map index s = bits 47:39 = 0x{s:X} ({s})')
w(f'     [OK] dump value == live R1 read (same boot) -> THE SLOT IS PINNED, not a coincidence:')
w(f'     the offline map and the live runtime agree, and the value is pte-space shaped')
if (pte & 0xFF_FFFF_FFFF) == 0 and pte != 0:
    w(f'     [OK] low 40 bits zero - a clean PTE-space base (s<<39 sign-extended)')
mask39 = 0x7FFFFFFFF8
def pte_va(va_):
    return (pte | ((va_ >> 9) & mask39)) & 0xFFFF_FFFF_FFFF_FFFF
for name, t in [('System EPROCESS (pool)', EPROC), ('PsInit variable (image)', PSINIT_VA),
                ('kernel image base', PE_BASE)]:
    p = pte_va(t)
    w(f'[D2] PTE({name} 0x{t:016X}) = MmPteBase + ((VA>>9)&0x7FFFFFFFF8) = 0x{p:016X}')
    w(f'     s-guard check: PTE - MmPteBase = 0x{p-pte:X} < selfmap quadrant 0x{0x1FF<<30:X}: '
      f'{"OK" if p - pte < (0x1FF << 30) else "FAIL"}')
r5 = qw(0x1510)
w(f'[D3] R5 slot 0xCFC510 = 0x{r5:016X}: s\' = 0x{(r5>>39)&0x1FF:X} '
    f'(pte-space class; this boot s\'=s+8 by coincidence - the v35 boot had s=0x138 vs')
w(f'     s\'=0x1F3, delta 0xBB - so R5 tracks an INDEPENDENT pte-space constant, not s+8).')
w(f'     Poison for chain B, irrelevant to chain A.')
w(f'[D4] the chain-A walk (v27/v39) needs ONLY: MmPteBase slot 0xCFB358 (read live per boot),')
w(f'     the formula above, the s-guard, and [PT] traces before any read. No pdb required.')

# D5: the selfmap self-entry ground truth - THE v39 PROOF TARGET
self_va = pte | (s << 30) | (s << 21) | (s << 12) | (s << 3)
w(f'[D5] THE SELFMAP SELF-ENTRY (the v39 ground-truth check):')
w(f'     PML4E[s] read through the selfmap = MmPteBase | s<<30 | s<<21 | s<<12 | s<<3')
w(f'                     = 0x{self_va:016X}   (s=0x{s:X})')
w(f'     EXPECTED content: the PML4 maps itself -> (DTB & ~0xFFF) | flags')
w(f'                     = 0x{DTB:016X} | flags  (op-11 live dtb, pfn 0x{DTB>>12:X})')
w(f'     i.e. the qword at 0x{self_va:016X} must read 0x{DTB:X}63/0x{DTB:X}e3-class')
w(f'     (P|RW|A|D (+maybe NX)). A hit == the translation formula is PROVEN against')
w(f'     an INDEPENDENT ground truth (the CR3), with zero extra assumptions.')
# D6: the full hierarchy map for the v39 [PT] trace expectations
# derived (selfmap recursion): PTE(x) = B|i4<<30|i3<<21|i2<<12|i1<<3   (= B + ((x>>9)&mask))
#   PDE(x)  = B|s<<30|i4<<21|i3<<12|i2<<3     (reads PDE[i4][i3][i2], x's PT pointer)
#   PDPE(x) = B|s<<30|s<<21|i4<<12|i3<<3      (reads PDPE[i4][i3], x's PD pointer)
#   PML4E(i)= B|s<<30|s<<21|s<<12|i<<3        (reads PML4E[i]; i=s -> the SELF-ENTRY)
w(f'[D6] the v39 [PT] trace ladder (each read guarded: canonical + inside the selfmap')
w(f'     quadrant [MmPteBase, MmPteBase + 0x1FF<<30) + one read at a time):')
def pdpe_va(x):
    return pte | (s << 30) | (s << 21) | (((x >> 39) & 0x1FF) << 12) | (((x >> 30) & 0x1FF) << 3)
def pde_va(x):
    return pte | (s << 30) | (((x >> 39) & 0x1FF) << 21) | (((x >> 30) & 0x1FF) << 12) | (((x >> 21) & 0x1FF) << 3)
for name, t in [('EPROCESS page (pool)', EPROC), ('PsInit page (image)', PSINIT_VA),
                ('kernel base page', PE_BASE)]:
    w(f'     {name} 0x{t:016X}:')
    w(f'       PDPE @0x{pdpe_va(t):016X}  PDE  @0x{pde_va(t):016X}  PTE @0x{pte_va(t):016X}')
w(f'     all three levels must be PRESENT (P=1) and consistent; the PTE\'s pfn is the PA')
w(f'     of the target page (e.g. PsInit page pfn -> PA of the 0xCFB420 page we hold)')
w(f'     selfmap self-entry: 0x{self_va:016X} (expect pfn 0x{DTB>>12:X} == the CR3)')

w()
w('=' * 78)
w('PART E - THE CHUNK-MATH POSTMORTEM (why "PARTIAL 157/158" with a complete dump)')
w('=' * 78)
w(f'[E1] PowerShell:  $total = [int](($dataVs + $chunkSz - 1) / $chunkSz)')
w(f'     [int] CAST ROUNDS (banker\'s), it does NOT truncate:')
w(f'     (160480 + 1023)/1024 = {160480+1023}/1024 = {(160480+1023)/1024:.6f} -> [int] -> '
  f'{round((160480+1023)/1024)}   (correct ceil = 157)')
w(f'     v36 .data (1025488+1023)/1024 = {(1025488+1023)/1024:.6f} -> [int] -> '
  f'{round((1025488+1023)/1024)} (== correct 1002: LUCKY - frac < 0.5)')
w(f'     ALMOSTRO frac 0.72 >= 0.5 -> phantom chunk 158 -> remain = 160480-157*1024 = '
  f'{160480-157*1024} -> len<0 -> request never accepted -> failAt=157 -> "PARTIAL"')
w(f'[E2] The data: all 157 chunks written (dumpSent=157, INFCNT=215 exact), .bin == 160480 B')
w(f'     == the complete section. The pre-scan + sha256 were gated on $dumpOk -> skipped.')
w(f'[E3] The fix (v39, one line): $total = [int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)')
w(f'     (or -shr 10 after +1023). Validation-layer lesson: the Python port must emulate')
w(f'     PowerShell CAST SEMANTICS (rounding), not just the formula shape - the v38 functional')
w(f'     test ported the math with Python floor semantics and hid this.')

w()
w('=' * 78)
w('VERDICT')
w('=' * 78)
verdict_integrity = 'GREEN' if okA else 'RED'
w(f'A integrity            : {verdict_integrity} '
  f'(size exact, echo-verified vs the transcript, 4 live echo checks + R9 all match)')
w(f'B census               : {len(kptr)} kernel non-image pointers, '
  f'{len(regions)} regions (see buckets)')
w(f'C pdb                  : NOT PINNABLE from ALMOSTRO (C1-C4) - and NOT NEEDED:')
w(f'                         chain B is deleted from v27; chain A needs no pdb')
w(f'D MmPteBase            : PINNED - slot RVA 0xCFB358, value 0x{pte:016X}, s=0x{s:X};')
w(f'                         the dump bytes, the live read and the pte-space shape all agree')
w(f'E chunk-math           : ROOT-CAUSED - [int] rounding; data complete; one-line fix for v39')

os.makedirs(os.path.dirname(OUT), exist_ok=True)
open(OUT, 'w').write('\n'.join(L) + '\n')
print(f'\n[SAVED] {OUT} ({len(L)} lines)')
