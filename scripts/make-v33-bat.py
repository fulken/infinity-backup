#!/usr/bin/env python3
# ============================================================================
# make-v33-bat.py — build patches/phase-d-v33.bat from patches/phase-d-v32.bat
#
# v33 bat story:
#   1. NEW "Phase D v25" header block (the v24 block demoted to historical)
#   2. pre-flight 1 retargeted: trigger-test-v33.ps1
#   3. pre-flight 1b: size guard v25-RT = 141154 (v24 = 134842; v23/v22 =
#      134330 both - the 134330 branch explains both historical bugs)
#   4. pre-flight 1c: THE HASH GUARD now FOUR-way:
#      022e6d1c... = v25 (GO) / f8a01814... = v24 (REFUSE: no page tables -
#      op 12 answers ErrUnsupported(8)) / d7562a7d... = v23 (REFUSE: the
#      missing deref - the v31 signature) / 276b744c... = v22 (REFUSE: the
#      export-size gate bug) / neither = unknown REFUSE
#   5. milestone/banner/run/send/pristine lines: v33 + the F4 story
#
# Usage: python3 scripts/make-v33-bat.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v32.bat'
DST = BASE / 'patches' / 'phase-d-v33.bat'

V25_HASH = '022e6d1c01fb7de7704182bcf230062905c58f5d8677e1b75cdd0582609b398b'
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
# 1. the v25 header block (the v24 block demoted)
# =========================================================
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v24: v23 + THE DEREF FIX. The v31 field""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v25: v24 + THE PAGE-TABLE WALK (F4). The
rem v32 field run (2026-09-27 21:09) PROVED F3 IN SUBSTANCE -
rem W1 all-PASS (eproc=0xFFFFDC89140BF080 canonical OUT-OF-IMAGE
rem via the deref chain, System pid 4 at eproc, names live at
rem +0x5A8, 64 procs/236 pages), W4/W5 clean, 6th consecutive
rem F1/F2 green, zero crashes. The single FAIL was the W2 count
rem tolerance - root-caused to a SCRIPT-side cap-blind
rem calibration (the walk stops at 64 BY DESIGN; this VM ran
rem 102 live). Driver v24 is INNOCENT.
rem
rem v25 ADDS op 12 TranslateVa: VA -> page-table walk through
rem the SELF-MAP (no CR3 switching - the v17/v19 lesson; no
rem physical reads; no kernel calls). PTE_BASE discovery by TWO
rem ordered chains: A = nt!MmPteBase (.data, RVA candidates
rem from 19 real 19041/19045 PDBs) + the 512-value structural
rem check - A gates ALL out-of-image reads, so a drifted patch
rem level refuses CLEANLY (VM alive); B = the PFN bootstrap
rem (MmPfnDatabase -> System CR3 from EPROCESS+0x28 ->
rem _MMPFN.PteAddress -> the s-identity); A and B must AGREE.
rem THE TWO-WAY PROOF: PML4E[s] must point at the System CR3
rem frame - the page tables and the EPROCESS validate each
rem other. Host-proven 89/89 incl. the T26 drifted-world and
rem T32 absent-parent class-kills; disasm-verified; bench A
rem 13/13 + B 5/5. Test script: trigger-test-v33.ps1 (full
rem K/L/M/J/W regression + the CAP-AWARE W2 fix + the P ladder
rem P1..P7 with the two-way proof + the DTB cross-check).
rem
rem DRIVER SIZE: v25-RT = 141154 bytes (sha256 022e6d1c...).
rem v24-RT = 134842 (no page tables: op 12 answers
rem ErrUnsupported(8)); v23-RT/v22-RT = BOTH 134330. The bat's
rem pre-flight 1b/1c check size + hash.
rem ============================================================
rem INFINITY Phase D v24 (historical): v23 + THE DEREF FIX. The v31 field""",
'B25-header')

# =========================================================
# 2. pre-flight 1: the script name
# =========================================================
rep('trigger-test-v32.ps1', 'trigger-test-v33.ps1', 'B25-scriptname', count=8)

# =========================================================
# 3. pre-flight 1b: size guard retarget (v25-RT = 141154)
# =========================================================
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v24-RT = 134842) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134842" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v24 RT driver ^(v24-RT = 134842 bytes^).""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v25-RT = 141154) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="141154" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v25 RT driver ^(v25-RT = 141154 bytes^).""",
'B25-sizeguard')

# the size-mismatch branch: name v24 and the 134330 pair
rep(
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
"""            echo clean refusal, never a crash^). Replace with the v25
            echo driver for the F4 page-table proof.
          ) else (
            if "%DRIVERSIZE%"=="134842" (
              echo That size is the v24 RT driver ^(deref-fixed, but NO
              echo page tables^): op 12 answers ErrUnsupported^(8^) - the
              echo P ladder can never run. Pre-flight 1c confirms by hash.
            ) else (
              if "%DRIVERSIZE%"=="134330" (
                echo That size is the v23 or v22 RT driver ^(both 134330^):
                echo v23 = the MISSING-DEREF bug - the v31 field run had
                echo M1..M4 green but W refused payload status=4 not-System
                echo with walk=0 ^(fail-closed, no crash^); v22 =
                echo additionally refuses every M resolve. Pre-flight 1c
                echo names which one you have.
              ) else (
                echo Unknown driver build. Only the v25 RT driver runs
                echo the v33 P steps.
              )
            )
          )""",
'B25-sizebranches')

# =========================================================
# 4. pre-flight 1c: the FOUR-way hash guard
# =========================================================
_HG_OLD = """rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
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
_HG_OLD = _HG_OLD.replace('@V24HASH@', V24_HASH).replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

_HG_NEW = """rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
set ISV25=0
set ISV24=0
set ISV23=0
set ISV22=0
certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"@V25HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV25=1
findstr /I /C:"@V24HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV24=1
findstr /I /C:"@V23HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV23=1
findstr /I /C:"@V22HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV22=1
del "%TEMP%\\inf-drv-hash.txt" >nul 2>&1
if "%ISV25%"=="1" (
  echo [Phase D] memory.efi verified - v25 RT build ^(141154 bytes, sha256 022e6d1c...^).
) else (
  if "%ISV24%"=="1" (
    echo [ERROR] usb-d\\memory.efi is the v24 driver ^(134842 bytes,
    echo sha256 f8a01814...^). v24 is the deref-fixed F3 build but has
    echo NO PAGE TABLES: op 12 answers ErrUnsupported^(8^) - the P
    echo ladder can never run ^(the K/L/M/J/W regression still would^).
    echo Fix: copy this package's memory.efi over usb-d\\memory.efi.
    pause
    exit /b 1
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
        echo [ERROR] the sha256 matches NEITHER v25 ^(022e6d1c...^) NOR
        echo v24 ^(f8a01814...^) NOR v23 ^(d7562a7d...^) NOR v22
        echo ^(276b744c...^) - unknown build.
        echo Replace usb-d\\memory.efi with this package's v25 driver.
        pause
        exit /b 1
      )
    )
  )
)"""
_HG_NEW = _HG_NEW.replace('@V25HASH@', V25_HASH).replace('@V24HASH@', V24_HASH).replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

rep(_HG_OLD, _HG_NEW, 'B25-hashguard')

# =========================================================
# 5. milestone/banner/run/send/pristine lines
# =========================================================
rep(
"echo [Phase D] package v24 - Windows + memory.efi v24 RT boot test ^(F3 the EPROCESS walk, deref-fixed: walk from the EPROCESS^). Mode %MODE%.",
"echo [Phase D] package v25 - Windows + memory.efi v25 RT boot test ^(F4 the page-table walk: self-map translation + the two-way proof^). Mode %MODE%.",
'B25-milestone')

rep(
"echo [Phase D] The banner must say: memory.efi v24 RT ^(kernel data path: direct reads + export resolution + process walk^).",
"echo [Phase D] The banner must say: memory.efi v25 RT ^(kernel data path: direct reads + export resolution + process walk + page tables^).",
'B25-bannerline')

rep(
"""echo [Phase D]      Its FIRST line must say: trigger test v32.""",
"""echo [Phase D]      Its FIRST line must say: trigger test v33.""",
'B25-runline')

rep(
"echo   2. send the trigger-test-v32 output .txt ^(Desktop, via transfer stick^)",
"echo   2. send the trigger-test-v33 output .txt ^(Desktop, via transfer stick^)",
'B25-sendline')

# (the pristine-list line was already renamed by the B25-scriptname count=8 replace)

# =========================================================
# post checks
# =========================================================
if '\r\n' in text:
    print('[post] FATAL: CRLF crept in')
    sys.exit(1)
print('[post] LF-only preserved')
for must in ('trigger test v33', 'trigger-test-v33.ps1', '022e6d1c', 'f8a01814',
             'd7562a7d', '276b744c', 'certutil -hashfile', 'pre-flight 1c: HASH GUARD',
             'v25 RT build', 'INFINITY Phase D v25', '141154',
             'NO PAGE TABLES', 'v25-RT = 141154', 'the page tables and the EPROCESS validate each'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
print(f'[post] all {15} must-strings present')
for gone in ('"134842" (\n  echo [ERROR]', 'Only the v24 RT driver runs the',
             'the v24 RT driver ^(v24-RT = 134842 bytes^).'):
    if gone in text:
        print(f'[post] FATAL: stale text survived: {gone!r}')
        sys.exit(1)
print('[post] stale v24 guard texts removed')

DST.write_text(text, encoding='utf-8', newline='')
import hashlib
h = hashlib.sha256(DST.read_bytes()).hexdigest()
print()
print(f'[make-v33-bat] wrote {DST} ({DST.stat().st_size} bytes)')
print(f'[make-v33-bat] sha256 {h}')
print('[make-v33-bat] ALL EDITS + POST-CHECKS PASS')
