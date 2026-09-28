#!/usr/bin/env python3
# ============================================================================
# make-v28.py — trigger-test-v27.ps1 -> trigger-test-v28.ps1 (F2 proper)
#
# WHAT v28 ADDS (the v21 driver is REQUIRED - memory.efi v21 RT,
# "anchors + exports", 131709 bytes):
#   STEP M (op=10 ReqOp_ResolveSymbol) — the F2 export-resolution
#   proof, conditional on K converged (exactly like L1..L3):
#     M1 resolve "PsInitialSystemProcess" (the F3 EPROCESS-walk
#        entry) -> expect Success + found=1 + resolved_va INSIDE
#        [pe_base, pe_base+pe_size) + pe_base/pe_size echoes exact
#     M2 resolve "NtBuildNumber" -> then op-1 READ 4 bytes at the
#        resolved VA -> the dword (masked 0x7FFFFFFF) MUST equal
#        19045 — the export-resolved data cross-validates against
#        the KUSD ground truth J1 already proved
#     M3 resolve "KeBugCheckEx" -> then op-1 READ 8 bytes -> real
#        kernel code bytes via the export table (printed, non-zero)
#     M4 resolve "NoSuchSymbolV28" -> expect status=7 ErrNotFound
#        + found=0 + the VM alive (the honest negative)
#   M also surfaces the op-10 payload diagnostics: kpcr_base (from
#   IA32_GS_BASE) + the V5 idt cross-match flag.
#
# OTHER v28 CHANGES:
#   - Stat-Name corrected to the DRIVER's real SlotStatus enum
#     (2=ErrGeneric 3=ErrTimeout 5=ErrInvalid 6=ErrNoBridge
#     7=ErrNotFound 8=ErrUnsupported — the v27 table mislabeled
#     2/3/5 and had no 7; only statuses 1/4 had ever appeared, so
#     it was harmless until M4 made 7 reachable)
#   - INFCNT expectation text now names the M requests (converged
#     17+6=23 via $anSent; fail-closed 13 — M skips like L1..L3)
#   - summary item [13] F2 exports + the F2 verdict ladder
#   - transcript/banner/END markers v28 + the v28 header block
#
# K/L/J request logic stays BYTE-IDENTICAL (regression).
#
# Usage: python3 scripts/make-v28.py
#   reads  infinity-qemu-test/trigger-test-v27.ps1
#   writes infinity-qemu-test/trigger-test-v28.ps1
# ============================================================================
import pathlib, sys

BASE = pathlib.Path("/home/z/my-project")
SRC = BASE / "infinity-qemu-test/trigger-test-v27.ps1"
DST = BASE / "infinity-qemu-test/trigger-test-v28.ps1"

V28_HEADER = r'''# ============================================================
# INFINITY bridge trigger test v28  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v28 = the v21 DRIVER (memory.efi v21 RT - "anchors + exports",
# 131709 bytes) + STEP M: F2 export resolution. The v27 field run
# (2026-09-26 19:36) was FULL GREEN - F1 PROVEN: the containing-
# walk converged on the true ntoskrnl [0xFFFFF80719800000, +0x1046000),
# MZ + PE header + entry code came back through the gate, L4/L5
# rejected both range negatives, J1..J7 100%, INFCNT 17 exact.
# F2 answers the next question: WHERE is everything else? The
# image's own EXPORT TABLE resolves symbols by name at runtime -
# no per-build offset tables, no pattern scans, no hardcoded VAs.
# The driver parses the export table with every read bounds-checked
# inside the VALIDATED image (host-proven 50/50, zero out-of-map),
# then M2 cross-validates export data against the KUSD ground
# truth (NtBuildNumber == 19045 == J1) and M3 reads real code via
# a resolved symbol. M4 is the not-found negative. The op-9 wire,
# the read gate and the K/L/J semantics are UNTOUCHED.
# Stat-Name fixed to the driver's real SlotStatus enum (7 =
# ErrNotFound becomes reachable in M4).
# ============================================================
'''

M_BLOCK = r'''
# ============================================================
# [14a] F2 STEP M: ReqOp_ResolveSymbol (op=10) - export resolution
#       (v21 driver: the VALIDATED image's own export table, every
#       parse read in-image bounds-checked; the symbol NAME travels
#       via InfinityData, the answer is a 64-byte payload:
#       +0 found, +4 name_index, +8 resolved_va, +16 pe_base echo,
#       +24 pe_size echo, +32 kpcr_base, +40 idt_base echo,
#       +48 name_len, +52 rcode, +56 flags bit0 = kpcr-idt match)
# ============================================================
Write-Host ''
Write-Host '--- step M: ReqOp_ResolveSymbol (op=10) - F2 export resolution (v21 driver) ---'
$m1Ok = $false; $m2Ok = $false; $m2ReadOk = $false
$m3Ok = $false; $m3ReadOk = $false; $m4Ok = $false
$mKpcr = [uint64]0; $mKpcrMatch = 0; $mVa = [uint64]0; $nbVa = [uint64]0
function Send-Resolve([object]$rseq, [string]$symName) {
    # writes the symbol name to InfinityData, then sends the op-10
    # request with data_size = name length; returns the Send-Req result
    $nb = [System.Text.Encoding]::ASCII.GetBytes($symName)
    $null = Write-Var 'InfinityData' $nb
    return (Send-Req (New-Req $rseq 10 'FFFFFFFF' $nb.Length '0000000000000000' $null))
}
if ($anOk) {
    # ---- M1: PsInitialSystemProcess (the F3 walk entry) ----
    Write-Host ''
    Write-Host '--- step M1: resolve PsInitialSystemProcess (the F3 EPROCESS-walk entry) ---'
    Canary 'pre-M1'
    $M1 = $null
    try { $M1 = Send-Resolve 0x1801 'PsInitialSystemProcess' } catch { Write-Host "[!] M1 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M1 -and $M1.Status -eq 1 -and $null -ne $M1.Data -and $M1.Data.Length -ge 64) {
        $mFound  = U32 $M1.Data 0
        $mIdx    = U32 $M1.Data 4
        $mVa     = U64 $M1.Data 8
        $mPb     = U64 $M1.Data 16
        $mPs     = U64 $M1.Data 24
        $mKpcr   = U64 $M1.Data 32
        $mIdt    = U64 $M1.Data 40
        $mFlags  = U32 $M1.Data 56
        $mKpcrMatch = ($mFlags -band 1)
        Write-Host ("     [M1] payload: found={0} idx={1} va=0x{2:X} pe_base=0x{3:X} pe_size=0x{4:X}" -f $mFound, $mIdx, $mVa, $mPb, $mPs)
        Write-Host ("     [M1] kpcr_base=0x{0:X} (IA32_GS_BASE)  idt echo=0x{1:X}  V5 kpcr-idt match={2}" -f $mKpcr, $mIdt, $mKpcrMatch)
        $m1Ok = ($mFound -eq 1) -and ($mVa -ge $peBase) -and ($mVa -lt ($peBase + $peSize)) -and ($mPb -eq $peBase) -and ($mPs -eq $peSize)
        if ($m1Ok) { Write-Host ("     [M1] PASS: resolved IN-IMAGE at 0x{0:X} (echoes exact) - the F3 walk entry is located" -f $mVa) }
        else       { Write-Host '     [M1] FAIL: not found / out of the validated range / echo mismatch (see raw above)' }
    } else { Write-Host '     [M1] FAIL: no Success response or short payload (see raw above + serial [XS])' }

    # ---- M2: NtBuildNumber + read it back (== 19045 ground truth) ----
    Write-Host ''
    Write-Host '--- step M2: resolve NtBuildNumber, then read it (must equal the KUSD 19045) ---'
    Canary 'pre-M2'
    $M2 = $null
    try { $M2 = Send-Resolve 0x1802 'NtBuildNumber' } catch { Write-Host "[!] M2 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M2 -and $M2.Status -eq 1 -and $null -ne $M2.Data -and $M2.Data.Length -ge 64) {
        $nbFound = U32 $M2.Data 0
        $nbVa    = U64 $M2.Data 8
        $m2Ok = ($nbFound -eq 1) -and ($nbVa -ge $peBase) -and ($nbVa -lt ($peBase + $peSize))
        if ($m2Ok) { Write-Host ("     [M2] PASS: NtBuildNumber resolved in-image at 0x{0:X}" -f $nbVa) }
        else       { Write-Host '     [M2] FAIL: resolve failed (see raw above + serial [XS])' }
    } else { Write-Host '     [M2] FAIL: no Success response or short payload' }
    if ($m2Ok) {
        Canary 'pre-M2r'
        $M2r = $null
        try { $M2r = Send-Req (New-Req 0x1803 1 'FFFFFFFF' 4 ('{0:X16}' -f $nbVa) $null) } catch { Write-Host "[!] M2r threw: $($_.Exception.Message)" }
        $anSent++
        if ($null -ne $M2r -and $M2r.Status -eq 1 -and $null -ne $M2r.Data -and $M2r.Data.Length -ge 4) {
            $nbVal = U32 $M2r.Data 0
            $nbMasked = [uint32]($nbVal -band 0x7FFFFFFF)
            Write-Host ("     [M2r] raw dword = 0x{0:X} ({0})  masked = {1}" -f $nbVal, $nbMasked)
            $m2ReadOk = ($nbMasked -eq 19045)
            if ($m2ReadOk) { Write-Host '     [M2r] PASS: export-resolved NtBuildNumber == 19045 == the KUSD J1 ground truth (double-proven)' }
            else           { Write-Host '     [M2r] FAIL: value mismatch - see raw above + serial [RD]' }
        } else { Write-Host '     [M2r] FAIL: read at the resolved VA failed (see raw above + serial [RD])' }
    }

    # ---- M3: KeBugCheckEx + read 8 code bytes ----
    Write-Host ''
    Write-Host '--- step M3: resolve KeBugCheckEx, then read 8 bytes (real code via exports) ---'
    Canary 'pre-M3'
    $M3 = $null
    try { $M3 = Send-Resolve 0x1804 'KeBugCheckEx' } catch { Write-Host "[!] M3 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M3 -and $M3.Status -eq 1 -and $null -ne $M3.Data -and $M3.Data.Length -ge 64) {
        $kbFound = U32 $M3.Data 0
        $kbVa    = U64 $M3.Data 8
        $m3Ok = ($kbFound -eq 1) -and ($kbVa -ge $peBase) -and ($kbVa -lt ($peBase + $peSize))
        if ($m3Ok) { Write-Host ("     [M3] PASS: KeBugCheckEx resolved in-image at 0x{0:X}" -f $kbVa) }
        else       { Write-Host '     [M3] FAIL: resolve failed (see raw above + serial [XS])' }
    } else { Write-Host '     [M3] FAIL: no Success response or short payload' }
    if ($m3Ok) {
        Canary 'pre-M3r'
        $M3r = $null
        try { $M3r = Send-Req (New-Req 0x1805 1 'FFFFFFFF' 8 ('{0:X16}' -f $kbVa) $null) } catch { Write-Host "[!] M3r threw: $($_.Exception.Message)" }
        $anSent++
        if ($null -ne $M3r -and $M3r.Status -eq 1 -and $null -ne $M3r.Data -and $M3r.Data.Length -ge 8) {
            $codeTxt = (HexStr $M3r.Data 8)
            $nonZero = $false
            for ($i = 0; $i -lt 8; $i++) { if ($M3r.Data[$i] -ne 0) { $nonZero = $true; break } }
            Write-Host ("     [M3r] code bytes: {0}" -f $codeTxt)
            $m3ReadOk = $nonZero
            if ($m3ReadOk) { Write-Host '     [M3r] PASS: non-zero kernel code bytes read via an export-resolved symbol' }
            else           { Write-Host '     [M3r] FAIL: all-zero bytes at the resolved VA - see serial [RD]' }
        } else { Write-Host '     [M3r] FAIL: read at the resolved VA failed (see raw above + serial [RD])' }
    }

    # ---- M4: the not-found negative ----
    Write-Host ''
    Write-Host '--- step M4: resolve NoSuchSymbolV28 (the honest negative: ErrNotFound) ---'
    Canary 'pre-M4'
    $M4 = $null
    try { $M4 = Send-Resolve 0x1806 'NoSuchSymbolV28' } catch { Write-Host "[!] M4 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M4 -and $null -ne $M4.Resp) {
        if ($M4.Status -eq 7) {
            $m4Ok = $true
            Write-Host '     [M4] PASS: status=7(ErrNotFound) as designed - the parser refuses cleanly, VM alive'
        } else {
            Write-Host ("     [M4] FAIL: expected 7(ErrNotFound), got {0}({1}) - see raw above + serial [XS]" -f $M4.Status, (Stat-Name $M4.Status))
        }
    } else { Write-Host '     [M4] FAIL: no response at all (see raw above + serial [XS])' }
} else {
    Write-Host '     [M] SKIPPED (anchors not converged - the resolve refuses without the validated range)'
}
'''

SUMMARY_13 = r'''$mTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
         elseif ($m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok) { 'PROVEN - resolve + cross-validated reads + negative' }
         else { 'PARTIAL/FAILED - see the M-step lines above + serial [XS]/[KPCR]' }
Write-Host ("[13] F2 export resolution (M1..M4) : {0}" -f $mTxt)
'''

F2_VERDICT = r'''$f2Ok = $anOk -and $m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok
if ($f2Ok) {
    Write-Host ''
    Write-Host '>>> F2 PROVEN: EXPORT-RESOLVED SYMBOLS + VALIDATED READS VIA REQUESTS <<<'
    Write-Host 'The image answers its own layout: export table -> PsInitialSystemProcess,'
    Write-Host 'NtBuildNumber (== the KUSD ground truth), KeBugCheckEx code bytes - all'
    Write-Host 'through the validated gate. No per-build offset tables ever again.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F2 PARTIAL: anchors converged but an M-step failed - see above. <<<'
    Write-Host 'Serial [XS]/[KPCR]/[RD] lines matter - send them + the output .txt.'
}
'''

def main():
    t = SRC.read_text(encoding="utf-8-sig")   # keep the BOM as-is
    def sub(old, new, tag, count=1):
        nonlocal t
        if t.count(old) != count:
            print(f"  FAIL {tag}: anchor found {t.count(old)}x (want {count})")
            sys.exit(1)
        t = t.replace(old, new)
        print(f"  {tag} OK")

    # 1) the v28 header goes between the v23 block and the v27 header
    sub("# INFINITY bridge trigger test v27  (run INSIDE the Windows VM,\n",
        V28_HEADER + "# INFINITY bridge trigger test v27  (run INSIDE the Windows VM,\n",
        "W1-v28-header")

    # 2) transcript name
    sub('$transPath = Join-Path $spot ("trigger-test-v27-output-$stamp.txt")',
        '$transPath = Join-Path $spot ("trigger-test-v28-output-$stamp.txt")',
        "W2-transcript-name")

    # 3) banner
    sub("Write-Host '==== INFINITY trigger test v27 (v20 driver: K CONVERGED in the field; L validated reads - the L2b 88-byte read-back fixed + J regression) ===='",
        "Write-Host '==== INFINITY trigger test v28 (v21 driver: F1 PROVEN in the field; M export resolution - symbols resolved from the validated image + J/L/K regression) ===='",
        "W3-banner")

    # 4) the M-step block: after the kernOk/jTxt lines, before step N
    sub("""Canary 'post-ladder (all J-steps done)'
$kernOk = ($jVal -eq 19045)
if ($kernOk) { $jTxt = "PROVEN - 19045 via $jWhere" }
else         { $jTxt = 'NOT PROVEN - see the ladder results above + serial [RD] lines' }

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
        """Canary 'post-ladder (all J-steps done)'
$kernOk = ($jVal -eq 19045)
if ($kernOk) { $jTxt = "PROVEN - 19045 via $jWhere" }
else         { $jTxt = 'NOT PROVEN - see the ladder results above + serial [RD] lines' }
""" + M_BLOCK + """
# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
        "W4-m-block")

    # 5) step N header text: name the M requests
    sub("Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+anchors: H +1, J1..J7 +7, K/L requests) ---'",
        "Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+requests: H +1, J1..J7 +7, K/L + M export requests) ---'",
        "W5-n-header")

    # 6) summary [12] text: K/L -> K/L/M
    sub("Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor requests (+anSent); requests are consumed in RAM and deletes never count)'",
        "Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor + M export requests (+anSent); requests are consumed in RAM and deletes never count)'",
        "W6-infcnt-text")

    # 7) summary item [13] after [12]
    sub("""Write-Host ("    INFCNT final = {0}   (expect G+8+{4} = {1}: H's InfinityData write (+1), the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 + $anSent } else { '?' }), '', '', '', $anSent)
Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor + M export requests (+anSent); requests are consumed in RAM and deletes never count)'
""",
        """Write-Host ("    INFCNT final = {0}   (expect G+8+{4} = {1}: H's InfinityData write (+1), the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 + $anSent } else { '?' }), '', '', '', $anSent)
Write-Host '     7 ladder InfinityReq writes (+7), and the K/L anchor + M export requests (+anSent); requests are consumed in RAM and deletes never count)'
""" + SUMMARY_13,
        "W7-summary-13")

    # 8) the F2 verdict after the F1 verdict block, before END
    sub("""    Write-Host '>>> F1 FAIL-CLOSED (the gate never opened). The ladder regression below still counts. <<<'
    Write-Host 'Serial [AN] lines name the exact reason - send them + the output .txt.'
}
Write-Host '==== END v27 ===='""",
        """    Write-Host '>>> F1 FAIL-CLOSED (the gate never opened). The ladder regression below still counts. <<<'
    Write-Host 'Serial [AN] lines name the exact reason - send them + the output .txt.'
}
""" + F2_VERDICT + """Write-Host '==== END v28 ===='""",
        "W8-f2-verdict")

    # 9) Stat-Name corrected to the driver's real SlotStatus enum
    sub("""    switch ($s) {
        0 { 'None' }
        1 { 'Success' }
        2 { 'ErrNotFound' }
        3 { 'ErrArgs' }
        4 { 'ErrAccess' }
        5 { 'ErrUnsupported' }
        default { "code-$s" }
    }""",
        """    switch ($s) {
        0 { 'None' }
        1 { 'Success' }
        2 { 'ErrGeneric' }
        3 { 'ErrTimeout' }
        4 { 'ErrAccess' }
        5 { 'ErrInvalid' }
        6 { 'ErrNoBridge' }
        7 { 'ErrNotFound' }
        8 { 'ErrUnsupported' }
        default { "code-$s" }
    }""",
        "W9-stat-name")

    DST.write_text(t, encoding="utf-8")   # NO BOM — the v27 convention (pure ASCII, PS 5.1 ANSI-safe)
    print()
    print(f"[make-v28] written: {DST} ({len(t)} bytes)")
    print("[make-v28] M-steps conditional on $anOk; $anSent++ x6 (total 12 increments -> final 13 converged / 1 fail-closed)")
    print("[make-v28] INFCNT converged 23 / fail-closed 13 (dynamic via $anSent)")

if __name__ == "__main__":
    main()
