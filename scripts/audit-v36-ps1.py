#!/usr/bin/env python3
# ============================================================================
# audit-v36-ps1.py — machine audit of patches/trigger-test-v36.ps1
# (the v35 audit core, re-targeted v34->v35 as the byte-identity base,
#  PLUS the v36 gate-fix checks: nsec 1..96, no -le 24 remnant, the D2
#  chunked table read, the table-fits bound — and the ABSOLUTE op-12
#  absence gate stands: the crash op must NEVER be sent)
# ============================================================================
import sys, re, pathlib

P = pathlib.Path('/home/z/my-project/patches/trigger-test-v36.ps1')
t = P.read_text(encoding='utf-8')
srcbase = pathlib.Path('/home/z/my-project/patches/trigger-test-v35.ps1').read_text(encoding='utf-8')
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

print('== v36 structural audit ==')

# 1. encoding / NULs / line endings
nul = t.count('\x00')
check('NUL count == 2 (the PE display bytes)', nul == 2, f'got {nul}')
check('LF-only line endings', '\r\n' not in t)
check('pure ASCII', all(ord(c) < 128 for c in t))

# 2. brace / paren balance
n_open, n_close = t.count('{'), t.count('}')
check('brace balance', n_open == n_close, f'{n_open} vs {n_close}')
dbase = srcbase.count(')') - srcbase.count('(')
d36 = t.count(')') - t.count('(')
check('paren delta == the field-run v35 base', d36 == dbase, f'v35={dbase} v36={d36}')

# 3. THE ABSOLUTE GATE: op-12 must NEVER be sent (the two-BSOD op stays retired)
sends12 = re.findall(r"New-Req\s+\S+\s+12\s", t)
check('*** op-12 sends == 0 (RETIRED — the class-kill) ***', len(sends12) == 0, str(sends12))
check('op-12 retirement note present', 'op-12 stays RETIRED' in t or 'op-12 is RETIRED' in t)
check('no stale P-ladder labels', '--- step P1:' not in t and 'step P: op 12' not in t)
check('no stale pSent/p1 variables', '$pSent' not in t and '$p1Ok' not in t and '$p1Cr3' not in t)

# 4. THE GATE FIX (v36's whole reason to exist)
check('*** D1 gate accepts nsec up to 96 ***', '$nsec -ge 1 -and $nsec -le 96' in t)
check('*** no live -le 24 gate remnant (the v35 skip cause) ***', '$nsec -ge 1 -and $nsec -le 24' not in t)
check('the 33-sections story documented', '33 sections' in t or 'nsec=33' in t)
check('gate comment explains the v35 field truth', 'LEGITIMATELY has 33 sections' in t or 'LEGALLY has 33' in t or 'nsec=33 is LEGAL' in t)

# 5. THE D2 CHUNKED TABLE READ (1320B assembled from <=1024B reads)
check('D2 chunk loop present', 'New-Req $d2Seq 1 ' in t)
check('D2 chunk size capped at 1024', '[Math]::Min(1024, ([uint64]$secRva + [uint64]$secLen) - $d2Off)' in t)
check('D2 retry x3 + sleep (same as the dump loop)', 'for ($try = 1; $try -le 3; $try++)' in t)
check('D2 assembly via List[byte]', 'New-Object System.Collections.Generic.List[byte]' in t)
check('D2 fail-closed throw on chunk failure', 'failed x3" -f $d2Off' in t)
check('D2 seq base 0x1B02', '$d2Seq  = 0x1B02' in t)
check('D2 rSent counts per chunk', '$rSent++' in t)
check('D2 assembled-status line', 'section table assembled: {0} bytes in {1} chunk read(s)' in t)
check('*** D2 single unproven-size read GONE ***', 'New-Req 0x1B02 1 ' + "'FFFFFFFF' $secLen" not in t)
check('D2 table-fits-image bound', '(($secRva + $secLen) -le [int]$peSize)' in t)
check('old D2 .Resp condition gone (assembled array now)', "$d2.Resp -and $d2.Status -eq 1 -and $null -ne $d2.Data -and $d2.Data.Length -ge $secLen) {" not in t)

# 6. the W-wire: 4 op-11 sends, byte-identical to v35
w = re.findall(r"New-Req (0x19[0-9A-Fa-f]{2}) 11 (\S+) (\d+) '([0-9]{16})' \$null", t)
check('W sends found (4)', len(w) == 4, str(w))
seqs = [x[0] for x in w]
check('W seqs 0x1901..0x1904 unique', sorted(set(seqs)) == ['0x1901','0x1902','0x1903','0x1904'], str(seqs))
check('W1/W4a/W4b/W5 pid fields', w[0][1] == "'FFFFFFFF'" and w[3][1] == '$myPid', str([x[1] for x in w]))
check('W4 outN gate values', w[1][2] == '0' and w[2][2] == '33', str([x[2] for x in w]))

# 7. the M-wire byte-identical to v35
mbase = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", srcbase)
m36 = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", t)
check('M-wire identical to v35 (4 sites)', mbase == m36 and len(m36) == 4, f'{m36}')

# 8. the op-11 payload decode offsets (the 1056-byte layout) + the dtb echo
for off, label in ((1024,'status'),(1028,'count'),(1032,'sys'),(1040,'nameOfs'),
                   (1044,'closed'),(1048,'pages'),(1052,'stored')):
    check(f'payload offset {label}@{off}', f'U32 $W1.Data {off}' in t or f'U64 $W1.Data {off}' in t)
check('dtb@1056 echo parsed', 'U64 $W1.Data 1056' in t)

# 9. THE RECON WIRE (R1..R7: op-1 8B reads at the 7 candidate RVAs) — unchanged from v35
rseqs = re.findall(r"Send-Req \(New-Req \$seqR 1 'FFFFFFFF' 8 \('\{0:X16\}' -f \(\$peBase \+ \[uint64\]\$cd\.rva\)\) \$null\)", t)
check('R-loop send shape (the cands table drives it)', len(rseqs) == 1, str(len(rseqs)))
for k, rva in (('R1','0xCFB358'),('R2','0xCFA358'),('R3','0xCFC508'),
               ('R4','0xCFC500'),('R5','0xCFC510'),('R6','0xCFB500'),('R7','0xCFB508')):
    check(f'cand {k} rva {rva}', f"n='{k}'; rva={rva}" in t, f'cand {k}')
check('recon seq base 0x1A01', '$seqR = 0x1A01' in t)
check('rSent static sites == 4 (R-loop + D0 + D1 + D2-chunk)', t.count('$rSent++') == 4, str(t.count('$rSent++')))
check('PS shape mirror: bits38:0 == 0', "'0x0000007FFFFFFFFF'" in t)
check('PS shape mirror: hi == 0xFFFF', '-shr 48' in t)
check('collision guard s=0x100 (MmSystemRangeStart)', '($sIx -eq 0x100)' in t and 'MmSystemRangeStart' in t)
check('collision guard s=0x1EF (KUSD)', '($sIx -eq 0x1EF)' in t)
check('the deadly-arithmetic display (pdb + pfn*0x30 + 8)', '$pfnIx * 0x30' in t and 'pdb + {1}*0x30 + 8' in t)
check('R8 = the W dtb echo cross-display', '--- step R8: the System DTB' in t)
check('recon canaries', "Canary (\"pre-\" + $cd.n)" in t)

# 10. THE DUMP WIRE (D0/D1 + the loop) — byte-identical to v35
check('D0 self-verify: 1024B @ pe_base + MZ + e_lfanew == L2a', 'New-Req 0x1B00' in t and
      "$d0.Data[0] -eq 0x4D -and $d0.Data[1] -eq 0x5A" in t and
      '((U32 $d0.Data 0x3C) -eq [uint32]$lfanew)' in t)
check('D1 section header read (20B @ lfanew+4)', 'New-Req 0x1B01' in t)
check('.data section parse (name + VirtualSize + VirtualAddress)', "-eq '.data'" in t and
      '($si * 40 + 8)' in t and '($si * 40 + 12)' in t)
check('dump bounds gate (rva+vs <= peSize)', '($dataRva + $dataVs) -le [int]$peSize' in t)
check('chunk size 1024', '$chunkSz  = 1024' in t)
check('dump loop dynamic seq (0x2000 + chunk)', '(0x2000 + $ci)' in t)
check('dump retry x3 + sleep', 'for ($try = 1; $try -le 3; $try++)' in t and 'Start-Sleep -Milliseconds 150' in t)
check('dump resume marker (pe_base bound)', 'pe_base=0x{0:X};rva=0x{1:X};vs=0x{2:X};chunk={3}' in t)
check('resume only on identical marker', '"$mkOld" -eq "$mkTxt"' in t)
check('resume append mode', "'Append')" in t)
check('fresh dump starts a new marker', '[System.IO.File]::WriteAllText($mkPath, $mkTxt)' in t)
check('progress line + ETA', 'ETA~{4}m{5:d2}s' in t)
check('sha256 of the dump', 'Get-FileHash -Algorithm SHA256' in t)
check('manifest written with recon RVAs + w_dtb + v36 name', '.manifest.txt' in t and 'recon_{0}_rva=0x{1:X}' in t and
      'generated by trigger-test-v36' in t)
check('dumpSent increments in the loop', t.count('$dumpSent++') == 1, str(t.count('$dumpSent++')))
check('dump fail-closed stop (failAt)', '$failAt = $ci; break' in t)
check('send-the-dump instruction', 'SEND THE .bin + .manifest.txt + this .txt' in t)

# 11. W2 exit-race tolerance (the v34 pid-656 lesson) — unchanged
check('W2 re-query on missing pid', 'Get-Process -Id ([int]$ep) -ErrorAction Stop' in t)
check('W2 EXITED tolerance text', 'EXITED between walk and snapshot (tolerated, v35)' in t)
check('W2 threshold missing -le 1', '($missing -le 1) -and ($cntDelta -le 3)' in t)
check('W2 CAP-AWARE expected value', '$liveCap = [Math]::Min($liveProcs.Count, 64)' in t)

# 12. step 0 (full bugcheck args + the CONFIRMED fingerprint)
check('step0 message truncation 420', '$m.Length -gt 420' in t)
check('step0 args regex extract', "bugcheck was:\\s*(0x[0-9a-fA-F]+)\\s*\\(([^)]+)\\)" in t)
check('step0 both-crashes-confirmed hint', 'fingerprint-CONFIRMED' in t)
check('step0 the arithmetic stated for NEW crashes', '0x5078 = 0x1AD*0x30+8 = chain B' in t)
check('step0 minidump hint', 'C:\\Windows\\Minidump' in t)

# 13. INFCNT arithmetic includes rSent + dumpSent (dynamic for the chunked D2)
check('expFinal includes rSent + dumpSent', '$cntVal + 8 + $anSent + $mNameWrites + $wSent + $rSent + $dumpSent' in t)
line = [l for l in t.splitlines() if 'INFCNT final = {0}' in l]
if line:
    m = re.search(r'-f (.+)$', line[0])
    if m:
        args = [a.strip() for a in m.group(1).split(',')]
        check('INFCNT printf has 9 args (slots 0,1,4..8)', len(args) == 9, str(args))
    else:
        check('INFCNT printf has -f', False, 'no -f on the line')
else:
    check('INFCNT printf line exists', False, 'line not found')

# 14. canaries
for c in ('pre-W1', 'pre-W4', 'pre-W5'):
    check(f"canary {c}", f"Canary '{c}'" in t)
for c in ('pre-M1','pre-M2r','pre-M3','pre-M4'):
    check(f'canary {c}', f"Canary '{c}'" in t)
for c in ('pre-D0','pre-D1','pre-D2'):
    check(f'canary {c} (the dump gates)', f"Canary '{c}'" in t)

# 15. verdict + summary + END
check('F3 verdict block intact', '>>> F3 PROVEN: THE EPROCESS WALK' in t)
check('F4 RECON verdict', '>>> F4 RECON COMPLETE + GROUND-TRUTH DUMP CAPTURED' in t)
check('F4 partial-recon verdict (fail-closed language)', 'F4 RECON PARTIAL' in t and 'alive by construction' in t)
check('[15] summary line intact', '"[15] F4 constants recon (R1..R8) : {0}" -f $f4Sum' in t)
check('END v36 marker', "Write-Host '==== END v36 ===='" in t)
check('no stale v35 END', '==== END v35 ====' not in t)
check('wSent increments == 4', t.count('$wSent++') == 4, str(t.count('$wSent++')))

# 16. driver-ID texts (v26 UNCHANGED is correct for the 4th run)
check('v26-RT = 140582 documented', '140582' in t)
check('v36 is script-only / v26 unchanged', 'SCRIPT-ONLY' in t and 'UNCHANGED' in t)
check('the v26 sha256 documented', 'c8f79b95' in t and '921bb' in t)
check('v25 = the first BSOD binary (fingerprint cited)', 'pdb + 0x1AD*0x30 + 8' in t)

# 17. the story in the headers
check('the fingerprint arithmetic documented', '0x1AD*0x30 + 8' in t)
check('chain B named as the killer', 'chain B dereferencing a garbage MmPfnDatabase' in t or 'fingerprint-confirmed as chain B' in t)
check('the v36 header tells the skip story', 'were never created' in t or 'never appear' in t)
check('the dump-skip cause named (the gate)', 'nsec <= 24' in t)

# 18. step positions: R after W, D after R, N after D
iw = t.index('--- step W5'); ir = t.index('--- step R: the constant RECON'); idm = t.index('--- step D: the .data dump'); inn = t.index('--- step N: final INFCNT read')
check('R after W5, D after R, N after D', iw < ir < idm < inn)

# 19. the regression core byte-identical vs v35: K wire + J ladder + L reads
kbase = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", srcbase)
k36 = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", t)
check('K wire (op-9) byte-identical to v35', kbase == k36 and len(k36) >= 1, f'{len(kbase)} vs {len(k36)}')
jbase = re.findall(r"n = 'J[0-9]';[^\n]+", srcbase)
j36 = re.findall(r"n = 'J[0-9]';[^\n]+", t)
check('J ladder rows byte-identical to v35 (7 rows)', jbase == j36 and len(j36) == 7, f'{len(jbase)} vs {len(j36)}')
lbase = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", srcbase)
l36 = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", t)
check('L-step op-1 reads byte-identical to v35', lbase == l36, f'{len(lbase)} vs {len(l36)}')

# 20. selftest preserved
check('selftest DEADBEEF intact', "ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF" in t)
check('startup selftest gate', 'SELFTEST][ABORT' in t)

# 21. W1 expectations (the v24 semantics) intact
check('eproc OUT-OF-IMAGE gate (THE F3 claim)', '$eprocOutside = ($wSys -lt $peBase) -or ($wSys -ge ($peBase + $peSize))' in t)
check('out-of-image PASS text', 'PROCESS DATA OUTSIDE THE IMAGE - the F3 claim itself' in t)

# 22. transcript
check('transcript v36 name', 'trigger-test-v36-output-' in t)

print()
if fails:
    print(f'==== AUDIT: {len(fails)} FAIL ====')
    sys.exit(1)
print('==== AUDIT: ALL PASS ====')
