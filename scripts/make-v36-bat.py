#!/usr/bin/env python3
# ============================================================================
# make-v36-bat.py — build phase-d-v36.bat from the field-run v35 bat
#
# v36 bat = the v35 bat with THE SAME 5-way driver hash guard (the v26
# binary is UNCHANGED, 4th script run - v26 = GO) + the script-side checks
# retargeted to v36 + the honest gate-bug story (33 sections is LEGAL;
# the v35 gate wanted <=24; the skip was fail-closed BY DESIGN) + the
# stale-script taxonomy updated: v33/v34 = the BSOD scripts (op-12 senders),
# v35 = safe-but-obsolete (its gate refuses the legal 33 sections).
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v35.bat'
DST = BASE / 'patches' / 'phase-d-v36.bat'

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
# 1. the v36 header block (the v35 header demoted to history)
# =========================================================
rep(
"""rem INFINITY Phase D v35: SCRIPT-ONLY - the v26 driver UNCHANGED.""",
"""rem INFINITY Phase D v36: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v35 field run (2026-09-28 06:01, 78 s, ZERO crashes) ended
rem the crash era: the 9th green K/L/M/J/W regression, W2 now PASS
rem (exit-race tolerant), op-12 never sent - and the RECON captured
rem the F4 ground truth: MmPteBase = 0xFFFF9C0000000000 (s=0x138)
rem at RVA 0xCFB358 LIVE, ALL FIVE researched MmPfnDatabase RVAs
rem wrong for this build (2 are page-aligned POISON pointers that
rem pass the old weak check - one at 0xCFC500 is the exact killer
rem slot class), and BOTH BSODs fingerprint-confirmed (each arg1
rem decomposes as pdb + 0x1AD*0x30 + 8 - the chain B raw deref -
rem with the live System dtb pfn = 0x1AD).
rem
rem THE DUMP SKIPPED ITSELF - BY DESIGN: the v35 D1 plausibility
rem gate wanted nsec <= 24; ntoskrnl LEGALLY has 33 sections (the
rem hotpatch-era layout: .rdata/.pdata/.idata/.edata/PROTDATA/
rem GFIDS/Pad1/.text/PAGE/PAGELK/POOLCODE/PAGEKD/... + the tail
rem sections where .data and the recon RVAs live). Fail-closed
rem worked exactly as designed: the VM survived, the skip was
rem LOUD. THAT is why the ntoskrnl-data-*.bin / .manifest.txt
rem files never appeared - they were never created. Nothing was
rem lost; nothing was the user's fault.
rem
rem v36 = the SAME crash-proof kit with the gate fixed:
rem   - D1 accepts nsec in [1..96] (33 is legal; 96 = the PE max)
rem   - D2 assembles the 33*40 = 1320B section table from
rem     <=1024B chunk reads (retried x3 - no unproven-size read)
rem   - The RECON re-runs on the dump boot: the offline analysis
rem     will match the live R-values against the dumped bytes
rem   - Expect MINUTES of [D] progress lines with ETA (resumable
rem     via the marker file); ntoskrnl-data-*.bin + .manifest.txt
rem     land on the Desktop next to the transcript.
rem
rem DRIVER: v26-RT = 140582 bytes, sha256 c8f79b95... - THE SAME
rem BINARY (9-times field-proven op-1/op-11 paths; op-12 stays
rem dead code). v25-RT = 141154 (the FIRST BSOD binary) - refused
rem by hash as before. Test script: trigger-test-v36.ps1.
rem ============================================================
rem INFINITY Phase D v35 (historical): SCRIPT-ONLY - the v26 driver UNCHANGED.""",
'B36-header')

# =========================================================
# 2. the stale-script branch (v33/v34 = BSOD; v35 = safe/obsolete)
# =========================================================
rep(
"""  echo [ERROR] usb-d\\trigger-test-v35.ps1 is NOT the v35 script.
  echo A STALE v34 COPY IS THE SECOND-BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo DO NOT RUN THE v34 SCRIPT. Replace it with the v35 script
  echo from this package ^(v35 never sends op-12^).""",
"""  echo [ERROR] usb-d\\trigger-test-v36.ps1 is NOT the v36 script.
  echo A STALE v34/v33 COPY IS THE BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo A stale v35 copy is SAFE but OBSOLETE: its dump gate refuses
  echo this kernel's LEGAL 33 sections ^(the v36 fix^) - the .bin
  echo and .manifest.txt would never appear with it.
  echo DO NOT RUN v33/v34 SCRIPTS. Replace with the v36 script
  echo from this package ^(v36 never sends op-12^).""",
'B36-stale-branch')

# =========================================================
# 3. the findstr needle
# =========================================================
rep(
"""findstr /I /C:"trigger test v35" usb-d\\trigger-test-v35.ps1 >nul 2>&1""",
"""findstr /I /C:"trigger test v36" usb-d\\trigger-test-v35.ps1 >nul 2>&1""",
'B36-findstr')

# =========================================================
# 4. pre-flight 1 title
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v35 ----""",
"""rem ---- pre-flight 1: the trigger test script must be v36 ----""",
'B36-pf1-title')

# =========================================================
# 5. the milestone line
# =========================================================
rep(
"""echo [Phase D] package v26/v35 - Windows + memory.efi v26 RT boot test ^(F4 RECON + THE .data DUMP: op-12 retired after the 2nd 0x50 - the constant recon + the ground-truth capture, all through the proven image gate^). Mode %MODE%.""",
"""echo [Phase D] package v26/v36 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 3 COMPLETE: the recon captured MmPteBase live + proved all 5 researched pfnDb RVAs wrong; v36 = THE DUMP RETRY - the gate now accepts the legal 33 sections + the table read is chunked; op-12 still retired, zero sends^). Mode %MODE%.""",
'B36-milestone')

# =========================================================
# 6. the first-line hint + the branch wordings
# =========================================================
rep(
"""echo [Phase D]      Its FIRST line must say: trigger test v35.""",
"""echo [Phase D]      Its FIRST line must say: trigger test v36.""",
'B36-firstline')

rep(
"""            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the v35 recon + dump steps.""",
"""            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the v36 dump run.""",
'B36-v24-branch')

rep(
"""                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v35 R/D steps.""",
"""                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v36 R/D steps.""",
'B36-unknown-branch')

# =========================================================
# 7. global script-name refs (after all named anchors are done)
# =========================================================
rep('trigger-test-v35.ps1', 'trigger-test-v36.ps1', 'B36-scriptname', count=10)

# =========================================================
# final: write + checks
# =========================================================
DST.write_text(text, encoding='utf-8')
raw = text.encode('utf-8')
print()
print(f'wrote {DST} ({len(raw)} bytes)')
fails = []
def need(cond, label):
    print(('  OK   ' if cond else '  FAIL ') + label)
    if not cond: fails.append(label)

need(b'\r' not in raw, 'LF-only (no CR)')
need(all(b < 128 for b in raw), 'pure ASCII')
need('Phase D v36' in text, 'v36 header present')
need('trigger-test-v36.ps1' in text and 'trigger-test-v35.ps1' not in text, 'script refs all v36')
need('trigger test v36' in text, 'the findstr needle v36')
need('140582' in text, 'the v26 size guard intact (driver unchanged)')
need('c8f79b95' in text, 'the v26 hash guard intact')
need('022e6d1c' in text and 'f8a01814' in text and 'd7562a7d' in text and '276b744c' in text, 'the 5-way hash list intact')
need('DO NOT RUN v33/v34 SCRIPTS' in text, 'the stale-script DO-NOT-RUN warning')
need('SAFE but OBSOLETE' in text, 'the v35-safe-but-obsolete taxonomy')
need('never sends op-12' in text, 'the op-12 retirement note')
need('nsec in [1..96]' in text, 'the gate fix documented')
need('33 sections' in text, 'the 33-sections story')
need('pdb + pfn*0x30 + 8' in text, 'the chain-B killer named')
print()
if fails:
    print(f'FAILURES: {fails}'); sys.exit(1)
print(f'sha256 = {hashlib.sha256(raw).hexdigest()}')
print('BAT v36 ALL CHECKS PASS')
