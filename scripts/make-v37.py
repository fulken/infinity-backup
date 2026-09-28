#!/usr/bin/env python3
# ============================================================================
# make-v37.py -- build trigger-test-v37.ps1 from the FIELD-RUN v36 script
#
# v37 story (what this patch encodes):
#   The v36 field run (2026-09-28 06:53 -> 07:20, 27m11s, ZERO crashes -
#   the 3rd consecutive crash-proof run) was a FULL SUCCESS:
#     - the 11th green K/L/M/J/W regression (W2 exit-race tolerant)
#     - the gate fix field-proven (nsec=33 ACCEPTED; v35's <=24 had
#       refused the LEGAL 33-section kernel header)
#     - THE GROUND-TRUTH DUMP LANDED: .data = 1025488 B / 1002 chunks,
#       in-VM sha256 == the received file's hash (byte-exact transport)
#     - the R-section repeated the v35 boot values EXACTLY (this VM
#       boots deterministically: same pe_base 0xFFFFF80651600000, same
#       MmPteBase 0xFFFF9C0000000000 s=0x138, same R4/R5 poison)
#   THE OFFLINE ANALYSIS OF THE DUMP re-mapped the target:
#     - ANCHOR-VERIFIED (NtBuildNumber @RVA 0xC12130 = 0xF0004A65,
#       the R2 slot @0xCFA358 = 0) - the dump IS the real .data
#     - THE FULL 33-SECTION MAP: .data @0xC00000 VS=0xFA5D0, then
#       ALMOSTRO @0xCFB000 VS=0x272E0 - the hotpatch-era section that
#       holds the MUTABLE NONPAGED GLOBALS: MmPteBase @0xCFB358,
#       PsInitialSystemProcess @0xCFC420 AND the researched pdb slots
#       0xCFC500-0xCFC510 ALL live THERE. The .data dump CANNOT contain
#       the pdb slot - by structure, not by accident.
#     - R5's 0xFFFFF98000000000 IDENTIFIED: the system-VA region
#       descriptor table (.data @RVA 0xC4FB08) shows it is the PAGED-
#       POOL REGION BASE - a layout CONSTANT. Definitively not pdb.
#     - the same table independently records the PTE-space region
#       [0xFFFF9C0000000000, +512GB) - chain A's constant, x2-proven.
#
# v37 STRATEGY (script-only AGAIN; the v26 driver is UNCHANGED, 5th run):
#   - THE TARGET MOVES ONE SECTION RIGHT: dump ALMOSTRO (EXPECTED
#     ~160 KB = ~157 chunks ~ 4-5 min) through the SAME proven op-1
#     image-gated 1024B chunk path - just the next section's RVA
#     window, still 100% inside [pe_base, pe_base+pe_size).
#   - R9 (NEW): 16 live singles around the researched slots
#     [0xCFC4C0..0xCFC538) - the transcript echoes the neighborhood
#     (the dump covers the same bytes; this is the visible proof).
#   - THE IN-SCRIPT PRE-SCAN (NEW, pure PowerShell over the dumped
#     bytes - ZERO driver reads): pdb value candidates (page-aligned
#     canonical non-image) + the MmPageLocationList-style LATTICE
#     windows (>=3 same-residue-mod-0x30 array links + >=2 empty-list
#     self-links pointing home) + 2 dump-vs-live echo cross-checks.
#   - THE F4-BRACE BUG FIXED: in v35/v36 the F4 verdict block was
#     nested INSIDE the F3-PARTIAL branch (a brace-structure bug), so
#     it never printed when F3 was PROVEN - the normal green path.
#     v37 moves it to top level after the F3 chain.
#   - Everything else byte-identical to the field-run v36: op-12 zero
#     sends, gate 1..96, chunked D2, dynamic INFCNT accounting.
#
# Usage: python3 scripts/make-v37.py
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v36.ps1'
DST = BASE / 'patches' / 'trigger-test-v37.ps1'

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
# 1. the v37 header, above the v36 header
# =========================================================
rep(
"""# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v37  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v36 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v37 is SCRIPT-ONLY, the
# 5th run of the SAME field-proven binary; op-12 stays RETIRED
# (zero sends - it killed the VM twice, both fingerprint-confirmed).
#
# THE v36 STORY (a FULL SUCCESS - the dump era works):
#   The v36 field run (2026-09-28 06:53 -> 07:20, 27 minutes,
#   ZERO crashes - the 3rd consecutive crash-proof run):
#     - the 11th green K/L/M/J/W regression (W2 exit-tolerant)
#     - the gate fix field-proven: nsec=33 ACCEPTED (v35's <=24
#       gate had refused the LEGAL 33-section kernel header)
#     - THE GROUND-TRUTH DUMP LANDED: ntoskrnl .data = 1025488
#       bytes in 1002 chunks (the in-VM sha256 == the received
#       file's hash - byte-exact end-to-end) + manifest + marker
#     - the R-section repeated the v35 boot values EXACTLY (this
#       VM boots deterministically: same pe_base, same MmPteBase
#       0xFFFF9C0000000000 s=0x138, same R4/R5 poison)
#
# THE OFFLINE ANALYSIS OF THE .data DUMP (what it taught us):
#     - ANCHOR-VERIFIED: NtBuildNumber @RVA 0xC12130 = 0xF0004A65
#       (build 19045) + the R2 slot @0xCFA358 = 0 - the dump IS
#       the real .data of this exact binary
#     - THE FULL 33-SECTION MAP: .data @0xC00000 VS=0xFA5D0, then
#       *** ALMOSTRO @0xCFB000 VS=0x272E0 *** - the hotpatch-era
#       section that holds the MUTABLE NONPAGED GLOBALS: MmPteBase
#       @0xCFB358, PsInitialSystemProcess @0xCFC420 AND the
#       researched MmPfnDatabase slots 0xCFC500-0xCFC510 all live
#       THERE. THE .data DUMP CANNOT CONTAIN the pdb slot - not by
#       accident, BY STRUCTURE.
#     - R5's 0xFFFFF98000000000 IDENTIFIED: the system-VA region
#       descriptor table (found in .data @RVA 0xC4FB08) shows it
#       is the PAGED-POOL REGION BASE - a layout CONSTANT, not a
#       dynamic allocation. Definitively not the pdb.
#     - the same table independently records the PTE-space region
#       from 0xFFFF9C0000000000 spanning +512GB - chain A's constant,
#       twice confirmed.
#
# v37 = THE ALMOSTRO DUMP (the Mm globals cluster, EXPECTED ~160 KB
# = ~157 chunks ~ 4-5 min - the SAME proven image-gated chunk path,
# just the NEXT section's RVA window inside the validated image) +
# R9 (16 live singles around the researched slots) +
# an in-script PowerShell PRE-SCAN (pdb candidates + the page-list
# LATTICE windows + 2 dump-vs-live echo checks - no driver reads).
# NOTHING here can fault: every read stays inside the validated
# image; the pre-scan only touches the .bin bytes on disk.
#
# EXPECT: [R9] 16 shape-classified qwords; [D] ~157 chunks with
# ETA (resumable); [D+] the pre-scan lines; ntoskrnl-almostro.bin +
# .manifest.txt on the Desktop next to the transcript.
#
# ============================================================
# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,""",
'1-v37-header')

# =========================================================
# 2. driver-ID line inside the v36 header (now history)
#    (anchored with the v36 title line - the demoted v35 header
#     carries the SAME driver-ID text and must stay untouched)
# =========================================================
rep(
"""# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v35 (memory.efi v26 RT,""",
"""# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v36 (memory.efi v26 RT,""",
'2-driver-id')

# =========================================================
# 3. transcript filename
# =========================================================
rep(
"""    $transPath = Join-Path $spot ("trigger-test-v36-output-$stamp.txt")""",
"""    $transPath = Join-Path $spot ("trigger-test-v37-output-$stamp.txt")""",
'3-transpath')

# =========================================================
# 4. the banner
# =========================================================
rep(
"""Write-Host '==== INFINITY trigger test v36 (v26 driver UNCHANGED: F4 ATTEMPT 3 FINISHED - the RECON is COMPLETE (MmPteBase SHAPED s=0x138 live; all 5 researched pfnDb RVAs wrong; both BSODs fingerprint-confirmed as chain B); the v35 dump SKIPPED itself because its gate wanted <=24 sections and ntoskrnl legally has 33 - v36 = the SAME crash-proof kit (op-12 still RETIRED, zero sends) with the gate fixed + the section table read in <=1024B chunks: full K/L/M/J/W regression + RECON + THE .data DUMP) ===='""",
"""Write-Host '==== INFINITY trigger test v37 (v26 driver UNCHANGED a 5th time: F4 ATTEMPT 4 - the v36 .data dump LANDED (1002 chunks, zero crashes, hash-matched) and the offline analysis re-mapped the target: the Mm globals cluster (MmPteBase@0xCFB358, PsInitialSystemProcess@0xCFC420, the researched pdb slots) lives in ALMOSTRO - the section AFTER .data - NOT in .data itself; v37 dumps ALMOSTRO (157 chunks ~4-5 min) through the SAME proven image-gated path + R9 neighborhood singles + an in-script pre-scan; op-12 still RETIRED, zero sends) ===='""",
'4-banner')

# =========================================================
# 5. the step-0 ARGS hint (label bump v36 -> v37)
# =========================================================
rep(
"""            Write-Host ("      ARGS: {0} ({1})  <- v36: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())""",
"""            Write-Host ("      ARGS: {0} ({1})  <- v37: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())""",
'5-step0-hint')

# =========================================================
# 6. R-step stale print (said 'v35') + the step-R comment label
# =========================================================
rep(
"""    Write-Host '      v35 reads the candidate slots through the PROVEN image gate instead -'""",
"""    Write-Host '      v37 reads the candidate slots through the PROVEN image gate instead -'""",
'6a-r-print')
rep(
"""# [14b] step R: THE CONSTANT RECON (v35 - op-12 is RETIRED)""",
"""# [14b] step R: THE CONSTANT RECON (v37 - op-12 is RETIRED)""",
'6b-r-comment')

# =========================================================
# 7. R9: the researched-slot NEIGHBORHOOD (16 live singles) -
#    inserted after R8, before the R-step anOk-else
# =========================================================
rep(
"""    } else {
        Write-Host '     [R8] SKIPPED (W1 did not echo a dtb - the walk refused?)'
        $reconTxt = 'RECON PARTIAL (no W dtb echo)'
    }
} else {""",
"""    } else {
        Write-Host '     [R8] SKIPPED (W1 did not echo a dtb - the walk refused?)'
        $reconTxt = 'RECON PARTIAL (no W dtb echo)'
    }

    # ---- R9 (v37): the researched-slot NEIGHBORHOOD - 16 live singles ----
    # The v36 offline analysis mapped this build's layout: the Mm globals
    # cluster (MmPteBase@0xCFB358, PsInitialSystemProcess@0xCFC420, the
    # researched pdb slots 0xCFC500-0xCFC510) lives in ALMOSTRO - the
    # section AFTER .data. These 16 singles echo the researched-slot
    # neighborhood into the transcript LIVE (the D-step dump below covers
    # the same bytes - the transcript then shows both, a cross-check).
    Write-Host ''
    Write-Host '--- step R9: the researched-slot neighborhood (op-1 image-gated 8B reads; 16 qwords @0xCFC4C0..0xCFC538) ---'
    $r9Base = 0xCFC4C0
    for ($r9i = 0; $r9i -lt 16; $r9i++) {
        $r9Rva = $r9Base + ($r9i * 8)
        Canary ("pre-R9-" + [string]$r9i)
        $r9 = $null
        try { $r9 = Send-Req (New-Req $seqR 1 'FFFFFFFF' 8 ('{0:X16}' -f ($peBase + [uint64]$r9Rva)) $null) }
        catch { Write-Host ("[!] R9+0x{0:X2} threw: {1}" -f ($r9i * 8), $_.Exception.Message) }
        $rSent++
        $seqR++
        $r9v = [UInt64]0; $r9ok = $false
        if ($null -ne $r9 -and $null -ne $r9.Resp -and $r9.Status -eq 1 -and $null -ne $r9.Data -and $r9.Data.Length -ge 8) {
            $r9v = U64 $r9.Data 0; $r9ok = $true
        }
        if ($r9ok) {
            $r9al = ($r9v -band [UInt64]0xFFF) -eq [UInt64]0
            $r9cn = ($r9v -ge [UInt64]'0xFFFF800000000000')
            $r9im = $r9cn -and ($r9v -ge [UInt64]$peBase) -and ($r9v -lt ([UInt64]$peBase + [UInt64]$peSize))
            $r9t = 'dead/low'
            if ($r9im) {
                $r9t = 'in-IMAGE ptr' + $(if ($r9al) { ', page-aligned' } else { '' })
            } elseif ($r9cn) {
                $r9t = 'KERNEL ptr' + $(if ($r9al) { (", PAGE-ALIGNED res=0x{0:X}" -f [int]($r9v % [UInt64]48)) } else { '' })
            }
            Write-Host ("     [R9+0x{0:X2}] @0x{1:X} = 0x{2:X16}  {3}" -f ($r9i * 8), $r9Rva, $r9v, $r9t)
        } else {
            Write-Host ("     [R9+0x{0:X2}] @0x{1:X} FAIL: no data (status={2})" -f ($r9i * 8), $r9Rva, $(if ($null -ne $r9) { $r9.Status } else { 'none' }))
        }
    }
} else {""",
'7-r9-block')

# =========================================================
# 8. the [15a] step-D comment block (.data -> ALMOSTRO)
# =========================================================
rep(
"""# [15a] step D: THE .data DUMP (the ground-truth capture - v35)
# The whole .data section through the SAME op-1 image gate, 1024B
# per request. This is what the offline analysis uses to pin the
# TRUE constants for this exact build (the end of researched-RVA
# guessing - it cost two VMs). Self-verified + resumable + manifest.
# EXPECT ~2000-4000 chunks: minutes of quiet hook traffic. The
# progress line shows the ETA. NOTHING here can fault: every read
# is inside [pe_base, pe_base+pe_size) - the L1-L5-proven gate.""",
"""# [15a] step D: THE ALMOSTRO DUMP (the Mm globals cluster - v37)
# The v36 offline analysis proved the Mm constants live in ALMOSTRO
# (the section AFTER .data: MmPteBase@0xCFB358 + PsInitialSystem-
# Process@0xCFC420 + the researched pdb slots are all in it). The
# whole ALMOSTRO section (EXPECTED ~160 KB = ~157 chunks, ~4-5 min)
# through the SAME op-1 image gate, 1024B per request, self-verified
# + resumable + manifest - the same machinery that captured .data
# flawlessly in the v36 field run. NOTHING here can fault: every
# read is inside [pe_base, pe_base+pe_size) - the L1-L5-proven gate.""",
'8-stepD-comment')

# =========================================================
# 9. the step-D banner print
# =========================================================
rep(
"""    Write-Host '--- step D: the .data dump (op-1 image-gated 1024B chunks; minutes; resumable) ---'""",
"""    Write-Host '--- step D: the ALMOSTRO dump (op-1 image-gated 1024B chunks; ~4-5 minutes; resumable) ---'""",
'9-stepD-banner')

# =========================================================
# 10. THE SECTION FILTER: .data -> ALMOSTRO
# =========================================================
rep(
"""                        if ($nm -eq '.data') {""",
"""                        # v37: the target section is ALMOSTRO (the Mm
                        # globals cluster - the v36 offline analysis
                        # proved the constants are NOT in .data)
                        if ($nm -eq 'ALMOSTRO') {""",
'10-section-filter')

# =========================================================
# 11. the D2 print + the dump basename + the not-found line
# =========================================================
rep(
"""                    Write-Host ("     [D2] .data RVA=0x{0:X} size=0x{1:X} ({2} bytes) - dumping" -f $dataRva, $dataVs, $dataVs)""",
"""                    Write-Host ("     [D2] ALMOSTRO RVA=0x{0:X} size=0x{1:X} ({2} bytes) - dumping (the Mm globals cluster)" -f $dataRva, $dataVs, $dataVs)""",
'11a-d2-print')
rep(
"""                    $dumpBase = Join-Path $spot2 'ntoskrnl-data'""",
"""                    $dumpBase = Join-Path $spot2 'ntoskrnl-almostro'""",
'11b-dumpbase')
rep(
"""                    Write-Host '     [D2] .data not found / out of bounds in the section table - dump SKIPPED (report it)'""",
"""                    Write-Host '     [D2] ALMOSTRO not found / out of bounds in the section table - dump SKIPPED (report it)'""",
'11c-notfound')

# =========================================================
# 12. the manifest (ALMOSTRO labels + the r9 window line)
# =========================================================
rep(
"""                    $man += ("# ntoskrnl .data dump manifest - generated by trigger-test-v36")""",
"""                    $man += ("# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v37")
                    $man += ("sec_name=ALMOSTRO")""",
'12a-manifest-head')
rep(
"""                    $man += ("data_rva=0x{0:X}" -f $dataRva)
                    $man += ("data_vs=0x{0:X}" -f $dataVs)""",
"""                    $man += ("sec_rva=0x{0:X}" -f $dataRva)
                    $man += ("sec_vs=0x{0:X}" -f $dataVs)
                    $man += ("r9_window=0xCFC4C0..0xCFC538")""",
'12b-manifest-fields')

# =========================================================
# 13. THE PRE-SCAN (in-script, pure PowerShell over the .bin)
# =========================================================
rep(
"""                    [System.IO.File]::WriteAllLines("$dumpBase.manifest.txt", $man)
                    Write-Host ("     [D] manifest -> {0}.manifest.txt" -f $dumpBase)
                    Write-Host '     [D] SEND THE .bin + .manifest.txt + this .txt OUT with the usual report zip.'""",
"""                    [System.IO.File]::WriteAllLines("$dumpBase.manifest.txt", $man)
                    Write-Host ("     [D] manifest -> {0}.manifest.txt" -f $dumpBase)
                    Write-Host '     [D] SEND THE .bin + .manifest.txt + this .txt OUT with the usual report zip.'

                    # ---- the v37 PRE-SCAN (pure PowerShell over the dumped
                    #      .bin bytes on disk - ZERO driver reads; this block
                    #      cannot touch the VM. It prints the pdb value
                    #      candidates + the Mm page-list LATTICE windows +
                    #      2 dump-vs-live echo cross-checks, so the answer is
                    #      visible IN the transcript; the offline analysis
                    #      re-scans and ranks from the .bin itself.) ----
                    if ($dumpOk) {
                        Write-Host ''
                        Write-Host '--- step D+: the ALMOSTRO pre-scan (in-script, no driver reads) ---'
                        try {
                            $db = [System.IO.File]::ReadAllBytes($dumpPath)
                            if ($db.Length -eq [int64]$dataVs) {
                                $peLo = [UInt64]$peBase
                                $peHi = [UInt64]$peBase + [UInt64]$peSize
                                $nq = [int]([Math]::Floor($db.Length / 8))
                                $qa = New-Object 'UInt64[]' $nq
                                for ($i = 0; $i -lt $nq; $i++) { $qa[$i] = [UInt64]([BitConverter]::ToUInt64($db, $i * 8)) }
                                # (a) pdb VALUE candidates: page-aligned + canonical + non-image
                                $cands = New-Object System.Collections.Generic.List[object]
                                for ($i = 0; $i -lt $nq; $i++) {
                                    $v = $qa[$i]
                                    if (($v -band [UInt64]0xFFF) -eq [UInt64]0 -and $v -ge [UInt64]'0xFFFF800000000000' -and -not (($v -ge $peLo) -and ($v -lt $peHi))) {
                                        $cands.Add([pscustomobject]@{ o = ($i * 8); v = $v; r = [int]($v % [UInt64]48) })
                                    }
                                }
                                Write-Host ("     [D+] pdb value candidates (page-aligned, canonical, non-image): {0}" -f $cands.Count)
                                # (b) the MmPageLocationList-style LATTICE: 128-byte
                                #     windows with >=3 same-residue array links
                                #     (mod 0x30 - the _MMPFN stride) + >=2 empty-list
                                #     self-links pointing back INTO the window
                                $latRes = @{}
                                $wi = 0
                                while ($wi -le ($db.Length - 128)) {
                                    $resC = @{}; $self = 0
                                    for ($k = 0; $k -lt 16; $k++) {
                                        $v = $qa[[int](($wi / 8) + $k)]
                                        if ($v -ge [UInt64]'0xFFFF800000000000') {
                                            if (($v -ge $peLo) -and ($v -lt $peHi)) {
                                                $tgt = $v - $peLo
                                                $lo2 = [UInt64]($dataRva + $wi)
                                                $hi2 = [UInt64]($dataRva + $wi + 128)
                                                if ($tgt -ge $lo2 -and $tgt -lt $hi2) { $self++ }
                                            } else {
                                                $rk = [int]($v % [UInt64]48)
                                                if ($resC.ContainsKey($rk)) { $resC[$rk] = $resC[$rk] + 1 } else { $resC[$rk] = 1 }
                                            }
                                        }
                                    }
                                    $bestR = -1; $bestN = 0
                                    foreach ($rk in $resC.Keys) { if ($resC[$rk] -gt $bestN) { $bestN = $resC[$rk]; $bestR = $rk } }
                                    if ($bestN -ge 3 -and $self -ge 2) {
                                        Write-Host ("     [D+] LATTICE WINDOW dump 0x{0:X} rva 0x{1:X}: res=0x{2:X} links={3} selflinks={4}" -f $wi, ($dataRva + $wi), $bestR, $bestN, $self)
                                        $latRes[$bestR] = $true
                                        $wi += 120
                                    } else { $wi += 8 }
                                }
                                if ($latRes.Count -eq 0) { Write-Host '     [D+] no lattice window found (the offline analysis re-scans the .bin anyway)' }
                                # (c) the candidates, residue-tagged (lattice residues marked)
                                $shown = 0
                                foreach ($cd2 in ($cands | Sort-Object -Property r, o)) {
                                    $tag = ''
                                    if ($latRes.ContainsKey($cd2.r)) { $tag = '  <-- LATTICE-MATCH' }
                                    Write-Host ("       cand dump 0x{0:X6} rva 0x{1:X6} val 0x{2:X16} res 0x{3:X2}{4}" -f $cd2.o, ($dataRva + $cd2.o), $cd2.v, $cd2.r, $tag)
                                    $shown++
                                    if ($shown -ge 40) { Write-Host '       ... (all are in the .bin - the offline analysis ranks them)'; break }
                                }
                                # (d) dump-vs-live echo cross-checks (2 slots this run read LIVE)
                                $off1 = 0xCFB358 - $dataRva
                                if ($off1 -ge 0 -and ($off1 + 8) -le $db.Length) {
                                    Write-Host ("     [D+] echo: dump[0x{0:X}] (RVA 0xCFB358, the MmPteBase slot) = 0x{1:X16} (R1 read it live above)" -f $off1, (U64 $db $off1))
                                }
                                $off2 = 0xCFC420 - $dataRva
                                if ($off2 -ge 0 -and ($off2 + 8) -le $db.Length) {
                                    Write-Host ("     [D+] echo: dump[0x{0:X}] (RVA 0xCFC420, the PsInitialSystemProcess slot) = 0x{1:X16} (W1 echoed the EPROC 0x{2:X})" -f $off2, (U64 $db $off2), $wSys)
                                }
                            } else {
                                Write-Host ("     [D+] dump size {0} != section vs {1} - scan skipped (send everything)" -f $db.Length, $dataVs)
                            }
                        } catch { Write-Host ("     [D+] pre-scan threw: {0} (harmless - the .bin is what matters)" -f $_.Exception.Message) }
                    }""",
'13-prescan')

# =========================================================
# 14. the summary labels ([14] v35->v36 field, [15] R1..R9)
# =========================================================
rep(
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v35 field: the cap-aware W2 PASSed)" -f $wTxt)""",
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v36 field: the cap-aware W2 PASSed)" -f $wTxt)""",
'14a-summary-14')
rep(
"""Write-Host ("[15] F4 constants recon (R1..R8) : {0}" -f $f4Sum)""",
"""Write-Host ("[15] F4 constants recon (R1..R9) : {0}" -f $f4Sum)""",
'14b-summary-15')

# =========================================================
# 15. THE F4-BRACE FIX + the F4 verdict text + END marker
#     (v35/v36 bug: the F4 block was nested inside the F3-PARTIAL
#      branch - it never printed when F3 was PROVEN. v37 moves it
#      to top level, after the F3 chain closes.)
# =========================================================
rep(
"""} elseif ($anOk -and $wCount -ge 1) {
    Write-Host ''
    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
$f4Ok = $anOk -and $reconPteOk -and $dumpOk
if ($f4Ok) {
    Write-Host ''
    Write-Host '>>> F4 RECON COMPLETE + GROUND-TRUTH DUMP CAPTURED (the VM SURVIVED) <<<'
    Write-Host 'A pte-base-shaped MmPteBase candidate was found in-image (s below) and the'
    Write-Host ('whole .data section is on the stick ({0}). The offline analysis pins' -f $dumpInfoTxt)
    Write-Host 'the TRUE constants for THIS build; the v27/v36 walk kit ships with them'
    Write-Host 'VERIFIED - chain B is retired until then, and its replacement must'
    Write-Host 'pass a mapped-by-construction proof before any deref.'
    Write-Host ("recon pte-base s=0x{0:X}  w_dtb=0x{1:X}" -f $reconPteS, $wDtb)
    Write-Host 'Next: the offline dump analysis, then the v27/v36 walk kit (attempt 4).'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F4 RECON PARTIAL (no pte-base-shaped candidate or the dump did not complete) <<<'
    Write-Host 'That is NOT a failure of the bridge: the researched RVAs are simply not this'
    Write-Host ("build's layout. The dump ({0}) + the .txt are exactly what the offline" -f $dumpInfoTxt)
    Write-Host 'analysis needs - send everything. The VM is alive by construction.'
}
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F3 NOT PROVEN THIS RUN (the walk refused or was skipped). <<<'
    Write-Host 'Refusals are clean by design - the payload status + serial [PW] name it.'
}
Write-Host '==== END v36 ===='""",
"""} elseif ($anOk -and $wCount -ge 1) {
    Write-Host ''
    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F3 NOT PROVEN THIS RUN (the walk refused or was skipped). <<<'
    Write-Host 'Refusals are clean by design - the payload status + serial [PW] name it.'
}

# ---- the F4 verdict (v37: moved OUT of the F3 chain - the v35/v36
#      brace bug nested it inside the F3-PARTIAL branch, so it never
#      printed when F3 was PROVEN, the normal green path; only the
#      [15] summary line carried the dump status) ----
$f4Ok = $anOk -and $reconPteOk -and $dumpOk
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
}
Write-Host '==== END v37 ===='""",
'15-f4-brace-fix')

# =========================================================
# 16. the F3 PROVEN 'Next:' line (the F4 pointer)
# =========================================================
rep(
"""    Write-Host 'Next: F4 (PTE/page-table base for arbitrary-VA validation), then Infinity.exe.'""",
"""    Write-Host 'Next: F4 (the ALMOSTRO constants + the walk), then Infinity.exe.'""",
'16-f3-next')

DST.write_text(text, encoding='utf-8', newline='\n')
import hashlib
h = hashlib.sha256(text.encode()).hexdigest()
print(f'\nwrote {DST}  {len(text)} bytes  sha256 {h}')
