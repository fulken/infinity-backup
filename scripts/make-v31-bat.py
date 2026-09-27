#!/usr/bin/env python3
# ============================================================================
# make-v31-bat.py — build patches/phase-d-v31.bat from the v30 bat
#
# v31 changes:
#   1. NEW "Phase D v23" header block (the v22 block demoted to historical)
#   2. pre-flight 1: v31 script refs + marker "trigger test v31"
#   3. pre-flight 1b: size table retargeted (v23-RT = 134330; the v21
#      branch's fix-text now points at v23)
#   4. NEW pre-flight 1c: THE HASH GUARD - v22-RT and v23-RT are BOTH
#      134330 bytes, so size alone cannot tell them apart. certutil
#      SHA256 + findstr: d7562a7d... = v23 (GO) / 276b744c... = v22
#      (REFUSE: the export-gate bug - the v30 field run refused every
#      M/W resolve) / neither = unknown (REFUSE)
#   5. milestone/banner/instruction lines: v23 + the fix story
#
# Usage: python3 scripts/make-v31-bat.py
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v30.bat'
DST = BASE / 'patches' / 'phase-d-v31.bat'

V23_HASH = 'd7562a7dddc4227844036f7e397f1580338be74015715419b757bfac0577c5e8'
V22_HASH = '276b744c069389aa1d3ee649be56a4ee1e4ff0292ca8475af7529e9cf1cb9cc2'

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
# 1. the v23 header block above the v22 block (+ demote v22)
# =========================================================
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v22: boot installed Windows WITH the v22 RT""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v23: v22 + THE ONE-CONSTANT FIX. The v30
rem field run (2026-09-27 17:50) was F1-green + J-matrix 100% on
rem the v22 binary, but EVERY M/W resolve refused rc=4 /
rem resolve-failed. ROOT CAUSE (disassembly of the field-proven
rem v21 binary @10fbb): the export-size gate's true bound is
rem 0x100000 (1 MiB), not 0x10000 - the hand-RE dropped a zero
rem and v22 coded it. ntoskrnl 19045's export directory (~0x12000
rem bytes) tripped the wrong 64 KiB bound. Fail-closed held
rem everywhere: zero crashes, all negatives clean. v23 = v22 +
rem 0x10000 -> 0x100000 + banners; wire contract UNTOUCHED.
rem Host-proven 55/55 (incl. the NEW realistic-directory
rem class-kill that FAILS on v22 by construction), bench-proven
rem A 13/13 + B 5/5. Test script: trigger-test-v31.ps1 (the same
rem K/L/M/J/W steps as v30; only the driver-ID texts changed).
rem
rem CAUTION: v22-RT and v23-RT are BOTH 134330 bytes. Only the
rem sha256 tells them apart: v23 = d7562a7d...7c5e8 (GO) /
rem v22 = 276b744c...cb9cc2 (REFUSE - the gate bug). The bat's
rem pre-flight 1c checks the hash automatically.
rem ============================================================
rem INFINITY Phase D v22 (historical): boot installed Windows WITH the v22 RT""",
'B23-header')

# =========================================================
# 2. pre-flight 1: the v31 script
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v30 ----
if not exist usb-d\\trigger-test-v30.ps1 (
  echo [ERROR] usb-d\\trigger-test-v30.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v30" usb-d\\trigger-test-v30.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v30.ps1 is NOT the v30 script.
  echo A stale v29 copy runs the whole K/L/M/J regression fine but
  echo has NO step W - the F3 proof never runs and the verdict
  echo stops at F2. Replace it with the v30 script.
  echo Fix: extract the NEW v30 swap package over this folder.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v30.ps1 verified - pre-placed on the boot disk.""",
"""rem ---- pre-flight 1: the trigger test script must be v31 ----
if not exist usb-d\\trigger-test-v31.ps1 (
  echo [ERROR] usb-d\\trigger-test-v31.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v31" usb-d\\trigger-test-v31.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v31.ps1 is NOT the v31 script.
  echo A stale v30 copy runs the SAME wire steps, but its decision
  echo table points at the v22 driver - and with the v22/v23 size
  echo collision you want the v31 texts ^(sha256 guidance^). Replace
  echo it with the v31 script from this package.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v31.ps1 verified - pre-placed on the boot disk.""",
'B23-preflight1')

# =========================================================
# 3. pre-flight 1b: size guard retarget + 4. NEW hash guard
# =========================================================
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v22-RT = 134330) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134330" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v22 RT driver ^(v22-RT = 134330 bytes^).""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v23-RT = 134330) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134330" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v23 RT driver ^(v23-RT = 134330 bytes^).""",
'B23-sizeguard')

rep(
"""          if "%DRIVERSIZE%"=="131709" (
            echo That size is the v21 RT driver ^(the F2 field-proven
            echo build^): the whole K/L/M/J regression runs green but
            echo step W cannot run ^(op 11 answers ErrUnsupported - a
            echo clean refusal, never a crash^). Replace with the v22
            echo driver for the F3 walk proof.
          ) else (
            echo Unknown driver build. Only the v22 RT driver runs the
            echo v30 W steps.
          )""",
"""          if "%DRIVERSIZE%"=="131709" (
            echo That size is the v21 RT driver ^(the F2 field-proven
            echo build^): the whole K/L/M/J regression runs green but
            echo step W cannot run ^(op 11 answers ErrUnsupported - a
            echo clean refusal, never a crash^). Replace with the v23
            echo driver for the F3 walk proof.
          ) else (
            echo Unknown driver build. Only the v23 RT driver runs the
            echo v31 W steps.
          )""",
'B23-v21branch')

_HASHGUARD = """rem ---- pre-flight 1c: HASH GUARD (v22-RT and v23-RT are BOTH 134330 bytes) ----
set ISV23=0
set ISV22=0
certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"@V23HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV23=1
findstr /I /C:"@V22HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV22=1
del "%TEMP%\\inf-drv-hash.txt" >nul 2>&1
if "%ISV23%"=="1" (
  echo [Phase D] memory.efi verified - v23 RT build ^(134330 bytes, sha256 d7562a7d...^).
) else (
  if "%ISV22%"=="1" (
    echo [ERROR] usb-d\\memory.efi is the v22 driver ^(134330 bytes,
    echo sha256 276b744c...^). v22 has the export-size gate bug
    echo ^(0x10000 instead of 0x100000^): the v30 field run refused
    echo EVERY M/W resolve with rc=4 / resolve-failed - fail-closed,
    echo no crash, but F2/F3 can never prove on v22.
    echo Fix: copy this package's memory.efi over usb-d\\memory.efi.
    pause
    exit /b 1
  ) else (
    echo [ERROR] 134330 bytes but the sha256 matches NEITHER v23
    echo ^(d7562a7d...^) NOR v22 ^(276b744c...^) - unknown build.
    echo Replace usb-d\\memory.efi with this package's v23 driver.
    pause
    exit /b 1
  )
)"""
_HASHGUARD = _HASHGUARD.replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

rep(
"""echo [Phase D] memory.efi verified - v22 RT build ^(134330 bytes^).""",
_HASHGUARD,
'B23-hashguard')

# =========================================================
# 5. milestone/banner/instruction lines
# =========================================================
rep(
"echo [Phase D] package v22 - Windows + memory.efi v22 RT boot test ^(F3 the EPROCESS walk^). Mode %MODE%.",
"echo [Phase D] package v23 - Windows + memory.efi v23 RT boot test ^(F3 the EPROCESS walk, export-gate fixed^). Mode %MODE%.",
'B23-milestone')

rep(
"echo [Phase D] The banner must say: memory.efi v22 RT ^(kernel data path: direct reads + export resolution + process walk^).",
"echo [Phase D] The banner must say: memory.efi v23 RT ^(kernel data path: direct reads + export resolution + process walk^).",
'B23-bannerline')

rep(
"""echo [Phase D]        D:\\trigger-test-v30.ps1
echo [Phase D]      Its FIRST line must say: trigger test v30.""",
"""echo [Phase D]        D:\\trigger-test-v31.ps1
echo [Phase D]      Its FIRST line must say: trigger test v31.""",
'B23-runline')

rep(
"echo   2. send the trigger-test-v30 output .txt ^(Desktop, via transfer stick^)",
"echo   2. send the trigger-test-v31 output .txt ^(Desktop, via transfer stick^)",
'B23-sendline')

rep(
"    echo   EFI  memory.efi  startup.nsh  trigger-test-v30.ps1",
"    echo   EFI  memory.efi  startup.nsh  trigger-test-v31.ps1",
'B23-pristine')

# =========================================================
# post checks
# =========================================================
if '\r\n' in text:
    print('[post] FATAL: CRLF crept in')
    sys.exit(1)
print('[post] LF-only preserved')
for must in ('trigger test v31', 'trigger-test-v31.ps1', 'd7562a7d', '276b744c',
             'certutil -hashfile', 'pre-flight 1c: HASH GUARD',
             'v23 RT build', 'INFINITY Phase D v23'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
    print(f'[post] present: {must!r}')
n30 = text.count('v30')
print(f'[post] remaining v30 mentions (historical header blocks only): {n30}')
if 'phase-d-v30.bat' in text or 'v30 swap package' in text:
    print('[post] FATAL: stale self-references')
    sys.exit(1)

DST.write_text(text, encoding='utf-8', newline='')
print()
print(f'[make-v31-bat] wrote {DST} ({DST.stat().st_size} bytes)')
print('[make-v31-bat] ALL EDITS + POST-CHECKS PASS')
