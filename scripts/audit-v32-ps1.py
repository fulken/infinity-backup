#!/usr/bin/env python3
# ============================================================================
# audit-v32-ps1.py — machine audit of patches/trigger-test-v32.ps1
# (the v31 audit core, re-targeted v30->v31 as the byte-identity base,
#  + the v32 driver-ID checks + the corrected W1 expectation checks)
# ============================================================================
import sys, re, pathlib

P = pathlib.Path('/home/z/my-project/patches/trigger-test-v32.ps1')
t = P.read_text(encoding='utf-8')
srcbase = pathlib.Path('/home/z/my-project/patches/trigger-test-v30.ps1').read_text(encoding='utf-8')
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

print('== v32 structural audit ==')

# 1. encoding / no NULs beyond the known PE\0\0 display pair
nul = t.count('\x00')
check('NUL count == 2 (the PE display bytes)', nul == 2, f'got {nul}')
check('LF-only line endings', '\r\n' not in t)

# 2. brace / paren balance
n_open, n_close = t.count('{'), t.count('}')
check('brace balance', n_open == n_close, f'{n_open} vs {n_close}')
dbase = srcbase.count(')') - srcbase.count('(')
d32 = t.count(')') - t.count('(')
# v32 adds TWO intentional half-open interval strings "[pe_base, pe_base+pe_size)"
# (the out-of-image W1 PASS text + the header doc) - same notation family as the
# F1 verdict line that already accounts for the v30 baseline imbalance.
n_interval = t.count('[pe_base, pe_base+pe_size)')
check('two new half-open interval strings present', n_interval == 2, f'got {n_interval}')
check('paren delta == v30 + 2 (the two interval strings)', d32 == dbase + 2, f'v30={dbase} v32={d32}')

# 3. the W-wire: 4 op-11 sends, correct arg shape
w = re.findall(r"New-Req (0x19[0-9A-Fa-f]{2}) 11 (\S+) (\d+) '([0-9]{16})' \$null", t)
check('W sends found (4)', len(w) == 4, str(w))
seqs = [x[0] for x in w]
check('W seqs 0x1901..0x1904 unique', sorted(set(seqs)) == ['0x1901','0x1902','0x1903','0x1904'], str(seqs))
check('W1/W4a/W4b/W5 pid fields', w[0][1] == "'FFFFFFFF'" and w[3][1] == '$myPid', str([x[1] for x in w]))
check('W4 outN gate values', w[1][2] == '0' and w[2][2] == '33', str([x[2] for x in w]))
check('W1/W5 outN=32', w[0][2] == '32' and w[3][2] == '32')

# 4. the op-10 M-wire byte-identical to v30 (F2 regression untouched)
mbase = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", srcbase)
m32 = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", t)
check('M-wire identical to v30 (4 sites)', mbase == m32 and len(m32) == 4, f'{m32}')

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
for c in ('pre-M1','pre-M2r','pre-M3','pre-M4'):
    check(f'canary {c} (v30 heritage)', f"Canary '{c}'" in t)

# 8. $wSent increments == 4
check('wSent++ count == 4', t.count('$wSent++') == 4, str(t.count('$wSent++')))

# 9. verdict + summary + END
check('F3 verdict block', '>>> F3 PROVEN: THE EPROCESS WALK' in t)
check('[14] F3 process walk summary', '"[14] F3 process walk (W1..W5)    : {0}" -f $wTxt' in t)
check('END v32 marker', "Write-Host '==== END v32 ===='" in t)
check('no stale v31 END', '==== END v31 ====' not in t)

# 10. driver-size hints
check('v24-RT = 134842 documented', '134842' in t)
check('v23/v22 = 134330 still documented (history + refusal texts)', '134330' in t)
check('v21-RT size still referenced (history)', 'v21-RT = 131709' in t or '131709' in t)

# 11. W-step position: after M4, before step N
iw = t.index('step W: ReqOp_ProcessWalk'); im4 = t.index('NoSuchSymbolV28'); inn = t.index('--- step N: final INFCNT read')
check('W-step between M and N', im4 < iw < inn)

# 12. the regression core byte-identical vs v30: K wire + J ladder rows + L reads
kbase = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", srcbase)
k32 = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", t)
check('K wire (op-9) byte-identical to v30', kbase == k32 and len(k32) >= 1, f'{len(kbase)} vs {len(k32)}')
jbase = re.findall(r"n = 'J[0-9]';[^\n]+", srcbase)
j32 = re.findall(r"n = 'J[0-9]';[^\n]+", t)
check('J ladder rows byte-identical to v30 (7 rows)', jbase == j32 and len(j32) == 7, f'{len(jbase)} vs {len(j32)}')
lbase = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", srcbase)
l32 = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", t)
check('L-step op-1 reads byte-identical to v30', lbase == l32, f'{len(lbase)} vs {len(l32)}')

# 13. selftest preserved
check('selftest DEADBEEF intact', "ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF" in t)
check('startup selftest gate', 'SELFTEST][ABORT' in t)

# 14. W2 tolerance logic present
check('W2 live cross-check', '$liveIds.ContainsKey' in t and 'Get-Process' in t)
check('W2 count tolerance (-le 3)', '$cntDelta -le 3' in t)

# 15. transcript v32
check('transcript v32 name', 'trigger-test-v32-output-' in t)

# 16. v32 driver-ID: sizes + hashes
check('v24 sha256 documented', 'f8a01814' in t and 'dbcf5846' in t)
check('v23 (missing-deref) sha256 documented as history', 'd7562a7d' in t)

# 17. THE CORRECTED W1 EXPECTATIONS (the v24 semantics)
check('eproc canonical gate', "$kPwMinKernel = [UInt64]'0xFFFF800000000000'" in t and '$eprocCanon' in t)
check('eproc OUT-OF-IMAGE gate (THE F3 claim)', '$eprocOutside = ($wSys -lt $peBase) -or ($wSys -ge ($peBase + $peSize))' in t)
check('count sanity 1..64', '($wCount -ge 1) -and ($wCount -le 64)' in t)
check('entries[0] must sit at the EPROCESS (not the symbol VA)', '($e0eproc -eq $wSys)' in t)
check('eproc payload label renamed', 'eproc=0x{6:X}' in t and 'sys=0x{6:X}' not in t)
check('the serial-side symbol cross-check documented', 'serial [PW] sys= must equal the M1 va' in t)
check('out-of-image PASS text', 'PROCESS DATA OUTSIDE THE IMAGE - the F3 claim itself' in t)

# 18. the v31 misconception must be GONE
check('old symbol-VA expectation removed', '$sysEcho' not in t and '($e0eproc -eq $mVa)' not in t)
check('old self-echo PASS text removed', 'System self-echo at the M1-resolved VA' not in t)

print()
if fails:
    print(f'==== AUDIT: {len(fails)} FAIL ====')
    sys.exit(1)
print('==== AUDIT: ALL PASS ====')
