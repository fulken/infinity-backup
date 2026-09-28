#!/usr/bin/env python3
# ============================================================================
# make-v36.py -- build trigger-test-v36.ps1 from the FIELD-RUN v35 script
#
# v36 story (what this patch encodes):
#   The v35 field run (2026-09-28 06:01, 78 s, ZERO crashes - the crash-proof
#   design held) completed the RECON and closed the forensic loop:
#     - step 0 captured BOTH BSODs' full args: crash1 (v33) arg1
#       0xfffff807154e5078, crash2 (v34) arg1 0xfffff80551725078 - and BOTH
#       decompose EXACTLY as pdb + 0x1AD*0x30 + 8 (pdb 0xfffff807154e0000 /
#       0xfffff80551720000). R8/W1 proved the live System dtb = 0x1AD000 ->
#       pfn 0x1AD - the same pfn in both crashes. CHAIN B IS FORMALLY
#       CONFIRMED as the killer of both VMs.
#     - R1: the qword @ pe_base+0xCFB358 = 0xFFFF9C0000000000, PTE-BASE
#       SHAPED, s=0x138 (not the 0x100/0x1EF colliders) - THE LIVE
#       MmPteBase. Chain A's RVA is CORRECT for this build.
#     - R2 = 0, R3 = 0, R6 = 0x1400000000, R7 = 0x28 - four of the five
#       researched pfnDb slots are dead on this build.
#     - R4 (0xCFC500) = 0xFFFFF8064D930000 - a page-aligned kernel pointer
#       ~0x38D0000 BELOW the image: THE KILLER SLOT (its deref would be
#       0xFFFFF8064D935078 - the exact fingerprint class). R5 (0xCFC510) =
#       0xFFFFF98000000000 - same weak-check-passing poison. NEITHER is the
#       real MmPfnDatabase; ALL FIVE researched pfnDb RVAs are wrong here.
#     - D0 (1024B @ pe_base) PASSED and its bytes are in the transcript:
#       the offline parse shows nsec=33 (0x21), SOOH=0xF0, characteristics
#       0x22, ImageBase == the K-anchor pe_base, and a hotpatch-era section
#       order: .rdata@0x1000, .pdata, .idata, .edata, PROTDATA, GFIDS,
#       Pad1, .text@0x200000 (VS 0x3CBEB9), PAGE@0x5CC000, PAGELK,
#       POOLCODE, PAGEKD ... 21 more entries (incl. .data) beyond the 1024B.
#       The recon RVAs (0xCFxxxx ~ 13.6 MB) sit in the unseen TAIL region -
#       exactly where this build's .data lives.
#     - THE DUMP WAS SKIPPED BY DESIGN: the v35 D1 gate required
#       nsec -le 24; ntoskrnl LEGITIMATELY has 33 sections -> "implausible"
#       -> fail-closed skip. The parse itself was correct (sections=33,
#       SOOH=0xF0 - both right). The gate was calibrated on driver PEs and
#       small user binaries; the audit's PE-parse proof never exercised a
#       33-section kernel. Seam: the world (small PEs) vs the real kernel.
#       THIS IS WHY THE USER HAS NO ntoskrnl-data-*.bin/.manifest.txt FILES.
#
# v36 STRATEGY (script-only again; the v26 driver is UNCHANGED, 4th run):
#   - THE GATE FIX: accept nsec in [1..96] (the PE spec's practical max;
#       the v35 field truth: 33 is legal) + keep the table-fits-image bound.
#   - D2 CHUNKED: 33*40 = 1320 B > the proven 1024 B read size - the table
#       is now assembled from <=1024B chunk reads (retried x3, like the
#       dump loop) instead of one unproven-size read.
#   - Everything else BYTE-IDENTICAL to the field-run v35: the op-12
#       zero-send class-kill stands, the RECON runs again (a fresh-boot
#       MmPteBase + poison re-capture: the dump-boot's own values for the
#       offline match against the dumped bytes), W2 stays exit-race
#       tolerant, step 0 keeps the fingerprint hint for any NEW 0x50.
#   - Expected: [D] minutes of chunk traffic with ETA (resumable) ->
#     ntoskrnl-data-*.bin + .manifest.txt on the Desktop, verdict
#     'F4 RECON COMPLETE + GROUND-TRUTH DUMP CAPTURED (the VM SURVIVED)'.
#
# Usage: python3 scripts/make-v36.py
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v35.ps1'
DST = BASE / 'patches' / 'trigger-test-v36.ps1'

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
# 1. the v36 header, above the v35 header
# =========================================================
rep(
"""# INFINITY bridge trigger test v35  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v35 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v36 is SCRIPT-ONLY, the
# 4th run of the SAME field-proven binary; op-12 stays RETIRED
# (zero sends - it killed the VM twice, both fingerprint-confirmed).
#
# THE v36 STORY (one bug found, one bug fixed):
#   The v35 field run was a FULL SUCCESS *except* the dump: 78 s,
#   zero crashes, the 9th green K/L/M/J/W regression, W2 now PASS
#   (exit-race tolerant), and the RECON captured everything:
#     - MmPteBase @ pe_base+0xCFB358 = 0xFFFF9C0000000000, s=0x138
#       - PTE-BASE SHAPED live. Chain A's RVA is CORRECT here.
#     - ALL FIVE researched MmPfnDatabase RVAs are WRONG on this
#       build: R3/R6/R7 dead, R4 (0xCFC500) = a page-aligned
#       module-base-class pointer (THE killer slot - deref would be
#       pdb+0x1AD*0x30+8, the exact fingerprint of both BSODs),
#       R5 (0xCFC510) = 0xFFFFF98000000000 (same weak-check poison).
#     - step 0 gave BOTH crashes' full args: both decompose as
#       pdb + 0x1AD*0x30 + 8 with the live System dtb pfn = 0x1AD.
#   THE DUMP SKIPPED ITSELF: the v35 D1 plausibility gate wanted
#   nsec <= 24, but this kernel LEGITIMATELY has 33 sections (the
#   hotpatch-era layout: .rdata, .pdata, .idata, .edata, PROTDATA,
#   GFIDS, Pad1, .text, PAGE, PAGELK, POOLCODE, PAGEKD, ... + the
#   tail where .data and the recon RVAs live). Fail-closed did its
#   job - the VM survived and the skip was LOUD, not silent. THIS
#   is why the .bin/.manifest.txt files were never created (they
#   were NOT lost - the dump never started).
#
# v36 = the SAME crash-proof kit with the gate fixed:
#   - D1 now accepts nsec in [1..96] (PE's practical maximum).
#   - D2 assembles the section table from <=1024B chunk reads
#     (33*40 = 1320 B exceeds the proven single-read size).
#   - The RECON runs again: a fresh-boot MmPteBase + the poison
#     slots re-read on the SAME boot the dump lands from - the
#     offline analysis matches the dumped .data bytes against the
#     live R-values, zero cross-boot assumptions.
#   - The dump: minutes of [D] progress lines with ETA, resumable;
#     ntoskrnl-data-*.bin + .manifest.txt land on the Desktop.
#
# ============================================================
# INFINITY bridge trigger test v35  (run INSIDE the Windows VM,""",
'1-v36-header')

# =========================================================
# 2. driver-ID line inside the v35 header (now history)
# =========================================================
rep(
"""# REQUIRES the v26 DRIVER - UNCHANGED from v34 (memory.efi v26 RT,""",
"""# REQUIRES the v26 DRIVER - UNCHANGED from v35 (memory.efi v26 RT,""",
'2-driver-id')

# =========================================================
# 3. transcript filename
# =========================================================
rep(
"""    $transPath = Join-Path $spot ("trigger-test-v35-output-$stamp.txt")""",
"""    $transPath = Join-Path $spot ("trigger-test-v36-output-$stamp.txt")""",
'3-transpath')

# =========================================================
# 4. the banner
# =========================================================
rep(
"""Write-Host '==== INFINITY trigger test v35 (v26 driver UNCHANGED: F4 RECON + THE .data DUMP - after the SECOND 0x50, fingerprint-named: chain B derefs a garbage MmPfnDatabase at pdb+pfn*0x30+8; op-12 RETIRED this run; full K/L/M/J/W regression + the cap-aware W2 + RECON + the ground-truth dump) ===='""",
"""Write-Host '==== INFINITY trigger test v36 (v26 driver UNCHANGED: F4 ATTEMPT 3 FINISHED - the RECON is COMPLETE (MmPteBase SHAPED s=0x138 live; all 5 researched pfnDb RVAs wrong; both BSODs fingerprint-confirmed as chain B); the v35 dump SKIPPED itself because its gate wanted <=24 sections and ntoskrnl legally has 33 - v36 = the SAME crash-proof kit (op-12 still RETIRED, zero sends) with the gate fixed + the section table read in <=1024B chunks: full K/L/M/J/W regression + RECON + THE .data DUMP) ===='""",
'4-banner')

# =========================================================
# 5. the step-0 ARGS hint (both crashes now confirmed)
# =========================================================
rep(
"""            Write-Host ("      ARGS: {0} ({1})  <- v35: if this is a 0x50 from the v34 run," -f $Matches[1], $Matches[2].Trim())
            Write-Host '      compare arg1 - (a page-aligned kernel ptr): is the remainder pfn*0x30+8? = chain B'""",
"""            Write-Host ("      ARGS: {0} ({1})  <- v36: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())
            Write-Host '      (arg1 - a page-aligned kernel ptr = 0x5078 = 0x1AD*0x30+8 = chain B). Any NEW 0x50: same arithmetic'""",
'5-step0-hint')

# =========================================================
# 6. THE GATE FIX (D1): 24 -> 96
# =========================================================
rep(
"""        if ($nsec -ge 1 -and $nsec -le 24 -and $optSize -ge 0xE0 -and $optSize -le 0x400) {""",
"""        # v36: the v35 field run PROVED nsec=33 is LEGAL on this build (the
        # hotpatch-era kernel: .rdata/.pdata/.idata/.edata/PROTDATA/GFIDS/
        # Pad1/.text/PAGE*/POOLCODE/PAGEKD/... + the tail sections = 33).
        # The v35 gate (-le 24) rejected the LEGITIMATE header and skipped
        # the dump BY DESIGN (fail-closed, VM alive, skip loud). PE's
        # practical maximum is 96 sections - that is the new bound.
        if ($nsec -ge 1 -and $nsec -le 96 -and $optSize -ge 0xE0 -and $optSize -le 0x400) {""",
'6-gate-fix')

# =========================================================
# 7. D2: the chunked section-table read (1320B > the proven 1024B)
# =========================================================
rep(
"""            # ---- D2: the section array - find .data ----
            Canary 'pre-D2'
            $secRva = $lfanew + 0x18 + $optSize
            $secLen = $nsec * 40
            $d2 = $null
            try { $d2 = Send-Req (New-Req 0x1B02 1 'FFFFFFFF' $secLen ('{0:X16}' -f ($peBase + [uint64]$secRva)) $null) }
            catch { Write-Host ("[!] D2 threw: {0}" -f $_.Exception.Message) }
            $rSent++
            if ($null -ne $d2 -and $null -ne $d2.Resp -and $d2.Status -eq 1 -and $null -ne $d2.Data -and $d2.Data.Length -ge $secLen) {""",
"""            # ---- D2: the section array - find .data ----
            # v36: 33 sections x 40B = 1320B > the proven 1024B single-read
            # size, so the table is ASSEMBLED from <=1024B chunk reads
            # (each retried x3 with 150 ms sleeps, exactly like the dump
            # loop) - no unproven-size read anywhere in the kit
            Canary 'pre-D2'
            $secRva = $lfanew + 0x18 + $optSize
            $secLen = $nsec * 40
            $d2 = $null
            try {
                $d2List = New-Object System.Collections.Generic.List[byte]
                $d2Off  = [uint64]$secRva
                $d2Seq  = 0x1B02
                while ($d2Off -lt [uint64]($secRva + $secLen)) {
                    $d2Len = [int][Math]::Min(1024, ([uint64]$secRva + [uint64]$secLen) - $d2Off)
                    $d2c = $null
                    for ($try = 1; $try -le 3; $try++) {
                        try { $d2c = Send-Req (New-Req $d2Seq 1 'FFFFFFFF' $d2Len ('{0:X16}' -f ($peBase + $d2Off)) $null) } catch {}
                        if ($null -ne $d2c -and $null -ne $d2c.Resp -and $d2c.Status -eq 1 -and $null -ne $d2c.Data -and $d2c.Data.Length -eq $d2Len) { break }
                        $d2c = $null
                        Start-Sleep -Milliseconds 150
                    }
                    if ($null -eq $d2c) { throw ("section-table chunk @RVA 0x{0:X} failed x3" -f $d2Off) }
                    $d2List.AddRange($d2c.Data)
                    $d2Off += [uint64]$d2Len
                    $d2Seq++
                    $rSent++
                }
                $d2 = @{ Data = $d2List.ToArray() }
                Write-Host ("     [D2] section table assembled: {0} bytes in {1} chunk read(s)" -f $d2.Data.Length, ($d2Seq - 0x1B02))
            } catch { Write-Host ("[!] D2 threw: {0}" -f $_.Exception.Message) }
            if ($null -ne $d2 -and $null -ne $d2.Data -and $d2.Data.Length -ge $secLen -and (($secRva + $secLen) -le [int]$peSize)) {""",
'7-d2-chunked')

# =========================================================
# 8. the manifest generator name
# =========================================================
rep(
"""    $man += ("# ntoskrnl .data dump manifest - generated by trigger-test-v35")""",
"""    $man += ("# ntoskrnl .data dump manifest - generated by trigger-test-v36")""",
'8-manifest-name')

# =========================================================
# 9. [14] cosmetic: the W2 fix era
# =========================================================
rep(
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v33: W2 is now cap-aware)" -f $wTxt)""",
"""Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v35 field: the cap-aware W2 PASSed)" -f $wTxt)""",
'9-w2-era')

# =========================================================
# 10. the F4 verdict branch: the next-kit naming
# =========================================================
rep(
"""    Write-Host 'the TRUE constants for THIS build; the v36 walk kit ships with them'""",
"""    Write-Host 'the TRUE constants for THIS build; the v27/v36 walk kit ships with them'""",
'10-verdict-kit-name')

rep(
"""    Write-Host 'Next: v36 (the walk, attempt 4 - constants verified offline first).'""",
"""    Write-Host 'Next: the offline dump analysis, then the v27/v36 walk kit (attempt 4).'""",
'11-verdict-next')

# =========================================================
# 12. the END marker
# =========================================================
rep(
"""Write-Host '==== END v35 ===='""",
"""Write-Host '==== END v36 ===='""",
'12-end-marker')

# =========================================================
# write + verify
# =========================================================
DST.write_text(text, encoding='utf-8', newline='')
raw = DST.read_bytes()
print(f'wrote {DST} ({len(raw)} bytes)')
# sanity: pure ASCII, LF-only, no stray v35 script-self-references
try:
    raw.decode('ascii')
    print('ASCII: OK')
except UnicodeDecodeError as e:
    print(f'FATAL: non-ascii at {e}'); sys.exit(1)
if b'\\r' in raw:
    print('FATAL: CR found'); sys.exit(1)
# v35 markers that MUST remain (history headers stay; only the LIVE script identity changed)
for probe, want in [
    (b'trigger test v36', 2),          # banner + END marker
    (b'trigger-test-v36-output-', 1),  # transPath (the [LOG] echo uses $transPath)
    (b'-le 96', 1),                    # the gate fix
    (b'New-Req $d2Seq', 1),            # the chunked D2
    (b'generated by trigger-test-v36', 1),
    (b'INFINITY bridge trigger test v35', 1),  # the historical header stays
]:
    n = raw.count(probe)
    print(f'probe {probe!r}: {n} (want {want})', 'OK' if n == want else 'FATAL')
    if n != want:
        sys.exit(1)
print('ALL EDITS VERIFIED')
