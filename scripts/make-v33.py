#!/usr/bin/env python3
# ============================================================================
# make-v33.py — build trigger-test-v33.ps1 from the FIELD-RUN v32 script
#
# v33 story (what this patch encodes):
#   v32 field run (2026-09-27 21:09): F3 FIELD-PROVEN IN SUBSTANCE — W1
#   all-PASS (eproc=0xFFFFDC89140BF080 canonical OUT-OF-IMAGE via the
#   deref chain, System pid 4 at eproc, names live at +0x5A8, 64 procs,
#   236 pages), W4/W5 clean, INFCNT arithmetic exact, 6th consecutive
#   F1/F2 green, zero crashes. The ONLY failure: W2's count-tolerance
#   (walked=64 live=102 delta=38 > 3) — root-caused to a SCRIPT-side
#   cap-blind calibration: the walk stops at kPwMaxEntries=64 BY DESIGN
#   (host-proven T19a-d: count capped, closed=0) and this VM ran 102
#   live processes, so |walked-live| >= 35 ALWAYS. The membership half
#   (checked=12 missing=0) was green. Driver v24 is INNOCENT.
#
# v33 CHANGES (anchored on the field-run v32 text):
#   1. v33 header + transcript + banner + END
#   2. driver-ID texts: the v25 driver (141154 bytes — sizes differ
#      again; v24 = 134842, v23/v22 = 134330)
#   3. K label v20..v25
#   4. *** THE W2 CAP-AWARE FIX ***: compare walked against
#      min(live, 64) — the driver's by-design cap — tolerance stays 3;
#      membership (missing==0) unchanged. live>64 worlds now PASS
#      exactly when they should.
#   5. *** THE NEW P-SECTION (op 12 TranslateVa, driver v25) ***:
#      P1 op-12(pe_base): the 4-level walk + the two-chain PTE_BASE
#      discovery payload (rc/selfIdx/pteBase/cr3/entries/frame/mask/
#      source/selfOk/reads)
#      P2 op-12(the System EPROCESS): F3's anchor is RESIDENT,
#      PTE-VALIDATED (F3 x F4 integration)
#      P3 op-12(KUSD kernel alias): the J-ladder window resident
#      P4 op-12(idt_base): the IDT resident
#      P5/P6 negatives: non-canonical + user-VA -> ErrInvalid(5)
#      P7 the DTB cross-check: W1's payload dtb@1056 == P1's cr3@16
#      (two independent driver paths to the same System DirectoryTableBase)
#   6. INFCNT formula: + pSent (P requests; P5/P6 are refused but
#      still count — same as W4)
#   7. summary [15] + the F4 verdict block
#
# THE WIRE CONTRACT OF EVERY EXISTING STEP IS UNCHANGED except:
#   - op-11's payload grows 1056 -> 1064 (ADDITIVE dtb@1056; the v32
#     script read nothing at that offset)
#   - op 12 is NEW (v24 and older answer ErrUnsupported(8) — the
#     decision table documents it)
#
# Usage: python3 scripts/make-v33.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v32.ps1'
DST = BASE / 'patches' / 'trigger-test-v33.ps1'

V25_SHA = '022e6d1c01fb7de7704182bcf230062905c58f5d8677e1b75cdd0582609b398b'
V24_SHA = 'f8a01814f4ffeb9a9b1595a722c733b0dbf92d5eb5710b25d88d7818dbcf5846'

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
# 1. v33 header above the v32 header
# =========================================================
rep(
"""# ============================================================
# INFINITY bridge trigger test v32  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v33  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v25 DRIVER (memory.efi v25 RT - "anchors + exports
# + process walk + page tables (F4)", 141154 bytes, sha256
# 022e6d1c...09b398b). v25 = v24 + op 12 TranslateVa: VA ->
# page-table walk through the SELF-MAP (no CR3 switching - the
# v17/v19 lesson; no physical reads; no kernel calls). PTE_BASE
# discovery via TWO ordered chains: A = nt!MmPteBase (.data, RVA
# candidates 0xCFB358/0xCFA358 from 19 real 19041/19045 PDBs) with
# the 512-value structural check (A gates ALL out-of-image reads:
# a drifted patch level refuses CLEANLY, VM alive); B = the PFN
# bootstrap (MmPfnDatabase -> System CR3 from EPROCESS+0x28 ->
# _MMPFN.PteAddress -> the s-identity); A and B must AGREE. The
# TWO-WAY PROOF: PML4E[s] must point at the System CR3 frame - the
# page tables and the EPROCESS validate each other. Host-proven
# 89/89 incl. the T26 drifted-world and T32 absent-parent
# class-kills; disasm-verified; bench A 13/13 + B 5/5.
#
# ALSO: the W2 count-tolerance is now CAP-AWARE (the v32 root
# cause: the walk stops at 64 BY DESIGN; this VM ran 102 live
# processes, so the old |walked-live|<=3 could never pass).
# v33 compares walked against min(live,64).
#
# op-11 payload grew ADDITIVELY: dtb@1056 (the System
# DirectoryTableBase, PCID-masked) - the P7 cross-check source.
#
# ============================================================
# INFINITY bridge trigger test v32  (run INSIDE the Windows VM,""",
'header')

# =========================================================
# 2. transcript name
# =========================================================
rep('trigger-test-v32-output-', 'trigger-test-v33-output-', 'transcript')

# =========================================================
# 3. banner
# =========================================================
rep(
"Write-Host '==== INFINITY trigger test v32 (v24 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression + the v24 DEREF fix: walk from the EPROCESS the symbol points at, not the symbol slot) ===='",
"Write-Host '==== INFINITY trigger test v33 (v25 driver: F4 PAGE-TABLE TRANSLATION - the self-map walk with the two-chain PTE_BASE discovery + the two-way proof; full K/L/M/J/W regression + the cap-aware W2 fix + the P ladder) ===='",
'banner')

# =========================================================
# 4. driver-ID texts (v25 first, v24 demoted)
# =========================================================
rep(
"""# + process walk (F3)", 134842 bytes, sha256 f8a01814...dbcf5846).""",
"""# + process walk + page tables (F4)", 141154 bytes, sha256
# 022e6d1c...09b398b).""",
'driver-id-1')

rep(
"""# DRIVER SIZE CHECK: v24-RT = 134842 bytes. v23-RT and v22-RT are""",
"""# DRIVER SIZE CHECK: v25-RT = 141154 bytes. v24-RT = 134842 (no
# page tables: op 12 answers ErrUnsupported(8)). v23-RT and v22-RT are""",
'driver-id-2')

rep(
"""# v24 sha256 = f8a01814...dbcf5846. phase-d.bat checks all of it.""",
"""# v25 sha256 = 022e6d1c...09b398b (v24 = f8a01814...dbcf5846).
# phase-d.bat checks all of it.""",
'driver-id-3')


# =========================================================
# 4b. op-11 payload doc: the ADDITIVE dtb@1056 (1064B payload)
# =========================================================
rep(
"""#   The symbol cross-check (serial [PW] sys= == M1's va) is read
#   from serial-phase-d.log, not the payload.
#""",
"""#   The symbol cross-check (serial [PW] sys= == M1's va) is read
#   from serial-phase-d.log, not the payload.
#   v25 ADDS dtb@1056 (u64: the System DirectoryTableBase from
#   EPROCESS+0x28, PCID-masked) - payload 1056 -> 1064B; P7
#   cross-checks it against op-12's cr3.
#""",
'op11-doc')

# =========================================================
# 5. K label
# =========================================================
rep(
"'--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v24 containing-walk) ---'",
"'--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v25 containing-walk) ---'",
'k-label')

# =========================================================
# 6. W1 payload: parse + echo the NEW dtb@1056
# =========================================================
rep(
"""        $wPages  = U32 $W1.Data 1048
        $wStored = U32 $W1.Data 1052
        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} eproc=0x{6:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys)""",
"""        $wPages  = U32 $W1.Data 1048
        $wStored = U32 $W1.Data 1052
        $wDtb    = U64 $W1.Data 1056     # v25: the System DirectoryTableBase
        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} eproc=0x{6:X} dtb=0x{7:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys, $wDtb)""",
'w1-dtb')

# =========================================================
# 7. THE W2 CAP-AWARE FIX (the v32 root cause)
# =========================================================
rep(
"""                $cntDelta = [Math]::Abs([int]$wCount - $liveProcs.Count)
                Write-Host ("     [W2] walked={0} live={1} delta={2} checked={3} missing={4}" -f $wCount, $liveProcs.Count, $cntDelta, $checked, $missing)
                $w2Ok = ($missing -eq 0) -and ($cntDelta -le 3)
                if ($w2Ok) { Write-Host '     [W2] PASS: the walked list matches the live process list' }
                else       { Write-Host '     [W2] FAIL: too many mismatches - send the .txt + serial [PW]' }""",
"""                # v33 CAP-AWARE (the v32 root cause): the driver's walk
                # stops at kPwMaxEntries=64 BY DESIGN (host-proven T19a-d;
                # the v32 field run: walked=64 live=102). Compare against
                # min(live,64); membership (missing==0) is unchanged.
                $liveCap = [Math]::Min($liveProcs.Count, 64)
                $cntDelta = [Math]::Abs([int]$wCount - $liveCap)
                Write-Host ("     [W2] walked={0} live={1} (cap-aware expected={2}) delta={3} checked={4} missing={5}" -f $wCount, $liveProcs.Count, $liveCap, $cntDelta, $checked, $missing)
                if ($liveProcs.Count -gt 64) { Write-Host "     [W2] NOTE: live > the driver's 64-entry cap (by design, not a bug) - count checked against the cap" }
                $w2Ok = ($missing -eq 0) -and ($cntDelta -le 3)
                if ($w2Ok) { Write-Host '     [W2] PASS: the walked list matches the live process list (cap-aware)' }
                else       { Write-Host '     [W2] FAIL: too many mismatches - send the .txt + serial [PW]' }""",
'w2-capfix')

# =========================================================
# 8. THE NEW P-SECTION (after W5, before step N)
# =========================================================
rep(
"""} else {
    Write-Host ''
    Write-Host '--- step W: SKIPPED (anchors not converged - the walk refuses without the validated range) ---'
}

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
"""} else {
    Write-Host ''
    Write-Host '--- step W: SKIPPED (anchors not converged - the walk refuses without the validated range) ---'
}

# ============================================================
# [14b] step P: THE PAGE-TABLE LADDER (op 12 TranslateVa - v25 F4)
# Every P request: op=12, pid FFFFFFFF (kernel data - no pid gate),
# len/outN unused; req address = the TARGET kernel VA. Payload 80B:
#   rc@0, selfIdx@4, pteBase@8, cr3@16, pml4e@24, pdpte@32,
#   pde@40, pte@48, frame@56, presentMask@64, source@68,
#   selfOk@72, reads@76.
# ============================================================
$pSent = 0
$P1 = $null; $p1Ok = $false; $p1Rc = 0; $p1Mask = 0; $p1SelfOk = 0
$p1PteBase = [UInt64]0; $p1Cr3 = [UInt64]0; $p1Frame = [UInt64]0; $p1Source = 0
$P2 = $null; $p2Ok = $false
$P3 = $null; $p3Ok = $false
$P4 = $null; $p4Ok = $false
$wDtbOk = $false
if ($anOk) {
    Write-Host ''
    Write-Host '--- step P: op 12 TranslateVa - the page-table walk (v25) ---'
    Write-Host '     (PTE_BASE discovery: chain A = nt!MmPteBase .data + the 512-value structural'
    Write-Host '      check; chain B = MmPfnDatabase -> CR3 -> _MMPFN.PteAddress -> the s-identity;'
    Write-Host '      A and B must agree. The TWO-WAY PROOF: PML4E[s] -> the System CR3 frame.)'

    # ---- P1: translate pe_base (the validated image itself) ----
    Write-Host ''
    Write-Host ('--- step P1: op-12(pe_base=0x{0:X}) - the kernel image walk ---' -f $peBase)
    Canary 'pre-P1'
    try { $P1 = Send-Req (New-Req 0x1A01 12 'FFFFFFFF' 0 ('{0:X16}' -f $peBase) $null) } catch { Write-Host "[!] P1 threw: $($_.Exception.Message)" }
    $pSent++
    if ($null -ne $P1 -and $null -ne $P1.Resp -and $P1.Status -eq 1 -and $P1.Data.Length -ge 80) {
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
        Write-Host ("     [P1] rc={0} selfIdx=0x{1:X} pteBase=0x{2:X} cr3=0x{3:X}" -f $p1Rc, $p1Self, $p1PteBase, $p1Cr3)
        Write-Host ("     [P1] pml4e=0x{0:X} pdpte=0x{1:X} pde=0x{2:X} pte=0x{3:X}" -f $p1M4, $p1M3, $p1M2, $p1M1)
        Write-Host ("     [P1] frame=0x{0:X} mask=0x{1:X} source=0x{2:X} selfOk={3} reads={4}" -f $p1Frame, $p1Mask, $p1Source, $p1SelfOk, $p1Reads)
        # structural: pteBase must be one of the 512 canonical shapes
        $kPtMin = [UInt64]'0xFFFF800000000000'
        $ptbCanon = ($p1PteBase -ge $kPtMin) -and (($p1PteBase -band [UInt64]'0x0000007FFFFFFFFF') -eq 0)
        $frameOk  = ($p1Frame -gt 0) -and ($p1Frame -lt [UInt64]'0x400000000')
        $maskOk   = ($p1Mask -band 0x1F) -eq 0x1F -or ($p1Mask -band 0x17) -eq 0x17 -or ($p1Mask -band 0x13) -eq 0x13
        $p1Ok = ($p1Rc -eq 1) -and $ptbCanon -and $frameOk -and $maskOk -and ($p1SelfOk -eq 1)
        if ($p1Ok) {
            Write-Host '     [P1] PASS: the kernel image translated - all levels present, frame sane'
            if (($p1Source -band 0x10) -ne 0) { Write-Host '     [P1] PASS: chain B AGREED with chain A (the PFN bootstrap confirmed the base)' }
            else { Write-Host '     [P1] NOTE: chain B missed (unseen MmPfnDatabase RVA?) - chain A stands (structural check)' }
            Write-Host '     [P1] PASS: THE TWO-WAY PROOF - PML4E[s] points at the System CR3 frame (the page tables and the EPROCESS validated each other)'
        } else {
            Write-Host "     [P1] FAIL: rc=$p1Rc (2=no-base: both discovery chains refused - a patch level with unseen .data RVAs; report + serial [PT] tell all), mask/ptebase/frame/selfOk above"
        }
    } else {
        $st = if ($null -ne $P1) { $P1.Status } else { 'none' }
        Write-Host "     [P1] FAIL: no/bad response (status=$st) - v24 or older answers ErrUnsupported(8); serial [PT]"
    }

    # ---- P2: translate the System EPROCESS (F3's anchor) ----
    if ($null -ne $wSys -and $wSys -ne 0) {
        Write-Host ''
        Write-Host ('--- step P2: op-12(System EPROCESS=0x{0:X}) - F3 x F4: is the EPROCESS RESIDENT? ---' -f $wSys)
        Canary 'pre-P2'
        $P2 = $null
        try { $P2 = Send-Req (New-Req 0x1A02 12 'FFFFFFFF' 0 ('{0:X16}' -f $wSys) $null) } catch { Write-Host "[!] P2 threw: $($_.Exception.Message)" }
        $pSent++
        if ($null -ne $P2 -and $null -ne $P2.Resp -and $P2.Status -eq 1 -and $P2.Data.Length -ge 80) {
            $p2Rc = U32 $P2.Data 0; $p2Mask = U32 $P2.Data 64; $p2Frame = U64 $P2.Data 56
            Write-Host ("     [P2] rc={0} mask=0x{1:X} frame=0x{2:X}" -f $p2Rc, $p2Mask, $p2Frame)
            $p2Ok = ($p2Rc -eq 1) -and ((($p2Mask -band 0x1F) -eq 0x1F) -or (($p2Mask -band 0x17) -eq 0x17) -or (($p2Mask -band 0x13) -eq 0x13))
            if ($p2Ok) { Write-Host '     [P2] PASS: the EPROCESS page is RESIDENT - PTE-validated (the residency assumption REMOVED for F3 data)' }
            else       { Write-Host "     [P2] FAIL: rc=$p2Rc mask=$p2Mask (4 = not present - the page is absent: the read would be unsafe)" }
        } else { Write-Host '     [P2] FAIL: no/bad response - see raw above + serial [PT]' }
    } else { Write-Host '     [P2] SKIPPED (W1 gave no EPROCESS)' }

    # ---- P3: translate the KUSD kernel alias (the J-ladder window) ----
    Write-Host ''
    Write-Host '--- step P3: op-12(KUSD kernel alias 0xFFFFF78000000260) ---'
    Canary 'pre-P3'
    $P3 = $null
    try { $P3 = Send-Req (New-Req 0x1A03 12 'FFFFFFFF' 0 'FFFFF78000000260' $null) } catch { Write-Host "[!] P3 threw: $($_.Exception.Message)" }
    $pSent++
    if ($null -ne $P3 -and $null -ne $P3.Resp -and $P3.Status -eq 1 -and $P3.Data.Length -ge 80) {
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
    if ($null -ne $P4 -and $null -ne $P4.Resp -and $P4.Status -eq 1 -and $P4.Data.Length -ge 80) {
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

    # ---- P7: the DTB cross-check (two independent driver paths) ----
    Write-Host ''
    Write-Host '--- step P7: the DTB cross-check - W1 dtb@1056 == P1 cr3@16 ---'
    $wDtbAligned = ($wDtb -band [UInt64]'0xFFF') -eq 0
    $wDtbOk = ($wDtb -gt 0) -and $wDtbAligned -and ($wDtb -eq $p1Cr3)
    if ($wDtbOk) {
        Write-Host ('     [P7] PASS: op-11 walk-echo dtb=0x{0:X} == op-12 chain cr3 - the SAME System DirectoryTableBase via two independent paths' -f $wDtb)
    } else {
        Write-Host ('     [P7] FAIL: W1 dtb=0x{0:X} (aligned={1}) vs P1 cr3=0x{2:X} - they MUST match' -f $wDtb, $wDtbAligned, $p1Cr3)
    }
} else {
    Write-Host ''
    Write-Host '--- step P: SKIPPED (anchors not converged) ---'
}

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)""",
'p-section')

# =========================================================
# 9. INFCNT formula: + pSent
# =========================================================
rep(
"""$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites) and the W walk requests (+wSent); requests are consumed in RAM and deletes never count)'""",
"""$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent + $pSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6}+{7} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent, $pSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites), the W walk requests (+wSent) and the P translate requests (+pSent); requests are consumed in RAM and deletes never count)'""",
'infcnt')

# =========================================================
# 10. summary [15] + the F4 verdict
# =========================================================
rep(
"""    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'""",
"""    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
$f4Ok = $anOk -and $p1Ok -and $p2Ok -and $p3Ok -and $p4Ok -and $p5Ok -and $p6Ok -and $wDtbOk
if ($f4Ok) {
    Write-Host ''
    Write-Host '>>> F4 PROVEN: PAGE-TABLE TRANSLATION + RESIDENCY VALIDATION <<<'
    Write-Host 'PTE_BASE discovered by TWO independent chains (nt!MmPteBase + the PFN'
    Write-Host 'bootstrap) and the TWO-WAY PROOF holds: PML4E[s] points at the System'
    Write-Host ("CR3 (0x{0:X}) from the EPROCESS+0x28 - the page tables and the EPROCESS" -f $p1Cr3)
    Write-Host 'validated each other. The kernel image, the EPROCESS, the KUSD window and'
    Write-Host 'the IDT are all PTE-backed present - the residency assumption is GONE.'
    Write-Host 'No CR3 switching, no physical reads, no kernel calls - the self-map only.'
    Write-Host 'Next: Infinity.exe (the userspace client on the proven transport).'
} elseif ($anOk -and ($null -ne $P1)) {
    Write-Host ''
    Write-Host '>>> F4 PARTIAL/REFUSED - see the P lines (rc=2 = both discovery chains'
    Write-Host 'refused: a patch level with unseen .data RVAs - send the .txt + serial [PT]).'
}""",
'f4-verdict')

# =========================================================
# 11. summary [15] line (the numbered list)
# =========================================================
# the [14] summary line keeps its dynamic $wTxt form; ADD [15] right after it
rep(
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0}" -f $wTxt)""",
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v33: W2 is now cap-aware)" -f $wTxt)
$f4Sum = if ($f4Ok) { 'PROVEN - two-chain PTE_BASE + the two-way proof + PTE-backed residency' } elseif ($anOk -and ($null -ne $P1)) { 'REFUSED/PARTIAL - see the P lines' } else { 'SKIPPED (anchors)' }
Write-Host ("[15] F4 page tables (P1..P7)     : {0}" -f $f4Sum)""",
'summary-15')

# =========================================================
# 12. END marker
# =========================================================
rep("Write-Host '==== END v32 ===='", "Write-Host '==== END v33 ===='", 'end')

# =========================================================
# post-checks
# =========================================================
assert 'trigger test v33' in text, 'banner missing'
assert "'{0:X16}' -f $peBase" in text, 'P1 address formatting missing'
assert '$liveCap = [Math]::Min($liveProcs.Count, 64)' in text, 'cap fix missing'
assert 'U64 $W1.Data 1056' in text, 'dtb parse missing'
assert '$p1Cr3 -eq $wDtb' not in text.replace('($wDtb -eq $p1Cr3)', ''), 'cross-check form'
assert text.count('$pSent++') == 6, 'pSent count wrong'
assert '==== END v33 ====' in text, 'END missing'
DST.write_text(text, encoding='utf-8')
h = hashlib.sha256(text.encode('utf-8')).hexdigest()
print(f'wrote {DST}: {len(text)} bytes, {len(text.splitlines())} lines, sha256 {h[:16]}...')
