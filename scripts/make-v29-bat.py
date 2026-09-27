#!/usr/bin/env python3
"""make-v29-bat.py - retarget phase-d.bat from the v21 kit (trigger v28)
to the v29 script. DRIVER UNCHANGED (v21-RT, 131709 - the five-way
stale-driver detection stays byte-identical); only the script refs,
the stale-copy story and the old-files range move v28 -> v29.

Anchored edits (each asserted unique before replace):
 B1   header line: Test script trigger-test-v28.ps1 -> v29
 B2   v29 SCRIPT story block above the v28 story block
 B3/B4/B5/B6/B7  pre-flight 1: filename, findstr pattern, stale message
 B8   guard texts: "the v27 ladder" -> v29 (x2), "the v28 K/L/M steps" -> v29
 B9   old-files range v17..v27 -> v17..v28
 B10  pristine-content list x2 (EFI memory.efi startup.nsh trigger-test-v29.ps1)
 B12/B13/B14  run instructions: D:\\trigger-test-v29.ps1 + first-line hint + output .txt
"""
import re, hashlib

SRC = '/home/z/my-project/upload/infinity-qemu-test-v21/pkg-v21/phase-d.bat'
DST = '/home/z/my-project/patches/phase-d-v29.bat'

src = open(SRC, encoding='utf-8').read()

def rep(old, new, label):
    global src
    c = src.count(old)
    assert c == 1, f'[{label}] anchor not unique ({c} hits): {old[:60]!r}'
    src = src.replace(old, new, 1)

# B1 - header test-script line
rep("rem Test script: trigger-test-v28.ps1 (K/L/M steps + J regression).",
    "rem Test script: trigger-test-v29.ps1 (K/L/M steps + J regression).", 'B1')

# B2 - the v29 story block, above the v28 story block
V29STORY = """rem v29 SCRIPT (2026-09-27): THE M2R EXPECTATION FIX + THE FULL
rem INFCNT ARITHMETIC (script-only - the v21 driver STAYS, 131709
rem bytes, untouched). The v28 field run (2026-09-26 21:11) was
rem DRIVER-GREEN end to end: all four M resolutions + both M reads
rem returned perfect data - but the script printed [M2r] FAIL on
rem the CANONICAL NtBuildNumber dword 0xF0004A65 (build in the LOW
rem WORD 0x4A65 = 19045 = the KUSD J1 ground truth; QFE flag bits
rem above it). v28 masked 0x7FFFFFFF and compared against bare
rem 19045. v29 masks the BUILD field (0xFFFF) + accepts the
rem canonical dword (as a DECIMAL literal - no hex-cast trap).
rem Also: the v28 final-INFCNT line printed "expect G+8+ = 23" (an
rem empty format slot + the 4 M-side symbol-NAME writes missing) -
rem v29 counts every term: INFCNT 27 converged / 13 fail-closed.
rem
"""
rep("rem v28 SCRIPT (2026-09-26): STEP M - the F2 export-resolution",
    V29STORY + "rem v28 SCRIPT (2026-09-26): STEP M - the F2 export-resolution", 'B2')

# B3 - pre-flight 1 title
rep("rem ---- pre-flight 1: the trigger test script must be v28 ----",
    "rem ---- pre-flight 1: the trigger test script must be v29 ----", 'B3')

# B4 - existence check + message
rep("""if not exist usb-d\\trigger-test-v28.ps1 (
  echo [ERROR] usb-d\\trigger-test-v28.ps1 not found.""",
    """if not exist usb-d\\trigger-test-v29.ps1 (
  echo [ERROR] usb-d\\trigger-test-v29.ps1 not found.""", 'B4')

# B5 - findstr pattern
rep('findstr /I /C:"trigger test v28" usb-d\\trigger-test-v28.ps1 >nul 2>&1',
    'findstr /I /C:"trigger test v29" usb-d\\trigger-test-v29.ps1 >nul 2>&1', 'B5')

# B6 - the stale-copy message (the v28 story: driver-green, script-blind)
rep("""  echo [ERROR] usb-d\\trigger-test-v28.ps1 is NOT the v28 script.
  echo A stale v27 copy still runs and is F1-green, but the M steps
  echo ^(export resolution^) never run - the verdict stops at
  echo F1 PROVEN. Replace it with the v28 script.
  echo Fix: extract the NEW v28 swap package over this folder.""",
    """  echo [ERROR] usb-d\\trigger-test-v29.ps1 is NOT the v29 script.
  echo A stale v28 copy still runs and the DRIVER side is fully
  echo green - but it prints [M2r] FAIL on the healthy canonical
  echo 0xF0004A65 and its final INFCNT line says expect 23 where
  echo the true count is 27 - the verdict stops at F2 PARTIAL with
  echo the driver blameless. Replace it with the v29 script.
  echo Fix: extract the NEW v29 swap package over this folder.""", 'B6')

# B7 - verified line
rep("echo [Phase D] trigger-test-v28.ps1 verified - pre-placed on the boot disk.",
    "echo [Phase D] trigger-test-v29.ps1 verified - pre-placed on the boot disk.", 'B7')

# B8 - guard inner texts (driver sizes/branch logic UNTOUCHED)
rep("""  echo That size is the v17 RT driver. The v27 ladder with the""",
    """  echo That size is the v17 RT driver. The v29 ladder with the""", 'B8a')
rep("""      echo That size is the v18 RT driver ^(no anchors^). The v27 K/L""",
    """      echo That size is the v18 RT driver ^(no anchors^). The v29 K/L""", 'B8b')
rep("""          echo Unknown driver build. Only the v21 RT driver runs the
          echo v28 K/L/M steps.""",
    """          echo Unknown driver build. Only the v21 RT driver runs the
          echo v29 K/L/M steps.""", 'B8c')

# B9 - old-files range
rep("echo [Phase D] Old trigger files ^(v17..v27^) may stay in the ROOT of",
    "echo [Phase D] Old trigger files ^(v17..v28^) may stay in the ROOT of", 'B9')

# B10 - pristine-content list (x2)
rep("  echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v28.ps1",
    "  echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v29.ps1", 'B10a')
rep("  echo   EFI  memory.efi  startup.nsh  trigger-test-v28.ps1",
    "  echo   EFI  memory.efi  startup.nsh  trigger-test-v29.ps1", 'B10b')

# B12 - run instruction
rep("echo [Phase D]        D:\\trigger-test-v28.ps1",
    "echo [Phase D]        D:\\trigger-test-v29.ps1", 'B12')

# B13 - first-line hint
rep("echo [Phase D]      Its FIRST line must say: trigger test v28.",
    "echo [Phase D]      Its FIRST line must say: trigger test v29.", 'B13')

# B14 - send-instructions
rep("echo   2. send the trigger-test-v28 output .txt ^(Desktop, via transfer stick^)",
    "echo   2. send the trigger-test-v29 output .txt ^(Desktop, via transfer stick^)", 'B14')

# ---- post-edit verification ----
assert src.count('trigger-test-v29.ps1') == 9, 'v29 filename refs: B1 + B4x2 + B5 + B6 + B7 + B10x2 + B12'
assert 'trigger-test-v28.ps1' not in src, 'a v28 filename ref survived'
assert src.count('"trigger test v29"') == 1
assert 'v17..v28' in src and 'v17..v27' not in src
assert '131709' in src and src.count('"131709"') == 1, 'the driver size guard itself must stay'
assert src.count('120678') == 2 and src.count('121253') == 2 and src.count('125450') == 2 and src.count('128010') == 2, \
    'the five-way stale-driver detection sizes must stay byte-identical'
assert src.count('131709') == 6, 'v21-RT size: original 5 (title+guard x3+verified) + the v29 story block'
assert src.count('v29 K/L/M') == 1 and src.count('The v29 ladder') == 1 and src.count('The v29 K/L') == 1

open(DST, 'w', encoding='utf-8', newline='\n').write(src)
h = hashlib.sha256(open(DST, 'rb').read()).hexdigest().upper()
print(f'WROTE {DST}')
print(f'  bytes: {len(src)}  sha256: {h[:16]}...')
