#!/usr/bin/env python3
# ============================================================================
# patch-v24.py — trigger-test-v23.ps1 -> trigger-test-v24.ps1
#
# v24 = v23 + THE F1 PROOF STEPS (K + L1..L5). Driver = v19 (the F1
# anchor build, memory.efi v19 RT 125450 bytes). The J1..J7 ladder is
# kept BYTE-IDENTICAL as a full v23 regression (same seq numbers
# 0x1601..0x1607, same addresses, same expectations).
#
# NEW STEPS:
#   K    ReqOp_Anchors (op=9): asks the driver to run SIDT + IDT#PF/#BP
#        + LSTAR + 3 walk-backs + PE validation + containment
#        (fail-closed). 32-byte payload: state, reason, pe_base,
#        pe_size, idt_base. status=Success => CONVERGED (range opens).
#   L1   read @pe_base len=4          -> must be 4D 5A ('MZ')
#   L2a  read @pe_base+0x3C len=4     -> e_lfanew (0x40..0x1000)
#   L2b  read @pe_base+e_lfanew len=0x58 -> 'PE\0\0' + machine 0x8664 +
#        entry RVA @0x28 + SizeOfImage @0x50 (MUST equal the payload's
#        pe_size — the transport double-validates the driver's range)
#   L3   read @pe_base+entryRVA len=8 -> real kernel entry code bytes
#   L4   read @pe_base-0x1000 len=4   -> NEGATIVE: ErrAccess(4) (below)
#   L5   read @pe_base+pe_size len=4  -> NEGATIVE: ErrAccess(4) (above)
#        (if anchors FAIL-CLOSED: L1..L3 skip; L4/L5 still run at a
#        fixed kernel VA and MUST be rejected — the gate stays closed)
#
# INFCNT: v23 expected G+8; v24 expects G+8+anSent (K + L sends).
#
# Usage: python3 scripts/patch-v24.py
#   reads  infinity-qemu-test/trigger-test-v23.ps1
#   writes infinity-qemu-test/trigger-test-v24.ps1
# ============================================================================
import sys, pathlib

BASE = pathlib.Path(__file__).resolve().parent.parent
SRC = BASE / "infinity-qemu-test" / "trigger-test-v23.ps1"
DST = BASE / "infinity-qemu-test" / "trigger-test-v24.ps1"


def main():
    src = SRC.read_text(encoding="utf-8")
    n_edits = 0

    def rep(old, new, tag):
        nonlocal src, n_edits
        if src.count(old) != 1:
            print(f"  FAIL {tag}: anchor found {src.count(old)}x (want 1)")
            sys.exit(1)
        src = src.replace(old, new)
        n_edits += 1
        print(f"  {tag}: OK")

    # ------------------------------------------------------------------
    # R1: v24 header block (stacked after the v23 header, house style)
    # ------------------------------------------------------------------
    rep("""# ============================================================

$ErrorActionPreference = 'Continue'""",
        """# ============================================================
# INFINITY bridge trigger test v24  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v24 = v23 + THE F1 PROOF STEPS. REQUIRES the v19 driver stick
# (memory.efi v19 RT - "anchors + validated image reads", 125450
# bytes). The v19 driver = the field-proven v18 + KernelAnchor.h:
# SIDT + anchor stack + 4 converging validators, FAIL-CLOSED.
#
# NEW STEPS (before the J-ladder, which is kept IDENTICAL as a
# full v23 regression):
#   K   ReqOp_Anchors (op=9): the driver runs the discovery once -
#       SIDT -> IDT #PF/#BP handler VAs -> IA32_LSTAR MSR -> three
#       independent 64KB-step walk-backs to the image base (32MB
#       bound, 'MZ' probes, full PE validation at every candidate)
#       - all three walks must AGREE, the PE header must be fully
#       valid, and all three anchor VAs must lie INSIDE the image
#       (containment). ANY failure = FAIL-CLOSED: the gate stays
#       KUSD-only for the whole boot and L1..L3 are skipped.
#   L1  read @pe_base len=4       -> expect 4D 5A 00 00 ('MZ')
#   L2a read @pe_base+0x3C len=4  -> e_lfanew (0x40..0x1000)
#   L2b read @pe_base+lfanew len=0x58 -> expect 'PE\0\0' + machine
#       0x8664 + entry RVA + SizeOfImage == the payload's pe_size
#       (the transport double-validates the driver's range!)
#   L3  read @pe_base+entryRVA len=8 -> real kernel entry bytes
#   L4  read @pe_base-0x1000      -> NEGATIVE: ErrAccess(4) below
#   L5  read @pe_base+pe_size     -> NEGATIVE: ErrAccess(4) above
# If K fails closed, L4/L5 still run at a fixed kernel VA and
# MUST be rejected - proof the gate never opens without anchors.
#
# EXPECTED with the v19 driver on a healthy boot:
#   K  Success + state=1 reason=0 + real pe_base/pe_size/idt_base
#   L1 Success + 4D 5A;  L2 Success + PE sig + size match;  L3 8 bytes
#   L4/L5 ErrAccess(4), no crash   J1..J7 exactly as v23 (regression)
#   N  INFCNT = G+8+7 = G+15 when converged (K,L1,L2a,L2b,L3,L4,L5)
#      or G+8+3 when fail-closed (K,L4,L5)
# ============================================================

$ErrorActionPreference = 'Continue'""",
        "R1-v24-header")

    # ------------------------------------------------------------------
    # R2: transcript filename v23 -> v24
    # ------------------------------------------------------------------
    rep('trigger-test-v23-output-', 'trigger-test-v24-output-', "R2-transcript-name")

    # ------------------------------------------------------------------
    # R3: banner
    # ------------------------------------------------------------------
    rep("==== INFINITY trigger test v23 (v18 driver: direct KUSD reads - the proof ladder J1..J7) ====",
        "==== INFINITY trigger test v24 (v19 driver: anchors - the F1 proof ladder K,L + J regression) ====",
        "R3-banner")

    # ------------------------------------------------------------------
    # R4: self-test — the F1 constants must round-trip (MZ, PE, a
    #     canonical kernel base through U64)
    # ------------------------------------------------------------------
    rep("""ST-Check $stOk2 'New-Req user alias 000000007FFE0260 -> bytes 60 02 FE 7F 00 00 00 00 (the v22 slip, never again)'""",
        """ST-Check $stOk2 'New-Req user alias 000000007FFE0260 -> bytes 60 02 FE 7F 00 00 00 00 (the v22 slip, never again)'
$stb[0] = 0x4D; $stb[1] = 0x5A; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]0x00005A4D) 'U32 4D 5A 00 00 must be 0x5A4D (the MZ dword - the L1 expectation)'
$stb[0] = 0x50; $stb[1] = 0x45
ST-Check ((U32 $stb 0) -eq [uint32]0x00004550) 'U32 50 45 00 00 must be 0x4550 (the PE dword - the L2 expectation)'
$stU64 = New-Object byte[] 8
$stU64[0] = 0x00; $stU64[1] = 0x00; $stU64[2] = 0x10; $stU64[3] = 0x80
$stU64[4] = 0xFF; $stU64[5] = 0xFF; $stU64[6] = 0xFF; $stU64[7] = 0xFF
ST-Check ((U64 $stU64 0) -eq [uint64]18446603336489631744) 'U64 must parse a canonical kernel base 0xFFFF800010000000 (DECIMAL literal - the v21 hex-cast trap class)'
ST-Check (([uint64]18446603336489631744 + [uint64]0x400000) -gt [uint64]18446603336489631744) 'uint64 range math (validated-range end must not wrap)'""",
        "R4-selftest-f1")

    # ------------------------------------------------------------------
    # R5: step K + L1..L5 (inserted after the InfinityData hygiene,
    #     before the J-ladder comment block)
    # ------------------------------------------------------------------
    rep("""# ============================================================
# [11] THE DIRECT-READ LADDER - J1..J7 (v18 driver semantics)""",
        """# ============================================================
# [11a] F1 STEP K: ReqOp_Anchors (op=9) - the anchor discovery
#       (SIDT + IDT + LSTAR + walk-backs + validators, fail-closed)
# ============================================================
Write-Host ''
Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery ---'
Write-Host '      status=1(Success) => CONVERGED: the validated image range unlocks (L1..L3).'
Write-Host '      status=4(ErrAccess) => FAIL-CLOSED: gate stays KUSD-only (L1..L3 skip; L4/L5 still run).'
Canary 'pre-K'
$K = $null
try { $K = Send-Req (New-Req 0x1701 9 '00000000' 32 '0000000000000000' $null) }
catch { Write-Host "[!] step K threw: $($_.Exception.Message)" }
$anState = -1; $anReason = -1
$peBase = [uint64]0; $peSize = [uint64]0; $anIdt = [uint64]0
if ($null -ne $K -and $null -ne $K.Data -and $K.Data.Length -ge 32) {
    $anState  = U32 $K.Data 0
    $anReason = U32 $K.Data 4
    $peBase   = U64 $K.Data 8
    $peSize   = U64 $K.Data 16
    $anIdt    = U64 $K.Data 24
}
$anSent = 1
$anOk = ($anState -eq 1)
if ($anState -ge 0) {
    Write-Host ("     [K] payload: state={0} reason={1} pe_base=0x{2:X} pe_size=0x{3:X} idt_base=0x{4:X}" -f $anState, $anReason, $peBase, $peSize, $anIdt)
} else {
    Write-Host '     [K] NO PAYLOAD (no response / no data) - treat as fail-closed'
}
if ($anOk) {
    Write-Host ("     [K] >>> ANCHORS CONVERGED - validated range [0x{0:X}, 0x{1:X}) UNLOCKED <<<" -f $peBase, ($peBase + $peSize))
} else {
    Write-Host '     [K] FAIL-CLOSED (reason above) - L1..L3 SKIPPED, L4/L5 run at a fixed VA'
}

# ---- L1: the validated image must start with 'MZ' ----
Write-Host ''
Write-Host '--- step L1: read @pe_base len=4 - the MZ signature ---'
$mzOk = $false; $L1 = $null
if ($anOk) {
    Canary 'pre-L1'
    try { $L1 = Send-Req (New-Req 0x1702 1 'FFFFFFFF' 4 ('{0:X16}' -f $peBase) $null) }
    catch { Write-Host "[!] L1 threw: $($_.Exception.Message)" }
    if ($null -ne $L1 -and $null -ne $L1.Resp -and $L1.Status -eq 1 -and $null -ne $L1.Data -and $L1.Data.Length -ge 2) {
        $mzOk = ($L1.Data[0] -eq 0x4D -and $L1.Data[1] -eq 0x5A)
    }
    $anSent++
    if ($mzOk) { Write-Host '     [L1] PASS: 4D 5A = MZ - the validated image header came back through the gate' }
    else       { Write-Host '     [L1] FAIL: no MZ (see raw above + serial [AN]/[RD])' }
} else { Write-Host '     [L1] SKIPPED (anchors not converged)' }

# ---- L2a: e_lfanew ----
Write-Host ''
Write-Host '--- step L2a: read @pe_base+0x3C len=4 - e_lfanew ---'
$lfanew = -1; $L2a = $null
if ($anOk) {
    Canary 'pre-L2a'
    try { $L2a = Send-Req (New-Req 0x1703 1 'FFFFFFFF' 4 ('{0:X16}' -f ($peBase + [uint64]0x3C)) $null) }
    catch { Write-Host "[!] L2a threw: $($_.Exception.Message)" }
    if ($null -ne $L2a -and $L2a.Status -eq 1 -and $null -ne $L2a.Data -and $L2a.Data.Length -ge 4) {
        $lfanew = U32 $L2a.Data 0
    }
    $anSent++
    if ($lfanew -ge 0x40 -and $lfanew -le 0x1000) { Write-Host ("     [L2a] PASS: e_lfanew=0x{0:X} (in range)" -f $lfanew) }
    else { Write-Host ("     [L2a] FAIL: e_lfanew={0} (expect 0x40..0x1000)" -f $lfanew) }
} else { Write-Host '     [L2a] SKIPPED (anchors not converged)' }

# ---- L2b: the PE header block (0x58 bytes: sig, machine, entry, size) ----
Write-Host ''
Write-Host '--- step L2b: read @pe_base+e_lfanew len=0x58 - the PE header block ---'
$peOk = $false; $sizeMatch = $false; $epRva = -1; $L2b = $null
if ($anOk -and $lfanew -ge 0x40) {
    Canary 'pre-L2b'
    try { $L2b = Send-Req (New-Req 0x1704 1 'FFFFFFFF' 0x58 ('{0:X16}' -f ($peBase + [uint64]$lfanew)) $null) }
    catch { Write-Host "[!] L2b threw: $($_.Exception.Message)" }
    if ($null -ne $L2b -and $L2b.Status -eq 1 -and $null -ne $L2b.Data -and $L2b.Data.Length -ge 0x58) {
        $sigOk  = ($L2b.Data[0] -eq 0x50 -and $L2b.Data[1] -eq 0x45 -and $L2b.Data[2] -eq 0x00 -and $L2b.Data[3] -eq 0x00)
        $machOk = ((U32 $L2b.Data 4) -band [uint32]0xFFFF) -eq [uint32]0x8664
        $epRva    = U32 $L2b.Data 0x28
        $sizeImg  = U32 $L2b.Data 0x50
        $sizeMatch = ([uint64]$sizeImg -eq $peSize)
        $epOkR     = ($epRva -gt 0 -and [uint64]$epRva -lt $peSize)
        $peOk = ($sigOk -and $machOk -and $epOkR)
        Write-Host ("     [L2b] sig PE\\0\\0={0}  machine AMD64={1}  entry RVA=0x{2:X}  SizeOfImage=0x{3:X}" -f $sigOk, $machOk, $epRva, $sizeImg)
        if ($sizeMatch) { Write-Host '     [L2b] PASS + SizeOfImage == the anchor payload pe_size (transport double-validates the range)' }
        else            { Write-Host '     [L2b] FAIL: header SizeOfImage != payload pe_size - send everything' }
    }
    $anSent++
} else { Write-Host '     [L2b] SKIPPED (anchors not converged / no e_lfanew)' }

# ---- L3: real kernel entry code bytes ----
Write-Host ''
Write-Host '--- step L3: read @pe_base+entryRVA len=8 - real kernel code bytes ---'
$epOk = $false; $L3 = $null
if ($anOk -and $epRva -gt 0) {
    Canary 'pre-L3'
    try { $L3 = Send-Req (New-Req 0x1705 1 'FFFFFFFF' 8 ('{0:X16}' -f ($peBase + [uint64]$epRva)) $null) }
    catch { Write-Host "[!] L3 threw: $($_.Exception.Message)" }
    if ($null -ne $L3 -and $L3.Status -eq 1 -and $null -ne $L3.Data -and $L3.Data.Length -ge 8) {
        $nonzero = $false
        foreach ($b in $L3.Data[0..7]) { if ($b -ne 0) { $nonzero = $true; break } }
        $epOk = $nonzero
        $hx = ($L3.Data[0..7] | ForEach-Object { $_.ToString('X2') }) -join ' '
        if ($epOk) { Write-Host "     [L3] PASS: 8 entry-point bytes back: $hx" }
        else       { Write-Host '     [L3] FAIL: all-zero bytes (implausible for an entry point)' }
    }
    $anSent++
} else { Write-Host '     [L3] SKIPPED (no validated entry RVA)' }

# ---- L4/L5: the gate must stay CLOSED outside the validated range ----
Write-Host ''
Write-Host '--- steps L4/L5: gate negatives (below and above the validated range) ---'
$l4AddrStr = 'FFFFF80002000000'; $l4Txt = 'fixed kernel VA (fail-closed mode)'
if ($anOk) {
    $l4AddrStr = '{0:X16}' -f ($peBase - [uint64]0x1000)
    $l4Txt = 'pe_base-0x1000 (below the range)'
}
Canary 'pre-L4'
$L4 = $null
try { $L4 = Send-Req (New-Req 0x1706 1 'FFFFFFFF' 4 $l4AddrStr $null) }
catch { Write-Host "[!] L4 threw: $($_.Exception.Message)" }
$anSent++
$l4Ok = ($null -ne $L4 -and $L4.Status -eq 4)
if ($l4Ok) { Write-Host "     [L4] PASS: $l4Txt rejected ErrAccess(4) - gate closed below" }
else       { Write-Host "     [L4] FAIL: status=$($L4.Status) (expect 4) - see serial" }
$l5AddrStr = 'FFFFF80004000000'; $l5Txt = 'fixed kernel VA (fail-closed mode)'
if ($anOk) {
    $l5AddrStr = '{0:X16}' -f ($peBase + $peSize)
    $l5Txt = 'pe_base+pe_size (above the range)'
}
Canary 'pre-L5'
$L5 = $null
try { $L5 = Send-Req (New-Req 0x1707 1 'FFFFFFFF' 4 $l5AddrStr $null) }
catch { Write-Host "[!] L5 threw: $($_.Exception.Message)" }
$anSent++
$l5Ok = ($null -ne $L5 -and $L5.Status -eq 4)
if ($l5Ok) { Write-Host "     [L5] PASS: $l5Txt rejected ErrAccess(4) - gate closed above" }
else       { Write-Host "     [L5] FAIL: status=$($L5.Status) (expect 4) - see serial" }
$lNegTxt = if ($l4Ok -and $l5Ok) { 'OK - both outside-range reads rejected ErrAccess(4), no crash' } else { 'FAILED - a read outside the range was NOT rejected (see L4/L5 + serial)' }

# ============================================================
# [11] THE DIRECT-READ LADDER - J1..J7 (v18 driver semantics)""",
        "R5-KL-steps")

    # ------------------------------------------------------------------
    # R6: decision-table driver-size note (v18 -> v19)
    # ------------------------------------------------------------------
    rep("Check usb-d\\memory.efi size: v18-RT = 121253 bytes.",
        "Check usb-d\\memory.efi size: v19-RT = 125450 bytes.",
        "R6-decision-note")

    # ------------------------------------------------------------------
    # R7: ladder warning comment (driver size check)
    # ------------------------------------------------------------------
    rep("phase-d.bat checks memory.efi size 121253.",
        "phase-d.bat checks memory.efi size 125450 (v19-RT).",
        "R7-warning-note")

    # ------------------------------------------------------------------
    # R8: step N expectation text
    # ------------------------------------------------------------------
    rep("Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8: H +1 and J1..J7 +7) ---'",
        "Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+anchors: H +1, J1..J7 +7, K/L requests) ---'",
        "R8-stepN-text")

    # ------------------------------------------------------------------
    # R9: summary — the F1 lines + the INFCNT expectation formula
    # ------------------------------------------------------------------
    rep("""Write-Host ("[9] Negatives (J6 gate, J7 no-attach) : {0}" -f $negTxt)""",
        """Write-Host ("[9] Negatives (J6 gate, J7 no-attach) : {0}" -f $negTxt)
if ($anOk) {
    Write-Host ("[10] F1 anchors (K) : CONVERGED - pe_base=0x{0:X} pe_size=0x{1:X} idt_base=0x{2:X}" -f $peBase, $peSize, $anIdt)
    Write-Host ("[11] Validated-image reads (L1..L3) : MZ={0} PE-sig+machine={1} size-match={2} entry-bytes={3}" -f $mzOk, $peOk, $sizeMatch, $epOk)
} else {
    Write-Host ("[10] F1 anchors (K) : FAIL-CLOSED (state={0} reason={1}) - the gate stayed KUSD-only" -f $anState, $anReason)
    Write-Host '     [11] Validated-image reads (L1..L3) : SKIPPED (fail-closed)'
}
Write-Host ("[12] Range negatives (L4 below, L5 above) : {0}" -f $lNegTxt)""",
        "R9-summary-f1")
    rep("""Write-Host ("    INFCNT final = {0}   (expect G+8 = {1}: H's InfinityData write (+1) and the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 } else { '?' }))
Write-Host '     7 ladder InfinityReq writes (+7); requests are consumed in RAM and deletes never count)'""",
        """Write-Host ("    INFCNT final = {0}   (expect G+8+{4} = {1}: H's InfinityData write (+1), the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 + $anSent } else { '?' }), '', '', '', $anSent)
Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor requests (+anSent); requests are consumed in RAM and deletes never count)'""",
        "R9b-infcnt-final")

    # ------------------------------------------------------------------
    # R10: verdict — the F1 block
    # ------------------------------------------------------------------
    rep("""} else {
    Write-Host '>>> BRIDGE REGRESSION (PING or payload transport failed). <<<'
    Write-Host 'Send output .txt + serial-phase-d.log.'
}""",
        """} else {
    Write-Host '>>> BRIDGE REGRESSION (PING or payload transport failed). <<<'
    Write-Host 'Send output .txt + serial-phase-d.log.'
}
Write-Host ''
$f1Ok = $anOk -and $mzOk -and $peOk -and $sizeMatch -and $epOk -and ($lNegTxt -like 'OK*')
if ($f1Ok) {
    Write-Host '>>> F1 PROVEN: ANCHORS CONVERGED + VALIDATED-IMAGE READS VIA REQUESTS <<<'
    Write-Host ("SIDT -> IDT/LSTAR -> walk-backs -> 4 validators -> gate opened [0x{0:X}, 0x{1:X}) ->" -f $peBase, ($peBase + $peSize))
    Write-Host 'real kernel bytes came back (MZ, PE header, entry code) and the gate'
    Write-Host 'stayed CLOSED one page below and one byte above. Fail-closed works.'
} elseif ($anOk) {
    Write-Host '>>> F1 PARTIAL: anchors converged but a validated read or negative failed. <<<'
    Write-Host 'Send output .txt + serial-phase-d.log (every [AN]/[RD] line matters).'
} else {
    Write-Host '>>> F1 FAIL-CLOSED (the gate never opened). The ladder regression below still counts. <<<'
    Write-Host 'Serial [AN] lines name the exact reason - send them + the output .txt.'
}""",
        "R10-verdict-f1")

    # ------------------------------------------------------------------
    # R11: END marker
    # ------------------------------------------------------------------
    rep("==== END v23 ====", "==== END v24 ====", "R11-end-marker")

    # ------------------------------------------------------------------
    # sanity
    # ------------------------------------------------------------------
    for good in [
        "trigger test v24", "==== INFINITY trigger test v24", "==== END v24 ====",
        "ReqOp_Anchors (op=9)", "0x1701", "New-Req 0x1706", "lNegTxt",
        "F1 PROVEN", "trigger-test-v24-output-", "125450",
    ]:
        if good not in src:
            print(f"  FAIL sanity: '{good}' missing")
            sys.exit(1)
    # runtime markers must not say v23 anywhere OUTSIDE the stacked headers
    import re
    runtime = src.split("$ErrorActionPreference = 'Continue'", 1)[1]
    for bad in ["trigger test v23", "END v23", "v23-output", "expect G+8: H +1"]:
        if bad in runtime:
            print(f"  FAIL sanity: stale runtime string '{bad}'")
            sys.exit(1)
    # the J-ladder must be untouched (regression): same 7 seq constants,
    # each exactly once (in the ladder array)
    for seq in ["0x1601", "0x1602", "0x1603", "0x1604", "0x1605", "0x1606", "0x1607"]:
        if src.count(seq) != 1:
            print(f"  FAIL sanity: ladder seq {seq} count={src.count(seq)} (expect 1)")
            sys.exit(1)
    if src.count("'000000007FFE0260'") != 4:   # selftest + J1/J5/J7 rungs
        print("  FAIL sanity: user-alias addresses disturbed (expect 4)")
        sys.exit(1)

    DST.write_text(src, encoding="utf-8")
    print(f"[patch-v24] ALL {n_edits} EDITS APPLIED")
    print(f"[patch-v24] wrote {DST} ({len(src)} bytes)")


if __name__ == "__main__":
    main()
