#!/usr/bin/env python3
# ============================================================================
# make-v35-bat.py — build phase-d-v35.bat from the field-run v34 bat
#
# v35 bat = the v34 bat with THE SAME 5-way driver hash guard (the v26
# binary is UNCHANGED - v26 = GO) + the script-side checks retargeted to
# v35 + the honest second-BSOD story (chain B, the fingerprint) + the
# op-12-retired note. The stale-v34-script branch becomes the DO-NOT-RUN
# warning: the v34 script's P1 IS the second BSOD op.
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v34.bat'
DST = BASE / 'patches' / 'phase-d-v35.bat'

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
# 1. the v35 header block (the v26 block demoted)
# =========================================================
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v26: v25 + THE FORMULA FIX. The v33 field""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v35: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v34 field run (2026-09-28 04:50) = THE SECOND F4-ERA BSOD
rem (0x50 PAGE_FAULT_IN_NONPAGED_AREA, same as v33). The v34 run's
rem step 0 captured the v33 crash's FULL bugcheck args:
rem   0x50 (0xfffff807154e5078, 0, 0xfffff8071d08707c, 0)
rem and 0xfffff807154e5078 - 0xfffff807154e0000 = 0x5078 =
rem 0x1AD*0x30 + 8 EXACTLY (pfn 0x1AD = the v33 System DTB
rem 0x1AD000 >> 12; stride 0x30 = _MMPFN; +8 = .PteAddress).
rem THE FINGERPRINT NAMES THE REAL KILLER: op-12's chain B -
rem pdb + pfn*0x30 + 8 deref'd RAW with pdb = a GARBAGE kernel
rem pointer from a WRONG nt!MmPfnDatabase RVA (the 5 researched
rem candidates do not match this build; the weak canonical+
rem aligned check passes random pointers). NOT the v25 formulas
rem (with chain A's correct base the old addresses stay INSIDE
rem the mapped PTE space - wrong data maybe, a fault NEVER).
rem The v26 formula fix was real but irrelevant; "constants
rem intact" kept the poison and killed the VM a second time.
rem
rem v35 STRATEGY (fail-closed to the bone): op-12 IS RETIRED -
rem the script NEVER sends it (the crash op is simply not
rem called). Everything runs through the op-1 image gate
rem (L1-L5 field-proven since v20) + op-11 (the W walk):
rem   [R] RECON: the 7 candidate qwords (2x MmPteBase + 5x
rem       MmPfnDatabase) + the op-11 dtb echo - the actual
rem       values THIS build has there, through the proven gate.
rem   [D] THE .data DUMP: the whole .data section, 1024B chunks
rem       (self-verified vs MZ/e_lfanew, resumable, manifest +
rem       sha256) - the ground truth for the offline constant
rem       verification that gates the v36 walk kit.
rem   Plus: step 0 prints the FULL bugcheck args (the v34
rem   crash's own args will show the same +0x30-stride+8
rem   fingerprint) + W2 exit-race tolerance (the v34 pid-656).
rem
rem DRIVER: v26-RT = 140582 bytes, sha256 c8f79b95... - THE
rem SAME BINARY AS v34 (8-times field-proven op-1/op-11 paths;
rem its op-12 is never called by v35). v25-RT = 141154 (the
rem FIRST BSOD binary) - refused by hash as before.
rem Test script: trigger-test-v35.ps1.
rem ============================================================
rem INFINITY Phase D v26 (historical): v25 + THE FORMULA FIX. The v33 field""",
'B35-header')

# =========================================================
# 2. script name refs (10 in the v34 bat)
# =========================================================
rep('trigger-test-v34.ps1', 'trigger-test-v35.ps1', 'B35-scriptname', count=10)

# =========================================================
# 3. the findstr marker check + the stale-script story
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v34 ----""",
"""rem ---- pre-flight 1: the trigger test script must be v35 ----""",
'B35-pf1-title')

rep(
"""findstr /I /C:"trigger test v34" usb-d\\trigger-test-v35.ps1 >nul 2>&1""",
"""findstr /I /C:"trigger test v35" usb-d\\trigger-test-v35.ps1 >nul 2>&1""",
'B35-pf1-findstr')

rep(
"""  echo [ERROR] usb-d\\trigger-test-v35.ps1 is NOT the v34 script.
  echo A stale v33 copy runs the SAME wire steps - but its P1 expects
  echo the OLD v25 selfOk==1 semantics ^(frame == System CR3 - wrong
  echo for the caller context^) and would print a FAIL line on a
  echo HEALTHY v26 walk. Replace it with the v34 script from this
  echo package.""",
"""  echo [ERROR] usb-d\\trigger-test-v35.ps1 is NOT the v35 script.
  echo A STALE v34 COPY IS THE SECOND-BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo DO NOT RUN THE v34 SCRIPT. Replace it with the v35 script
  echo from this package ^(v35 never sends op-12^).""",
'B35-pf1-story')

# =========================================================
# 4. the v25-BSOD branch wording (the P-story -> the R/D story)
# =========================================================
rep(
"""            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the F4 page-table proof.""",
"""            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the v35 recon + dump steps.""",
'B35-v24-branch')

rep(
"""                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v34 P steps.""",
"""                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v35 R/D steps.""",
'B35-unknown-branch')

# =========================================================
# 5. milestone/banner/run lines
# =========================================================
rep(
"echo [Phase D] package v26 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 2: the level-base formula fix - the true self-map slots + the LIVE selfOk^). Mode %MODE%.",
"echo [Phase D] package v26/v35 - Windows + memory.efi v26 RT boot test ^(F4 RECON + THE .data DUMP: op-12 retired after the 2nd 0x50 - the constant recon + the ground-truth capture, all through the proven image gate^). Mode %MODE%.",
'B35-milestone')

rep(
"echo [Phase D]      Its FIRST line must say: trigger test v34.",
"echo [Phase D]      Its FIRST line must say: trigger test v35.",
'B35-firstline')

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
need('Phase D v35' in text, 'v35 header present')
need('trigger-test-v35.ps1' in text and 'trigger-test-v34.ps1' not in text, 'script refs all v35')
need('trigger test v35' in text, 'the findstr needle v35')
need('140582' in text, 'the v26 size guard intact (driver unchanged)')
need('c8f79b95' in text, 'the v26 hash guard intact')
need('022e6d1c' in text and 'f8a01814' in text and 'd7562a7d' in text and '276b744c' in text, 'the 5-way hash list intact')
need('DO NOT RUN THE v34 SCRIPT' in text, 'the stale-v34 DO-NOT-RUN warning')
need('op-12 IS RETIRED' in text or 'op-12 IS RETIRED -' in text, 'the op-12 retirement note')
need('0x1AD*0x30 + 8' in text, 'the fingerprint arithmetic in the header')
need('pdb + pfn*0x30 + 8' in text, 'the chain-B killer named')
print()
if fails:
    print(f'FAILURES: {fails}'); sys.exit(1)
import hashlib
print(f'sha256 = {hashlib.sha256(raw).hexdigest()}')
print('BAT v35 ALL CHECKS PASS')
