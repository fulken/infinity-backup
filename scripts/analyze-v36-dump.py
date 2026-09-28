#!/usr/bin/env python3
# ============================================================================
# analyze-v36-dump.py — offline analysis of the v36 field dump (ntoskrnl .data)
#
# Input : upload/v36-extract/ntoskrnl-data.bin      (1025488 B = .data @ RVA 0xC00000)
#         upload/v36-extract/trigger-test-v36-*.txt (D2 section-table chunks)
# Facts : pe_base=0xFFFFF80651600000 pe_size=0x1046000 (K CONVERGED, v35+v36 boots)
#         MmPteBase live = 0xFFFF9C0000000000 s=0x138 (R1 @RVA 0xCFB358)
#         System dtb=0x1AD000 -> pfn 0x1AD ; _MMPFN entry size 0x30
#         (fingerprint: chain-B read = pdb + pfn*0x30 + 8, both 0x50 BSODs)
# Goal  : PIN the TRUE MmPfnDatabase for this build/boot:
#         Method 1: MmPageLocationList-style heads in .data -> array links
#                   all share residue r = pdb % 0x30; pdb is page-aligned ->
#                   r in {0,0x10,0x20}. Then pdb = the dump qword that is
#                   page-aligned, canonical, non-image, residue == r.
#         Method 2: stride-witness count for each candidate (links pointing
#                   into its 0x30-lattice).
# ============================================================================
import struct, sys
from collections import Counter, defaultdict

BIN  = '/home/z/my-project/upload/v36-extract/ntoskrnl-data.bin'
TXT  = '/home/z/my-project/upload/v36-extract/trigger-test-v36-output-20260928-065345.txt'
DATA_RVA = 0xC00000
PE_BASE  = 0xFFFFF80651600000
PE_SIZE  = 0x1046000
PE_END   = PE_BASE + PE_SIZE
ENTRY    = 0x30
SYS_PFN  = 0x1AD
# live-read poison/dead values from the v35+v36 R-section (same both boots)
POISON_R4 = 0xFFFFF8064D930000   # @RVA 0xCFC500 module-base-class
POISON_R5 = 0xFFFFF98000000000   # @RVA 0xCFC510 round dynamic-VA-class
PTE_BASE_LIVE = 0xFFFF9C0000000000

data = open(BIN, 'rb').read()
N = len(data)
assert N == 0xFA5D0, hex(N)
u64 = lambda o: struct.unpack_from('<Q', data, o)[0]
u32 = lambda o: struct.unpack_from('<I', data, o)[0]
rva = lambda off: DATA_RVA + off

print('=' * 78)
print('PART A — integrity + anchors')
print('=' * 78)
print(f'dump: {N} bytes = 0x{N:X}  (.data RVA 0x{DATA_RVA:X} .. 0x{rva(N):X})')

# anchor 1: NtBuildNumber @RVA 0xC12130 (M2 live-resolved v31 AND v36:
#           0x52212130-0x51600000 = 0xC12130 = 0x1A412130-0x19800000)
off_nb = 0xC12130 - DATA_RVA
nb = u32(off_nb)
ok_nb = (nb & 0xFFFF) == 19045
print(f'[ANCHOR] NtBuildNumber @RVA 0xC12130 (dump 0x{off_nb:X}): 0x{nb:08X} '
      f'-> low word {nb & 0xFFFF} {"== 19045 OK" if ok_nb else "!! MISMATCH"}')

# anchor 2: R2 slot @RVA 0xCFA358 (live-read 0 in BOTH v35 and v36)
off_r2 = 0xCFA358 - DATA_RVA
r2 = u64(off_r2)
print(f'[ANCHOR] R2 slot      @RVA 0xCFA358 (dump 0x{off_r2:X}): 0x{r2:016X} '
      f'{"== 0 OK (matches live read)" if r2 == 0 else "!! MISMATCH vs live 0"}')

# anchor 3: poison values must NOT appear as .data self-globals? (informational)
cnt_r4 = sum(1 for o in range(0, N - 7, 8) if u64(o) == POISON_R4)
cnt_r5 = sum(1 for o in range(0, N - 7, 8) if u64(o) == POISON_R5)
cnt_pt = sum(1 for o in range(0, N - 7, 8) if u64(o) == PTE_BASE_LIVE)
print(f'[INFO] qwords == R4 poison 0xFFFFF8064D930000 in .data: {cnt_r4}')
print(f'[INFO] qwords == R5 value 0xFFFFF98000000000 in .data: {cnt_r5}')
print(f'[INFO] qwords == live MmPteBase 0xFFFF9C0000000000 in .data: {cnt_pt}')

print()
print('=' * 78)
print('PART B — full section table (D2 chunks from the transcript)')
print('=' * 78)
sec_bytes = bytearray()
want = False
for line in open(TXT, encoding='utf-8', errors='replace'):
    if 'sequence=0x1B02' in line or 'sequence=0x1B03' in line:
        want = True
        continue
    if want and '[DT] InfinityData' in line:
        hexpart = line.split('bytes:', 1)[1]
        sec_bytes += bytes.fromhex(hexpart)
        want = False
assert len(sec_bytes) == 1320, len(sec_bytes)
sections = []
for i in range(33):
    e = sec_bytes[i * 40:(i + 1) * 40]
    name = e[0:8].rstrip(b'\x00').decode('latin1')
    vsz, vad, rsz, rad = struct.unpack_from('<IIII', e, 8)
    ch = struct.unpack_from('<I', e, 36)[0]
    sections.append((name, vsz, vad, rsz, rad, ch))
    print(f'  [{i:2d}] {name:<10} VA=0x{vad:08X} VS=0x{vsz:08X} '
          f'RS=0x{rsz:08X} RA=0x{rad:08X} CH=0x{ch:08X} end=0x{vad+vsz:X}')
# which section holds the researched-slot neighborhood 0xCFC420..0xCFC520?
for probe in (0xCFB358, 0xCFC420, 0xCFC500, 0xCFC510):
    hit = None
    for (name, vsz, vad, rsz, rad, ch) in sections:
        if vad <= probe < vad + vsz:
            hit = (name, vad, vsz)
            break
    print(f'  probe RVA 0x{probe:X} -> {hit}')

print()
print('=' * 78)
print('PART C — qword census (all 8-aligned qwords, %d slots)' % (N // 8))
print('=' * 78)
cls = Counter()
byhi = Counter()
for o in range(0, N - 7, 8):
    v = u64(o)
    if v == 0:
        cls['zero'] += 1
    elif PE_BASE <= v < PE_END:
        cls['image-self'] += 1
        byhi[f'0x{v>>36:03X}'] += 1
    elif 0xFFFF800000000000 <= v:
        cls['canonical-kernel-nonimage'] += 1
        byhi[f'0x{v>>36:03X}'] += 1
    elif v < 0x0000800000000000:
        cls['low/user'] += 1
    else:
        cls['noncanonical'] += 1
for k, c in cls.most_common():
    print(f'  {k:<30} {c:>7}')
print('  kernel-pointer VA classes (top-16 bits of the value, top 20):')
for k, c in byhi.most_common(20):
    print(f'    {k}  {c:>7}')

print()
print('=' * 78)
print('PART D — MmPageLocationList signature hunt (0x30-stride link clusters)')
print('=' * 78)
def is_kern_nonimg(v):
    return 0xFFFF800000000000 <= v and not (PE_BASE <= v < PE_END)

# D.1 collect every non-image canonical kernel pointer (potential array link)
links = []
for o in range(0, N - 7, 8):
    v = u64(o)
    if is_kern_nonimg(v):
        links.append((o, v))
print(f'non-image canonical kernel pointers in .data: {len(links)}')

# D.2 residue classes (mod 0x30). Page-aligned pdb -> residue in {0,0x10,0x20}.
res = Counter(v % ENTRY for _, v in links)
print('residue census of those pointers (mod 0x30):')
for r, c in sorted(res.items()):
    print(f'  r=0x{r:02X}  {c:>6}')

# D.3 window clustering: 128-byte windows with >=3 same-residue links
wins = []
for w in range(0, N - 128, 8):
    wl = [(o, v) for (o, v) in links if w <= o < w + 128]
    if len(wl) < 3:
        continue
    rc = Counter(v % ENTRY for _, v in wl)
    r, c = rc.most_common(1)[0]
    if c >= 3:
        wins.append((w, r, c, len(wl)))
# merge overlapping windows with the same dominant residue
merged = []
for (w, r, c, tot) in wins:
    if merged and merged[-1][2] + 128 >= w and merged[-1][1] == r:
        merged[-1][2] = max(merged[-1][2], w)
        merged[-1][3] = max(merged[-1][3], c)
    else:
        merged.append([w, r, w, c])
print(f'same-residue link clusters (>=3 links / 128B): {len(merged)}')
for (a, r, b, c) in merged[:20]:
    print(f'  dump 0x{a:X}..0x{b:X}  r=0x{r:02X}  max-links={c}')

# D.4 the classic list-head signature: window where image-class qwords point
#     back INTO the same window (empty-list self-links) mixed with array links
print()
print('self-linking-head signature windows (empty LIST_ENTRYs point home):')
sig = []
for w in range(0, N - 128, 8):
    arr = [v for (o, v) in links if w <= o < w + 128]
    selfs = 0
    for o in range(w, w + 128, 8):
        v = u64(o)
        if PE_BASE <= v < PE_END:
            tgt = v - PE_BASE - DATA_RVA
            if w <= tgt < w + 128:
                selfs += 1
    if len(arr) >= 3 and selfs >= 2:
        rc = Counter(v % ENTRY for v in arr)
        r, c = rc.most_common(1)[0]
        sig.append((w, r, c, len(arr), selfs))
for (w, r, c, a, s) in sig[:20]:
    print(f'  dump 0x{w:X} r=0x{r:02X} arraylinks={a}({c} congruent) selflinks={s}'
          f'  RVA 0x{rva(w):X}')

print()
print('=' * 78)
print('PART E — THE PIN: page-aligned non-image canonical qwords by residue')
print('=' * 78)
cands = []
for o in range(0, N - 7, 8):
    v = u64(o)
    if v & 0xFFF == 0 and is_kern_nonimg(v):
        cands.append((o, v))
print(f'page-aligned non-image canonical qwords in .data: {len(cands)}')
byres = defaultdict(list)
for o, v in cands:
    byres[v % ENTRY].append((o, v))
for r in sorted(byres):
    print(f'  residue 0x{r:02X}: {len(byres[r])} candidates')
# rank residues by the link census (PART D) — the pdb residue is the one
# enriched among non-image kernel pointers, esp. in clusters
rank = [r for r, _ in res.most_common()]
print(f'link-census ranking (most common residues): {[hex(r) for r in rank[:6]]}')

print()
print('=' * 78)
print('PART F — stride-witness scoring of every candidate (vs all links)')
print('=' * 78)
def witnesses(p):
    return [v for (_, v) in links if v > p and (v - p) % ENTRY == 0]

scored = []
for o, v in cands:
    w = witnesses(v)
    scored.append((len(w), o, v, w))
scored.sort(reverse=True)
print('top 15 candidates by stride-witness count:')
for (w, o, v, wl) in scored[:15]:
    print(f'  W={w:5d}  dump 0x{o:06X} RVA 0x{rva(o):08X}  val 0x{v:016X} '
          f'(res 0x{v % ENTRY:02X})')

print()
print('=' * 78)
print('PART G — verdict scaffolding')
print('=' * 78)
best_r = None
if sig:
    best_r = Counter(s[1] for s in sig).most_common(1)[0][0]
    print(f'dominant cluster residue from self-link signature: 0x{best_r:02X}')
elif merged:
    best_r = merged[0][1]
    print(f'dominant cluster residue from link clusters: 0x{best_r:02X}')
else:
    print('no clear cluster found - falling back to global residue ranking')

if best_r is not None:
    print(f'candidates with residue 0x{best_r:02X} (the pdb lattice):')
    for o, v in byres.get(best_r, []):
        w = witnesses(v)
        print(f'  dump 0x{o:06X} RVA 0x{rva(o):08X} val 0x{v:016X} W={len(w)}')
    print()
    print('R4/R5 poison residue check (should NOT match the lattice):')
    print(f'  R4 0x{POISON_R4:016X} residue 0x{POISON_R4 % ENTRY:02X}'
          f'{"  !!! MATCHES lattice" if POISON_R4 % ENTRY == best_r else "  (different)"}')
    print(f'  R5 0x{POISON_R5:016X} residue 0x{POISON_R5 % ENTRY:02X}'
          f'{"  !!! MATCHES lattice" if POISON_R5 % ENTRY == best_r else "  (different)"}')

# chain-B read address for the top candidate (the field chain B wanted)
if scored:
    w, o, v, wl = scored[0]
    print()
    print(f'top candidate pdb=0x{v:016X}:')
    print(f'  slot: dump 0x{o:06X} RVA 0x{rva(o):08X}')
    print(f'  chain-B-style probe for System pfn 0x{SYS_PFN:X}: '
          f'pdb + 0x{SYS_PFN:X}*0x30 + 8 = 0x{v + SYS_PFN * ENTRY + 8:016X}')
    print(f'  example witness links: {[hex(x) for x in wl[:5]]}')
