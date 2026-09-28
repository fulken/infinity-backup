#!/usr/bin/env python3
# ============================================================================
# make-v37-bat.py — build phase-d-v37.bat from the field-run v36 bat
#
# v37 bat = the v36 bat with THE SAME 5-way driver hash guard (the v26
# binary is UNCHANGED, 5th script run - v26 = GO) + the script-side
# checks retargeted to v37 + the honest ALMOSTRO story + the
# stale-script taxonomy updated: v33/v34 = the BSOD scripts (op-12
# senders), v35/v36 = safe-but-obsolete (v35 gate-refuses the legal 33
# sections; v36 re-dumps the ALREADY-captured .data).
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v36.bat'
DST = BASE / 'patches' / 'phase-d-v37.bat'

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
# 1. the v37 header block (the v36 header demoted to history)
# =========================================================
rep(
"""rem INFINITY Phase D v36: SCRIPT-ONLY - the v26 driver UNCHANGED.""",
"""rem INFINITY Phase D v37: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v36 field run (2026-09-28 06:53 -> 07:20, 27 min, ZERO
rem crashes - the 3rd consecutive crash-proof run) was a FULL
rem SUCCESS: the 11th green K/L/M/J/W regression, the gate fix
rem field-proven (nsec=33 ACCEPTED), and THE GROUND-TRUTH DUMP
rem LANDED: ntoskrnl .data = 1025488 bytes in 1002 chunks (the
rem in-VM sha256 == the received file's hash - byte-exact
rem end-to-end) + manifest + marker on the Desktop.
rem
rem THE OFFLINE ANALYSIS RE-MAPPED THE TARGET: the dump is
rem anchor-verified (NtBuildNumber @RVA 0xC12130 = 0xF0004A65
rem + the R2 slot = 0 - the real .data of this exact binary),
rem and the FULL 33-SECTION MAP is now known: .data @0xC00000
rem VS=0xFA5D0, then ALMOSTRO @0xCFB000 VS=0x272E0 - the
rem hotpatch-era section holding the MUTABLE NONPAGED GLOBALS:
rem MmPteBase @0xCFB358, PsInitialSystemProcess @0xCFC420 AND
rem the researched MmPfnDatabase slots 0xCFC500-0xCFC510 ALL
rem live THERE. The pdb slot is NOT in .data - by structure,
rem not by accident. R5's 0xFFFFF98000000000 is IDENTIFIED as
rem the paged-pool REGION BASE constant (the system-VA
rem descriptor table in .data @0xC4FB08 proves it) - poison,
rem definitively.
rem
rem v37 = THE ALMOSTRO DUMP (the Mm globals cluster - EXPECTED
rem ~160 KB = ~157 chunks, ~4-5 min, the SAME proven image-
rem gated chunk path, just the next section's RVA window):
rem   - R9: 16 live singles around the researched slots
rem     [0xCFC4C0..0xCFC538] - the transcript echoes the
rem     neighborhood the dump covers (a cross-check)
rem   - D+: an in-script PowerShell PRE-SCAN over the dumped
rem     bytes (ZERO driver reads): the pdb value candidates +
rem     the Mm page-list LATTICE windows + 2 dump-vs-live echo
rem     checks - the answer previews IN the transcript
rem   - ntoskrnl-almostro.bin + .manifest.txt land on the
rem     Desktop next to the transcript
rem   - also fixed: the v35/v36 F4-verdict brace bug (the F4
rem     block was nested inside the F3-PARTIAL branch and never
rem     printed when F3 was green)
rem
rem DRIVER: v26-RT = 140582 bytes, sha256 c8f79b95... - THE SAME
rem BINARY (11-times field-proven op-1/op-11 paths; op-12 stays
rem dead code). v25-RT = 141154 (the FIRST BSOD binary) - refused
rem by hash as before. Test script: trigger-test-v37.ps1.
rem ============================================================
rem INFINITY Phase D v36 (historical): SCRIPT-ONLY - the v26 driver UNCHANGED.""",
'1-v37-header')

# =========================================================
# 2. the script name refs (12 sites incl. the historical headers)
# =========================================================
rep('trigger-test-v36.ps1', 'trigger-test-v37.ps1', '2-scriptname', count=12)

# =========================================================
# 3. the findstr needle
# =========================================================
rep(
"""findstr /I /C:"trigger test v36" usb-d\\trigger-test-v37.ps1 >nul 2>&1""",
"""findstr /I /C:"trigger test v37" usb-d\\trigger-test-v37.ps1 >nul 2>&1""",
'3-findstr-needle')

# =========================================================
# 4. the pre-flight error text + the stale-script taxonomy
# =========================================================
rep(
"""  echo [ERROR] usb-d\\trigger-test-v37.ps1 is NOT the v36 script.
  echo A STALE v34/v33 COPY IS THE BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo A stale v35 copy is SAFE but OBSOLETE: its dump gate refuses
  echo this kernel's LEGAL 33 sections ^(the v36 fix^) - the .bin
  echo and .manifest.txt would never appear with it.
  echo DO NOT RUN v33/v34 SCRIPTS. Replace with the v36 script
  echo from this package ^(v36 never sends op-12^).""",
"""  echo [ERROR] usb-d\\trigger-test-v37.ps1 is NOT the v37 script.
  echo A STALE v34/v33 COPY IS THE BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo A stale v35/v36 copy is SAFE but OBSOLETE: v35's gate
  echo refuses this kernel's LEGAL 33 sections; v36 re-dumps the
  echo .data section that is ALREADY captured - neither can
  echo produce the ALMOSTRO .bin this run needs.
  echo DO NOT RUN v33/v34 SCRIPTS. Replace with the v37 script
  echo from this package ^(v37 never sends op-12^).""",
'4-stale-taxonomy')

# =========================================================
# 5. the verified line (no parens - the bat paren audit)
# =========================================================
rep(
"""echo [Phase D] trigger-test-v37.ps1 verified - pre-placed on the boot disk.""",
"""echo [Phase D] trigger test v37 script verified - pre-placed on the boot disk.""",
'5-verified-line')

# =========================================================
# 6. the driver-guard texts (v36 -> v37 references)
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v36 ----""",
"""rem ---- pre-flight 1: the trigger test script must be v37 ----""",
'5b-preflight-comment')
rep(
"""            echo driver for the v36 dump run.""",
"""            echo driver for the v37 dump run.""",
'6a-driver-guard-1')
rep(
"""                echo the v36 R/D steps.""",
"""                echo the v37 R9/D steps.""",
'6b-driver-guard-2')

# =========================================================
# 7. the milestone line
# =========================================================
rep(
"""echo [Phase D] package v26/v36 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 3 COMPLETE: the recon captured MmPteBase live + proved all 5 researched pfnDb RVAs wrong; v36 = THE DUMP RETRY - the gate now accepts the legal 33 sections + the table read is chunked; op-12 still retired, zero sends^). Mode %MODE%.""",
"""echo [Phase D] package v26d/v37 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 4: the v36 .data dump LANDED - and the offline analysis located the real target: the Mm globals cluster lives in ALMOSTRO, the section after .data; v37 = THE ALMOSTRO DUMP ~157 chunks ~4-5 min + R9 neighborhood singles + an in-script pre-scan; op-12 still retired, zero sends^). Mode %MODE%.""",
'7-milestone')

DST.write_text(text, encoding='utf-8', newline='\n')
h = hashlib.sha256(text.encode()).hexdigest()
print(f'\nwrote {DST}  {len(text)} bytes  sha256 {h}')
