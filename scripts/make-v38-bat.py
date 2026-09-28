#!/usr/bin/env python3
# ============================================================================
# make-v38-bat.py — build phase-d-v38.bat from the field-run v37 bat
#
# v38 bat = the v37 bat with THE SAME 5-way driver hash guard (the v26
# binary is UNCHANGED, 6th script run - v26 = GO) + the script-side
# checks retargeted to v38 + the honest one-guard-byte story + the
# stale-script taxonomy updated: v33/v34 = the BSOD scripts (op-12
# senders), v35/v36/v37 = safe-but-obsolete (v35 gate-refuses the legal
# 33 sections; v36 re-dumps the ALREADY-captured .data; v37 SKIPS its
# ALMOSTRO dump on the 0x2E guard bug).
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v37.bat'
DST = BASE / 'patches' / 'phase-d-v38.bat'

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
# 1. the v38 header block (the v37 header demoted to history)
# =========================================================
rep(
"""rem INFINITY Phase D v37: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v36 field run (2026-09-28 06:53 -> 07:20, 27 min, ZERO
rem crashes - the 3rd consecutive crash-proof run) was a FULL
rem SUCCESS: the 11th green K/L/M/J/W regression, the gate fix
rem field-proven (nsec=33 ACCEPTED), and THE GROUND-TRUTH DUMP
rem LANDED: ntoskrnl .data = 1025488 bytes in 1002 chunks (the
rem in-VM sha256 == the received file's hash - byte-exact
rem end-to-end) + manifest + marker on the Desktop.""",
"""rem INFINITY Phase D v38: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v37 field run (2026-09-28 08:50 -> 08:51, ~90 s, ZERO
rem crashes - the 4th consecutive crash-proof run) was the 12th
rem green K/L/M/J/W regression + R9 captured live (16 neighborhood
rem qwords @0xCFC4C0-0xCFC538, incl. an EMPTY-LIST SELF-LINK
rem @0xCFC4F0) - but THE DUMP NEVER STARTED: the script printed
rem "ALMOSTRO not found / out of bounds" and no .bin landed (the
rem user saw only the .txt on the Desktop - exactly right).
rem
rem THE ROOT CAUSE (found offline, from the transcript's own
rem bytes): the section table WAS correctly read (33 sections,
rem 1320 B in 2 chunks) and ALMOSTRO IS IN IT - RVA 0xCFB000
rem VS=0x272E0, in bounds, byte-parsed from the transcript echo.
rem THE BUG: a v36-era fast-path guard - only section names
rem starting with '.' were even decoded. Harmless when the
rem target was '.data'; FATAL for 'ALMOSTRO' ('A' != '.'): the
rem name was never decoded, never matched. ONE GUARD BYTE.
rem
rem v38 = THE GUARD REMOVED (every section name is decoded now -
rem the fix is one deleted condition, validated OFFLINE against
rem the REAL v37 field table: the v38 logic finds ALMOSTRO at
rem 0xCFB000/0x272E0, the v37 logic provably cannot) + a census
rem fallback (on any future name miss the transcript alone lists
rem ALL section names - one-trip diagnosis). The dump itself is
rem byte-identical v37 machinery: ~160 KB = 157 chunks, ~4-5 min,
rem resumable, image-gated; R9 + the pre-scan unchanged; op-12
rem stays RETIRED (zero sends).
rem
rem INFINITY Phase D v37 (historical): SCRIPT-ONLY - the v26
rem driver UNCHANGED. The v36 field run (2026-09-28 06:53 ->
rem 07:20, 27 min, ZERO crashes - the 3rd consecutive crash-proof
rem run) was a FULL SUCCESS: the 11th green K/L/M/J/W regression,
rem the gate fix field-proven (nsec=33 ACCEPTED), and THE
rem GROUND-TRUTH DUMP LANDED: ntoskrnl .data = 1025488 bytes in
rem 1002 chunks (byte-exact end-to-end) + manifest + marker.""",
'1-v38-header')

# =========================================================
# 2. the script name refs (12 sites)
# =========================================================
rep('trigger-test-v37.ps1', 'trigger-test-v38.ps1', '2-scriptname', count=12)

# =========================================================
# 3. the findstr needle
# =========================================================
rep(
"""findstr /I /C:"trigger test v37" usb-d\\trigger-test-v38.ps1 >nul 2>&1""",
"""findstr /I /C:"trigger test v38" usb-d\\trigger-test-v38.ps1 >nul 2>&1""",
'3-findstr-needle')

# =========================================================
# 4. the pre-flight error text + the stale-script taxonomy
# =========================================================
rep(
"""  echo [ERROR] usb-d\\trigger-test-v38.ps1 is NOT the v37 script.
  echo A STALE v34/v33 COPY IS THE BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo A stale v35/v36 copy is SAFE but OBSOLETE: v35's gate
  echo refuses this kernel's LEGAL 33 sections; v36 re-dumps the
  echo .data section that is ALREADY captured - neither can
  echo produce the ALMOSTRO .bin this run needs.
  echo DO NOT RUN v33/v34 SCRIPTS. Replace with the v37 script
  echo from this package ^(v37 never sends op-12^).""",
"""  echo [ERROR] usb-d\\trigger-test-v38.ps1 is NOT the v38 script.
  echo A STALE v34/v33 COPY IS THE BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo A stale v35/v36/v37 copy is SAFE but OBSOLETE: v35's gate
  echo refuses this kernel's LEGAL 33 sections; v36 re-dumps the
  echo ALREADY-captured .data; v37 SKIPS its ALMOSTRO dump on the
  echo 0x2E name-guard bug - only v38 can produce the .bin.
  echo DO NOT RUN v33/v34 SCRIPTS. Replace with the v38 script
  echo from this package ^(v38 never sends op-12^).""",
'4-stale-taxonomy')

# =========================================================
# 5. the verified line (no parens - the bat paren audit)
# =========================================================
rep(
"""echo [Phase D] trigger test v37 script verified - pre-placed on the boot disk.""",
"""echo [Phase D] trigger test v38 script verified - pre-placed on the boot disk.""",
'5-verified-line')

# =========================================================
# 6. the driver-guard texts (v37 -> v38 references)
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v37 ----""",
"""rem ---- pre-flight 1: the trigger test script must be v38 ----""",
'5b-preflight-comment')
rep(
"""            echo driver for the v37 dump run.""",
"""            echo driver for the v38 dump run.""",
'6a-driver-guard-1')
rep(
"""                echo the v37 R9/D steps.""",
"""                echo the v38 R9/D steps.""",
'6b-driver-guard-2')

# =========================================================
# 7. the milestone line
# =========================================================
rep(
"""echo [Phase D] package v26d/v37 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 4: the v36 .data dump LANDED - and the offline analysis located the real target: the Mm globals cluster lives in ALMOSTRO, the section after .data; v37 = THE ALMOSTRO DUMP ~157 chunks ~4-5 min + R9 neighborhood singles + an in-script pre-scan; op-12 still retired, zero sends^). Mode %MODE%.""",
"""echo [Phase D] package v26e/v38 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 5: the v37 run was 12th-green + R9 live but its dump never started - a v36-era 0x2E name guard made the ALMOSTRO match impossible; v38 = THE GUARD REMOVED, every name decoded, validated offline against the REAL v37 field table + a census fallback; the dump: 157 chunks ~4-5 min; op-12 still retired, zero sends^). Mode %MODE%.""",
'7-milestone')

DST.write_text(text, encoding='utf-8', newline='\n')
h = hashlib.sha256(text.encode()).hexdigest()
print(f'\nwrote {DST}  {len(text)} bytes  sha256 {h}')

# sanity: paren balance on the whole bat (echo text must escape its parens)
o, c = text.count('('), text.count(')')
print(f'paren balance: ( {o} vs ) {c}  delta {o - c}')
