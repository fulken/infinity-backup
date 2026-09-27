#!/usr/bin/env python3
"""make-v29.py - build trigger-test-v29.ps1 from the FIELD-RUN v28 script.

v29 = v28 + THE M2R EXPECTATION FIX + FULL INFCNT ARITHMETIC (script-only;
the v21 driver STAYS - memory.efi v21 RT, 131709 bytes, untouched).

The v28 field run (2026-09-26 21:11) was DRIVER-GREEN end to end:
all four M resolutions (PsInitialSystemProcess / NtBuildNumber /
KeBugCheckEx / NoSuchSymbolV28->7) and both M reads returned
perfect data - but the script printed "[M2r] FAIL: value mismatch"
on the CANONICAL Win10 19045 dword. Three independent sources
agree the read was perfect (transcript raw value, serial [RD]
va=0xFFFFF8071A412130 ok=1, canonical NtBuildNumber knowledge):
NtBuildNumber packs the BUILD in the LOW WORD (19045 = 0x4A65 -
the same KUSD J1 ground truth) while the high bits carry the QFE
flag nibble: the canonical dword is 0xF0004A65. v28 masked
0x7FFFFFFF (leaving 0x70004A65) and compared against bare 19045.

The v28 final-INFCNT line had TWO more cosmetic defects, proven by
the field transcript: it printed "expect G+8+ = 23" - (a) the {4}
format slot pointed at an EMPTY argument ($anSent sat at index 5,
unused), and (b) G+8+anSent=23 undercounted reality by exactly the
4 M-side InfinityData symbol-NAME writes (each Send-Resolve writes
the name via Write-Var THEN sends the op-10 request - both bump
INFCNT; the field counted 27 = G2 + H1 + J7 + KL7 + name4 + req6).

Script-side changes (K/L/M/J request logic byte-identical):
  1.  v29 header block above the v28 header block
  2.  transcript filename v28 -> v29
  3.  banner v29 (F1+F2 field-proven + the fix named)
  4.  END marker v29
  5.  THE FIX: M2r masks the BUILD field (0xFFFF) + accepts the
      canonical dword 0xF0004A65 - a healthy 19045 system can
      never print FAIL again
  6.  mNameWrites counter: initialized beside the M flags,
      incremented ($script:) inside Send-Resolve
  7.  step-N header text names the name-writes term
  8.  THE ARITHMETIC: expect = G+8+anSent+mNameWrites, format
      slots {4}/{5} now point at the real counters
  9.  stale era texts refreshed: pre-A canary (the script-v21
      death spot), step-0 post-mortem hint, the ladder decision
      table still said v20-RT 128010 (x2), step K said v20-only
"""
import re, hashlib, sys

SRC = '/home/z/my-project/patches/trigger-test-v28.ps1'
DST = '/home/z/my-project/patches/trigger-test-v29.ps1'

src = open(SRC, 'rb').read().decode('utf-8')  # keeps the 2 PE\0\0 NULs as-is

def must_count(pat, n, label):
    got = len(re.findall(pat, src, flags=re.M))
    assert got == n, f'[{label}] pattern {pat!r}: expected {n} hits, got {got}'

# ---- pre-edit sanity: every v28 shape we rely on is present exactly once ----
must_count(r'trigger-test-v28-output-\$stamp', 1, 'transcript name')
must_count(r"==== INFINITY trigger test v28 \(v21 driver: F1 PROVEN in the field; M export resolution", 1, 'banner')
must_count(r"==== END v28 ====", 1, 'end marker')
must_count(r'\$nbMasked = \[uint32\]\(\$nbVal -band 0x7FFFFFFF\)', 1, 'wrong mask')
must_count(r"\$m2ReadOk = \(\$nbMasked -eq 19045\)", 1, 'wrong compare')
must_count(r"died HERE", 1, 'pre-A canary')
must_count(r"v20-RT = 128010 bytes", 1, 'ladder size hint 1')
must_count(r"Do NOT rerun until memory.efi is replaced \(size 128010\)", 1, 'ladder size hint 2')
must_count(r"F1 anchor discovery \(v20 containing-walk\)", 1, 'step K title')
must_count(r"CONVERGED \(EXPECTED with v20\): the containing-walk skips", 1, 'step K status text')
must_count(re.escape("$m1Ok = $false; $m2Ok = $false; $m2ReadOk = $false"), 1, 'M flags init')
must_count(re.escape("    $nb = [System.Text.Encoding]::ASCII.GetBytes($symName)\n    $null = Write-Var 'InfinityData' $nb"), 1, 'Send-Resolve body')
must_count(re.escape('(expect G+8+{4} = {1}: H\'s InfinityData write (+1), the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 + $anSent } else { \'?\' }), \'\', \'\', \'\', $anSent)'), 1, 'INFCNT expect line')
must_count(r"7 ladder InfinityReq writes \(\+7\), and the K/L anchor \+ M export requests", 1, 'INFCNT expect line 2')
must_count(r"expect G\+8\+requests: H \+1, J1\.\.J7 \+7, K/L \+ M export requests", 1, 'step N header')
must_count(r"a BUGCHECK line at the v21 run time names the v21 step-A killer", 1, 'step-0 hint 1')
must_count(r"41-only = instant death with no chance to log \(v19/v20 class\)", 1, 'step-0 hint 2')
must_count(r'0xF0004A65', 0, 'canonical dword absent pre-edit')
must_count(r'\$mNameWrites', 0, 'counter absent pre-edit')

# ---- 1. v29 header block, inserted above the v28 header block ----
V29HDR = '''# ============================================================
# INFINITY bridge trigger test v29  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v29 = v28 + THE M2R EXPECTATION FIX (script-only - the v21
# driver STAYS: memory.efi v21 RT, 131709 bytes, untouched).
# WHY: the v28 field run (2026-09-26 21:11) was DRIVER-GREEN:
# all four M resolutions and both M reads returned perfect
# data - but the script printed "[M2r] FAIL: value mismatch"
# on the CANONICAL Win10 19045 dword. The read returned
# 0xF0004A65 - exactly right for NtBuildNumber: the BUILD is
# the LOW WORD (0x4A65 = 19045 = the KUSD J1 ground truth) and
# the high bits carry the QFE flag nibble. v28 masked
# 0x7FFFFFFF (leaving 0x70004A65) and compared against bare
# 19045 - a healthy system can never pass that. v29 masks the
# BUILD field correctly (0xFFFF) AND accepts the full canonical
# dword. Also fixed, same run: the final-INFCNT expectation
# line printed "expect G+8+ = 23" - the {4} slot pointed at an
# EMPTY argument, and the arithmetic forgot the 4 M-side
# symbol-NAME InfinityData writes (each Send-Resolve writes the
# name, THEN sends the op-10 request - both bump INFCNT; the
# field counted 27 = G2+H1+J7+KL7+name4+req6). v29 counts
# every term. Stale era texts refreshed (the ladder table still
# said driver 128010/v20; the pre-A canary still pointed at the
# script-v21 death spot). K/L/M/J request logic byte-identical.
# ============================================================
'''
anchor = '# INFINITY bridge trigger test v28  (run INSIDE the Windows VM,'
assert src.count(anchor) == 1
src = src.replace(anchor, V29HDR + anchor, 1)

# ---- 2. transcript filename ----
old = 'trigger-test-v28-output-$stamp.txt'
assert src.count(old) == 1
src = src.replace(old, 'trigger-test-v29-output-$stamp.txt', 1)

# ---- 3. banner ----
old = "Write-Host '==== INFINITY trigger test v28 (v21 driver: F1 PROVEN in the field; M export resolution - symbols resolved from the validated image + J/L/K regression) ===='"
assert src.count(old) == 1
new = "Write-Host '==== INFINITY trigger test v29 (v21 driver: F1+F2 PROVEN IN THE FIELD; M export resolution - the M2r build-mask fix + full INFCNT arithmetic + J/L/K regression) ===='"
src = src.replace(old, new, 1)

# ---- 4. END marker ----
old = "Write-Host '==== END v28 ===='"
assert src.count(old) == 1
src = src.replace(old, "Write-Host '==== END v29 ===='", 1)

# ---- 5. THE FIX: M2r build mask + canonical dword ----
old = """            $nbVal = U32 $M2r.Data 0
            $nbMasked = [uint32]($nbVal -band 0x7FFFFFFF)
            Write-Host ("     [M2r] raw dword = 0x{0:X} ({0})  masked = {1}" -f $nbVal, $nbMasked)
            $m2ReadOk = ($nbMasked -eq 19045)
            if ($m2ReadOk) { Write-Host '     [M2r] PASS: export-resolved NtBuildNumber == 19045 == the KUSD J1 ground truth (double-proven)' }
            else           { Write-Host '     [M2r] FAIL: value mismatch - see raw above + serial [RD]' }"""
assert src.count(old) == 1, 'M2r block not found verbatim'
new = """            $nbVal = U32 $M2r.Data 0
            # v29: NtBuildNumber packs the BUILD in the LOW WORD (19045
            # = 0x4A65); the bits above carry the QFE/lab flags - the
            # canonical 19045 dword is 0xF0004A65. (v28 masked 0x7FFFFFFF
            # and compared against bare 19045 - the v28 field "FAIL" on a
            # perfect read.) The canonical compare uses the DECIMAL literal
            # 4026550885 - a [uint32]0xF0004A65 cast would re-trigger the
            # v21 line-444 hex-cast trap class (hex >= 0x80000000 parses
            # as NEGATIVE Int32 and the cast THROWS).
            $nbBuild = [uint32]($nbVal -band 0xFFFF)
            $nbCanon = ($nbVal -eq 4026550885)
            Write-Host ("     [M2r] raw dword = 0x{0:X} ({0})  build(low word) = {1}  canonical = {2}" -f $nbVal, $nbBuild, $nbCanon)
            $m2ReadOk = ($nbBuild -eq 19045) -or $nbCanon
            if ($m2ReadOk) { Write-Host '     [M2r] PASS: NtBuildNumber build field == 19045 == the KUSD J1 ground truth (double-proven; the bits above the low word are the QFE marker)' }
            else           { Write-Host '     [M2r] FAIL: build field != 19045 - see raw above + serial [RD] (a healthy 19045 system answers 0xF0004A65)' }"""
src = src.replace(old, new, 1)

# ---- 6. mNameWrites counter: init beside the M flags ----
old = "$m1Ok = $false; $m2Ok = $false; $m2ReadOk = $false"
assert src.count(old) == 1
new = old + "\n$mNameWrites = 0   # v29: every Send-Resolve ALSO writes the symbol name to InfinityData (+1 INFCNT each)"
src = src.replace(old, new, 1)

# ---- 6b. ...and count it inside Send-Resolve ----
old = """    $nb = [System.Text.Encoding]::ASCII.GetBytes($symName)
    $null = Write-Var 'InfinityData' $nb"""
assert src.count(old) == 1
new = """    $nb = [System.Text.Encoding]::ASCII.GetBytes($symName)
    $null = Write-Var 'InfinityData' $nb
    $script:mNameWrites = $script:mNameWrites + 1   # v29: the NAME write bumps INFCNT too"""
src = src.replace(old, new, 1)

# ---- 7. step-N header text ----
old = "Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+requests: H +1, J1..J7 +7, K/L + M export requests) ---'"
assert src.count(old) == 1
new = "Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+name-writes+requests: H +1, J1..J7 +7, K/L + M requests + M symbol-NAME writes) ---'"
src = src.replace(old, new, 1)

# ---- 8. THE ARITHMETIC: full expectation with correct format slots ----
old = """Write-Host ("    INFCNT final = {0}   (expect G+8+{4} = {1}: H's InfinityData write (+1), the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 + $anSent } else { '?' }), '', '', '', $anSent)
Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor + M export requests (+anSent); requests are consumed in RAM and deletes never count)'"""
assert src.count(old) == 1, 'INFCNT expectation pair not found verbatim'
new = """$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent) and the M symbol-NAME InfinityData writes (+mNameWrites); requests are consumed in RAM and deletes never count)'"""
src = src.replace(old, new, 1)

# ---- 9. pre-A canary: the script-v21 death spot, named as history ----
old = "Canary 'pre-A (baseline INFDIAG reads next - v21 died HERE)'"
assert src.count(old) == 1
new = "Canary 'pre-A (baseline INFDIAG reads next - the script-v21 death spot, class-killed long ago)'"
src = src.replace(old, new, 1)

# ---- 9b. step-0 post-mortem hints ----
old = "Write-Host '      -> a BUGCHECK line at the v21 run time names the v21 step-A killer;'"
assert src.count(old) == 1
new = "Write-Host '      -> a BUGCHECK line at an OLD run time names THAT era killer;'"
src = src.replace(old, new, 1)
old = "Write-Host '         41-only = instant death with no chance to log (v19/v20 class).'"
assert src.count(old) == 1
new = "Write-Host '         41-only = instant death with no chance to log (the long-dead v19/v20 class).'"
src = src.replace(old, new, 1)

# ---- 9c. ladder decision table: the driver-size hints ----
old = "Write-Host '                  Check usb-d\\memory.efi size: v20-RT = 128010 bytes.'"
assert src.count(old) == 1
new = "Write-Host '                  Check usb-d\\memory.efi size: v21-RT = 131709 bytes.'"
src = src.replace(old, new, 1)
old = "Write-Host '                  Do NOT rerun until memory.efi is replaced (size 128010).'"
assert src.count(old) == 1
new = "Write-Host '                  Do NOT rerun until memory.efi is replaced (size 131709).'"
src = src.replace(old, new, 1)

# ---- 9d. step K titles: the containing-walk is v20/v21 now ----
old = "Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20 containing-walk) ---'"
assert src.count(old) == 1
new = "Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20/v21 containing-walk) ---'"
src = src.replace(old, new, 1)
old = "Write-Host '      status=1(Success) => CONVERGED (EXPECTED with v20): the containing-walk skips'"
assert src.count(old) == 1
new = "Write-Host '      status=1(Success) => CONVERGED (EXPECTED with v20/v21): the containing-walk skips'"
src = src.replace(old, new, 1)

# ---- post-edit verification ----
# NOTE: the v29 header block QUOTES the old mask/canonical values as
# history - only the OPERATIVE code shapes are asserted dead/present.
assert 'band 0x7FFFFFFF' not in src, 'the wrong mask still in operative code'
assert src.count('0xF0004A65') == 4, 'canonical dword: header(1) + M2r comment(2) + FAIL hint(1)'
assert src.count('4026550885') == 2, 'decimal canonical: M2r comment(1) + the compare(1)'
assert src.count('-eq [uint32]0xF0004A65') == 0, 'hex-cast trap: the OPERATIVE compare must be decimal (comment mentions stay allowed)'
assert src.count('$mNameWrites') == 3, 'counter: init(1) + expFinal(1) + format slot(1)'
assert src.count('$script:mNameWrites') == 2, 'the Send-Resolve increment reads+writes via the script scope'
assert src.count('{4}+{5}') == 1
assert src.count('==== END v29 ====') == 1
assert src.count('trigger-test-v29-output-') == 1
assert src.count('==== INFINITY trigger test v29 ') == 1
assert 'died HERE' not in src
assert src.count('v21-RT = 131709 bytes') == 1
# request logic untouched: the op/seq/address wires stay byte-identical
for probe in ("New-Req $rseq 10 'FFFFFFFF' $nb.Length '0000000000000000' $null",
              "Send-Req (New-Req 0x1803 1 'FFFFFFFF' 4 ('{0:X16}' -f $nbVa) $null)",
              "Send-Req (New-Req 0x1805 1 'FFFFFFFF' 8 ('{0:X16}' -f $kbVa) $null)",
              "Send-Resolve 0x1801 'PsInitialSystemProcess'",
              "Send-Resolve 0x1802 'NtBuildNumber'",
              "Send-Resolve 0x1804 'KeBugCheckEx'",
              "Send-Resolve 0x1806 'NoSuchSymbolV28'"):
    assert src.count(probe) == 1, f'request wire changed?? {probe!r}'

open(DST, 'wb').write(src.encode('utf-8'))
h = hashlib.sha256(open(DST, 'rb').read()).hexdigest().upper()
print(f'WROTE {DST}')
print(f'  bytes: {len(src.encode("utf-8"))}  sha256: {h[:16]}...')
print(f'  edits applied: header block, transcript name, banner, END, M2r fix,')
print(f'  mNameWrites (init+inc), step-N text, INFCNT arithmetic, canary/step0/ladder/K texts')
