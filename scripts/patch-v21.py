#!/usr/bin/env python3
"""
Build trigger-test-v21.ps1 from the recoverable v18 base.

v21 story (what this patch encodes):
  v19: step I attach (op=7) killed the VM - the attach handler walks the
       process list hunting emulator EXE names; none exist in this VM.
  v20: attach skipped, first READ request (op=1, pid=0xFFFFFFFF, kernel
       alias) got "[INF][RD] kern va=0xFFFFF78000000260" printed on serial
       (request received + parsed CORRECTLY) - then the VM died inside the
       read primitive itself. No response was ever written.
  v21: the PID SAFETY LADDER - nine READ requests, safest-first, each one
       marked loudly BEFORE it is sent, so a crash names its killer.
       All script-controllable inputs left are pid / addr / len.
       $PID (this PowerShell) + the KUSD USER alias 0x7FFE0260 (same
       physical page as the kernel alias, mapped in every process) is the
       driver's DESIGNED use case and the safest possible first request.

Patch strategy: anchored replacements against trigger-test-v18.ps1
(the v19/v20 scripts were lost to a sandbox rollback; v18 is the newest
recoverable base and the v19/v20 deltas are re-applied here).
"""
import sys

SRC = '/home/z/my-project/infinity-qemu-test/trigger-test-v18.ps1'
DST = '/home/z/my-project/infinity-qemu-test/trigger-test-v21.ps1'

text = open(SRC, encoding='ascii', newline='').read()   # newline='' -> exact bytes, LF preserved

def rep(old, new, label):
    """Replace exactly-once anchored block; hard-fail otherwise."""
    global text
    n = text.count(old)
    if n != 1:
        print(f'[{label}] FATAL: anchor found {n} times (need exactly 1)')
        sys.exit(1)
    text = text.replace(old, new)
    print(f'[{label}] OK')

# =====================================================================
# R1: file header (everything before $ErrorActionPreference)
# =====================================================================
i = text.index("$ErrorActionPreference = 'Continue'")
new_header = """# ============================================================
# INFINITY bridge trigger test v21  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v17 driver stick (memory.efi v17 RT - "bridge +
# kernel data path (phase E)"). The DRIVER IS NOT CHANGED by v21;
# only this test script evolves (v18 -> v19 -> v20 -> v21).
#
# CRASH HISTORY (already root-caused - do not repeat):
#   v19: step I ReqOp_Attach (op=7, pid=0) KILLED the VM. The attach
#        handler walks the process list looking for emulator EXE
#        names; none exist in this VM -> fatal. v20+ SKIPS attach.
#   v20: first READ request (op=1, pid=0xFFFFFFFF, KUSD kernel alias
#        FFFFF78000000260, len=4) got FURTHER: serial shows
#        "[INF][RD] kern va=0xFFFFF78000000260" - the request was
#        received and parsed CORRECTLY (address exact), the kernel
#        read STARTED - then the VM died, no response ever written.
#        The crash is INSIDE the driver's cross-context read. The
#        only script-controllable inputs left: pid / addr / len.
#        (Proof plain reads CAN work in hook context: the driver's
#        own [BLD] probe read KUSD 0x260 fine in the SAME boot -
#        "live windows build=19045".)
#
# v21 STRATEGY - THE PID SAFETY LADDER (J1..J9):
#   Nine READ requests, ordered SAFEST-FIRST. Each prints a big
#   marker and pauses 1.5 s BEFORE it is sent - if the VM dies, the
#   last marker on screen + the last serial [RD] line name the
#   killer variant exactly. Every variant asks for known bytes:
#     KUSD+0x260 = 65 4A 00 00 (19045 LE), via the USER alias
#     0x7FFE0260 where possible (same physical page as the kernel
#     alias, mapped in EVERY process, no kernel-mode tricks needed)
#     J1  pid=$PID (this PowerShell)  addr=USER alias    - the
#         driver's DESIGNED job: read a live target process
#     J2  pid=$PID                    addr=KERNEL alias
#     J3  pid=4 (System process)      addr=USER alias
#     J4  pid=0                       addr=USER alias
#     J5  pid=0xFFFFFFFF              addr=USER alias  (v20 pid, safe addr)
#     J6  pid=0xFFFFFFFF              addr=KERNEL alias (exact v20 repeat)
#     J7  pid=$PID  KUSD+0x308 x4 (v15/v16 field truth: 0)
#     J8  pid=$PID  KUSD+0x260 x8 (chunk test; dword[0] must equal J1)
#     J9  pid=$PID  NON-CANONICAL VA  (expect ErrAccess(4), no crash)
#
# Step map:
#   A,B  INFDIAG reads          -> hook_calls must MOVE (read path)
#   C    INFPROBE write+read    -> raw NVRAM write path
#   D    INFTRIGGER write       -> trigger flag 0x20 + INFCNT
#   E    InfinityReq PING       -> the request transport
#   E2   InfinityResp read      -> FULL BRIDGE check (PONG)
#   F    final INFDIAG + read-backs
#   G    INFCNT read            -> live RAM write counter
#   H    InfinityData round trip-> payload transport
#   I    (SKIPPED - attach proven fatal in v19, see above)
#   J1..J9 the pid safety ladder
#   N    final INFCNT -> expect G+1 (H's data write is the only
#        counting write after G; requests are consumed in RAM and
#        deletes never count - proven by v17/v20 runs)
#
# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (virtual mode armed - OS runtime calls count).
#
# KEEP FILMING THE SCREEN. If the VM dies mid-ladder, the video plus
# serial-phase-d.log ARE the record (the .txt transcript dies with
# the VM). The last [Jn] marker on screen names the killer variant.
# ============================================================

"""
text = new_header + text[i:]
print('[R1 header] OK')

# =====================================================================
# R2: U32 - the v19 accumulator fix (v18 form truncated every dword
#     to its low byte: [byte] -shl 8 keeps the LEFT type; that made
#     v18's PONG decode lie - "BRIDGE REGRESSION" was FALSE)
# =====================================================================
rep("""function U32([byte[]]$b, [int]$o) {
    return $b[$o] -bor ($b[$o+1] -shl 8) -bor ($b[$o+2] -shl 16) -bor ($b[$o+3] -shl 24)
}""",
"""function U32([byte[]]$b, [int]$o) {
    # v19+ accumulator form: every intermediate stays [uint32].
    # (The v18 form kept the LEFT operand type on -shl - a [byte]!
    #  - so every dword was truncated to its low byte. That made the
    #  v18 PONG decode lie; the bridge itself was never broken.)
    $v = [uint32]0
    for ($i = 3; $i -ge 0; $i--) { $v = ($v -shl 8) -bor [uint32]$b[$o+$i] }
    return $v
}""", 'R2 U32')

# =====================================================================
# R3: U64 - same explicit-cast symmetry (v18 form was already correct)
# =====================================================================
rep("""function U64([byte[]]$b, [int]$o) {
    $v = [uint64]0
    for ($i = 7; $i -ge 0; $i--) { $v = ($v -shl 8) -bor $b[$o+$i] }
    return $v
}""",
"""function U64([byte[]]$b, [int]$o) {
    # accumulator form, explicit [uint64] casts - no operand-type traps
    $v = [uint64]0
    for ($i = 7; $i -ge 0; $i--) { $v = ($v -shl 8) -bor [uint64]$b[$o+$i] }
    return $v
}""", 'R3 U64')

# =====================================================================
# R4: Send-Req - clear InfinityData too, so every ladder variant gets
#     a fresh out-buffer dump (H's echo must not pollute them)
# =====================================================================
rep("""    Try-Del 'InfinityResp'
    return [pscustomobject]@{ Resp = $resp; SeqOk = $seqOk; Status = $status; Data = $dataBytes }""",
"""    Try-Del 'InfinityResp'
    Try-Del 'InfinityData'   # v21: fresh out-buffer for the next request
    return [pscustomobject]@{ Resp = $resp; SeqOk = $seqOk; Status = $status; Data = $dataBytes }""",
    'R4 Send-Req data-clear')

# =====================================================================
# R5: transcript filename v18 -> v21
# =====================================================================
rep('$transPath = Join-Path $spot ("trigger-test-v18-output-$stamp.txt")',
    '$transPath = Join-Path $spot ("trigger-test-v21-output-$stamp.txt")',
    'R5 transcript name')

# =====================================================================
# R6: banner line
# =====================================================================
rep("Write-Host '==== INFINITY trigger test v18 (v17 script bug fixed - the data-path proof: H..N) ===='",
    "Write-Host '==== INFINITY trigger test v21 (v20 crash root-caused - the pid safety ladder J1..J9) ===='",
    'R6 banner')

# =====================================================================
# R7: self-test block, inserted right after the [ENV] line
#     (v19 introduced it; its own 0xFFFFFFFF check tripped a PS cast
#      trap - v21 compares uint32-vs-uint32 directly, no int casts)
# =====================================================================
anchor_env = 'Write-Host ("[ENV] PowerShell $($PSVersionTable.PSVersion)  Windows build $([Environment]::OSVersion.Version.ToString())")'
selftest = anchor_env + """

# ---- self-test: the parsers must be perfect BEFORE touching the driver
#      (v18's U32 truncated every dword to its low byte - caught only by
#       field runs. v19 added this gate; its own 0xFFFFFFFF check tripped
#       a cast trap ("Cannot convert -1 to UInt32") that v20/v21 avoid:
#       uint32-vs-uint32 compares only, never an [u32] cast of an int)
$stFail = $false
function ST-Check([bool]$ok, [string]$what) {
    if (-not $ok) { $script:stFail = $true; Write-Host "[SELFTEST] FAILED: $what" }
}
$stb = New-Object byte[] 4
$stb[0] = 0x37; $stb[1] = 0x13; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]0x1337) 'U32 37 13 00 00 must be 0x1337'
$stb[0] = 0x65; $stb[1] = 0x4A; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]19045) 'U32 65 4A 00 00 must be 19045'
$stb[0] = 0xFF; $stb[1] = 0xFF; $stb[2] = 0xFF; $stb[3] = 0xFF
ST-Check ((U32 $stb 0) -eq [uint32]0xFFFFFFFF) 'U32 FF FF FF FF must be 0xFFFFFFFF'
$st8 = New-Object byte[] 8
$st8[0] = 0x00; $st8[1] = 0x10; $st8[2] = 0xC0; $st8[3] = 0x7F
$st8[4] = 0x00; $st8[5] = 0x00; $st8[6] = 0x00; $st8[7] = 0x00
ST-Check ((U64 $st8 0) -eq [uint64]0x7FC01000) 'U64 00 10 C0 7F 00 00 00 00 must be 0x7FC01000'
$stLe = HexLe4 'DEADBEEF'
ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF -and $stLe[1] -eq 0xBE -and $stLe[2] -eq 0xAD -and $stLe[3] -eq 0xDE) 'HexLe4 DEADBEEF must be EF BE AD DE'
$stReq = $null
try { $stReq = New-Req 0x1337 1 'FFFFFFFF' 4 'FFFFF78000000260' $null }
catch { $stReq = $null }
$stOk = ($null -ne $stReq -and $stReq.Length -eq 48 -and
    $stReq[0] -eq 0x37 -and $stReq[1] -eq 0x13 -and $stReq[2] -eq 0x00 -and $stReq[3] -eq 0x00 -and
    $stReq[4] -eq 0x01 -and $stReq[5] -eq 0x00 -and $stReq[6] -eq 0x00 -and $stReq[7] -eq 0x00 -and
    $stReq[8] -eq 0xFF -and $stReq[9] -eq 0xFF -and $stReq[10] -eq 0xFF -and $stReq[11] -eq 0xFF -and
    $stReq[12] -eq 0x04 -and $stReq[13] -eq 0x00 -and $stReq[14] -eq 0x00 -and $stReq[15] -eq 0x00 -and
    $stReq[16] -eq 0x60 -and $stReq[17] -eq 0x02 -and $stReq[18] -eq 0x00 -and $stReq[19] -eq 0x00 -and
    $stReq[20] -eq 0x80 -and $stReq[21] -eq 0xF7 -and $stReq[22] -eq 0xFF -and $stReq[23] -eq 0xFF)
ST-Check $stOk 'New-Req header bytes (seq/op/pid/len/addr) must round-trip'
if ($stFail) {
    Write-Host '[SELFTEST][ABORT] parser self-test failed - the driver was NOT touched. Send the output .txt / a photo.'
    if ($transPath) { try { Stop-Transcript | Out-Null } catch { } }
    exit 1
}
Write-Host '[SELFTEST] U32/U64/HexLe4/New-Req all passed - parsers verified before touching the driver'"""
rep(anchor_env, selftest, 'R7 selftest')

# =====================================================================
# R8: step A/B explainer line - version-neutral wording
# =====================================================================
rep("Write-Host '       v18: reads are answered LIVE from RAM by the hook (the'",
    "Write-Host '       v15+: reads are answered LIVE from RAM by the hook (the'",
    'R8 AB note')

# =====================================================================
# R9: replace steps I..M (attach + J/K/L/M) with: skipped-note + the
#     pid safety ladder. Anchors: from the step-I comment line up to
#     (not including) the step-N comment line.
# =====================================================================
def rep_between(start, end, new, label):
    global text
    a = text.find(start)
    b = text.find(end)
    if a < 0 or b < 0 or b <= a:
        print(f'[{label}] FATAL: between-anchors bad (a={a}, b={b})')
        sys.exit(1)
    text = text[:a] + new + text[b:]
    print(f'[{label}] OK (replaced {b - a} bytes)')

LADDER = '''# [10] step I: ReqOp_Attach -- SKIPPED. v19 PROVED op=7 kills this VM
#      (it walks the process list hunting emulator EXE names that do
#      not exist here). Kernel reads do not need it. Never re-enable.
Write-Host ''
Write-Host '--- step I: ReqOp_Attach -- SKIPPED (v19 crashed the VM here; op=7 walks the ---'
Write-Host '    process list for emulator EXEs that do not exist in this VM -'
Write-Host '    disassembly-proven fatal, and NOT needed for kernel reads)'
$attachTxt = 'SKIPPED (v19-proven fatal in this VM)'

# ---- InfinityData hygiene: H's echo must not pollute the ladder dumps
Try-Del 'InfinityData'
Start-Sleep -Milliseconds 150

# ============================================================
# [11] THE PID SAFETY LADDER - J1..J9
#      Nine READ requests (op=1), ordered SAFEST-FIRST. Each prints
#      its marker and pauses 1.5 s BEFORE sending, so if the VM dies
#      the video + serial log name the killer variant exactly.
#      Known-answer bytes everywhere:
#        KUSD+0x260 -> 65 4A 00 00 (19045 LE). The USER alias
#                      0x7FFE0260 and the KERNEL alias
#                      0xFFFFF78000000260 are the SAME physical
#                      page - but the user alias is mapped in EVERY
#                      process and needs no kernel-mode tricks.
#        KUSD+0x308 -> 00 00 00 00 (v15/v16 field truth)
#      $PID = this very PowerShell: a real, listed, alive target
#      process - exactly the read-a-target-process job the driver
#      was built for.
# ============================================================
$expBuild = New-Object byte[] 4
$expBuild[0] = 0x65; $expBuild[1] = 0x4A; $expBuild[2] = 0x00; $expBuild[3] = 0x00   # 19045 = 0x4A65 LE
$myPid = [uint32]$PID
$ladder = @(
    @{ n = 'J1'; seq = 0x1601; rpid = $myPid;     len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'the designed use case: read a live process (this PowerShell) - safest possible' }
    @{ n = 'J2'; seq = 0x1602; rpid = $myPid;     len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias';          why = 'same safe pid, kernel-space address' }
    @{ n = 'J3'; seq = 0x1603; rpid = 4;          len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'pid=4 (System process) - a different real, existing process' }
    @{ n = 'J4'; seq = 0x1604; rpid = 0;          len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'pid=0 semantics probe (Idle? current? attached?)' }
    @{ n = 'J5'; seq = 0x1605; rpid = 'FFFFFFFF'; len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = "v20's killer PID with a SAFE address - isolates pid vs addr" }
    @{ n = 'J6'; seq = 0x1606; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias';          why = 'EXACT v20 repeat (pid=FFFFFFFF + kernel alias) - reproduce/confirm' }
    @{ n = 'J7'; seq = 0x1607; rpid = $myPid;     len = 4; addr = '00007FFE00000308'; atxt = 'USER alias 0x7FFE0308';  why = 'second KUSD field (v15/v16 truth: 0)' }
    @{ n = 'J8'; seq = 0x1608; rpid = $myPid;     len = 8; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'x8 chunk test (dword[0] must equal J1)' }
    @{ n = 'J9'; seq = 0x1609; rpid = $myPid;     len = 4; addr = '0000800000000000'; atxt = 'NON-CANONICAL VA';      why = 'negative test: expect ErrAccess(4), NO crash' }
)

Write-Host ''
Write-Host 'LADDER DECISION TABLE (for reading the video if the VM dies):'
Write-Host ' dies at J1     -> the per-pid read path itself is fatal (needs attach?) - Phase E rests on [BLD]'
Write-Host ' dies at J2     -> J1 PROVED the data path (user space); kernel-alias reads are the killer'
Write-Host ' dies at J3/J4  -> pid=4 / pid=0 resolution fatal; J1 already proved the path'
Write-Host ' dies at J5     -> pid=FFFFFFFF (os_cr3 / kernel mode) is the killer; J1 proved the path'
Write-Host ' dies at J6     -> v20 crash reproduced AFTER J1..J5 passed: the pid+addr COMBINATION kills'
Write-Host ' survives all 9 -> full matrix ran; verdict printed at the end'
Start-Sleep -Milliseconds 800

$jVal     = -1
$jWhere   = 'NOWHERE'
$dataOff  = -1
$bufKind  = ''
$ladderLog = @()
$negTxt   = 'never reached'

foreach ($v in $ladder) {
    Write-Host ''
    Write-Host ("--- step $($v.n): kernel READ  pid=$($v.rpid)  len=$($v.len)  addr=$($v.atxt) ---")
    Write-Host "      why: $($v.why)"
    Write-Host ("[{0}] >>> SENDING op=1(READ) seq=0x{1:X} pid={2} len={3} addr=0x{4}" -f $v.n, $v.seq, $v.rpid, $v.len, $v.addr)
    Write-Host ("[{0}]     if the VM dies NOW, the killer is: pid={1} + addr={2} + len={3}" -f $v.n, $v.rpid, $v.atxt, $v.len)
    Start-Sleep -Milliseconds 1500
    $R = $null
    try { $R = Send-Req (New-Req $v.seq 1 $v.rpid $v.len $v.addr $null) }
    catch { Write-Host "[!] step $($v.n) threw: $($_.Exception.Message)" }

    $vTxt = 'NO RESPONSE (see marker above + serial [RD])'
    if ($null -ne $R -and $null -ne $R.Resp) {
        $vTxt = "ANSWERED status=$($R.Status)($(Stat-Name $R.Status)) seq_ok=$($R.SeqOk)"
    }
    # known-bytes search: 65 4A 00 00 in the response (offset >= 8),
    # then in the InfinityData out-buffer
    $foundWhere = ''
    if ($null -ne $R -and $null -ne $R.Resp) {
        $o = Find-From $R.Resp $expBuild 8
        if ($o -ge 8) {
            $foundWhere = "InfinityResp offset $o"
            if ($dataOff -lt 0) { $dataOff = $o; $bufKind = 'resp' }
        }
    }
    if ($foundWhere -eq '' -and $null -ne $R -and $null -ne $R.Data) {
        $o = Find-From $R.Data $expBuild 0
        if ($o -ge 0) {
            $foundWhere = "InfinityData offset $o"
            if ($dataOff -lt 0) { $dataOff = $o; $bufKind = 'data' }
        }
    }
    if ($foundWhere -ne '') {
        $vTxt += " + 19045 FOUND at $foundWhere"
        if ($jVal -lt 0) {
            $jVal = 19045
            $jWhere = "$($v.n) $foundWhere"
            Write-Host "      *** KERNEL DATA PATH ANSWER: 19045 (0x4A65) came back at $foundWhere ***"
        }
    }
    # J7 cross-check (expected 0) and J8 chunk check, at the learned offset
    if (($v.n -eq 'J7' -or $v.n -eq 'J8') -and $dataOff -ge 0 -and $null -ne $R) {
        $srcArr = $null
        if ($bufKind -eq 'resp' -and $null -ne $R.Resp) { $srcArr = $R.Resp }
        if ($bufKind -eq 'data' -and $null -ne $R.Data) { $srcArr = $R.Data }
        if ($null -ne $srcArr) {
            if ($v.n -eq 'J7' -and ($dataOff + 4) -le $srcArr.Length) {
                $kv = U32 $srcArr $dataOff
                $vTxt += " | J7 dword@$dataOff = $kv (expected 0)"
            }
            if ($v.n -eq 'J8' -and ($dataOff + 8) -le $srcArr.Length) {
                $d0 = U32 $srcArr $dataOff
                $d1 = U32 $srcArr ($dataOff + 4)
                $vTxt += " | J8 dword[0]=$d0 dword[1]=$d1 (dword[0] must be 19045)"
            }
        }
    }
    if ($v.n -eq 'J9') {
        if ($null -ne $R -and $null -ne $R.Resp) {
            if ($R.Status -eq 4) { $negTxt = 'OK - status=4(ErrAccess) as designed; script still alive = no crash' }
            else { $negTxt = "UNEXPECTED status=$($R.Status)($(Stat-Name $R.Status)) - see serial" }
        } else {
            $negTxt = 'NO RESPONSE (but script alive - see serial [RD])'
        }
    }
    Write-Host ("      [{0}] result: {1}" -f $v.n, $vTxt)
    $ladderLog += ("    [{0}] pid={1,-10} addr={2,-22} -> {3}" -f $v.n, $v.rpid, $v.atxt, $vTxt)
}

$kernOk = ($jVal -eq 19045)
if ($kernOk) { $jTxt = "PROVEN - 19045 via $jWhere" }
else         { $jTxt = 'NOT PROVEN - see the ladder results above + serial [RD] lines' }

'''

rep_between('# [10] step I: ReqOp_Attach', '# [15] step N: final INFCNT', LADDER, 'R9 ladder')

# =====================================================================
# R10: summary line [7] - attach is now a skip, not a decode
# =====================================================================
rep('Write-Host ("[7] ReqOp_Attach decode            : {0}" -f $attachTxt)',
    'Write-Host ("[7] Attach step (I)                : {0}" -f $attachTxt)',
    'R10 summary 7')

# =====================================================================
# R11: summary line [8] - ladder log + new [8]
# =====================================================================
rep("""Write-Host ("[8] Kernel read KUSD+0x260 (J)     : {0}" -f $jTxt)""",
"""Write-Host '     ladder detail (each line = one variant, in send order):'
foreach ($ln in $ladderLog) { Write-Host $ln }
Write-Host ("[8] Kernel read via ladder (J1..J9) : {0}" -f $jTxt)""",
    'R11 summary 8')

# =====================================================================
# R12: summary line [9] - M -> J9 / $mTxt -> $negTxt
# =====================================================================
rep('Write-Host ("[9] Negative VA handling (M)       : {0}" -f $mTxt)',
    'Write-Host ("[9] Negative VA handling (J9)      : {0}" -f $negTxt)',
    'R12 summary 9')

# =====================================================================
# R13: INFCNT final wording (v21 clears InfinityData after dumping)
# =====================================================================
rep("""Write-Host ("    INFCNT final = {0}   (expect G+1 = {1}: only the InfinityData write persists;" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 1 } else { '?' }))
Write-Host '     request writes are consumed in RAM and never count - v17 said "expect 8", that was wrong)'""",
"""Write-Host ("    INFCNT final = {0}   (expect G+1 = {1}: H's InfinityData write is the only" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 1 } else { '?' }))
Write-Host '     counting write after G; requests are consumed in RAM and deletes never count)'""",
    'R13 INFCNT wording')

# =====================================================================
# R14: verdict block - kernOk computed in the ladder; new wording
# =====================================================================
rep("""$kernOk = ($jVal -eq 19045)
$bridgeOk = $respAnswered -and $hExact
if ($kernOk) {
    Write-Host '>>> KERNEL DATA PATH PROVEN - PHASE E COMPLETE <<<'
    Write-Host 'Windows -> InfinityReq -> our hook -> kernel read -> InfinityResp.'
    if (-not ($null -ne $M -and $M.Status -eq 4)) {
        Write-Host 'NOTE: step M did not return ErrAccess(4) - check [9] and the serial log.'
    }
} elseif ($bridgeOk) {
    Write-Host '>>> FULL BRIDGE PROVEN (v16/v17 result) - but the data path'
    Write-Host '>>> did not return the expected dword. <<<'
    Write-Host 'The requests WERE sent this time (no v17 script crash). The serial'
    Write-Host 'log has the [RD] kern va / kern read ok lines - send output .txt +'
    Write-Host 'serial-phase-d.log.'
} else {
    Write-Host '>>> BRIDGE REGRESSION vs v17 (PING or payload transport failed). <<<'
    Write-Host 'Send output .txt + serial-phase-d.log.'
}""",
"""$bridgeOk = $respAnswered -and $hExact
if ($kernOk) {
    Write-Host '>>> KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE <<<'
    Write-Host "Windows -> InfinityReq -> our hook -> cross-context read -> InfinityResp ($jWhere)."
    if ($negTxt -notlike 'OK*') {
        Write-Host 'NOTE: J9 did not return a clean ErrAccess(4) - check [9] + serial.'
    }
} elseif ($bridgeOk) {
    Write-Host '>>> FULL BRIDGE PROVEN - and the VM SURVIVED all 9 ladder variants,'
    Write-Host '>>> but none returned the expected dword. <<<'
    Write-Host 'That combination is NEW information - send the output .txt +'
    Write-Host 'serial-phase-d.log (every [RD] line matters).'
} else {
    Write-Host '>>> BRIDGE REGRESSION (PING or payload transport failed). <<<'
    Write-Host 'Send output .txt + serial-phase-d.log.'
}""",
    'R14 verdict')

# =====================================================================
# R15: END banner
# =====================================================================
rep("Write-Host '==== END v18 ===='",
    "Write-Host '==== END v21 ===='",
    'R15 END banner')

open(DST, 'w', encoding='ascii', newline='').write(text)
print(f'\\nwrote {DST}: {len(text)} bytes, {text.count(chr(10))} lines')
