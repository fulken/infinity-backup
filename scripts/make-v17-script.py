#!/usr/bin/env python3
"""Derive trigger-test-v17.ps1 from trigger-test-v16.ps1 (anchored edits).

v17 = the v16 bridge (field-proven: ">>> FULL BRIDGE PROVEN - PHASE D
COMPLETE <<<", PONG PERFECT, win 19045=19045, INFCNT=2, stage 4) + THE
DATA-PATH TEST + the read-only-transcript fix:

  1. AUTO-TEE READ-ONLY FIX (the v16 field defect): the script lives
     on the boot stick (D:), which phase-d.bat attaches READ-ONLY on
     purpose (2026-09-20 FAT-corruption lesson). "Save beside the
     script" can never work there. v17 probes for writability and
     falls back Desktop -> TEMP, VERIFIES the file at the end, and
     prints copy-out instructions (transfer stick + refresh-files).
  2. NEW STEPS H..N - the data path the real client (Infinity.exe)
     uses for process memory, replicated exactly (48-byte EfiVarReq
     {sequence,op,pid,data_size,address,...} -> InfinityResp 32-byte
     {sequence,status,bytes_transferred,...} + InfinityData payload):
       H  InfinityData write+read round trip (payload transport,
          32-byte pattern, byte-exact compare)
       I  ReqOp_Attach (op=7, pid=0) - expect ErrNotFound(7) on the
          clean VM (no emulator running) - decode either way
       J  ReqOp_Read (op=1) KUSD+0x260 x4 with pid=0xFFFFFFFF
          (KERNEL_TARGET_PID, the v17 driver addition) - expect
          Success + InfinityData = 65 4A 00 00 = 19045 = script-side
       K  same at KUSD+0x308 - field truth says 0
       L  8-byte chunk read at KUSD+0x260 - dword[0] must equal J
       M  NEGATIVE read: non-canonical VA 0xDEADBEEF00000000 - expect
          ErrAccess(4) and NO crash (the driver page-walks and fails
          before any dereference - by design, no #PF/#GP path)
       N  final INFCNT - expect 8 (2 baseline + all 6 new writes)
  3. SUMMARY gains [6][7][8][9] + the INFCNT accounting line; the
     verdict gains the DATA PATH PROVEN branch above the v16 ones.

Anchors are EXACT v16 script text. An anchor that does not match
exactly once = FAIL LOUD, nothing written.
"""
import sys
from pathlib import Path

SRC = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v16.ps1")
DST = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v17.ps1")


def edit(text, tag, old, new, count=1):
    n = text.count(old)
    if n != count:
        print(f"FATAL: anchor {tag}: found {n} (need {count})")
        sys.exit(1)
    return text.replace(old, new)


def main():
    t = SRC.read_text(encoding="utf-8-sig") if SRC.read_bytes()[:3] == b"\xef\xbb\xbf" else SRC.read_text()

    # ------------------------------------------------ S1: header block
    t = edit(t, "S1-header", """# ============================================================
# INFINITY trigger test v16  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v16 driver (infinity-qemu-test-v16 package).
# Running it against v9..v15 drivers gives WRONG verdicts -
# check that phase-d.bat printed "package v16" and the boot
# log says "memory.efi v16 RT".
#
# What v16 changed (the v15 run COMPLETED the full bridge; the
# v15 verdict was a script bug, confirmed at source level):
#   - The v15 report said "WRONG-CONTENT status=1" - a FALSE
#     NEGATIVE. The protocol enum (SharedMemoryProtocol.h) says
#     Pending=0, Success=1, ErrGeneric=2, ErrTimeout=3,
#     ErrAccess=4 ... so {seq=0x1337 echoed, status=1, bytes=0,
#     addr=0} IS a perfect PONG. v16 decodes status NAMES.
#   - PowerShell -shl on a BYTE returns a BYTE, so the v15
#     dword parser truncated every field to its low byte
#     (win_build 19045 -> "101", hook_calls 377 -> "121",
#     resp seq 0x1337 -> "0x37"). The raw data was CORRECT;
#     v16 parses full dwords with plain [uint32] math.
#   - Step [4] relabelled: InfinityReq is RAM-consumed by design
#     (v13+) - an ABSENT NVRAM read-back is the EXPECTED result,
#     not a failure. Consumption is proven by INFCNT>=2 or the
#     PONG itself.
#   - All output is AUTO-SAVED to a timestamped .txt next to
#     this script - no photos needed, just send that file.
#
# Step map:
#   A,B  INFDIAG reads          -> hook_calls must MOVE (read path)
#   C    INFPROBE write+read    -> raw NVRAM write path
#   D    INFTRIGGER write       -> trigger flag + INFCNT +1 (write path)
#   E    InfinityReq PING       -> the real request
#   E2   InfinityResp read      -> FULL BRIDGE check
#   F    final INFDIAG + read-backs
#   G    INFCNT read            -> live write-path count, RAM-served
#
# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (armed; live RAM state from the first read).
# status=1 (Success) on InfinityResp is the CORRECT PONG status.
# ============================================================""",
"""# ============================================================
# INFINITY trigger test v17  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v17 driver (infinity-qemu-test-v17 package).
# Running it against v9..v16 drivers gives WRONG verdicts on the
# data steps - check that phase-d.bat printed "package v17" and
# the boot log says "memory.efi v17 RT".
#
# What v17 adds on top of the PROVEN bridge (the v16 field run
# printed ">>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<"):
#   - THE DATA PATH: steps H..N replicate exactly what the real
#     client (Infinity.exe) does for process memory - a 48-byte
#     InfinityReq {sequence, op, pid, data_size, address} -> the
#     driver page-walks the address and the payload comes back
#     through InfinityResp (status + bytes) + InfinityData (the
#     bytes themselves). J reads the Windows build dword straight
#     out of KUSER_SHARED_DATA (+0x260) THROUGH THE BRIDGE and it
#     must equal the script-side build (19045 on this VM).
#   - pid=0xFFFFFFFF (KERNEL_TARGET_PID, new in the v17 driver)
#     selects the kernel target: the read is served from the
#     CALLER's address space. A bad VA (step M) fails the page
#     walk cleanly - ErrAccess, never a crash.
#   - AUTO-TEE FIX: the boot stick (D:) is READ-ONLY by design,
#     so the transcript now lands on the first WRITABLE location
#     (beside script -> Desktop -> TEMP) and is VERIFIED at the
#     end. How to get it out: transfer stick + refresh-files.bat.
#
# Step map:
#   A,B  INFDIAG reads          -> hook_calls must MOVE (read path)
#   C    INFPROBE write+read    -> raw NVRAM write path
#   D    INFTRIGGER write       -> trigger flag + INFCNT +1 (write path)
#   E    InfinityReq PING       -> the real request
#   E2   InfinityResp read      -> FULL BRIDGE check
#   F    final INFDIAG + read-backs
#   G    INFCNT read            -> live write-path count, RAM-served
#   H    InfinityData round trip-> payload transport (byte-exact)
#   I    ReqOp_Attach           -> expect ErrNotFound on clean VM
#   J    kernel read KUSD+0x260 -> THE data path (expect 19045)
#   K    kernel read KUSD+0x308 -> field truth says 0
#   L    kernel read x8 (chunk) -> dword[0] must equal J
#   M    negative VA read       -> expect ErrAccess(4), no crash
#   N    final INFCNT           -> expect 8 (2 baseline + 6 new)
#
# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (armed; live RAM state from the first read).
# status=1 (Success) on InfinityResp is the CORRECT PONG status.
# ============================================================""")

    # ------------------------------------------------ S2: auto-tee rewrite
    t = edit(t, "S2-autotee", """# ---- v16: auto-tee - everything to a file next to this script ----
# No photos needed: the whole run (incl. SUMMARY + VERDICT) is saved
# to a timestamped .txt beside this script. Send that file back.
$__logDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$__log    = Join-Path $__logDir ("trigger-test-v16-output-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$__teeOk  = $false
try { Start-Transcript -Path $__log -ErrorAction Stop | Out-Null; $__teeOk = $true } catch { }
if ($__teeOk) {
    Write-Host '[LOG] auto-saving all output to:'
    Write-Host "[LOG] $__log"
} else {
    Write-Host '[LOG] transcript unavailable - photo the screen as before'
}

function __Finish([int]$code) {
    if ($__teeOk) {
        try { Stop-Transcript | Out-Null } catch { }
    }
    exit $code
}""",
"""# ---- v17: auto-tee with a WRITABLE-location fallback -------------
# The v16 run found the trap: this script usually lives on the boot
# stick (D:), and phase-d.bat attaches that stick READ-ONLY on
# purpose (the 2026-09-20 FAT-corruption lesson). "Save beside the
# script" can never work there. v17 probes each candidate folder
# (beside script -> Desktop -> TEMP), uses the first WRITABLE one,
# and VERIFIES the file at the end.
$__teeOk = $false
$__log   = $null
$__logNote = ''
$__cands = @()
if ($PSScriptRoot) { $__cands += $PSScriptRoot }
try { $d = [Environment]::GetFolderPath('Desktop'); if ($d) { $__cands += $d } } catch { }
if ($env:TEMP) { $__cands += $env:TEMP }
foreach ($__d in $__cands) {
    $__probe = Join-Path $__d ("infinity-v17-probe-{0}.tmp" -f $PID)
    try {
        [System.IO.File]::WriteAllText($__probe, 'x')
        Remove-Item -LiteralPath $__probe -Force -ErrorAction SilentlyContinue
    } catch { continue }
    $__log = Join-Path $__d ("trigger-test-v17-output-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    try {
        Start-Transcript -Path $__log -ErrorAction Stop | Out-Null
        $__teeOk = $true
    } catch { $__teeOk = $false }
    if ($__teeOk) {
        Write-Host '[LOG] writable spot found - auto-saving all output to:'
        Write-Host "[LOG] $__log"
        if ($PSScriptRoot -and ($__d -ne $PSScriptRoot)) {
            Write-Host '[LOG] (the folder beside the script is READ-ONLY - the boot'
            Write-Host '[LOG]  stick is read-only by design - so the transcript lands'
            Write-Host '[LOG]  on a writable drive instead. Get it out of the VM with'
            Write-Host '[LOG]  the transfer stick + refresh-files.bat - see the end.)'
        }
        break
    }
}
if (-not $__teeOk) {
    Write-Host '[LOG] transcript unavailable - photo the screen as before'
}

function __Finish([int]$code) {
    if ($__teeOk) {
        try { Stop-Transcript | Out-Null } catch { }
    }
    exit $code
}""")

    # ------------------------------------------------ S3: banner
    t = edit(t, "S3-banner",
        "Write-Host '==== INFINITY trigger test v16 (dword fix + status decode + auto-tee) ===='",
        "Write-Host '==== INFINITY trigger test v17 (the data-path proof: H..N) ===='")

    # ------------------------------------------------ S3b: Add-Type abort message
    t = edit(t, "S3b-abort",
        "        Write-Host '[ABORT] Add-Type failed (unexpected). Send the output .txt.'",
        "        Write-Host '[ABORT] Add-Type failed (unexpected). Send the output .txt or a photo.'")

    # ------------------------------------------------ S4: data-path steps
    # inserted after step G (INFCNT read) and before the attribution block
    t = edit(t, "S4-data-steps", """# ============================================================
# attribution (null-safe: -1 means that read failed)""",
"""# ============================================================
# v17: THE DATA PATH - steps H..N (everything the real client
# Infinity.exe does for process memory, minus the emulator
# attach: payload transport, request/response round trips,
# kernel-target reads, a negative VA, INFCNT accounting).
# ============================================================
$KUSD_260 = 'FFFFF78000000260'                    # KUSER_SHARED_DATA + 0x260 (hex STRING - no PS literal trap)
$KUSD_308 = 'FFFFF78000000308'                    # KUSER_SHARED_DATA + 0x308 (v15/v16 field truth: reads 0)
$BAD_VA   = 'DEADBEEF00000000'                    # non-canonical VA (negative test)
$KP       = [Convert]::ToUInt32('FFFFFFFF', 16)    # KERNEL_TARGET_PID (the v17 driver addition)

function New-Req([uint32]$seq, [uint32]$op, [uint32]$pid, [uint32]$size, [string]$addrHex) {
    # 48-byte EfiVarReq: sequence, op, pid, data_size, address
    $r = New-Object byte[] 48
    [BitConverter]::GetBytes($seq).CopyTo($r, 0)
    [BitConverter]::GetBytes($op).CopyTo($r, 4)
    [BitConverter]::GetBytes($pid).CopyTo($r, 8)
    [BitConverter]::GetBytes($size).CopyTo($r, 12)
    if ($addrHex) { [BitConverter]::GetBytes([Convert]::ToUInt64($addrHex, 16)).CopyTo($r, 16) }
    return $r
}

function Send-Req([string]$Label, [byte[]]$req) {
    # write the request, read InfinityResp + InfinityData, decode, print
    $null = Write-Var 'InfinityReq' $req
    Start-Sleep -Milliseconds 400
    $rb = New-Object byte[] 64
    $rn = Read-EfiVar 'InfinityResp' $rb
    $seq = 0; $stat = 0; $xfer = 0; $statName = 'ABSENT'; $data = $null; $dataN = 0
    if ($rn -ge 32) {
        $seq  = U32 $rb 0
        $stat = U32 $rb 4
        $xfer = U64 $rb 8
        $statName = switch ($stat) {
            0 {'Pending'}    1 {'Success'}      2 {'ErrGeneric'}
            3 {'ErrTimeout'} 4 {'ErrAccess'}    5 {'ErrInvalid'}
            6 {'ErrNoBridge'} 7 {'ErrNotFound'} 8 {'ErrUnsupported'}
            default { "Unknown($stat)" }
        }
        Write-Host ("[{0}] resp: seq=0x{1:X}  status={2}({3})  bytes={4}" -f $Label, $seq, $stat, $statName, $xfer)
    } else {
        Write-Host "[$Label] resp: ABSENT (Win32=$LastErr)"
    }
    $db = New-Object byte[] 4096
    $dn = Read-EfiVar 'InfinityData' $db
    if ($dn -gt 0) {
        $data = ,$db[0..($dn-1)]
        $dataN = $dn
        $show = [Math]::Min($dn, 16)
        Write-Host ("[{0}] data: {1} bytes{2}: {3}" -f $Label, $dn,
            $(if ($dn -gt 16) {' (first 16)'} else {''}), (HexStr $db $show))
    } else {
        Write-Host "[$Label] data: none (0 bytes, Win32=$LastErr)"
    }
    return [pscustomobject]@{ seq = $seq; stat = $stat; statName = $statName;
                              xfer = $xfer; data = $data; dataN = $dataN }
}

# ---- step H: InfinityData write+read round trip (payload transport) ----
Write-Host ''
Write-Host '--- step H: InfinityData write+read round trip (the payload transport) ---'
$hPat = New-Object byte[] 32
for ($i = 0; $i -lt 32; $i++) { $hPat[$i] = [byte](($i * 7 + 11) % 251) }
[BitConverter]::GetBytes([uint32]0x1447).CopyTo($hPat, 0)
$null = Write-Var 'InfinityData' $hPat
Start-Sleep -Milliseconds 300
$hBack = Read-VarBack 'InfinityData'
$bufOk = $false
if ($null -ne $hBack -and $hBack.Length -eq 32) {
    $bufOk = $true
    for ($i = 0; $i -lt 32; $i++) { if ($hBack[$i] -ne $hPat[$i]) { $bufOk = $false; break } }
}
Write-Host ("     32-byte pattern echoed back byte-exact: {0}" -f $(if ($bufOk) {'YES - payload transport WORKS'} else {'NO'}))

# ---- step I: ReqOp_Attach attempt (expect ErrNotFound on the clean VM) ----
Write-Host ''
Write-Host '--- step I: ReqOp_Attach (op=7, pid=0 = any emulator process) ---'
$I = Send-Req 'I' (New-Req 0x1555 7 0 0 $null)
if ($I.stat -eq 7) {
    $attachTxt = 'ErrNotFound(7) - clean VM, no emulator running (correct decode)'
} elseif ($I.stat -eq 1) {
    $attachTxt = 'Success(1) - AN EMULATOR IS RUNNING (attach worked!)'
} else {
    $attachTxt = "status=$($I.stat)($($I.statName)) - see serial log"
}
Write-Host "     attach decode: $attachTxt"

# ---- step J: THE kernel read - KUSD+0x260 through the bridge ----
Write-Host ''
Write-Host '--- step J: kernel read KUSD+0x260 x4  (pid=FFFFFFFF = KERNEL target) ---'
$J = Send-Req 'J' (New-Req 0x1666 1 $KP 4 $KUSD_260)
$jBuild = -1
if ($J.stat -eq 1 -and $J.dataN -ge 4) { $jBuild = U32 $J.data 0 }
$osBuild2 = [Environment]::OSVersion.Version.Build
Write-Host ("     KUSD build dword VIA THE BRIDGE = {0}   (script-side = {1})" -f $jBuild, $osBuild2)
if ($jBuild -eq $osBuild2 -and $jBuild -gt 0) {
    Write-Host '     MATCH - the data path returned the live Windows build dword'
}

# ---- step K: kernel read KUSD+0x308 (field truth: 0) ----
Write-Host ''
Write-Host '--- step K: kernel read KUSD+0x308 x4  (v15/v16 field truth: 0) ---'
$K = Send-Req 'K' (New-Req 0x1777 1 $KP 4 $KUSD_308)
$kVal = -1
if ($K.stat -eq 1 -and $K.dataN -ge 4) { $kVal = U32 $K.data 0 }
Write-Host ("     KUSD+0x308 dword = {0}" -f $kVal)

# ---- step L: 8-byte chunk read (consistency with J) ----
Write-Host ''
Write-Host '--- step L: kernel read KUSD+0x260 x8  (chunk test; dword[0] must equal J) ---'
$L = Send-Req 'L' (New-Req 0x1888 1 $KP 8 $KUSD_260)
$l0 = -1; $l1 = -1
if ($L.stat -eq 1 -and $L.dataN -ge 8) { $l0 = U32 $L.data 0; $l1 = U32 $L.data 4 }
$chunkOk = ($l0 -eq $jBuild -and $jBuild -gt 0)
Write-Host ("     dword[0]={0} dword[1]=0x{1:X}  consistent with J: {2}" -f $l0, $l1,
    $(if ($chunkOk) {'YES'} else {'NO'}))

# ---- step M: NEGATIVE read - non-canonical VA (expect ErrAccess, no crash) ----
Write-Host ''
Write-Host '--- step M: kernel read NON-CANONICAL VA (expect ErrAccess(4), NO crash) ---'
$M = Send-Req 'M' (New-Req 0x1999 1 $KP 4 $BAD_VA)
$negOk = ($M.stat -eq 4)
Write-Host ("     negative-VA handling: {0}" -f $(if ($negOk) {
    'ErrAccess(4) cleanly - the page walk refused the bad address (safe by design)'
} else { "UNEXPECTED status=$($M.stat)($($M.statName)) - see serial log" }))

# ---- step N: final INFCNT (expect 8 = 2 baseline + 6 new protocol writes) ----
Write-Host ''
Write-Host '--- step N: final INFCNT read (live RAM count; expect 8 = 2 + H,I,J,K,L,M) ---'
$cnt2 = Read-VarBack 'INFCNT'
$cntFinal = -1
if ($null -ne $cnt2 -and $cnt2.Length -ge 4) { $cntFinal = U32 $cnt2 0 }

# ============================================================
# attribution (null-safe: -1 means that read failed)""")

    # ------------------------------------------------ S5: summary additions
    t = edit(t, "S5-summary", """Write-Host ("    NVRAM read-back: {0} - ABSENT is EXPECTED (v13+ consumes it in RAM)" -f $(if ($reqLanded) {'landed (UNEXPECTED)'} else {'absent'}))
Write-Host ("[5] InfinityResp PING         : {0}" -f $respTxt)""",
"""Write-Host ("    NVRAM read-back: {0} - ABSENT is EXPECTED (v13+ consumes it in RAM)" -f $(if ($reqLanded) {'landed (UNEXPECTED)'} else {'absent'}))
Write-Host ("[5] InfinityResp PING         : {0}" -f $respTxt)
$kernTxt = if ($jBuild -eq $osBuild2 -and $jBuild -gt 0) {
    "PROVEN - build {0} read through the bridge == script-side (payload + status complete)" -f $jBuild
} else {
    "read returned {0} (expected {1}) - see serial [RD] lines" -f $jBuild, $osBuild2
}
Write-Host ("[6] InfinityData buffer round trip : {0}" -f $(if ($bufOk) {'BYTE-EXACT (payload transport works)'} else {'FAILED (pattern mismatch)'}))
Write-Host ("[7] ReqOp_Attach decode            : {0}" -f $attachTxt)
Write-Host ("[8] Kernel read KUSD+0x260 (J)     : {0}" -f $kernTxt)
Write-Host ("[9] Negative VA handling (M)       : {0}" -f $(if ($negOk) {'ErrAccess cleanly, no crash (safe by design)'} else {"UNEXPECTED status=$($M.stat)"}))
Write-Host ("    INFCNT final = {0}   (8 = the 2 baseline writes + all 6 new protocol writes reached the hook)" -f $cntFinal)""")

    # ------------------------------------------------ S6: verdict
    t = edit(t, "S6-verdict", """Write-Host ''
Write-Host 'VERDICT:'
if ($respAnswered) {
    Write-Host '>>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<'
    Write-Host 'Windows -> UEFI runtime variable -> OUR HOOK -> processed -> response.'
    Write-Host 'v17 direction: data-bearing round trips (ReqOp_Read through the'
    Write-Host 'bridge) - the transport the real client (Infinity.exe) uses.'
} elseif ($readOk -and $writeOk) {""",
"""Write-Host ''
Write-Host 'VERDICT:'
$dataOk = ($bufOk -and ($jBuild -eq $osBuild2) -and ($jBuild -gt 0) -and $chunkOk)
if ($respAnswered -and $dataOk) {
    Write-Host '>>> DATA PATH PROVEN - FULL PROTOCOL COMPLETE <<<'
    Write-Host 'Windows -> InfinityReq(op,addr,size) -> OUR HOOK -> page-walk ->'
    Write-Host 'payload -> InfinityResp + InfinityData -> script. The EXACT'
    Write-Host 'transport Infinity.exe uses for process memory, proven live:'
    Write-Host ("build {0} was read out of KUSER_SHARED_DATA through the bridge." -f $jBuild)
    Write-Host 'v18 direction: attach to a real emulator process and read its'
    Write-Host 'memory through the bridge (production integration).'
} elseif ($respAnswered) {
    Write-Host '>>> FULL BRIDGE PROVEN (v16 result) <<< - but the data path'
    Write-Host 'did not return the expected dword. The serial log has the [RD]'
    Write-Host 'kern va / kern read ok lines - send output .txt + serial-phase-d.log.'
} elseif ($readOk -and $writeOk) {""")

    # ------------------------------------------------ S7: END banner + file verification
    t = edit(t, "S7-end", """Write-Host '==== END v16 ===='
if ($__teeOk) {
    Write-Host ''
    Write-Host "[LOG] output saved: $__log  (send this file back)"
    __Finish 0
}""",
"""Write-Host '==== END v17 ===='
if ($__teeOk -and $__log) {
    Write-Host ''
    $fileOk = $false
    try {
        if ((Test-Path -LiteralPath $__log) -and ((Get-Item -LiteralPath $__log -ErrorAction Stop).Length -gt 0)) { $fileOk = $true }
    } catch { }
    if ($fileOk) {
        Write-Host "[LOG] output saved and VERIFIED: $__log"
    } else {
        Write-Host "[LOG] WARNING: transcript file missing or empty: $__log"
        Write-Host '[LOG] photo the screen as a backup.'
    }
    Write-Host '[LOG] HOW TO GET THE .TXT OUT of the VM (no photos needed):'
    Write-Host '[LOG]   1. on YOUR machine: put any file for the VM into the'
    Write-Host '[LOG]      transfer folder and double-click refresh-files.bat'
    Write-Host '[LOG]      - a USB stick appears inside Windows'
    Write-Host '[LOG]   2. inside Windows: copy the .txt onto that stick'
    Write-Host '[LOG]   3. on YOUR machine: run refresh-files.bat again - the'
    Write-Host '[LOG]      file lands in the transfer folder. Send that file.'
    __Finish 0
}""")

    # stale-driver guard text (the frozen-note section mentions v16 twice)
    t = edit(t, "S8-frozen-note",
        """    Write-Host 'the read path truly bypasses the hook. First rule out a stale'
    Write-Host 'driver: phase-d.bat must have said "package v16" and the serial'
    Write-Host 'log must show "memory.efi v16 RT".'""",
        """    Write-Host 'the read path truly bypasses the hook. First rule out a stale'
    Write-Host 'driver: phase-d.bat must have said "package v17" and the serial'
    Write-Host 'log must show "memory.efi v17 RT".'""")

    # cleanup list gains InfinityData
    t = edit(t, "S9-cleanup",
        """Try-Del 'INFPROBE'
Try-Del 'INFTRIGGER'
Try-Del 'InfinityReq'
Try-Del 'InfinityResp'
Try-Del 'INFCNT'""",
        """Try-Del 'INFPROBE'
Try-Del 'INFTRIGGER'
Try-Del 'InfinityReq'
Try-Del 'InfinityResp'
Try-Del 'InfinityData'
Try-Del 'INFCNT'""")

    DST.write_text(t, encoding="utf-8", newline="\n")
    print(f"written: {DST} ({len(t.encode('utf-8'))} bytes)")


if __name__ == "__main__":
    main()
