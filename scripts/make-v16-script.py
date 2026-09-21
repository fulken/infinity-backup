#!/usr/bin/env python3
"""Derive trigger-test-v16.ps1 from trigger-test-v15.ps1 (anchored edits).

v16 = the v15 bridge (field-proven COMPLETE) + script-side truth fixes:

  1. DWORD PARSING FIX (the display bug class): PowerShell -shl on a
     BYTE returns a BYTE, so v15's U32() truncated every dword to its
     low byte -> win_build 19045 displayed "101", hook_calls 377
     displayed "121", resp seq 0x1337 displayed "0x37". The raw data
     was CORRECT the whole time. v16 parses with plain [uint32] math
     (no shift operators -> no type-truncation trap at all).
  2. E2 EXPECTATION FIX: status=1 IS SlotStatus_Success
     (SharedMemoryProtocol.h: 0=Pending 1=Success 2=ErrGeneric
     3=ErrTimeout 4=ErrAccess 5=ErrInvalid 6=ErrNoBridge
     7=ErrNotFound 8=ErrUnsupported). {seq echoed, status=1} is a
     PERFECT PONG. v16 decodes the status NAME. (The v15 verdict
     "WRONG-CONTENT status=1" was a false negative.)
  3. STEP [4] RELABEL: InfinityReq is RAM-consumed by design (v13+);
     an ABSENT NVRAM read-back is the EXPECTED result. Consumption
     is proven by INFCNT>=2 and/or the PONG.
  4. AUTO-TEE: Start-Transcript to a timestamped .txt beside the
     script; every exit path goes through __Finish which stops the
     transcript. No more photos - send the file.
  5. v16 banners, v17 direction pointers, reworded notes.

Anchors are EXACT v15 script text (restored from the shipped
infinity-qemu-test-v15.zip package). An anchor that does not match
exactly once = FAIL LOUD, nothing written.
"""
import sys
from pathlib import Path

SRC = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v15.ps1")
DST = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v16.ps1")


def edit(text, tag, old, new, count=1):
    n = text.count(old)
    if n != count:
        print(f"FATAL: anchor {tag}: found {n} (need {count})")
        sys.exit(1)
    return text.replace(old, new)


def main():
    t = SRC.read_text(encoding="utf-8-sig") if SRC.read_bytes()[:3] == b"\xef\xbb\xbf" else SRC.read_text()

    # ---- S1: header block ------------------------------------------------
    t = edit(t, "S1-header", """# ============================================================
# INFINITY trigger test v15  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v15 driver (infinity-qemu-test-v15 package).
# Running it against v9..v14 drivers gives WRONG verdicts or a
# BSOD - check that phase-d.bat printed "package v15" and the boot
# log says "memory.efi v15 RT".
#
# What v15 changed (the v14 BSOD, root-caused by disassembly):
#   - v14 CRASHED (KMODE_EXCEPTION) on step A - the first INFDIAG
#     read. The serial log truncated mid-hex-print. Root cause:
#     SerialTrace's hex formatter used 'static const char* k = ...'
#     - the compiler materialized it as a POINTER SLOT holding the
#     load-time (physical) address, never converted at the VA
#     event. The FIRST hex print from the Windows kernel context
#     dereferenced that stale address -> page fault. (The v12 BSOD
#     had the SAME signature - both logs truncate mid '=0x'.)
#     v15 turns the table into an ARRAY - rip-relative, safe in
#     every address space.
#   - The v14 KUSD read returned an implausible build: +0x308 is
#     NOT NtBuildNumber on live Win10 19045 x64 (the base repo's
#     constant was wrong). v15 probes BOTH candidate offsets
#     (0x260, 0x308), traces the RAW values on serial, and takes
#     the first plausible one. SUMMARY shows driver vs script
#     build side by side.
#   - Everything else from v14 is UNCHANGED (GUID fixes, RAM
#     serve, dual-write chain, PING step E).
#
# Step map:""", """# ============================================================
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
# Step map:""")

    # ---- S1b: stage note gains the status note ---------------------------
    t = edit(t, "S1b-stage-note", """# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (armed; live RAM state from the first read).
# ============================================================""",
             """# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (armed; live RAM state from the first read).
# status=1 (Success) on InfinityResp is the CORRECT PONG status.
# ============================================================""")

    # ---- S2: auto-tee block ----------------------------------------------
    t = edit(t, "S2-autotee", """$ErrorActionPreference = 'Continue'

$src = @'""",
             """$ErrorActionPreference = 'Continue'

# ---- v16: auto-tee - everything to a file next to this script ----
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
}

$src = @'""")

    # ---- S3: exit points -> __Finish --------------------------------------
    t = edit(t, "S3-exit-addtype", """        Write-Host '[ABORT] Add-Type failed (unexpected). Send a photo of this window.'
        Write-Host $_.Exception.Message
        exit 1""",
             """        Write-Host '[ABORT] Add-Type failed (unexpected). Send the output .txt.'
        Write-Host $_.Exception.Message
        __Finish 1""")
    t = edit(t, "S3-exit-priv", """    Write-Host '[ABORT] SeSystemEnvironmentPrivilege failed - run PowerShell as Administrator.'
    exit 1""",
             """    Write-Host '[ABORT] SeSystemEnvironmentPrivilege failed - run PowerShell as Administrator.'
    __Finish 1""")
    t = edit(t, "S3-exit-ab", """    Write-Host '[ABORT] INFDIAG unreadable - is the RT driver (usb-d) the one that booted?'
    exit 1""",
             """    Write-Host '[ABORT] INFDIAG unreadable - is the RT driver (usb-d) the one that booted?'
    __Finish 1""")
    t = edit(t, "S3-exit-packet", """    Write-Host '[ABORT] packet bytes wrong - refusing to send a broken ping. Send a photo.'
    exit 1""",
             """    Write-Host '[ABORT] packet bytes wrong - refusing to send a broken ping.'
    __Finish 1""")

    # ---- S4: banner --------------------------------------------------------
    t = edit(t, "S4-banner", "Write-Host '==== INFINITY trigger test v15 (hex-safe serial + kusd probe) ===='",
             "Write-Host '==== INFINITY trigger test v16 (dword fix + status decode + auto-tee) ===='")

    # ---- S5: U32 dword parsing fix -----------------------------------------
    t = edit(t, "S5-u32", """function U32([byte[]]$b, [int]$o) {
    return $b[$o] -bor ($b[$o+1] -shl 8) -bor ($b[$o+2] -shl 16) -bor ($b[$o+3] -shl 24)
}""",
             """function U32([byte[]]$b, [int]$o) {
    # v16 fix: PowerShell -shl on a BYTE returns a BYTE - the v15
    # parser truncated every dword to its low byte (19045 -> "101",
    # 0x1337 -> "0x37"). Plain [uint32] math, no shift operators.
    return ([uint32]$b[$o]) + ([uint32]$b[$o+1] * 256) + ([uint32]$b[$o+2] * 65536) + ([uint32]$b[$o+3] * 16777216)
}""")

    # ---- S6: step A/B note ---------------------------------------------------
    t = edit(t, "S6-abnote", """Write-Host '       v15: reads are answered LIVE from RAM by the hook and the'
Write-Host '       hex printer is VA-safe now, so B must be A+1 or more if the'
Write-Host '       read path works.'""",
             """Write-Host '       v16: reads are answered LIVE from RAM by the hook (the'
Write-Host '       bridge is field-proven since v15), so B must be A+1 or'
Write-Host '       more if the read path works.'""")

    # ---- S7: E2 status decode ------------------------------------------------
    t = edit(t, "S7-e2-decode", """    $rseq  = U32 $rbuf 0
    $rstat = U32 $rbuf 4
    $rxfer = U64 $rbuf 8
    $raddr = U64 $rbuf 16
    Write-Host ("     sequence=0x{0:X}  status={1}  bytes_transferred={2}  out_address=0x{3:X}" -f $rseq, $rstat, $rxfer, $raddr)
    if ($rseq -eq 0x1337 -and $rstat -eq 1) {
        $respAnswered = $true
        $respTxt = "ANSWERED seq=0x1337 status=1"
    } else {
        $respTxt = "WRONG-CONTENT seq=0x$($rseq.ToString('X')) status=$rstat"
    }""",
             """    $rseq  = U32 $rbuf 0
    $rstat = U32 $rbuf 4
    $rxfer = U64 $rbuf 8
    $raddr = U64 $rbuf 16
    # v16: decode the SlotStatus enum (SharedMemoryProtocol.h):
    # 0=Pending 1=Success 2=ErrGeneric 3=ErrTimeout 4=ErrAccess
    # 5=ErrInvalid 6=ErrNoBridge 7=ErrNotFound 8=ErrUnsupported.
    # status=1 IS Success - {seq echoed, status=1} is a PERFECT
    # PONG (the v15 verdict misread this as a failure).
    $statName = switch ($rstat) {
        0 {'Pending'}    1 {'Success'}      2 {'ErrGeneric'}
        3 {'ErrTimeout'} 4 {'ErrAccess'}    5 {'ErrInvalid'}
        6 {'ErrNoBridge'} 7 {'ErrNotFound'} 8 {'ErrUnsupported'}
        default { "Unknown($rstat)" }
    }
    Write-Host ("     sequence=0x{0:X}  status={1}({2})  bytes_transferred={3}  out_address=0x{4:X}" -f $rseq, $rstat, $statName, $rxfer, $raddr)
    if ($rseq -eq 0x1337 -and $rstat -eq 1) {
        $respAnswered = $true
        $respTxt = "ANSWERED seq=0x1337 status=1(Success) - PONG PERFECT"
    } else {
        $respTxt = "WRONG-CONTENT seq=0x$($rseq.ToString('X')) status=$rstat($statName)"
    }""")

    # ---- S8: consumption evidence (before SUMMARY) ---------------------------
    t = edit(t, "S8-consumption", """$drvBuild = -1
if ($null -ne $A) { $drvBuild = [int]$A.build }
$osBuild  = [Environment]::OSVersion.Version.Build

Write-Host ''
Write-Host '==== SUMMARY (photo this block) ===='""",
             """$drvBuild = -1
if ($null -ne $A) { $drvBuild = [int]$A.build }
$osBuild  = [Environment]::OSVersion.Version.Build

# v16: under the v13+ RAM-consume design the driver consumes
# InfinityReq in RAM - the NVRAM read-back is EXPECTED to be ABSENT.
# Consumption evidence: INFCNT counted it (>= 2) and/or the PONG.
$reqConsumed = ($cntVal -ge 2) -or $respAnswered
$reqHow = if ($respAnswered) {'PONG proves it'}
          elseif ($cntVal -ge 2) {'INFCNT counted it'}
          else {'no evidence'}

Write-Host ''
Write-Host '==== SUMMARY (auto-saved to the output .txt) ===='""")

    # ---- S9: [4] relabel -------------------------------------------------------
    t = edit(t, "S9-step4", """Write-Host ("[4] InfinityReq landed, op ok : {0}" -f $(if ($reqLanded) {'YES'} else {'NO'}))""",
             """Write-Host ("[4] InfinityReq consumed (RAM) : {0} ({1})" -f $(if ($reqConsumed) {'YES'} else {'NO'}), $reqHow)
Write-Host ("    NVRAM read-back: {0} - ABSENT is EXPECTED (v13+ consumes it in RAM)" -f $(if ($reqLanded) {'landed (UNEXPECTED)'} else {'absent'}))""")

    # ---- S10: verdict branches ---------------------------------------------------
    t = edit(t, "S10-fullbridge", """if ($respAnswered) {
    Write-Host '>>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<'
    Write-Host 'Windows -> UEFI runtime variable -> OUR HOOK -> processed -> response.'""",
             """if ($respAnswered) {
    Write-Host '>>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<'
    Write-Host 'Windows -> UEFI runtime variable -> OUR HOOK -> processed -> response.'
    Write-Host 'v17 direction: data-bearing round trips (ReqOp_Read through the'
    Write-Host 'bridge) - the transport the real client (Infinity.exe) uses.'""")
    t = edit(t, "S10-directions", "Write-Host 'v16 direction: shared-memory pool transport for Infinity.exe'",
             "Write-Host 'v17 direction: shared-memory pool transport for Infinity.exe'",
             count=2)
    t = edit(t, "S10-direction-b", "Write-Host 'v16 direction: serve responses through a REAL NVRAM variable the'",
             "Write-Host 'v17 direction: serve responses through a REAL NVRAM variable the'")
    t = edit(t, "S10-send-lines", "    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'",
             "    Write-Host 'Send the output .txt + serial-phase-d.log.'", count=4)

    # ---- S11: frozen note -------------------------------------------------------
    t = edit(t, "S11-frozen", """    Write-Host 'NOTE: hook_calls frozen across ALL steps. With the v15 fixes'
    Write-Host 'this now means the read path truly bypasses the hook. First rule'
    Write-Host 'out a stale driver: phase-d.bat must have said "package v15" and'
    Write-Host 'the serial log must show "memory.efi v15 RT".'""",
             """    Write-Host 'NOTE: hook_calls frozen across ALL steps. Since v15 this means'
    Write-Host 'the read path truly bypasses the hook. First rule out a stale'
    Write-Host 'driver: phase-d.bat must have said "package v16" and the serial'
    Write-Host 'log must show "memory.efi v16 RT".'""")

    # ---- S12: build note + END banner + transcript stop ---------------------------
    t = edit(t, "S12-build-note", """    Write-Host 'NOTE: driver-side win_build still 0 - the KUSD probe found no'
    Write-Host 'plausible value at either candidate offset. Send the photo +'
    Write-Host 'serial-phase-d.log so we can read the [BLD] kusd raw 0x260/0x308'
    Write-Host 'lines and pin the real offset.'""",
             """    Write-Host 'NOTE: driver-side win_build still 0 - the probe worked in v15'
    Write-Host '(KUSD+0x260 = 19045, offset settled), so a zero here means no'
    Write-Host 'INFDIAG read reached the hook this run. Send the output .txt +'
    Write-Host 'serial-phase-d.log.'""")
    t = edit(t, "S12-end", """Write-Host '==== END v15 ===='""",
             """Write-Host '==== END v16 ===='
if ($__teeOk) {
    Write-Host ''
    Write-Host "[LOG] output saved: $__log  (send this file back)"
    __Finish 0
}""")

    # ---- final sanity ---------------------------------------------------------
    for probe in ("trigger test v16", "END v16", "v17 direction", "dword fix + status decode + auto-tee",
                  "[uint32]$b[$o]", "ErrNoBridge", "Start-Transcript", "trigger-test-v16-output-",
                  "__Finish", "status=1(Success)", "ABSENT is EXPECTED"):
        if probe not in t:
            print(f"FATAL: post-check - '{probe}' missing")
            sys.exit(1)
    if "exit 1" in t:
        print("FATAL: a bare 'exit 1' survived (must go through __Finish)")
        sys.exit(1)
    if "photo this block" in t:
        print("FATAL: stale 'photo this block' instruction survived")
        sys.exit(1)
    leftovers = [l for l in t.splitlines()
                 if "v15" in l
                 and "against v9..v15" not in l
                 and "field-proven since v15" not in l
                 and "worked in v15" not in l
                 and "Since v15" not in l
                 and "the v15 verdict" not in l
                 and "v15 verdict was a script bug" not in l
                 and "the v15" not in l
                 and "v15 parser truncated" not in l
                 and "v15 report said" not in l
                 and "COMPLETED the full bridge" not in l]
    if leftovers:
        print("FATAL: unintended v15 leftovers:")
        for l in leftovers[:10]:
            print("   ", l.strip()[:100])
        sys.exit(1)

    DST.write_text(t, encoding="utf-8")
    print(f"OK: {DST} written ({len(t.encode('utf-8'))} bytes, {len(t.splitlines())} lines)")


if __name__ == "__main__":
    main()
