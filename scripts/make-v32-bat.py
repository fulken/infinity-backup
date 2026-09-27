#!/usr/bin/env python3
# ============================================================================
# make-v32-bat.py — build patches/phase-d-v32.bat from the v31 bat
#
# v32 changes:
#   1. NEW "Phase D v24" header block (the v23 block demoted to historical)
#   2. pre-flight 1: v32 script refs + marker "trigger test v32"
#   3. pre-flight 1b: size table retargeted (v24-RT = 134842 - the sizes
#      DIFFER again: v23/v22 = 134330 both; new 134330 branch explains
#      the v23 missing-deref bug vs the v22 export-gate bug)
#   4. pre-flight 1c: THE HASH GUARD now three-way - f8a01814... = v24
#      (GO) / d7562a7d... = v23 (REFUSE: the missing deref - the v31
#      field run refused W with payload status=4 not-System, walk=0) /
#      276b744c... = v22 (REFUSE: the export gate refused every M) /
#      neither = unknown (REFUSE)
#   5. milestone/banner/instruction lines: v24 + the deref-fix story
#
# Usage: python3 scripts/make-v32-bat.py
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v31.bat'
DST = BASE / 'patches' / 'phase-d-v32.bat'

V24_HASH = 'f8a01814f4ffeb9a9b1595a722c733b0dbf92d5eb5710b25d88d7818dbcf5846'
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
# 1. the v24 header block above the v23 block (+ demote v23)
# =========================================================
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v23: v22 + THE ONE-CONSTANT FIX. The v30""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v24: v23 + THE DEREF FIX. The v31 field
rem run (2026-09-27 19:51) PROVED the v23 export fix - M1..M4
rem all green (M1 == the v29 value, M4 the correct rc=7), F1+F2
rem re-proven for the 5th time, J 100%, INFCNT 31 exact - but
rem the WALK still refused: payload status=4 (not-System),
rem walk=0, serial [PW] sys=0xFFFFF8071A4FC420. ROOT CAUSE:
rem op 11 passed the RESOLVED SYMBOL VA to the walk.
rem PsInitialSystemProcess is a POINTER VARIABLE in ntoskrnl
rem .data - *(u64*)slot is the System EPROCESS, a pool object
rem OUTSIDE the image. v24 derefs the slot via the same gated
rem in-image reads (no new trust root) and walks from the true
rem EPROCESS. Host-proven 66/66 incl. the T23 chain class-kill
rem (a deref-less build can never pass it), disasm-verified
rem (Resolve call -> range gate -> budget gate -> Rd32 -> the
rem [PW] eproc trace), bench A 13/13 + B 5/5. Test script:
rem trigger-test-v32.ps1 (the same wire steps as v31; the W1
rem success expectations corrected to the v24 semantics).
rem
rem DRIVER SIZE: v24-RT = 134842 bytes (sha256 f8a01814...).
rem v23-RT and v22-RT are BOTH 134330 (v23 = the missing deref:
rem W refuses status=4 not-System; v22 = additionally refuses
rem every M). The bat's pre-flight 1b/1c check size + hash.
rem ============================================================
rem INFINITY Phase D v23 (historical): v22 + THE ONE-CONSTANT FIX. The v30""",
'B24-header')

# =========================================================
# 2. pre-flight 1: the v32 script
# =========================================================
rep(
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
"""rem ---- pre-flight 1: the trigger test script must be v32 ----
if not exist usb-d\\trigger-test-v32.ps1 (
  echo [ERROR] usb-d\\trigger-test-v32.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v32" usb-d\\trigger-test-v32.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v32.ps1 is NOT the v32 script.
  echo A stale v31 copy runs the SAME wire steps, but its W1 success
  echo expectations are the OLD symbol-VA semantics - with the v24
  echo driver a green walk would print FAIL lines. Replace it with
  echo the v32 script from this package.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v32.ps1 verified - pre-placed on the boot disk.""",
'B24-preflight1')

# =========================================================
# 3. pre-flight 1b: size guard retarget (v24-RT = 134842)
# =========================================================
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v23-RT = 134330) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134330" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v23 RT driver ^(v23-RT = 134330 bytes^).""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v24-RT = 134842) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134842" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v24 RT driver ^(v24-RT = 134842 bytes^).""",
'B24-sizeguard')

# the v21 branch text points at v24 now
rep(
"""            echo clean refusal, never a crash^). Replace with the v23
            echo driver for the F3 walk proof.
          ) else (
            echo Unknown driver build. Only the v23 RT driver runs the
            echo v31 W steps.
          )""",
"""            echo clean refusal, never a crash^). Replace with the v24
            echo driver for the F3 walk proof.
          ) else (
            if "%DRIVERSIZE%"=="134330" (
              echo That size is the v23 or v22 RT driver ^(both 134330^):
              echo v23 = the MISSING-DEREF bug - the v31 field run had
              echo M1..M4 green but W refused payload status=4 not-System
              echo with walk=0 ^(fail-closed, no crash^); v22 = additionally
              echo refuses every M resolve. Pre-flight 1c names which one
              echo you have. Only the v24 driver ^(134842^) walks.
            ) else (
              echo Unknown driver build. Only the v24 RT driver runs the
              echo v32 W steps.
            )
          )""",
'B24-134330branch')

# =========================================================
# 4. pre-flight 1c: the three-way hash guard
# =========================================================
_HASHGUARD_OLD = """rem ---- pre-flight 1c: HASH GUARD (v22-RT and v23-RT are BOTH 134330 bytes) ----
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
_HASHGUARD_OLD = _HASHGUARD_OLD.replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

_HASHGUARD_NEW = """rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
set ISV24=0
set ISV23=0
set ISV22=0
certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"@V24HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV24=1
findstr /I /C:"@V23HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV23=1
findstr /I /C:"@V22HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV22=1
del "%TEMP%\\inf-drv-hash.txt" >nul 2>&1
if "%ISV24%"=="1" (
  echo [Phase D] memory.efi verified - v24 RT build ^(134842 bytes, sha256 f8a01814...^).
) else (
  if "%ISV23%"=="1" (
    echo [ERROR] usb-d\\memory.efi is the v23 driver ^(134330 bytes,
    echo sha256 d7562a7d...^). v23 has the MISSING-DEREF bug: the v31
    echo field run proved its export fix ^(M1..M4 green^) but the walk
    echo refused - op 11 walked from the PsInitialSystemProcess SYMBOL
    echo VA instead of the EPROCESS it points at ^(payload status=4
    echo not-System, walk=0 - fail-closed, no crash^). F3 can never
    echo prove on v23.
    echo Fix: copy this package's memory.efi over usb-d\\memory.efi.
    pause
    exit /b 1
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
      echo [ERROR] the sha256 matches NEITHER v24 ^(f8a01814...^) NOR
      echo v23 ^(d7562a7d...^) NOR v22 ^(276b744c...^) - unknown build.
      echo Replace usb-d\\memory.efi with this package's v24 driver.
      pause
      exit /b 1
    )
  )
)"""
_HASHGUARD_NEW = _HASHGUARD_NEW.replace('@V24HASH@', V24_HASH).replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

rep(_HASHGUARD_OLD, _HASHGUARD_NEW, 'B24-hashguard')

# =========================================================
# 5. milestone/banner/instruction lines
# =========================================================
rep(
"echo [Phase D] package v23 - Windows + memory.efi v23 RT boot test ^(F3 the EPROCESS walk, export-gate fixed^). Mode %MODE%.",
"echo [Phase D] package v24 - Windows + memory.efi v24 RT boot test ^(F3 the EPROCESS walk, deref-fixed: walk from the EPROCESS^). Mode %MODE%.",
'B24-milestone')

rep(
"echo [Phase D] The banner must say: memory.efi v23 RT ^(kernel data path: direct reads + export resolution + process walk^).",
"echo [Phase D] The banner must say: memory.efi v24 RT ^(kernel data path: direct reads + export resolution + process walk^).",
'B24-bannerline')

rep(
"""echo [Phase D]        D:\\trigger-test-v31.ps1
echo [Phase D]      Its FIRST line must say: trigger test v31.""",
"""echo [Phase D]        D:\\trigger-test-v32.ps1
echo [Phase D]      Its FIRST line must say: trigger test v32.""",
'B24-runline')

rep(
"echo   2. send the trigger-test-v31 output .txt ^(Desktop, via transfer stick^)",
"echo   2. send the trigger-test-v32 output .txt ^(Desktop, via transfer stick^)",
'B24-sendline')

rep(
"    echo   EFI  memory.efi  startup.nsh  trigger-test-v31.ps1",
"    echo   EFI  memory.efi  startup.nsh  trigger-test-v32.ps1",
'B24-pristine')

# =========================================================
# post checks
# =========================================================
if '\r\n' in text:
    print('[post] FATAL: CRLF crept in')
    sys.exit(1)
print('[post] LF-only preserved')
for must in ('trigger test v32', 'trigger-test-v32.ps1', 'f8a01814', 'd7562a7d',
             '276b744c', 'certutil -hashfile', 'pre-flight 1c: HASH GUARD',
             'v24 RT build', 'INFINITY Phase D v24', '134842',
             'MISSING-DEREF', 'v24-RT = 134842'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
    print(f'[post] present: {must!r}')
for gone in ('"134330" (\n  echo [ERROR]', 'Only the v23 RT driver runs the',
             'usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT\n  echo the v23 RT driver'):
    if gone in text:
        print(f'[post] FATAL: stale text survived: {gone!r}')
        sys.exit(1)
print('[post] stale v23 guard texts removed')

DST.write_text(text, encoding='utf-8', newline='')
import hashlib
h = hashlib.sha256(DST.read_bytes()).hexdigest()
print()
print(f'[make-v32-bat] wrote {DST} ({DST.stat().st_size} bytes)')
print(f'[make-v32-bat] sha256 {h}')
print('[make-v32-bat] ALL EDITS + POST-CHECKS PASS')
