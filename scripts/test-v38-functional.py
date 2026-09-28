#!/usr/bin/env python3
# ============================================================================
# test-v38-functional.py — THE REAL-DATA functional test of the v38 D2 fix
#
# The v37 field transcript carries the ACTUAL section table the VM's own
# kernel answered (33 sections x 40 B in 2 [DT] chunks). This test:
#   1. parses that REAL table out of the transcript
#   2. runs the v38 match logic (Python port: EVERY name decoded, no
#      first-byte guard) -> MUST find ALMOSTRO RVA=0xCFB000 VS=0x272E0
#   3. runs the OLD v37 logic (the 0x2E guard) -> MUST fail (reproduces
#      the field bug - proves this test would have caught it pre-ship)
#   4. runs the census fallback on a no-match synthetic -> must list all
#   5. bounds gate: RVA+VS must fit inside pe_size (0x1046000)
#   6. the v38 ps1's D+ pre-scan region must be BYTE-IDENTICAL to v37's
#      (the fix must not touch anything downstream of the match)
# ============================================================================
import re, struct, pathlib, sys

BASE = pathlib.Path('/home/z/my-project')
TX = BASE / 'upload' / 'v37-extract' / 'trigger-test-v37-output-20260928-085014.txt'
PS37 = (BASE / 'patches' / 'trigger-test-v37.ps1').read_text(encoding='utf-8')
PS38 = (BASE / 'patches' / 'trigger-test-v38.ps1').read_text(encoding='utf-8')
raw = TX.read_bytes().decode('utf-8', 'replace')
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

# ---- 1. the REAL table from the field transcript ----
hexes = re.findall(r"\[DT\] InfinityData (\d+) bytes: ((?:[0-9A-F]{2} )+[0-9A-F]{2})", raw)
dts = [(int(n), bytes.fromhex(h.replace(" ", ""))) for n, h in hexes]
chunks = [b for n, b in dts if len(b) in (1024, 296) and b[:2] != b"MZ"]
table = b"".join(chunks)
check('field table recovered: 1320 bytes', len(table) == 1320, f'got {len(table)}')
NSEC, PE_SIZE = 33, 0x1046000
LFANEW, OPTSZ = 0x118, 0xF0

def name_at(i):
    return table[i*40:i*40+8].rstrip(b'\x00').decode('latin1')

# ---- 2. the v38 logic: EVERY name decoded, match ALMOSTRO ----
found38 = None
for i in range(NSEC):
    if name_at(i) == 'ALMOSTRO':
        vs = struct.unpack_from('<I', table, i*40+8)[0]
        va = struct.unpack_from('<I', table, i*40+12)[0]
        found38 = (i, va, vs)
check('v38 logic FINDS ALMOSTRO in the REAL table', found38 is not None)
if found38:
    i, va, vs = found38
    check('  at section #24 (index 23)', i == 23, f'index {i}')
    check('  RVA == 0xCFB000', va == 0xCFB000, hex(va))
    check('  VS  == 0x272E0 (160480 B = 157 chunks)', vs == 0x272E0, hex(vs))
    check('  bounds gate: RVA+VS=0xD222E0 <= pe_size 0x1046000', va + vs <= PE_SIZE)

# ---- 3. the OLD v37 logic (the 0x2E guard) must FAIL on the same bytes ----
found37 = None
for i in range(NSEC):
    if table[i*40] == 0x2E:                       # <- the fatal guard
        if name_at(i) == 'ALMOSTRO':
            found37 = (i,)
check('v37 logic (0x2E guard) FAILS on the REAL table (bug reproduced)', found37 is None)
check('  ...because ALMOSTRO starts with A (0x41), not . (0x2E)',
      table[23*40] == 0x41, hex(table[23*40]))

# ---- 4. the census fallback on a synthetic no-match table ----
def census(t, n):
    return ' '.join(t[i*40:i*40+8].rstrip(b'\x00').decode('latin1') for i in range(n))
fake = bytearray(table)
fake[23*40:23*40+8] = b'XLMOSTRO'    # corrupt the name only
c = census(bytes(fake), NSEC)
check('census lists all 33 names on a miss', len(c.split()) == 33 and 'XLMOSTRO' in c and 'ALMOSTRO' not in c)
check('census would have shown the truth in ONE trip', '.data' in c and 'CACHEALI' in c)

# ---- 5. chunk-count math for the v38 dump expectation ----
import math
n_chunks = math.ceil(0x272E0 / 1024)
check('VS 0x272E0 == 160480 bytes', 0x272E0 == 160480, str(0x272E0))
check('expected dump = 157 chunks (last partial 736 B)', n_chunks == 157 and 0x272E0 - 156*1024 == 736,
      f'{n_chunks} chunks, tail {0x272E0 - 156*1024}')

# ---- 6. the v38 ps1: the fix present, the guard gone, pre-scan untouched ----
check('v38 ps1: no 0x2E guard anywhere', 'd2.Data[($si * 40)] -eq 0x2E' not in PS38)
check('v38 ps1: the guard-fix comment present', 'THE 0x2E-GUARD FIX' in PS38)
check('v38 ps1: census fallback present', '[D2] census of all' in PS38)
check('v38 ps1: census only fires on a miss', 'if ($dataRva -eq 0) {' in PS38)
check('v38 ps1: stale .data skip label GONE', 'no .data section / bounds' not in PS38)
check('v38 ps1: new skip label present', 'SKIPPED (the ALMOSTRO section not found / out of bounds)' in PS38)

# ---- 6b. CODE-line identity v37 <-> v38 (after v38->v37 cosmetic
# normalization; comments excluded - the version swaps are cosmetic,
# the CODE must be identical outside the D2 match-loop edit) ----
def code_lines(t):
    return [ln for ln in t.splitlines() if ln.strip() and not ln.lstrip().startswith('#')]

PS38N = PS38.replace('v38', 'v37')          # normalize cosmetic swaps
# the ONE intentional code edit inside the D+->N region: the skip label
PS38N = PS38N.replace('SKIPPED (the ALMOSTRO section not found / out of bounds)',
                      'SKIPPED (no .data section / bounds)')

def region(t, a, b):
    return t[t.index(a):t.index(b)]

pairs = [
    ('D+ pre-scan code identical', '--- step D+: the ALMOSTRO pre-scan', '--- step N: final INFCNT read'),
    ('R-step code identical', '--- step R: the constant RECON', '--- step R9:'),
    ('R9 code identical', '--- step R9:', '--- step D: the ALMOSTRO dump'),
    ('dump-loop code identical', '---- the dump loop (resumable via the .marker file) ----', '--- step D+: the ALMOSTRO pre-scan'),
]
for label, a, b in pairs:
    x = code_lines(region(PS37, a, b))
    y = code_lines(region(PS38N, a, b))
    check(label, x == y, f'{len(x)} vs {len(y)} lines' + ('' if x == y else f' first diff: {next((f"{i}: {p!r} != {q!r}" for i,(p,q) in enumerate(zip(x,y)) if p!=q), "len")}'))

# every driver-touching send line identical (the wires)
sends37 = [ln for ln in PS37.splitlines() if 'New-Req' in ln or 'Send-Req' in ln or 'Send-Resolve' in ln]
sends38 = [ln for ln in PS38.splitlines() if 'New-Req' in ln or 'Send-Req' in ln or 'Send-Resolve' in ln]
check('all send/wire lines identical to v37', sends37 == sends38, f'{len(sends37)} vs {len(sends38)}')

print()
if fails:
    print(f'== {len(fails)} FAILURES ==')
    for f in fails: print(f'  - {f}')
    sys.exit(1)
print('== ALL FUNCTIONAL CHECKS PASS ==')
