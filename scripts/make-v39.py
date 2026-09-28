#!/usr/bin/env python3
# ============================================================================
# make-v39.py — emit patches/trigger-test-v39.ps1 from the FIELD-PROVEN v38.
#
# F4 ATTEMPT 6 (the walk itself). v39 = v38 + THREE changes:
#
#   1. THE CHUNK-MATH FIX (one line, the Task-41 PART E postmortem):
#      [int](($dataVs + $chunkSz - 1) / $chunkSz) -> [int][Math]::Floor(...)
#      PowerShell's [int] CAST ROUNDS (banker's), it does not truncate:
#      (160480+1023)/1024 = 157.72 -> [int] -> 158 (phantom chunk;
#      remain = -288; the len<0 request never fires; $dumpOk never set;
#      "PARTIAL 157/158" printed over a COMPLETE 160480-B dump).
#      Floor gives the correct ceil: 157. $dumpOk now sets -> the
#      in-script PRE-SCAN (the [D+] census + lattice windows + echo
#      checks, shipped in v38 but never reached) finally runs.
#
#   2. THE P-LADDER RETURNS (op-12 UN-RETIRED - the v27 engine):
#      op-12 was retired at v35 because chain B's raw _MMPFN deref
#      BSOD'd the VM twice (fingerprint: 0x50, arg1 == pdb + pfn*0x30
#      + 8). v27 DELETES chain B at the binary level (the v38 offline
#      analysis proved all 5 researched MmPfnDatabase RVAs wrong: 3
#      dead + 2 poison) and adds [PT]-before-read serial traces. The
#      walk is host-proven 103/103 against a true-semantics world
#      incl. the POISON-IMMUNITY kill + the old-formula class-kill.
#      v27 payload: +liveCr3@80 +selfEntry@88 (96B, additive).
#
#   3. THE SELF-ENTRY GROUND TRUTH (the F4 proof, corrected for the
#      caller context): selfOk bit1 = the LIVE IDENTITY - the self-ref
#      frame == (the CR3 REGISTER captured at op-12 time) frame. The
#      self-map ALWAYS maps the CURRENT page tables, so bit1 = 1 is
#      expected in ANY caller context (PowerShell's own kernel PML4,
#      KPTI or not). The read + the register are two independent
#      derivations of the same PML4 - their agreement proves the level
#      formulas + the base with ZERO extra assumptions. The System DTB
#      (cr3@16, == W1 dtb@1056, P7) EXPECTEDLY differs from the self
#      frame in this caller (two different PML4s) - informational.
#
# Wire: op-12 sends return 96B (v27-only script; the bat guards the
# driver hash). Everything else byte-identical to the field-proven
# v38: step 0 post-mortem, canaries, A..H, K/L, J1..J7, M, W, R, D.
# ============================================================================
import pathlib
import sys

BASE = pathlib.Path("/home/z/my-project")
SRC = BASE / "patches" / "trigger-test-v38.ps1"
DST = BASE / "patches" / "trigger-test-v39.ps1"

t = SRC.read_text(encoding="utf-8", errors="replace")
failed = []


def edit(old, new, name, count=1):
    global t
    n = t.count(old)
    if n != count:
        failed.append(f"[{name}] anchor x{n} (want {count})")
        return
    t = t.replace(old, new, count)


# ---------------------------------------------------------------------------
# [1] the chunk-math fix (THE one-line data bug)
# ---------------------------------------------------------------------------
edit(
"""                    $chunkSz  = 1024
                    $total    = [int](($dataVs + $chunkSz - 1) / $chunkSz)""",
"""                    $chunkSz  = 1024
                    # v39: Floor, not the bare [int] cast - PowerShell's
                    # cast ROUNDS (banker's): (160480+1023)/1024 = 157.72
                    # -> [int] -> 158 = a PHANTOM chunk -> remain<0 ->
                    # "PARTIAL 157/158" over a complete dump (v38 field
                    # postmortem, Task-41 PART E). Floor = the true ceil.
                    $total    = [int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)""",
"1 chunk math fix")

# ---------------------------------------------------------------------------
# [2] the P-ladder (op-12 UN-RETIRED, the v27 engine) - inserted after the
#     D step, right before step N, so the whole v38 flow (regression +
#     recon + dump + pre-scan) lands FIRST and the walk is the climax.
#     Any walk-side death (not expected: host 103/103 + [PT] traces)
#     leaves every earlier artifact captured.
# ---------------------------------------------------------------------------
P_LADDER = r'''
# ============================================================
# [14c] step P: THE PAGE-TABLE WALK (op 12 TranslateVa - v27, THE
# F4 ENGINE: chain B DELETED at the binary level + [PT] traces
# BEFORE every PTE-space read + the LIVE-CR3 identity). Placed
# AFTER the D step so the whole v38 flow (regression + recon +
# dump + pre-scan) lands FIRST and the walk is the climax; any
# walk-side death (not expected: host 103/103 + [PT] traces)
# leaves every earlier artifact captured. Every P request:
# op=12, pid FFFFFFFF (kernel data - no pid gate), req address =
# the TARGET kernel VA. v27 payload 96B: rc@0 (1 ok / 2 no-base
# / 4 not-present / 5 bad args / 6 refused), selfIdx@4, pteBase@8,
# cr3@16 (System DTB via the EPROCESS chain), pml4e@24, pdpte@32,
# pde@40, pte@48, frame@56, presentMask@64, source@68 (bits 0-1 =
# the MmPteBase candidate; bits 4/5 DEAD - chain B deleted),
# selfOk@72 (bit0 = the PTE space LIVE; bit1 = THE LIVE IDENTITY:
# self frame == the CR3 register frame, expected 1 in ANY caller
# context), reads@76, liveCr3@80 (v27: the CR3 register AT op-12
# time, raw), selfEntry@88 (v27: the raw PML4E[s] qword).
# ============================================================
$pSent = 0
$P1 = $null; $p1Ok = $false; $p1Rc = 0; $p1Mask = 0; $p1SelfOk = 0
$p1PteBase = [UInt64]0; $p1Cr3 = [UInt64]0; $p1Frame = [UInt64]0; $p1Source = 0
$p1LiveCr3 = [UInt64]0; $p1SelfEntry = [UInt64]0; $pIdentityOk = $false
$P2 = $null; $p2Ok = $false
$P3 = $null; $p3Ok = $false
$P4 = $null; $p4Ok = $false
$wDtbOk = $false
if ($anOk) {
    Write-Host ''
    Write-Host '--- step P: op 12 TranslateVa - THE PAGE-TABLE WALK (v27: chain B deleted, the crash class is gone from the binary) ---'
    Write-Host '     (PTE_BASE discovery: chain A alone = nt!MmPteBase .data (slot 0xCFB358 FIELD-PINNED by the v38'
    Write-Host '      ALMOSTRO dump) + the 512-value structural check. chain B - the _MMPFN deref that BSOD-d the'
    Write-Host '      VM twice - is DELETED: no code path reads the MmPfnDatabase RVAs anymore, and every PTE-space'
    Write-Host '      read traces [PT] rd <addr> on serial BEFORE it happens: if the VM ever dies in the walk, the'
    Write-Host '      LAST [PT] line names the killer read.)'
    Write-Host '     (THE GROUND TRUTH: selfOk bit1 = the LIVE identity - the self-ref frame == the CR3 REGISTER'
    Write-Host '      frame captured at op-12 time. The self-map maps the CURRENT page tables, so 1 is expected'
    Write-Host '      in ANY caller context: this PowerShell process own PML4. The read + the register are two'
    Write-Host '      independent derivations of the same PML4; agreement proves the formulas + the base.)'

    # ---- P1: translate pe_base (the validated image itself) ----
    Write-Host ''
    Write-Host ('--- step P1: op-12(pe_base=0x{0:X}) - the kernel image walk ---' -f $peBase)
    Canary 'pre-P1'
    try { $P1 = Send-Req (New-Req 0x1A01 12 'FFFFFFFF' 0 ('{0:X16}' -f $peBase) $null) } catch { Write-Host "[!] P1 threw: $($_.Exception.Message)" }
    $pSent++
    if ($null -ne $P1 -and $null -ne $P1.Resp -and $P1.Status -eq 1 -and $P1.Data.Length -ge 96) {
        $p1Rc     = U32 $P1.Data 0
        $p1Self   = U32 $P1.Data 4
        $p1PteBase = U64 $P1.Data 8
        $p1Cr3    = U64 $P1.Data 16
        $p1M4     = U64 $P1.Data 24
        $p1M3     = U64 $P1.Data 32
        $p1M2     = U64 $P1.Data 40
        $p1M1     = U64 $P1.Data 48
        $p1Frame  = U64 $P1.Data 56
        $p1Mask   = U32 $P1.Data 64
        $p1Source = U32 $P1.Data 68
        $p1SelfOk = U32 $P1.Data 72
        $p1Reads  = U32 $P1.Data 76
        $p1LiveCr3   = U64 $P1.Data 80
        $p1SelfEntry = U64 $P1.Data 88
        Write-Host ("     [P1] rc={0} selfIdx=0x{1:X} pteBase=0x{2:X} cr3(System)=0x{3:X}" -f $p1Rc, $p1Self, $p1PteBase, $p1Cr3)
        Write-Host ("     [P1] pml4e=0x{0:X} pdpte=0x{1:X} pde=0x{2:X} pte=0x{3:X}" -f $p1M4, $p1M3, $p1M2, $p1M1)
        Write-Host ("     [P1] frame=0x{0:X} mask=0x{1:X} source=0x{2:X} selfOk={3} reads={4}" -f $p1Frame, $p1Mask, $p1Source, $p1SelfOk, $p1Reads)
        Write-Host ("     [P1] liveCr3(register)=0x{0:X} selfEntry(raw PML4E[s])=0x{1:X}" -f $p1LiveCr3, $p1SelfEntry)
        # structural: pteBase must be one of the 512 canonical shapes
        $kPtMin = [UInt64]'0xFFFF800000000000'
        $ptbCanon = ($p1PteBase -ge $kPtMin) -and (($p1PteBase -band [UInt64]'0x0000007FFFFFFFFF') -eq 0)
        $frameOk  = ($p1Frame -gt 0) -and ($p1Frame -lt [UInt64]'0x400000000')
        $maskOk   = ($p1Mask -band 0x1F) -eq 0x1F -or ($p1Mask -band 0x17) -eq 0x17 -or ($p1Mask -band 0x13) -eq 0x13
        # *** THE LIVE IDENTITY (the F4 ground truth) ***
        $pfnMaskV = [UInt64]'0x000FFFFFFFFFF000'
        $selfFrame = $p1SelfEntry -band $pfnMaskV
        $liveFrame = $p1LiveCr3 -band $pfnMaskV
        $pIdentityOk = ($selfFrame -ne 0) -and ($selfFrame -eq $liveFrame)
        if ($pIdentityOk) {
            Write-Host ('     [P1] PASS: THE LIVE IDENTITY - selfEntry frame 0x{0:X} == the CR3 REGISTER frame 0x{1:X} (two independent derivations of the SAME PML4; the level formulas + the base are PROVEN with zero extra assumptions)' -f $selfFrame, $liveFrame)
        } else {
            Write-Host ('     [P1] FAIL: the identity broke - selfEntry frame 0x{0:X} vs the CR3 register frame 0x{1:X} (serial [PT] rd lines + this payload tell all)' -f $selfFrame, $liveFrame)
        }
        $p1Ok = ($p1Rc -eq 1) -and $ptbCanon -and $frameOk -and $maskOk -and (($p1SelfOk -band 1) -eq 1) -and $pIdentityOk
        if ($p1Ok) {
            Write-Host '     [P1] PASS: the kernel image translated - all levels present, frame sane, the PTE space LIVE (selfOk bit0)'
            if (($p1SelfOk -band 2) -ne 0) { Write-Host '     [P1] PASS: selfOk bit1 SET - the identity held (expected in ANY caller context)' }
            else { Write-Host '     [P1] NOTE: selfOk bit1 clear while the payload identity agreed - see the [P1] identity line above + serial [PT]' }
            if (($p1Source -band 0x30) -ne 0) { Write-Host '     [P1] NOTE: source bits 4/5 set - UNEXPECTED for v27 (chain B deleted; bits are dead). Report this.' }
        } else {
            Write-Host "     [P1] FAIL: rc=$p1Rc (2=no-base: the .data layout drifted - report + serial [PT]; 4=not-present; 5=bad args), or a structural check failed above"
        }
    } else {
        $st = if ($null -ne $P1) { $P1.Status } else { 'none' }
        Write-Host "     [P1] FAIL: no/bad response (status=$st) - v26 or older answers 80B (v27 answers 96B); serial [PT]"
    }

    # ---- P2: translate the System EPROCESS (F3's anchor) ----
    if ($null -ne $wSys -and $wSys -ne 0) {
        Write-Host ''
        Write-Host ('--- step P2: op-12(System EPROCESS=0x{0:X}) - F3 x F4: is the EPROCESS RESIDENT? ---' -f $wSys)
        Canary 'pre-P2'
        $P2 = $null
        try { $P2 = Send-Req (New-Req 0x1A02 12 'FFFFFFFF' 0 ('{0:X16}' -f $wSys) $null) } catch { Write-Host "[!] P2 threw: $($_.Exception.Message)" }
        $pSent++
        if ($null -ne $P2 -and $null -ne $P2.Resp -and $P2.Status -eq 1 -and $P2.Data.Length -ge 96) {
            $p2Rc = U32 $P2.Data 0; $p2Mask = U32 $P2.Data 64; $p2Frame = U64 $P2.Data 56
            Write-Host ("     [P2] rc={0} mask=0x{1:X} frame=0x{2:X}" -f $p2Rc, $p2Mask, $p2Frame)
            $p2Ok = ($p2Rc -eq 1) -and ((($p2Mask -band 0x1F) -eq 0x1F) -or (($p2Mask -band 0x17) -eq 0x17) -or (($p2Mask -band 0x13) -eq 0x13))
            if ($p2Ok) { Write-Host '     [P2] PASS: the EPROCESS page is RESIDENT - PTE-validated (the residency assumption REMOVED for F3 data)' }
            else       { Write-Host "     [P2] FAIL: rc=$p2Rc mask=$p2Mask (4 = not present - the page is absent)" }
        } else { Write-Host '     [P2] FAIL: no/bad response - see raw above + serial [PT]' }
    } else { Write-Host '     [P2] SKIPPED (W1 gave no EPROCESS)' }

    # ---- P3: translate the KUSD kernel alias (the J-ladder window) ----
    Write-Host ''
    Write-Host '--- step P3: op-12(KUSD kernel alias 0xFFFFF78000000260) ---'
    Canary 'pre-P3'
    $P3 = $null
    try { $P3 = Send-Req (New-Req 0x1A03 12 'FFFFFFFF' 0 'FFFFF78000000260' $null) } catch { Write-Host "[!] P3 threw: $($_.Exception.Message)" }
    $pSent++
    if ($null -ne $P3 -and $null -ne $P3.Resp -and $P3.Status -eq 1 -and $P3.Data.Length -ge 96) {
        $p3Rc = U32 $P3.Data 0; $p3Mask = U32 $P3.Data 64
        Write-Host ("     [P3] rc={0} mask=0x{1:X}" -f $p3Rc, $p3Mask)
        $p3Ok = ($p3Rc -eq 1) -and ((($p3Mask -band 0x1F) -eq 0x1F) -or (($p3Mask -band 0x17) -eq 0x17) -or (($p3Mask -band 0x13) -eq 0x13))
        if ($p3Ok) { Write-Host '     [P3] PASS: the KUSD window resident - the J-ladder ground truth is PTE-backed' }
        else       { Write-Host "     [P3] FAIL: rc=$p3Rc mask=$p3Mask" }
    } else { Write-Host '     [P3] FAIL: no/bad response - see raw above + serial [PT]' }

    # ---- P4: translate the IDT base (the K payload echo) ----
    Write-Host ''
    Write-Host ('--- step P4: op-12(idt_base=0x{0:X}) ---' -f $anIdt)
    Canary 'pre-P4'
    $P4 = $null
    try { $P4 = Send-Req (New-Req 0x1A04 12 'FFFFFFFF' 0 ('{0:X16}' -f $anIdt) $null) } catch { Write-Host "[!] P4 threw: $($_.Exception.Message)" }
    $pSent++
    if ($null -ne $P4 -and $null -ne $P4.Resp -and $P4.Status -eq 1 -and $P4.Data.Length -ge 96) {
        $p4Rc = U32 $P4.Data 0; $p4Mask = U32 $P4.Data 64
        Write-Host ("     [P4] rc={0} mask=0x{1:X}" -f $p4Rc, $p4Mask)
        $p4Ok = ($p4Rc -eq 1) -and ((($p4Mask -band 0x1F) -eq 0x1F) -or (($p4Mask -band 0x17) -eq 0x17) -or (($p4Mask -band 0x13) -eq 0x13))
        if ($p4Ok) { Write-Host '     [P4] PASS: the IDT page resident - the F1 anchor chain is PTE-backed end to end' }
        else       { Write-Host "     [P4] FAIL: rc=$p4Rc mask=$p4Mask" }
    } else { Write-Host '     [P4] FAIL: no/bad response - see raw above + serial [PT]' }

    # ---- P5/P6: the honest negatives ----
    Write-Host ''
    Write-Host '--- step P5/P6: negatives - non-canonical + user-range must refuse ErrInvalid(5), VM alive ---'
    Canary 'pre-P5'
    $P5 = $null
    try { $P5 = Send-Req (New-Req 0x1A05 12 'FFFFFFFF' 0 '0000800000000000' $null) } catch { Write-Host "[!] P5 threw: $($_.Exception.Message)" }
    $pSent++
    $P6 = $null
    try { $P6 = Send-Req (New-Req 0x1A06 12 'FFFFFFFF' 0 '00007FF000000000' $null) } catch { Write-Host "[!] P6 threw: $($_.Exception.Message)" }
    $pSent++
    $p5Ok = ($null -ne $P5 -and $null -ne $P5.Resp -and $P5.Status -eq 5)
    $p6Ok = ($null -ne $P6 -and $null -ne $P6.Resp -and $P6.Status -eq 5)
    if ($p5Ok) { Write-Host '     [P5] PASS: non-canonical -> ErrInvalid(5) clean' } else { Write-Host '     [P5] FAIL: expected ErrInvalid(5)' }
    if ($p6Ok) { Write-Host '     [P6] PASS: user-range VA -> ErrInvalid(5) clean (kernel-data op by design)' } else { Write-Host '     [P6] FAIL: expected ErrInvalid(5)' }

    # ---- P7: the System-DTB cross-check (two independent driver paths) ----
    Write-Host ''
    Write-Host '--- step P7: the System-DTB cross-check - W1 dtb@1056 == P1 cr3@16 ---'
    $wDtbAligned = ($wDtb -band [UInt64]'0xFFF') -eq 0
    $wDtbOk = ($wDtb -gt 0) -and $wDtbAligned -and ($wDtb -eq $p1Cr3)
    if ($wDtbOk) {
        Write-Host ('     [P7] PASS: op-11 walk-echo dtb=0x{0:X} == op-12 chain cr3 - the SAME System DirectoryTableBase via two independent paths' -f $wDtb)
    } else {
        Write-Host ('     [P7] FAIL: W1 dtb=0x{0:X} (aligned={1}) vs P1 cr3=0x{2:X} - they MUST match' -f $wDtb, $wDtbAligned, $p1Cr3)
    }

    # ---- P8: the two-PML4 informational (the caller-context honesty) ----
    Write-Host ''
    Write-Host '--- step P8: the two-PML4 line (informational, not a gate) ---'
    if ($pIdentityOk -and ($wDtb -gt 0)) {
        if ($selfFrame -ne ($wDtb -band $pfnMaskV)) {
            Write-Host ('     [P8] EXPECTED: the live PML4 (self frame 0x{0:X} == the caller own page) DIFFERS from the System DTB 0x{1:X}' -f $selfFrame, $wDtb)
            Write-Host '     [P8] this PowerShell process runs on ITS OWN page tables; the System process has its own PML4.'
            Write-Host '     [P8] (v26 compared these two and expected inequality; v27 compares the self frame against the LIVE CR3 register - the identity that always holds.)'
        } else {
            Write-Host ('     [P8] NOTE: the self frame 0x{0:X} == the System DTB 0x{1:X} - the caller context IS System (unusual for a trigger run, but consistent)' -f $selfFrame, $wDtb)
        }
    } else { Write-Host '     [P8] SKIPPED (the identity or the W dtb echo missing)' }
} else {
    Write-Host ''
    Write-Host '--- step P: SKIPPED (anchors not converged) ---'
}
'''

edit(
"""# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
P_LADDER + """
# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
"2 p-ladder insert")

# ---------------------------------------------------------------------------
# [3] INFCNT expectation: + pSent
# ---------------------------------------------------------------------------
edit(
"""$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent + $rSent + $dumpSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6}+{7}+{8} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent, $rSent, $dumpSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites), the W walk requests (+wSent), the R recon requests (+rSent) and the D dump chunks (+dumpSent); requests are consumed in RAM and deletes never count)'""",
"""$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent + $rSent + $dumpSent + $pSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6}+{7}+{8}+{9} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent, $rSent, $dumpSent, $pSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites), the W walk requests (+wSent), the R recon requests (+rSent), the D dump chunks (+dumpSent) and the P walk requests (+pSent); requests are consumed in RAM and deletes never count)'""",
"3 infcnt psent")

# ---------------------------------------------------------------------------
# [4] the [15] summary line + the F4 verdict block (v39 = the WALK verdict)
# ---------------------------------------------------------------------------
edit(
"""$f4Sum = "RECON THIS RUN (op-12 retired after the 2nd 0x50): {0}; dump: {1}" -f $reconTxt, $dumpInfoTxt
Write-Host ("[15] F4 constants recon (R1..R9) : {0}" -f $f4Sum)""",
"""$f4WalkTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
              elseif ($p1Ok -and $p2Ok -and $p3Ok -and $p4Ok -and $p5Ok -and $p6Ok -and $wDtbOk) { 'PROVEN - the selfmap walk + THE LIVE-CR3 IDENTITY (P1) + resident EPROCESS/KUSD/IDT + clean negatives' }
              elseif ($pIdentityOk) { 'PARTIAL - the identity held but a walk rung failed (see the P lines)' }
              else { 'NOT PROVEN - see the P-step lines + serial [PT] (the last [PT] rd line names any killer read)' }
Write-Host ("[15] F4 the walk (P1..P8, op-12 v27): {0}" -f $f4WalkTxt)
Write-Host ("     F4 recon + dump (R/D, v38 path): {0}; dump: {1}" -f $reconTxt, $dumpInfoTxt)""",
"4 f4 summary")

edit(
"""$f4Ok = $anOk -and $reconPteOk -and $dumpOk
if ($f4Ok) {
    Write-Host ''
    Write-Host '>>> F4 RECON-2 COMPLETE + THE ALMOSTRO CLUSTER CAPTURED (the VM SURVIVED) <<<'
    Write-Host 'A pte-base-shaped MmPteBase was found in-image (s below) and the whole'
    Write-Host ("ALMOSTRO section - the Mm globals cluster - is on the stick ({0})." -f $dumpInfoTxt)
    Write-Host 'The offline analysis pins the TRUE MmPfnDatabase from these bytes (the'
    Write-Host 'page-list lattice: every Mm list link is pdb + pfn*0x30 - the residue'
    Write-Host 'class cannot lie). Then the v27 driver + the walk kit = F4 PROVEN.'
    Write-Host ("recon pte-base s=0x{0:X}  w_dtb=0x{1:X}" -f $reconPteS, $wDtb)
    Write-Host 'Next: the offline ALMOSTRO analysis, then the v27/walk kit (attempt 5).'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F4 RECON-2 PARTIAL (no pte-base-shaped candidate or the dump did not complete) <<<'
    Write-Host 'That is NOT a failure of the bridge: the section simply was not where'
    Write-Host ("the table said. The dump ({0}) + the .txt are exactly what the offline" -f $dumpInfoTxt)
    Write-Host 'analysis needs - send everything. The VM is alive by construction.'
}""",
"""$f4Ok = $anOk -and $p1Ok -and $p2Ok -and $p3Ok -and $p4Ok -and $p5Ok -and $p6Ok -and $wDtbOk
if ($f4Ok) {
    Write-Host ''
    Write-Host '>>> F4 PROVEN: PAGE-TABLE TRANSLATION VIA THE SELFMAP - GROUND-TRUTHED BY THE LIVE-CR3 IDENTITY <<<'
    Write-Host 'The kernel image, the System EPROCESS, the KUSD window and the IDT page all'
    Write-Host 'translated PML4 -> PDPT -> PD -> PT through the self-map (chain A, the'
    Write-Host 'field-pinned MmPteBase slot); every level present; every frame sane.'
    Write-Host ('THE GROUND TRUTH: the self-ref entry PML4E[s] frame 0x{0:X} == the CR3 REGISTER frame' -f $p1SelfEntry)
    Write-Host ('0x{0:X} captured at op-12 time - two independent derivations of the SAME PML4' -f $p1LiveCr3)
    Write-Host '(one through the translated self-map slot, one straight from the hardware'
    Write-Host 'register). Their agreement proves the level-base formulas AND the base'
    Write-Host 'value with zero extra assumptions - in the CALLER context, whatever it is.'
    Write-Host 'Negatives refused clean (non-canonical, user-range); chain B - the _MMPFN'
    Write-Host 'deref that BSOD-d the VM twice - is deleted from the binary; the whole'
    Write-Host 'walk ran with [PT] traces before every PTE-space read. THE F1..F4 LADDER'
    Write-Host 'IS COMPLETE. Next: Infinity.exe (the userspace client).'
} elseif ($anOk -and $pIdentityOk) {
    Write-Host ''
    Write-Host '>>> F4 PARTIAL: THE LIVE IDENTITY HELD but a walk rung failed - see the P lines. <<<'
    Write-Host 'The identity (self frame == the CR3 register frame) already proves the'
    Write-Host 'formulas + the base; the failed rung is a mapping-level fact (e.g. a page'
    Write-Host 'not present) - the [P] lines + serial [PT] tell exactly which. Send them.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F4 NOT PROVEN THIS RUN (a walk rung or the identity failed). <<<'
    Write-Host 'NOT a bridge failure: every refusal was a clean status and the VM is alive'
    Write-Host 'by construction. The [P] lines + the serial [PT] lines (the LAST [PT] rd'
    Write-Host 'line names any killer read) + the recon/dump lines above are exactly what'
    Write-Host 'the analysis needs - send everything.'
}""",
"5 f4 verdict")

# ---------------------------------------------------------------------------
# [6] version strings: banner, transcript, END marker
# ---------------------------------------------------------------------------
edit(
"    $transPath = Join-Path $spot (\"trigger-test-v38-output-$stamp.txt\")",
"    $transPath = Join-Path $spot (\"trigger-test-v39-output-$stamp.txt\")",
"6a transpath")

edit(
"# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v38",
"# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v39",
"6a2 manifest header")

edit(
"Write-Host '==== END v38 ===='",
"Write-Host '==== END v39 ===='",
"6b end marker")

BANNER = "Write-Host '==== INFINITY trigger test v39 (the v27 driver: chain B DELETED - the BSOD class is gone from the binary + [PT] traces BEFORE every PTE-space read + the LIVE-CR3 identity; op-12 UN-RETIRED: THE WALK ITSELF = F4 ATTEMPT 6; plus the v38 one-line chunk-math fix so the ALMOSTRO dump completes and the in-script pre-scan finally runs; the 13-green regression A..H K/L J M W R D all unchanged) ===='"
import re
m = re.search(r"Write-Host '==== INFINITY trigger test v38[^\n]*", t)
if not m:
    failed.append("[6c banner] not found")
else:
    t = t.replace(m.group(0), BANNER, 1)

# ---------------------------------------------------------------------------
# [7] header stack: the v39 story (house convention: stacked headers)
# ---------------------------------------------------------------------------
edit(
"""# INFINITY bridge trigger test v38  (run INSIDE the Windows VM,""",
"""# INFINITY bridge trigger test v39 - F4 ATTEMPT 6: THE WALK ITSELF
#   (built on the FIELD-PROVEN v38; driver v27 - a REAL driver
#   generation change: swap usb-d\\memory.efi too!)
#
#   WHAT CHANGED (3 things; everything else is the proven v38):
#   1. THE CHUNK-MATH FIX (one line): [int] cast -> [Math]::Floor.
#      PowerShell's [int] cast ROUNDS (157.72 -> 158), v38 computed
#      a phantom chunk 158, the len<0 request never fired, $dumpOk
#      never set - "PARTIAL 157/158" printed over a COMPLETE dump
#      and the in-script pre-scan never ran. Floor fixes the ceil;
#      the dump now completes + the pre-scan runs + sha256 lands.
#   2. OP-12 UN-RETIRED - THE P-LADDER RETURNS with the v27 engine:
#      v27 DELETES chain B (the _MMPFN deref behind BOTH F4-era
#      BSODs - the v38 offline analysis proved all 5 researched
#      MmPfnDatabase RVAs wrong: 3 dead + 2 poison) and traces
#      [PT] rd <addr> BEFORE every PTE-space read. Host-proven
#      103/103 against a true-semantics world incl. the poison-
#      immunity kill + the old-formula class-kill + the s=0x1FF
#      edge; bench-validated 13/13 RT + SAFE.
#   3. THE LIVE-CR3 IDENTITY (the F4 ground truth): selfOk bit1 =
#      self-ref frame == (the CR3 REGISTER captured at op-12 time)
#      frame. The self-map ALWAYS maps the CURRENT page tables, so
#      1 is expected in ANY caller context - the read + the
#      register prove the formulas together. (v26's bit1 compared
#      the System DTB and expected 0 from a user caller; that
#      comparison is now P8, informational.) P1 additionally
#      decodes liveCr3@80 + selfEntry@88 from the 96B v27 payload.
#
#   EXPECT: the 14th green regression + the SAME deterministic
#   anchors; [D] the dump COMPLETE (157 chunks, sha256 set) + the
#   [D+] pre-scan lines; P1 rc=1 + THE IDENTITY PASS + selfOk=3;
#   P2/P3/P4 resident; P5/P6 ErrInvalid(5); P7 dtb==cr3; P8 the
#   two-PML4 EXPECTED line; INFCNT = G+8+anSent+mNameWrites+wSent+
#   rSent+dumpSent+pSent; the F4 PROVEN verdict.
#
#   DRIVER SWAP REQUIRED: usb-d\\memory.efi v27-RT = 141041 bytes,
#   sha256 e13f9f24... (v26 = 140582 c8f79b95 - the v39 bat guards
#   the hash both ways). phase-d.bat + this script = the 2-file
#   script side.
# ============================================================
# INFINITY bridge trigger test v38  (run INSIDE the Windows VM,""",
"7 header stack")

# ---------------------------------------------------------------------------
# report
# ---------------------------------------------------------------------------
if failed:
    print("FAILED ANCHORS:")
    for f in failed:
        print("  " + f)
    sys.exit(1)

DST.write_text(t, encoding="utf-8", newline="\n")
n = len(t.splitlines())
print(f"[make-v39] wrote {DST}")
print(f"[make-v39] {n} lines, {len(t)} bytes")
print("[make-v39] 1. chunk-math Floor fix  2. P-ladder (op-12 v27, 96B, the identity)")
print("[make-v39] 3. INFCNT +pSent  4. F4 WALK verdict  5. banners v38->v39")
