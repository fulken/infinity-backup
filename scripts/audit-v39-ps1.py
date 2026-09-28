#!/usr/bin/env python3
# ============================================================================
# audit-v39-ps1.py — machine audit of patches/trigger-test-v39.ps1
# (the v38 audit core carried, with the v39 FLIPS: op-12 UN-RETIRED —
#  exactly 6 P-sends on seqs 0x1A01..0x1A06 with the 96B v27 payload
#  decode + THE LIVE-CR3 IDENTITY check + P5/P6 negatives + P7 dtb
#  cross + P8 informational; THE CHUNK-MATH FIX — [Math]::Floor in,
#  the bare [int]( cast out; THE F4 WALK VERDICT block; INFCNT +pSent.
#  Everything else must stay byte-identical to the field-run v38.)
# ============================================================================
import sys, re, pathlib

P = pathlib.Path('/home/z/my-project/patches/trigger-test-v39.ps1')
t = P.read_text(encoding='utf-8')
srcbase = pathlib.Path('/home/z/my-project/patches/trigger-test-v38.ps1').read_text(encoding='utf-8')
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

print('== v39 structural audit ==')

# 1. encoding / NULs / line endings
nul = t.count('\x00')
check('NUL count == 2 (the PE display bytes)', nul == 2, f'got {nul}')
check('LF-only line endings', '\r\n' not in t)
check('pure ASCII', all(ord(c) < 128 for c in t))

# 2. brace balance (absolute) + paren delta vs the v38 base
check('brace balance', t.count('{') == t.count('}'), f'{t.count("{")} vs {t.count("}")}')
d38 = srcbase.count('(') - srcbase.count(')')
d39 = t.count('(') - t.count(')')
print(f'  NOTE  paren delta: v38 base={d38} v39={d39} (the P-ladder adds prose parens; recorded)')

# 3. *** THE UN-RETIREMENT ***: op-12 sends == 6, seqs 0x1A01..0x1A06
sends12 = re.findall(r"New-Req (0x1A0[0-9A-Fa-f]) 12 ", t)
check('*** op-12 sends == 6 (the P-ladder UN-RETIRED, v27 engine) ***',
      len(sends12) == 6, str(sends12))
check('P seqs 0x1A01..0x1A06 unique + ordered',
      sends12 == ['0x1A01','0x1A02','0x1A03','0x1A04','0x1A05','0x1A06'], str(sends12))
check('P-ladder step banner (v27 story)', '--- step P: op 12 TranslateVa - THE PAGE-TABLE WALK (v27: chain B deleted, the crash class is gone from the binary) ---' in t)
check('[PT]-before-read discipline documented', 'LAST [PT] line names the killer read' in t)
check('pSent increments == 6', t.count('$pSent++') == 6, str(t.count('$pSent++')))

# 4. THE 96B PAYLOAD DECODE + THE IDENTITY (the F4 ground truth)
check('P1 payload gate -ge 96', '$P1.Data.Length -ge 96' in t)
for v in ('P2','P3','P4'):
    check(f'{v} payload gate -ge 96', f'${v}.Data.Length -ge 96' in t)
check('liveCr3@80 decoded', '$p1LiveCr3   = U64 $P1.Data 80' in t)
check('selfEntry@88 decoded', '$p1SelfEntry = U64 $P1.Data 88' in t)
check('*** THE LIVE-CR3 IDENTITY check ***', '$pIdentityOk = ($selfFrame -ne 0) -and ($selfFrame -eq $liveFrame)' in t)
check('identity PASS text (two independent derivations)', 'two independent derivations of the SAME PML4' in t)
check('pfn mask defined for the identity', "$pfnMaskV = [UInt64]'0x000FFFFFFFFFF000'" in t)
check('P1 ok includes the identity', '-and (($p1SelfOk -band 1) -eq 1) -and $pIdentityOk' in t)
check('P1 prints the register + the raw entry', 'liveCr3(register)=0x{0:X} selfEntry(raw PML4E[s])=0x{1:X}' in t)
check('source bits 4/5 dead note', 'UNEXPECTED for v27 (chain B deleted; bits are dead)' in t)
check('System DTB label clarified', 'cr3(System)=0x{3:X}' in t)

# 5. the P rungs
check('P1 = pe_base (the image walk)', "op-12(pe_base=0x{0:X}) - the kernel image walk" in t)
check('P2 = the System EPROCESS (residency)', 'is the EPROCESS RESIDENT?' in t)
check('P3 = the KUSD kernel alias', 'op-12(KUSD kernel alias 0xFFFFF78000000260)' in t)
check('P4 = the IDT base', 'op-12(idt_base=0x{0:X})' in t)
check('P5 non-canonical negative', "'0000800000000000'" in t and 'non-canonical -> ErrInvalid(5) clean' in t)
check('P6 user-range negative', "'00007FF000000000'" in t and 'user-range VA -> ErrInvalid(5) clean' in t)
check('P7 the System-DTB cross-check (two paths)', 'W1 dtb@1056 == P1 cr3@16' in t and '($wDtb -eq $p1Cr3)' in t)
check('P8 informational (two PML4s)', 'the two-PML4 line (informational, not a gate)' in t)
check('P8 the v26->v27 semantics note', 'v26 compared these two and expected inequality' in t)
for c in ('pre-P1','pre-P2','pre-P3','pre-P4','pre-P5'):
    check(f'canary {c}', f"Canary '{c}'" in t)

# 6. *** THE CHUNK-MATH FIX *** (v39 change 1)
check('*** [Math]::Floor in the chunk count ***', '$total    = [int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)' in t)
check('*** the bare [int]( cast form GONE from the dump loop ***',
      '$total    = [int](($dataVs + $chunkSz - 1) / $chunkSz)' not in t)
check('the fix story comment present', "PowerShell's" in t and 'PHANTOM chunk' in t)

# 7. the carried v38 core (gate fix + D2 chunked + census + ALMOSTRO)
check('D1 gate accepts nsec up to 96', '$nsec -ge 1 -and $nsec -le 96' in t)
check('no live -le 24 gate remnant', '$nsec -ge 1 -and $nsec -le 24' not in t)
check('D2 chunk loop present', 'New-Req $d2Seq 1 ' in t)
check('D2 chunk size capped at 1024', '[Math]::Min(1024, ([uint64]$secRva + [uint64]$secLen) - $d2Off)' in t)
check('D2 assembly via List[byte]', 'New-Object System.Collections.Generic.List[byte]' in t)
check('D2 fail-closed throw on chunk failure', 'failed x3" -f $d2Off' in t)
check('D2 seq base 0x1B02', '$d2Seq  = 0x1B02' in t)
check('D2 table-fits-image bound', '(($secRva + $secLen) -le [int]$peSize)' in t)
check('NO first-byte 0x2E guard anywhere', '-eq 0x2E' not in t)
check('*** section filter targets ALMOSTRO ***', "-eq 'ALMOSTRO'" in t)
check('the .data filter GONE', "-eq '.data'" not in t)
check('census fallback present', '[D2] census of all' in t)
check('dump basename ntoskrnl-almostro', "Join-Path $spot2 'ntoskrnl-almostro'" in t)
check('manifest header v39 + ALMOSTRO', '# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v39' in t)
check('manifest records the R9 window', 'r9_window=0xCFC4C0..0xCFC538' in t)
check('pre-scan banner', "--- step D+: the ALMOSTRO pre-scan (in-script, no driver reads) ---" in t)
check('pre-scan guarded by dumpOk', 'if ($dumpOk) {' in t)
check('pre-scan reads the .bin from disk', '[System.IO.File]::ReadAllBytes($dumpPath)' in t)
check('sha256 of the dump', 'Get-FileHash -Algorithm SHA256' in t)

# 8. THE F4 WALK VERDICT (v39 change 3)
check('*** f4Ok = the walk verdict (P1..P7) ***',
      '$f4Ok = $anOk -and $p1Ok -and $p2Ok -and $p3Ok -and $p4Ok -and $p5Ok -and $p6Ok -and $wDtbOk' in t)
check('*** F4 PROVEN verdict text ***', '>>> F4 PROVEN: PAGE-TABLE TRANSLATION VIA THE SELFMAP - GROUND-TRUTHED BY THE LIVE-CR3 IDENTITY <<<' in t)
check('F4 proven explains the ground truth', 'one through the translated self-map slot, one straight from the hardware' in t)
check('F4 partial branch (identity held)', '>>> F4 PARTIAL: THE LIVE IDENTITY HELD but a walk rung failed' in t)
check('F4 fail branch (fail-closed)', '>>> F4 NOT PROVEN THIS RUN (a walk rung or the identity failed)' in t)
check('F4 verdict names [PT] attribution', 'LAST [PT]' in t)
check('[15] summary = the walk line', '"[15] F4 the walk (P1..P8, op-12 v27): {0}" -f $f4WalkTxt' in t)
check('[15] recon+dump line kept (the v38 path)', '"     F4 recon + dump (R/D, v38 path): {0}; dump: {1}"' in t)
i_f3partial = t.index('} elseif ($anOk -and $wCount -ge 1) {')
i_f3not     = t.index('>>> F3 NOT PROVEN THIS RUN')
i_f4assign  = t.index('$f4Ok = $anOk -and $p1Ok')
check('F4 verdict still at TOP LEVEL (the v37 brace fix held)', i_f3partial < i_f3not < i_f4assign)
check('no $f4Ok inside the F3-PARTIAL branch', '$f4Ok' not in t[i_f3partial:i_f3not])
check('F1..F3 verdicts intact', '>>> F1 PROVEN' in t and '>>> F2 PROVEN' in t and '>>> F3 PROVEN: THE EPROCESS WALK' in t)
check('F4-proven next step = Infinity.exe', 'THE F1..F4 LADDER' in t and 'Next: Infinity.exe' in t)

# 9. INFCNT accounting with pSent
check('expFinal includes rSent + dumpSent + pSent', '$cntVal + 8 + $anSent + $mNameWrites + $wSent + $rSent + $dumpSent + $pSent' in t)
line = [l for l in t.splitlines() if 'INFCNT final = {0}' in l]
check('INFCNT printf line exists', bool(line))
check('INFCNT prose names the P walk requests', 'the P walk requests (+pSent)' in t)

# 10. the W-wire: 4 op-11 sends, byte-identical to the field v38
w = re.findall(r"New-Req (0x19[0-9A-Fa-f]{2}) 11 (\S+) (\d+) '([0-9]{16})' \$null", t)
check('W sends found (4)', len(w) == 4, str(w))
mbase = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", srcbase)
m39 = re.findall(r"Send-Resolve (0x18[0-9A-Fa-f]{2}) '([^']+)'", t)
check('M-wire identical to v38 (4 sites)', mbase == m39 and len(m39) == 4, f'{m39}')
for off, label in ((1024,'status'),(1028,'count'),(1032,'sys'),(1040,'nameOfs'),
                   (1044,'closed'),(1048,'pages'),(1052,'stored')):
    check(f'payload offset {label}@{off}', f'U32 $W1.Data {off}' in t or f'U64 $W1.Data {off}' in t)
check('dtb@1056 echo parsed', 'U64 $W1.Data 1056' in t)

# 11. THE RECON WIRE (R1..R7 + R8 + R9 unchanged)
for k, rva in (('R1','0xCFB358'),('R2','0xCFA358'),('R3','0xCFC508'),
               ('R4','0xCFC500'),('R5','0xCFC510'),('R6','0xCFB500'),('R7','0xCFB508')):
    check(f'cand {k} rva {rva}', f"n='{k}'; rva={rva}" in t, f'cand {k}')
check('recon seq base 0x1A01 (shared with the P ladder)', '$seqR = 0x1A01' in t)
check('R8 = the W dtb echo cross-display', '--- step R8: the System DTB' in t)
check('R9 window base 0xCFC4C0', '$r9Base = 0xCFC4C0' in t)
check('R9 rSent counts', t.count('$rSent++') == 5, str(t.count('$rSent++')))

# 12. THE DUMP WIRE (D0/D1 + the loop) — carried
check('D0 self-verify: MZ + e_lfanew == L2a', 'New-Req 0x1B00' in t and
      "$d0.Data[0] -eq 0x4D -and $d0.Data[1] -eq 0x5A" in t and
      '((U32 $d0.Data 0x3C) -eq [uint32]$lfanew)' in t)
check('D1 section header read (20B @ lfanew+4)', 'New-Req 0x1B01' in t)
check('dump loop dynamic seq (0x2000 + chunk)', '(0x2000 + $ci)' in t)
check('dump retry x3 + sleep', 'for ($try = 1; $try -le 3; $try++)' in t and 'Start-Sleep -Milliseconds 150' in t)
check('dump resume marker (pe_base bound)', 'pe_base=0x{0:X};rva=0x{1:X};vs=0x{2:X};chunk={3}' in t)
check('resume only on identical marker', '"$mkOld" -eq "$mkTxt"' in t)
check('dump fail-closed stop (failAt)', '$failAt = $ci; break' in t)
check('dumpSent increments in the loop', t.count('$dumpSent++') == 1, str(t.count('$dumpSent++')))

# 13. W2 exit-race tolerance + step 0 — carried
check('W2 CAP-AWARE expected value', '$liveCap = [Math]::Min($liveProcs.Count, 64)' in t)
check('step0 message truncation 420', '$m.Length -gt 420' in t)
check('step0 both-crashes-confirmed hint', 'fingerprint-CONFIRMED' in t)

# 14. step positions: W < R < R9 < D < D+ < P < N (the walk AFTER the
#     dump: the whole v38 flow lands first; the walk is the climax)
iw  = t.index('--- step W5')
ir  = t.index('--- step R: the constant RECON')
idm = t.index('--- step D: the ALMOSTRO dump')
idp = t.index('--- step D+: the ALMOSTRO pre-scan')
ip  = t.index('--- step P: op 12 TranslateVa')
inn = t.index('--- step N: final INFCNT read')
check('W5 < R < D < D+ < P < N', iw < ir < idm < idp < ip < inn)
check('the ordering rationale documented', 'the walk is the climax' in t)

# 15. the regression core byte-identical vs the field v38
kbase = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", srcbase)
k39 = re.findall(r"Send-Req \(New-Req 0x170[0-9A-Fa-f] 9 [^\n]+", t)
check('K wire (op-9) byte-identical to v38', kbase == k39 and len(k39) >= 1)
jbase = re.findall(r"n = 'J[0-9]';[^\n]+", srcbase)
j39 = re.findall(r"n = 'J[0-9]';[^\n]+", t)
check('J ladder rows byte-identical to v38 (7 rows)', jbase == j39 and len(j39) == 7)
lbase = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", srcbase)
l39 = re.findall(r"Send-Req \(New-Req 0x17[0-9A-Fa-f]{2} 1 [^\n]+", t)
check('L-step op-1 reads byte-identical to v38', lbase == l39)
rbase = re.findall(r"Send-Req \(New-Req \$seqR 1 [^\n]+", srcbase)
r39 = re.findall(r"Send-Req \(New-Req \$seqR 1 [^\n]+", t)
check('R-step gated reads byte-identical to v38', rbase == r39)

# 16. selftest + W1 gates — carried
check('selftest DEADBEEF intact', "ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF" in t)
check('startup selftest gate', 'SELFTEST][ABORT' in t)
check('eproc OUT-OF-IMAGE gate (THE F3 claim)', '$eprocOutside = ($wSys -lt $peBase) -or ($wSys -ge ($peBase + $peSize))' in t)

# 17. banners / markers / driver-ID
check('transcript v39 name', 'trigger-test-v39-output-' in t)
check('banner v39 (the walk)', "Write-Host '==== INFINITY trigger test v39 (" in t)
check('banner names F4 ATTEMPT 6 + the walk', 'F4 ATTEMPT 6' in t and 'op-12 UN-RETIRED' in t)
check('no stale v38 banner', "Write-Host '==== INFINITY trigger test v38 (" not in t)
check('END v39 marker', "Write-Host '==== END v39 ===='" in t)
check('no stale END v38', '==== END v38 ====' not in t)
check('v27-RT 141041 documented (the DRIVER SWAP)', '141041' in t)
check('v27 sha e13f9f24 documented', 'e13f9f24' in t)
check('v26 140582 still documented (the history)', '140582' in t)
check('header: DRIVER SWAP REQUIRED line', 'DRIVER SWAP REQUIRED' in t)
check('wSent increments == 4', t.count('$wSent++') == 4, str(t.count('$wSent++')))
for c in ('pre-W1', 'pre-W4', 'pre-W5', 'pre-M1','pre-D0','pre-D1','pre-D2'):
    check(f"canary {c}", f"Canary '{c}'" in t)

print()
if fails:
    print(f'== {len(fails)} FAILURES ==')
    for f in fails: print(f'  - {f}')
    sys.exit(1)
print('== ALL CHECKS PASS ==')
