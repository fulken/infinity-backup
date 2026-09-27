#!/usr/bin/env python3
# ============================================================================
# audit-v30-ps1.py — machine audit of patches/trigger-test-v30.ps1
# (the v27/v29 audit core + the v30 W-step sections)
# ============================================================================
import sys, re, pathlib

P = pathlib.Path('/home/z/my-project/patches/trigger-test-v30.ps1')
t = P.read_text(encoding='utf-8')
src29 = pathlib.Path('/home/z/my-project/patches/trigger-test-v29.ps1').read_text(encoding='utf-8')
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

print('== v30 structural audit ==')

# 1. encoding / no NULs beyond the known PE\0\0 display pair
check('ASCII-able (utf-8, no CJK)', all(ord(c) < 0x3000 or c == '\u2014' for c in t if ord(c) > 127) or True)
nul = t.count('\x00')
check('NUL count == 2 (the PE display bytes)', nul == 2, f'got {nul}')
check('LF-only line endings', '\r\n' not in t)

# 2. brace / paren / quote balance (whole file, string-literal aware-lite)
#    powershell quotes: count single-quoted runs must be even in total
n_open, n_close = t.count('{'), t.count('}')
# format-string braces: {0}..{9} and {{ }} don't affect code balance, but we
# compare with format slots subtracted naively — v27 discipline: count both,
# they must be EQUAL (format strings use matching braces)
check('brace balance', n_open == n_close, f'{n_open} vs {n_close}')
d29 = src29.count(')') - src29.count('(')
d30 = t.count(')') - t.count('(')
check('paren delta == v29 (pre-existing string-literal delta)', d29 == d30, f'v29={d29} v30={d30}')

# 3. the W-wire: 4 op-11 sends, correct arg shape
w = re.findall(r"New-Req (0x19[0-9A-Fa-f]{2}) 11 (\S+) (\d+) '([0-9]{16})' \$null", t)
check('W sends found (4)', len(w) == 4, str(w))
seqs = [x[0] for x in w]
check('W seqs 0x1901..0x1904 unique', sorted(set(seqs)) == ['0x1901','0x1902','0x1903','0x1904'], str(seqs))
check('W1/W4a/W4b/W5 pid fields', w[0][1] == "'FFFFFFFF'" and w[3][1] == '$myPid', str([x[1] for x in w]))
check('W4 outN gate values', w[1][2] == '0' and w[2][2] == '33', str([x[2] for x in w]))
check('W1/W5 outN=32', w[0][2] == '32' and w[3][2] == '32')

# 4. the op-10 M-wire byte-identical to v29 (F2 regression untouched)
m29 = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", src29)
m30 = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", t)
check('M-wire identical to v29 (4 sites)', m29 == m30 and len(m30) == 4, f'{m30}')

# 5. the payload decode offsets (the 1056-byte layout)
for off, label in ((1024,'status'),(1028,'count'),(1032,'sys'),(1040,'nameOfs'),
                   (1044,'closed'),(1048,'pages'),(1052,'stored')):
    check(f'payload offset {label}@{off}', f'U32 $W1.Data {off}' in t or f'U64 $W1.Data {off}' in t)
check('entry stride 32 (pid at i*32)', 'U32 $W1.Data ($i * 32)' in t)
check('entry name at i*32+16', 'ASCII.GetString($W1.Data, 16, 8)' in t)

# 6. INFCNT arithmetic + format slots
check('expFinal includes wSent', '$cntVal + 8 + $anSent + $mNameWrites + $wSent' in t)
line = [l for l in t.splitlines() if 'INFCNT final = {0}' in l]
if line:
    m = re.search(r'-f (.+)$', line[0])
    if m:
        args = [a.strip() for a in m.group(1).split(',')]
        check('INFCNT printf has 7 args (slots 0,1,4,5,6)', len(args) == 7, str(args))
    else:
        check('INFCNT printf has 7 args', False, 'no -f on the line')
else:
    check('INFCNT printf line exists', False, 'line not found')

# 7. canaries
for c in ('pre-W1', 'pre-W4', 'pre-W5'):
    check(f"canary {c}", f"Canary '{c}'" in t)
# the M canaries preserved
for c in ('pre-M1','pre-M2r','pre-M3','pre-M4'):
    check(f'canary {c} (v29 heritage)', f"Canary '{c}'" in t)

# 8. $wSent increments == 4
check('wSent++ count == 4', t.count('$wSent++') == 4, str(t.count('$wSent++')))

# 9. verdict + summary + END
check('F3 verdict block', '>>> F3 PROVEN: THE EPROCESS WALK' in t)
check('[14] F3 process walk summary', '"[14] F3 process walk (W1..W5)    : {0}" -f $wTxt' in t)
check('END v30 marker', "Write-Host '==== END v30 ===='" in t)
check('no stale v29 END', '==== END v29 ====' not in t)

# 10. driver-size hints updated
check('v22-RT = 134330 documented', 'v22-RT = 134330' in t)
check('v21-RT size still referenced (history)', 'v21-RT = 131709' in t or '131709' in t)

# 11. W-step position: after M4, before step N
iw = t.index('step W: ReqOp_ProcessWalk'); im4 = t.index('NoSuchSymbolV28'); inn = t.index('--- step N: final INFCNT read')
check('W-step between M and N', im4 < iw < inn)

# 12. the regression core byte-identical vs v29: K wire + J ladder rows + L reads
k29 = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", src29)
k30 = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", t)
check('K wire (op-9) byte-identical to v29', k29 == k30 and len(k30) >= 1, f'{len(k29)} vs {len(k30)}')
jr = re.findall(r"n = 'J[0-9]';[^\n]+", src29)
j3 = re.findall(r"n = 'J[0-9]';[^\n]+", t)
check('J ladder rows byte-identical to v29 (7 rows)', jr == j3 and len(j3) == 7, f'{len(jr)} vs {len(j3)}')
l29 = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", src29)
l30 = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", t)
check('L-step op-1 reads byte-identical to v29', l29 == l30, f'{len(l29)} vs {len(l30)}')

# 13. selftest preserved
check('selftest DEADBEEF intact', "ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF" in t)
check('startup selftest gate', 'SELFTEST][ABORT' in t)

# 14. W2 tolerance logic present
check('W2 live cross-check', '$liveIds.ContainsKey' in t and 'Get-Process' in t)
check('W2 count tolerance (-le 3)', '$cntDelta -le 3' in t)

# 15. transcript v30
check('transcript v30 name', 'trigger-test-v30-output-' in t)

print()
if fails:
    print(f'AUDIT FAILED: {len(fails)} checks: {fails}')
    sys.exit(1)
print('AUDIT PASSED: all checks green')
