#!/usr/bin/env python3
# ============================================================================
# make-v30.py — build trigger-test-v30.ps1 from the FIELD-RUN v29 script
#
# v30 story (what this patch encodes):
#   v29 field run (2026-09-27): FULL GREEN - F2 closed at both levels
#   (driver v21 + script v29; M1..M4 + J/L/K all PASS, INFCNT 27 exact).
#   F3 = the EPROCESS WALK: driver v22 (op-11 ReqOp_ProcessWalk) reads
#   process data OUTSIDE the validated ntoskrnl image for the first
#   time - the F2-resolved PsInitialSystemProcess + ActiveProcessLinks
#   + double-link consistency + canonical/cluster gates (the v19
#   name-hunting death class is structurally impossible).
#
# v30 CHANGES (script-only, anchored on the v29 text):
#   1. v30 header block above the v29 historical block
#   2. transcript name v29 -> v30
#   3. banner: the v30 story
#   4. NEW step W (the F3 ladder) between M and the final INFCNT:
#      W1 the walk itself (op-11 outN=32) + the M1<->sys cross-check
#      W2 live Get-Process cross-check (pids + count)
#      W3 the script's own $PID among the walked entries
#      W4 negatives: outN=0 / outN=33 -> ErrInvalid(5)
#      W5 pid-irrelevance: op-11 with a real pid still answers (no pid gate)
#   5. INFCNT arithmetic: + $wSent (every op-11 request +1)
#   6. summary [14] F3 line
#   7. verdict: the F3 block
#   8. END marker v30
#   9. driver-size docs: v22-RT = 134330 bytes
#
# Usage: python3 scripts/make-v30.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v29.ps1'
DST = BASE / 'patches' / 'trigger-test-v30.ps1'

text = SRC.read_text(encoding='utf-8')

def rep(old, new, label, count=1):
    global text
    n = text.count(old)
    if n != count:
        print(f'[{label}] FATAL: anchor found {n} times (need {count})')
        sys.exit(1)
    text = text.replace(old, new)
    print(f'[{label}] OK')

# =========================================================
# 1. v30 header above the v29 header
# =========================================================
rep(
"""# ============================================================
# INFINITY bridge trigger test v29  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v30  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v22 DRIVER (memory.efi v22 RT - "anchors + exports
# + process walk (F3)", 134330 bytes). v30 runs the FULL K/L/M/J
# regression against v22 (re-proving F1+F2 on the new binary) and
# then the NEW step W: the F3 EPROCESS walk (op=11). With the v21
# driver (131709 B) everything except W still works - W refuses
# cleanly (op 11 -> ErrUnsupported) and the F3 verdict says so.
#
# WHAT F3 IS: the first reads of kernel data OUTSIDE the validated
# ntoskrnl image. The driver resolves PsInitialSystemProcess via
# the F2 export machinery (in-image gate - no new trust root) and
# walks ActiveProcessLinks from there with: double-link LIST_ENTRY
# consistency (Blink(cur)==prev AND Blink(next)==cur before every
# advance), canonical-VA + no-wrap gates, a +-4 GB pool-cluster
# window, 64-entry / 256-page hard budgets, and LIVE name-slot
# discovery ("System\\0" probe - offsets derived, never trusted).
# The v19 attach death class (hardcoded name hunting) is
# structurally impossible here. Every refusal is a clean status -
# the VM stays alive (the M4 discipline).
#
# STEP W LADDER (all canaried; the serial [PW] lines cross-check):
#   W1  op-11 outN=32  -> payload.status=0(Ok), count>=1,
#       sys == M1's resolved VA (the built-in F2<->F3 cross-check),
#       entries[0] = System (pid 4, eproc == sys), names echoed
#       (flags bit0, "System\\0" at entries[0].name)
#   W2  live cross-check: the walked pids exist in Get-Process,
#       count within tolerance of the live process count
#   W3  the script's own $PID among the walked entries (NOTE if
#       beyond the 32-entry stored window - honest reporting)
#   W4  negatives: outN=0 and outN=33 -> ErrInvalid(5), no crash
#   W5  pid-irrelevance: op-11 with a REAL pid answers the same
#       (kernel-list data has no pid gate - unlike op-1 reads)
#
# INFCNT v30: v29 formula + $wSent (every op-11 request +1; W
# writes no InfinityData - outN travels in the request header).
#
# ============================================================
# INFINITY bridge trigger test v29  (run INSIDE the Windows VM,""",
'1-header')

# =========================================================
# 2. transcript name
# =========================================================
rep('trigger-test-v29-output-',
    'trigger-test-v30-output-',
    '2-transcript')

# =========================================================
# 3. banner
# =========================================================
rep(
"Write-Host '==== INFINITY trigger test v29 (v21 driver: F1+F2 PROVEN IN THE FIELD; M export resolution - the M2r build-mask fix + full INFCNT arithmetic + J/L/K regression) ===='",
"Write-Host '==== INFINITY trigger test v30 (v22 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression re-proves F1+F2 on v22) ===='",
'3-banner')

# =========================================================
# 4. the W-step block between M and step N
# =========================================================
W_ANCHOR = """} else {
    Write-Host '     [M] SKIPPED (anchors not converged - the resolve refuses without the validated range)'
}

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)"""

W_BLOCK = """} else {
    Write-Host '     [M] SKIPPED (anchors not converged - the resolve refuses without the validated range)'
}

# ============================================================
# [14.5] step W: ReqOp_ProcessWalk (op=11) - THE F3 EPROCESS WALK
# (v22 driver only; with v21 the op refuses ErrUnsupported cleanly)
# ============================================================
$wSent     = 0
$w1Ok      = $false
$wNamesOk  = $false
$w2Ok      = $false
$w3Txt     = 'NOT RUN'
$w4Ok      = $false
$w5Ok      = $false
$wCount    = -1
$wStored   = -1
$wPayloadTxt = 'no payload'

if ($anOk) {
    Write-Host ''
    Write-Host '--- step W: ReqOp_ProcessWalk (op=11, pid ignored, outN=32) - THE F3 WALK ---'
    Write-Host '      resp status=1(Success) + payload.status=0(Ok) => the walk ran'
    Write-Host '      payload.status: 0 Ok / 1 bad-args / 2 no-entry / 3 bad-S1 / 4 not-System /'
    Write-Host '                     5 broken-link / 6 window-refused / 7 budget (refuse = VM alive)'

    # ---- W1: the walk itself ----
    Canary 'pre-W1'
    $W1 = $null
    try { $W1 = Send-Req (New-Req 0x1901 11 'FFFFFFFF' 32 '0000000000000000' $null) } catch { Write-Host "[!] W1 threw: $($_.Exception.Message)" }
    $wSent++
    if ($null -ne $W1 -and $null -ne $W1.Resp -and $W1.Status -eq 1 -and $null -ne $W1.Data -and $W1.Data.Length -ge 1056) {
        $wSt     = U32 $W1.Data 1024
        $wCount  = U32 $W1.Data 1028
        $wSys    = U64 $W1.Data 1032
        $wOfs    = U32 $W1.Data 1040
        $wClosed = U32 $W1.Data 1044
        $wPages  = U32 $W1.Data 1048
        $wStored = U32 $W1.Data 1052
        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} sys=0x{6:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys)
        Write-Host ("     [W1] payload: {0}" -f $wPayloadTxt)
        if ($wSt -ne 0) {
            Write-Host ("     [W1] WALK REFUSED (payload status={0}) - the VM is alive; serial [PW] names the refusal" -f $wSt)
        } else {
            # the F2<->F3 cross-check: sys MUST equal M1's resolved VA
            $sysEcho = ($wSys -eq $mVa)
            $e0pid = U32 $W1.Data 0
            $e0eproc = U64 $W1.Data 8
            $e0flags = U32 $W1.Data 4
            $e0name = [System.Text.Encoding]::ASCII.GetString($W1.Data, 16, 8)
            Write-Host ("     [W1] entries[0]: pid={0} eproc=0x{1:X} flags={2} name='{3}'" -f $e0pid, $e0eproc, $e0flags, $e0name)
            $w1Ok = ($wCount -ge 1) -and $sysEcho -and ($e0pid -eq 4) -and ($e0eproc -eq $mVa)
            if ($w1Ok) {
                Write-Host '     [W1] PASS: System entry self-echo at the M1-resolved VA (F2<->F3 cross-check) - list head proven'
            } else {
                Write-Host '     [W1] FAIL: sys!=M1-va or entries[0] is not System@S1 (see above + serial [PW])'
            }
            # names
            $wNamesOk = ($wOfs -ne 0) -and ($e0flags -band 1) -and ($e0name.StartsWith('System'))
            if ($wNamesOk) { Write-Host ("     [W1] PASS: name slot discovered live at +0x{0:X} - names echoed (derive, never trust)" -f $wOfs) }
            else           { Write-Host '     [W1] NOTE: names not echoed (name_ofs=0 or flags bit0=0) - the walk itself is still valid' }

            # ---- W2: the live Get-Process cross-check ----
            Write-Host ''
            Write-Host '--- step W2: live cross-check (Get-Process) ---'
            try {
                $liveProcs = @(Get-Process -ErrorAction Stop)
                $liveIds = @{}
                foreach ($p in $liveProcs) { $liveIds[[int]$p.Id] = $true }
                $checked = 0; $missing = 0
                $lim = $wStored; if ($lim -gt 12) { $lim = 12 }
                for ($i = 0; $i -lt $lim; $i++) {
                    $ep = U32 $W1.Data ($i * 32)
                    if ($ep -ne 0) {
                        $checked++
                        if (-not $liveIds.ContainsKey([int]$ep) -and $ep -ne 4) { $missing++; Write-Host ("     [W2] pid {0} not in the live list (protected/exit race?)" -f $ep) }
                    }
                }
                $cntDelta = [Math]::Abs([int]$wCount - $liveProcs.Count)
                Write-Host ("     [W2] walked={0} live={1} delta={2} checked={3} missing={4}" -f $wCount, $liveProcs.Count, $cntDelta, $checked, $missing)
                $w2Ok = ($missing -eq 0) -and ($cntDelta -le 3)
                if ($w2Ok) { Write-Host '     [W2] PASS: the walked list matches the live process list' }
                else       { Write-Host '     [W2] FAIL: too many mismatches - send the .txt + serial [PW]' }
            } catch { Write-Host "     [W2] SKIPPED (Get-Process failed: $($_.Exception.Message))" }

            # ---- W3: the script's own $PID among the walked entries ----
            Write-Host ''
            Write-Host '--- step W3: is THIS PowerShell (pid $myPid) in the walked list? ---'
            $foundAt = -1
            $lim3 = $wStored
            for ($i = 0; $i -lt $lim3; $i++) {
                if ((U32 $W1.Data ($i * 32)) -eq [uint32]$myPid) { $foundAt = $i; break }
            }
            if ($foundAt -ge 0) {
                $nm3 = [System.Text.Encoding]::ASCII.GetString($W1.Data, ($foundAt * 32) + 16, 8)
                Write-Host ("     [W3] FOUND at entry {0}: name='{1}' - the walk sees the requester itself" -f $foundAt, $nm3)
                $w3Txt = "FOUND at entry $foundAt ('$nm3')"
            } elseif ($wStored -lt $wCount) {
                Write-Host ("     [W3] NOTE: not within the first {0} stored entries (list has {1}; late-started processes sit at the tail) - not a failure" -f $wStored, $wCount)
                $w3Txt = "beyond the stored window (stored=$wStored count=$wCount)"
            } else {
                Write-Host '     [W3] FAIL: the whole list was stored but this pid is absent'
                $w3Txt = 'ABSENT from a fully-stored list'
            }
        }
    } elseif ($null -ne $W1 -and $null -ne $W1.Resp) {
        Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v22 build (134330 B)? With v21 op 11 is ErrUnsupported(8)" -f $W1.Status, (Stat-Name $W1.Status))
    } else {
        Write-Host '     [W1] FAIL: no response at all (see raw above + serial [PW])'
    }

    # ---- W4: the honest negatives (outN gate) ----
    Write-Host ''
    Write-Host '--- step W4: negatives - outN=0 and outN=33 must both refuse ErrInvalid(5), VM alive ---'
    Canary 'pre-W4'
    $W4a = $null
    try { $W4a = Send-Req (New-Req 0x1902 11 'FFFFFFFF' 0 '0000000000000000' $null) } catch { Write-Host "[!] W4a threw: $($_.Exception.Message)" }
    $wSent++
    $W4b = $null
    try { $W4b = Send-Req (New-Req 0x1903 11 'FFFFFFFF' 33 '0000000000000000' $null) } catch { Write-Host "[!] W4b threw: $($_.Exception.Message)" }
    $wSent++
    $w4aOk = ($null -ne $W4a -and $null -ne $W4a.Resp -and $W4a.Status -eq 5)
    $w4bOk = ($null -ne $W4b -and $null -ne $W4b.Resp -and $W4b.Status -eq 5)
    if ($w4aOk) { Write-Host '     [W4a] PASS: outN=0 -> ErrInvalid(5) clean' } else { Write-Host '     [W4a] FAIL: expected ErrInvalid(5) - see raw above' }
    if ($w4bOk) { Write-Host '     [W4b] PASS: outN=33 -> ErrInvalid(5) clean' } else { Write-Host '     [W4b] FAIL: expected ErrInvalid(5) - see raw above' }
    $w4Ok = $w4aOk -and $w4bOk

    # ---- W5: pid-irrelevance (no pid gate on kernel-list data) ----
    Write-Host ''
    Write-Host '--- step W5: op-11 with a REAL pid must answer the same (kernel-list reads have no pid gate) ---'
    Canary 'pre-W5'
    $W5 = $null
    try { $W5 = Send-Req (New-Req 0x1904 11 $myPid 32 '0000000000000000' $null) } catch { Write-Host "[!] W5 threw: $($_.Exception.Message)" }
    $wSent++
    $w5Ok = ($null -ne $W5 -and $null -ne $W5.Resp -and $W5.Status -eq 1)
    if ($w5Ok) { Write-Host '     [W5] PASS: real pid answered Success - the walk is kernel data, not per-process (contrast: op-1 J7 ErrAccess)' }
    else       { Write-Host '     [W5] FAIL: expected Success with a real pid - see raw above' }
} else {
    Write-Host ''
    Write-Host '--- step W: SKIPPED (anchors not converged - the walk refuses without the validated range) ---'
}

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)"""

rep(W_ANCHOR, W_BLOCK, '4-wstep')

# =========================================================
# 5. INFCNT arithmetic + the printed expectation
# =========================================================
rep(
"$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites } else { '?' }",
"$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent } else { '?' }",
'5a-arith')
rep(
"Write-Host (\"    INFCNT final = {0}   (expect G+8+{4}+{5} = {1}: H's InfinityData write (+1),\" -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites)",
"Write-Host (\"    INFCNT final = {0}   (expect G+8+{4}+{5}+{6} = {1}: H's InfinityData write (+1),\" -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent)",
'5b-printf')
rep(
"Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent) and the M symbol-NAME InfinityData writes (+mNameWrites); requests are consumed in RAM and deletes never count)'",
"Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites) and the W walk requests (+wSent); requests are consumed in RAM and deletes never count)'",
'5c-arith-text')
rep(
"Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+name-writes+requests: H +1, J1..J7 +7, K/L + M requests + M symbol-NAME writes) ---'",
"Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+name-writes+requests: H +1, J1..J7 +7, K/L + M requests + M name-writes + W walk requests) ---'",
'5d-stepN-title')

# =========================================================
# 6. summary [14] F3 line
# =========================================================
rep(
"""Write-Host (\"[13] F2 export resolution (M1..M4) : {0}\" -f $mTxt)
""",
"""Write-Host (\"[13] F2 export resolution (M1..M4) : {0}\" -f $mTxt)
$wTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
        elseif ($w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok) { "PROVEN - {0} processes walked, System self-echo + live-list cross-check green" -f $wCount }
        elseif ($wCount -ge 1) { 'PARTIAL - the walk ran but a cross-check failed (see the W-step lines + serial [PW])' }
        else { "REFUSED ($wPayloadTxt) - serial [PW] names the reason" }
Write-Host (\"[14] F3 process walk (W1..W5)    : {0}\" -f $wTxt)
if ($wCount -ge 1) { Write-Host (\"     walked count={0} stored={1} closed(capped)={2}  self-pid: {3}\" -f $wCount, $wStored, $(if ($wClosed) {'circle'} else {'64-cap'}), $w3Txt) }
""",
'6-summary14')

# =========================================================
# 7. the F3 verdict block after the F2 verdict
# =========================================================
rep(
"""} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F2 PARTIAL: anchors converged but an M-step failed - see above. <<<'
    Write-Host 'Serial [XS]/[KPCR]/[RD] lines matter - send them + the output .txt.'
}
Write-Host '==== END v29 ===='""",
"""} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F2 PARTIAL: anchors converged but an M-step failed - see above. <<<'
    Write-Host 'Serial [XS]/[KPCR]/[RD] lines matter - send them + the output .txt.'
}
$f3Ok = $anOk -and $w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok
if ($f3Ok) {
    Write-Host ''
    Write-Host '>>> F3 PROVEN: THE EPROCESS WALK - PROCESS DATA OUTSIDE THE IMAGE <<<'
    Write-Host ('From the F2-resolved PsInitialSystemProcess: ActiveProcessLinks walked with' )
    Write-Host 'double-link consistency + canonical/cluster gates + hard budgets.'
    Write-Host ("{0} processes counted, System self-echo at the M1 VA, live-list cross-check green," -f $wCount)
    Write-Host 'names discovered live. The first arbitrary-kernel-VA reads are proven -'
    Write-Host 'fail-closed held the whole way (W4 negatives clean, VM alive).'
    Write-Host 'Next: F4 (PTE/page-table base for arbitrary-VA validation), then Infinity.exe.'
} elseif ($anOk -and $wCount -ge 1) {
    Write-Host ''
    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F3 NOT PROVEN THIS RUN (the walk refused or was skipped). <<<'
    Write-Host 'Refusals are clean by design - the payload status + serial [PW] name it.'
}
Write-Host '==== END v30 ===='""",
'7-verdict')

# =========================================================
# 8. driver-size docs (the W1 refuse hint + the decision table)
# =========================================================
rep(
"Write-Host '                  Check usb-d\\memory.efi size: v21-RT = 131709 bytes.'",
"Write-Host '                  Check usb-d\\memory.efi size: v22-RT = 134330 bytes (v21-RT = 131709 runs F1+F2 but not W).'",
'8a-size-hint')
rep(
"Write-Host ' dies at J1     -> the driver is NOT v18+ (a v17 would walk+CR3-switch = instant death).'",
"Write-Host ' dies at J1     -> the driver is NOT v18+ (a v17 would walk+CR3-switch = instant death).'\nWrite-Host ' dies at W1/W4/W5 -> the F3 walk path (v22-only; v21 refuses op-11 = ErrUnsupported, never a crash).' +\n                     '  Check size: v22-RT = 134330.'",
'8b-decision')
rep(
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20/v21 containing-walk) ---'",
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v22 containing-walk) ---'",
'8c-kstep-title')

# =========================================================
# write + report
# =========================================================
DST.write_text(text, encoding='utf-8')
h = hashlib.sha256(DST.read_bytes()).hexdigest().upper()
print(f'\n[make-v30] wrote {DST} ({DST.stat().st_size} B)')
print(f'[make-v30] sha256 {h[:16]}...{h[-6:]}')

# post-checks
t = DST.read_text(encoding='utf-8')
for marker in ('trigger test v30', 'trigger-test-v30-output-', 'step W: ReqOp_ProcessWalk',
               '0x1901 11', '0x1904 11', '$wSent', 'F3 PROVEN: THE EPROCESS WALK',
               'END v30', 'v22-RT = 134330', '[14] F3 process walk'):
    if marker not in t:
        print(f'FATAL: post-check missing: {marker}')
        sys.exit(1)
for stale in ('==== END v29 ====', 'trigger-test-v29-output-'):
    if stale in t:
        print(f'FATAL: stale marker remains: {stale}')
        sys.exit(1)
# structural sanity: the W-step must come after M4 and before step N
iw = t.index('step W: ReqOp_ProcessWalk')
im4 = t.index('NoSuchSymbolV28')
inn = t.index('--- step N: final INFCNT read')
assert im4 < iw < inn, 'W-step position wrong'
print('[make-v30] ALL POST-CHECKS PASS (anchors unique, W between M and N, no stale markers)')
