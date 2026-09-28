#!/usr/bin/env python3
# ============================================================================
# make-v38.py -- build trigger-test-v38.ps1 from the FIELD-RUN v37 script
#
# v38 story (what this patch encodes):
#   The v37 field run (2026-09-28 08:50 -> 08:51, ~90 s, ZERO crashes -
#   the 4th consecutive crash-proof run) was the 12th straight green
#   regression + R9 captured live (16 neighborhood qwords, incl. an
#   EMPTY-LIST SELF-LINK @0xCFC4F0 - the MmPageLocationList lattice
#   signature - and the R4/R5 values echoed @0xCFC500/0xCFC510) - but
#   THE DUMP NEVER STARTED: "[D2] ALMOSTRO not found / out of bounds".
#   No ntoskrnl-almostro.bin, nothing to send (user confirmed: only
#   the .txt landed on the Desktop).
#
#   THE ROOT CAUSE (found OFFLINE from the transcript's own [DT] bytes):
#   the section table WAS correctly read (33 sections, 1320 B in 2
#   chunks - the table itself is IN the transcript). Byte-parsing it
#   proves ALMOSTRO IS THERE: RVA 0xCFB000 VS=0x272E0, in bounds, both
#   targets (MmPteBase @0xCFB358, PsInitialSystemProcess @0xCFC420)
#   inside it. THE BUG: a v36-era fast-path guard - only names starting
#   with '.' (byte 0x2E) were ever decoded. Harmless when the target
#   was '.data'; FATAL for 'ALMOSTRO' ('A' = 0x41): the name was never
#   decoded, never matched. ONE GUARD BYTE - invisible to the 158-check
#   v37 audit (it checked the filter strings, not the guard).
#
# v38 STRATEGY (script-only AGAIN; the v26 driver is UNCHANGED, 6th run):
#   - THE GUARD REMOVED: every one of the nsec section names is decoded
#     and compared. THE FIX - one condition deleted.
#   - THE CENSUS FALLBACK: on a name miss the transcript alone carries
#     ALL section names in the table (one-trip diagnosis if it ever
#     happens again).
#   - The stale '.data'-era skip label corrected.
#   - Everything else byte-identical to the field-run v37: the same
#     ALMOSTRO dump (157 chunks), R9, the pre-scan, op-12 RETIRED.
#
# Usage: python3 scripts/make-v38.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v37.ps1'
DST = BASE / 'patches' / 'trigger-test-v38.ps1'

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
# 1. the header title + driver line
# =========================================================
rep('# INFINITY bridge trigger test v37  (run INSIDE the Windows VM,',
    '# INFINITY bridge trigger test v38  (run INSIDE the Windows VM,', '1a-title')
rep("""# REQUIRES the v26 DRIVER - UNCHANGED from v36 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v37 is SCRIPT-ONLY, the
# 5th run of the SAME field-proven binary; op-12 stays RETIRED""",
    """# REQUIRES the v26 DRIVER - UNCHANGED from v37 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v38 is SCRIPT-ONLY, the
# 6th run of the SAME field-proven binary; op-12 stays RETIRED""", '1b-driver-line')

# =========================================================
# 2. the story block (span-replace: v36 story + v37 plan -> v38)
# =========================================================
story_start = '# THE v36 STORY (a FULL SUCCESS - the dump era works):'
end_anchor = '# .manifest.txt on the Desktop next to the transcript.'
i0 = text.index(story_start)
i1 = text.index(end_anchor) + len(end_anchor)
NEW_STORY = """# THE v37 STORY (the 12th green run - ONE GUARD BYTE short of
# the dump):
#   The v37 field run (2026-09-28 08:50 -> 08:51, ~90 seconds,
#   ZERO crashes - the 4th consecutive crash-proof run):
#     - the 12th green K/L/M/J/W regression; F3 walked 64
#       processes, System at the pool EPROCESS, at the SAME
#       deterministic boot values (pe_base 0xFFFFF80651600000,
#       MmPteBase 0xFFFF9C0000000000 s=0x138, dtb=0x1AD000 - a
#       3rd identical boot in a row)
#     - R9 CAPTURED LIVE: the 16-qword neighborhood
#       @0xCFC4C0-0xCFC538, including an EMPTY-LIST SELF-LINK
#       @0xCFC4F0 (Flink=Blink=&self - the MmPageLocationList
#       lattice signature) and the R4/R5 values echoed
#       @0xCFC500/0xCFC510
#     - THE DUMP NEVER STARTED: "[D2] ALMOSTRO not found / out
#       of bounds" -> no ntoskrnl-almostro.bin, nothing to send
#       (user confirmed: only the .txt landed on the Desktop)
#
# THE ROOT CAUSE (found OFFLINE - from the transcript's own [DT]
# bytes, no field trip needed):
#     - the section table WAS correctly read + assembled: 33
#       sections, 1320 bytes in 2 chunks - the table itself is
#       IN the transcript
#     - byte-parsing it proves the section IS THERE: ***
#       ALMOSTRO RVA=0xCFB000 VS=0x272E0 *** (end 0xD222E0 <
#       pe_size - in bounds; MmPteBase @0xCFB358 and
#       PsInitialSystemProcess @0xCFC420 both inside it; .data
#       @0xC00000 VS=0xFA5D0 ends 0xCFA5D0 - the v36 .data dump
#       of 1025488 bytes was byte-exact)
#     - THE BUG: a v36-era fast-path guard - only section names
#       starting with '.' (byte 0x2E) were ever decoded.
#       Harmless while the target was '.data'; FATAL for
#       'ALMOSTRO' (starts with 'A' = 0x41): the name was never
#       decoded, never matched. ONE GUARD BYTE - invisible to
#       the 158-check v37 audit (it checked the filter strings,
#       not the guard).
#
# v38 = THE GUARD REMOVED (every one of the nsec names is
# decoded - THE FIX, one condition deleted) + the census
# fallback (on a name miss the transcript alone carries ALL
# section names - one-trip diagnosis) + the stale '.data'-era
# skip label corrected. EVERYTHING ELSE is byte-identical to
# the field-proven v37: the same ALMOSTRO dump (~160 KB = 157
# chunks ~ 4-5 min, resumable), R9 neighborhood, the in-script
# pre-scan (candidates + lattice + 2 echo checks), op-12 still
# RETIRED (zero sends).
#
# EXPECT: [R9] 16 shape-classified qwords; [D2] "ALMOSTRO
# RVA=0xCFB000 size=0x272E0 (160480 bytes) - dumping"; [D] 157
# chunks with ETA (resumable, last chunk partial 736 B); [D+] the
# pre-scan lines (the candidate census + LATTICE WINDOWs + the 2
# echo checks); ntoskrnl-almostro.bin + .manifest.txt on the
# Desktop next to the transcript."""
text = text[:i0] + NEW_STORY + text[i1:]
print('[2-story-block] OK')

# =========================================================
# 3. the transcript filename
# =========================================================
rep('    $transPath = Join-Path $spot ("trigger-test-v37-output-$stamp.txt")',
    '    $transPath = Join-Path $spot ("trigger-test-v38-output-$stamp.txt")', '3-transpath')

# =========================================================
# 4. the banner
# =========================================================
rep("Write-Host '==== INFINITY trigger test v37 (v26 driver UNCHANGED a 5th time: F4 ATTEMPT 4 - the v36 .data dump LANDED (1002 chunks, zero crashes, hash-matched) and the offline analysis re-mapped the target: the Mm globals cluster (MmPteBase@0xCFB358, PsInitialSystemProcess@0xCFC420, the researched pdb slots) lives in ALMOSTRO - the section AFTER .data - NOT in .data itself; v37 dumps ALMOSTRO (157 chunks ~4-5 min) through the SAME proven image-gated path + R9 neighborhood singles + an in-script pre-scan; op-12 still RETIRED, zero sends) ===='",
    "Write-Host '==== INFINITY trigger test v38 (v26 driver UNCHANGED a 6th time: F4 ATTEMPT 5 - the v37 run was the 12th straight green regression + R9 captured live, but the dump never started: a v36-era 0x2E first-byte guard (only dot-prefixed section names were ever decoded) made the ALMOSTRO match impossible - the section IS in the field-read table @RVA 0xCFB000 VS=0x272E0, proven by byte-parsing the v37 transcript echo; v38 removes the guard so every name is decoded + adds a census fallback; op-12 still RETIRED, zero sends) ===='",
    '4-banner')

# =========================================================
# 5. the step-0 ARGS note
# =========================================================
rep('Write-Host ("      ARGS: {0} ({1})  <- v37: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())',
    'Write-Host ("      ARGS: {0} ({1})  <- v38: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())',
    '5-args-note')

# =========================================================
# 6. minor v37 -> v38 comment swaps
# =========================================================
rep('# [14b] step R: THE CONSTANT RECON (v37 - op-12 is RETIRED)',
    '# [14b] step R: THE CONSTANT RECON (v38 - op-12 is RETIRED)', '6a-recon-comment')
rep('v37 reads the candidate slots through the PROVEN image gate instead -',
    'v38 reads the candidate slots through the PROVEN image gate instead -', '6b-recon-note')
rep('# ---- R9 (v37): the researched-slot NEIGHBORHOOD - 16 live singles ----',
    '# ---- R9 (v38): the researched-slot NEIGHBORHOOD - 16 live singles ----', '6c-r9-comment')
rep('# [15a] step D: THE ALMOSTRO DUMP (the Mm globals cluster - v37)',
    '# [15a] step D: THE ALMOSTRO DUMP (the Mm globals cluster - v38)', '6d-d-comment')
rep('# ---- the v37 PRE-SCAN (pure PowerShell over the dumped',
    '# ---- the v38 PRE-SCAN (pure PowerShell over the dumped', '6e-prescan-comment')
rep('# ---- the F4 verdict (v37: moved OUT of the F3 chain - the v35/v36',
    '# ---- the F4 verdict (v38: moved OUT of the F3 chain - the v35/v36', '6f-verdict-comment')

# =========================================================
# 7. *** THE FIX *** - the 0x2E guard removed + the census
# =========================================================
rep("""                for ($si = 0; $si -lt $nsec; $si++) {
                    if ($d2.Data[($si * 40)] -eq 0x2E) {
                        $nm = [System.Text.Encoding]::ASCII.GetString($d2.Data, ($si * 40), 8).TrimEnd([char]0)
                        # v37: the target section is ALMOSTRO (the Mm
                        # globals cluster - the v36 offline analysis
                        # proved the constants are NOT in .data)
                        if ($nm -eq 'ALMOSTRO') {
                            $dataVs  = [int](U32 $d2.Data ($si * 40 + 8))
                            $dataRva = [int](U32 $d2.Data ($si * 40 + 12))
                            break
                        }
                    }
                }""",
"""                for ($si = 0; $si -lt $nsec; $si++) {
                    # v38: THE 0x2E-GUARD FIX. v36/v37 carried a fast-path
                    # guard here: only names starting with '.' (byte 0x2E)
                    # were even decoded. Harmless while the target was
                    # '.data' - FATAL in the v37 field run: 'ALMOSTRO'
                    # starts with 'A' (0x41), so the name was never decoded,
                    # never matched; the section WAS in the table (RVA
                    # 0xCFB000 VS=0x272E0 - byte-parsed from the v37
                    # transcript's own [DT] echo). The guard is GONE: every
                    # one of the nsec names is decoded now.
                    $nm = [System.Text.Encoding]::ASCII.GetString($d2.Data, ($si * 40), 8).TrimEnd([char]0)
                    if ($nm -eq 'ALMOSTRO') {
                        $dataVs  = [int](U32 $d2.Data ($si * 40 + 8))
                        $dataRva = [int](U32 $d2.Data ($si * 40 + 12))
                        break
                    }
                }
                if ($dataRva -eq 0) {
                    # v38: the census fallback - if the target name ever
                    # mismatches again, the transcript alone carries EVERY
                    # section name in the table (one-trip diagnosis)
                    $census = ''
                    for ($si = 0; $si -lt $nsec; $si++) {
                        $census += [System.Text.Encoding]::ASCII.GetString($d2.Data, ($si * 40), 8).TrimEnd([char]0) + ' '
                    }
                    Write-Host ("     [D2] census of all {0} sections: {1}" -f $nsec, $census)
                }""",
'7-THE-GUARD-FIX')

# =========================================================
# 8. the stale '.data'-era skip label
# =========================================================
rep("                    $dumpInfoTxt = 'SKIPPED (no .data section / bounds)'",
    "                    $dumpInfoTxt = 'SKIPPED (the ALMOSTRO section not found / out of bounds)'",
    '8-skip-label')

# =========================================================
# 9. the manifest generator tag
# =========================================================
rep("$man += (\"# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v37\")",
    "$man += (\"# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v38\")",
    '9-manifest-tag')

# =========================================================
# 10. the END marker
# =========================================================
rep("Write-Host '==== END v37 ===='",
    "Write-Host '==== END v38 ===='", '10-end-marker')

DST.write_text(text, encoding='utf-8', newline='\n')
h = hashlib.sha256(text.encode()).hexdigest()
print(f'\nwrote {DST}  {len(text)} bytes  sha256 {h}')

# integrity: no stray v37 self-references left (except the story/history)
stray = [ln for ln in text.splitlines() if 'v37' in ln and not ln.lstrip().startswith('#')]
print(f'non-comment v37 mentions left (expect only none): {len(stray)}')
for ln in stray: print('   ', ln[:100])
