#!/usr/bin/env python3
# ============================================================================
# make-v34-bat.py — build patches/phase-d-v34.bat from patches/phase-d-v33.bat
#
# v34 bat story:
#   1. NEW "Phase D v26" header block (the v25 block demoted to historical)
#   2. pre-flight 1 retargeted: trigger-test-v34.ps1
#   3. pre-flight 1b: size guard v26-RT = 140582 (v25 = 141154 THE F4 BSOD
#      BINARY 0x50 - DO NOT RUN; v24 = 134842 no page tables; v23/v22 =
#      134330 both)
#   4. pre-flight 1c: THE HASH GUARD now FIVE-way:
#      c8f79b95... = v26 (GO) / 022e6d1c... = v25 (REFUSE: the F4 BSOD
#      binary - op-12's first PTE-space read faults in the caller context)
#      / f8a01814... = v24 (REFUSE: no page tables - op 12 answers
#      ErrUnsupported(8)) / d7562a7d... = v23 (REFUSE: the missing deref)
#      / 276b744c... = v22 (REFUSE: the export-size gate bug) / neither
#      = unknown REFUSE
#   5. milestone/banner/run/send lines: v34 + the F4-attempt-2 story
#
# Usage: python3 scripts/make-v34-bat.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v33.bat'
DST = BASE / 'patches' / 'phase-d-v34.bat'

V26_HASH = 'c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb'
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
# 1. the v26 header block (the v25 block demoted)
# =========================================================
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v25: v24 + THE PAGE-TABLE WALK (F4). The""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v26: v25 + THE FORMULA FIX. The v33 field
rem run (2026-09-28 01:16) was the FIRST F4-ERA BSOD: F1/F2/F3
rem green a 7th time, the cap-aware W2 PROVEN, the op-11 dtb
rem echo PROVEN (0x1AD000) - then P1 hit BSOD 0x50
rem PAGE_FAULT_IN_NONPAGED_AREA inside op-12 (the engine died on
rem its FIRST PTE-space read, never returned; [PT]=0 on serial).
rem Root cause (walk-level, engine-side): v25 addressed the upper
rem page-table levels at PTE_BASE + shifted-vpn*8 - LOW-USER PTE
rem slots; the self-ref read walked PML4E[0] of the CALLER process
rem (absent in the trigger script context) and faulted.
rem
rem v26 computes the TRUE level bases (ground-truthed against the
rem published classic s=0x1ED constants 0xFFFFF6FB40000000 /
rem 0xFFFFF6FB7DA00000 / 0xFFFFF6FB7DBED000):
rem   PDE_BASE = PTE_BASE + (s<<30)
rem   PPE_BASE = PDE_BASE + (s<<21)
rem   PXE_BASE = PPE_BASE + (s<<12)   (PML4E[s] at PXE_BASE+s*8)
rem Every corrected slot walks only the s-self-ref chain + parents
rem already proven present (fault-free). ALSO: chain-B identity =
rem PteAddress == PXE_BASE + s*8 (v25 compared the wrong slot, so
rem B always missed); selfOk is now a BITMASK (bit0 = the PTE
rem space LIVE; bit1 = self frame == System CR3 - EXPECTED 0 in
rem the trigger-script caller context); the PtRd64 range gate is
rem wrap-free (s=0x1FF). Host-proven 101/101 on a TRUE-SEMANTICS
rem world (a REAL 4-level hierarchy + an independent hardware
rem walk - the v25 world shared the engine's wrong formulas,
rem which is why 89/89 passed while the VM died) + TWO class-
rem kills (the v25 engine dies at 0xFFFFD58000000D58 = the exact
rem field read; redacted constants = 15 clean fails); disasm-
rem verified; bench A 13/13 + B 5/5. Test script:
rem trigger-test-v34.ps1 (full K/L/M/J/W regression + the
rem cap-aware W2 + the P ladder with the LIVE selfOk semantics).
rem
rem DRIVER SIZE: v26-RT = 140582 bytes (sha256 c8f79b95...).
rem v25-RT = 141154 (THE F4 BSOD BINARY - DO NOT RUN); v24-RT =
rem 134842 (no page tables: op 12 answers ErrUnsupported(8));
rem v23-RT/v22-RT = BOTH 134330. The bat's pre-flight 1b/1c
rem check size + hash.
rem ============================================================
rem INFINITY Phase D v25 (historical): v24 + THE PAGE-TABLE WALK (F4). The""",
'B26-header')

# =========================================================
# 2. pre-flight 1: the script name (9 occurrences in the v33 bat)
# =========================================================
rep('trigger-test-v33.ps1', 'trigger-test-v34.ps1', 'B26-scriptname', count=9)

# =========================================================
# 2b. FIX the v33-era weak banner check: the findstr needle still
#     said "trigger test v32" (it passed only because of the
#     stacked headers). v34 checks the REAL v34 banner marker.
# =========================================================
rep(
"""rem ---- pre-flight 1: the trigger test script must be v32 ----""",
"""rem ---- pre-flight 1: the trigger test script must be v34 ----""",
'B26-pf1-title')

rep(
"""findstr /I /C:"trigger test v32" usb-d\\trigger-test-v34.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v34.ps1 is NOT the v32 script.
  echo A stale v31 copy runs the SAME wire steps, but its W1 success
  echo expectations are the OLD symbol-VA semantics - with the v24
  echo driver a green walk would print FAIL lines. Replace it with
  echo the v32 script from this package.
  pause
  exit /b 1
)""",
"""findstr /I /C:"trigger test v34" usb-d\\trigger-test-v34.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v34.ps1 is NOT the v34 script.
  echo A stale v33 copy runs the SAME wire steps - but its P1 expects
  echo the OLD v25 selfOk==1 semantics ^(frame == System CR3 - wrong
  echo for the caller context^) and would print a FAIL line on a
  echo HEALTHY v26 walk. Replace it with the v34 script from this
  echo package.
  pause
  exit /b 1
)""",
'B26-pf1-findstr')

# =========================================================
# 3. pre-flight 1b: size guard retarget (v26-RT = 140582)
# =========================================================
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v25-RT = 141154) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="141154" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v25 RT driver ^(v25-RT = 141154 bytes^).""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v26-RT = 140582) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="140582" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v26 RT driver ^(v26-RT = 140582 bytes^).""",
'B26-sizeguard')

# the size-mismatch branches: v25 = the BSOD binary FIRST
rep(
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
"""            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the F4 page-table proof.
          ) else (
            if "%DRIVERSIZE%"=="141154" (
              echo That size is the v25 RT driver - THE F4 BSOD
              echo BINARY: the v33 field run died 0x50 on op-12's
              echo first PTE-space read ^(the upper-level slot
              echo formulas were wrong - low-USER slots^). DO NOT
              echo RUN IT AGAIN. Replace with this package's v26.
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
                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v34 P steps.
                )
              )
            )
          )""",
'B26-sizebranches')

# =========================================================
# 4. pre-flight 1c: the FIVE-way hash guard
# =========================================================
_HG_OLD = """rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
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
_HG_OLD = _HG_OLD.replace('@V25HASH@', V25_HASH).replace('@V24HASH@', V24_HASH).replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

_HG_NEW = """rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
set ISV26=0
set ISV25=0
set ISV24=0
set ISV23=0
set ISV22=0
certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"@V26HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV26=1
findstr /I /C:"@V25HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV25=1
findstr /I /C:"@V24HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV24=1
findstr /I /C:"@V23HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV23=1
findstr /I /C:"@V22HASH@" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV22=1
del "%TEMP%\\inf-drv-hash.txt" >nul 2>&1
if "%ISV26%"=="1" (
  echo [Phase D] memory.efi verified - v26 RT build ^(140582 bytes, sha256 c8f79b95...^).
) else (
  if "%ISV25%"=="1" (
    echo [ERROR] usb-d\\memory.efi is the v25 driver ^(141154 bytes,
    echo sha256 022e6d1c...^) - THE F4 BSOD BINARY: the v33 field
    echo run died 0x50 PAGE_FAULT_IN_NONPAGED_AREA on op-12's first
    echo PTE-space read ^(the upper-level slot formulas addressed
    echo low-USER slots; the self-ref read walked PML4E[0] of the
    echo caller process - absent in the trigger script context^).
    echo DO NOT RUN IT AGAIN - replace with this package's v26.
    pause
    exit /b 1
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
          echo [ERROR] the sha256 matches NEITHER v26 ^(c8f79b95...^) NOR
          echo v25 ^(022e6d1c...^) NOR v24 ^(f8a01814...^) NOR v23
          echo ^(d7562a7d...^) NOR v22 ^(276b744c...^) - unknown build.
          echo Replace usb-d\\memory.efi with this package's v26 driver.
          pause
          exit /b 1
        )
      )
    )
  )
)"""
_HG_NEW = _HG_NEW.replace('@V26HASH@', V26_HASH).replace('@V25HASH@', V25_HASH).replace('@V24HASH@', V24_HASH).replace('@V23HASH@', V23_HASH).replace('@V22HASH@', V22_HASH)

rep(_HG_OLD, _HG_NEW, 'B26-hashguard')

# =========================================================
# 5. milestone/banner/run/send lines
# =========================================================
rep(
"echo [Phase D] package v25 - Windows + memory.efi v25 RT boot test ^(F4 the page-table walk: self-map translation + the two-way proof^). Mode %MODE%.",
"echo [Phase D] package v26 - Windows + memory.efi v26 RT boot test ^(F4 ATTEMPT 2: the level-base formula fix - the true self-map slots + the LIVE selfOk^). Mode %MODE%.",
'B26-milestone')

rep(
"echo [Phase D] The banner must say: memory.efi v25 RT ^(kernel data path: direct reads + export resolution + process walk + page tables^).",
"echo [Phase D] The banner must say: memory.efi v26 RT ^(kernel data path: direct reads + export resolution + process walk + page tables^).",
'B26-bannerline')

rep(
"""echo [Phase D]      Its FIRST line must say: trigger test v33.""",
"""echo [Phase D]      Its FIRST line must say: trigger test v34.""",
'B26-runline')

rep(
"echo   2. send the trigger-test-v33 output .txt ^(Desktop, via transfer stick^)",
"echo   2. send the trigger-test-v34 output .txt ^(Desktop, via transfer stick^)",
'B26-sendline')

# =========================================================
# post checks
# =========================================================
if '\r\n' in text:
    print('[post] FATAL: CRLF crept in')
    sys.exit(1)
print('[post] LF-only preserved')
for must in ('trigger test v34', 'trigger-test-v34.ps1', 'c8f79b95', '022e6d1c',
             'f8a01814', 'd7562a7d', '276b744c', 'certutil -hashfile',
             'pre-flight 1c: HASH GUARD', 'v26 RT build', 'INFINITY Phase D v26',
             '140582', 'THE F4 BSOD BINARY', 'v26-RT = 140582',
             'LOW-USER PTE', 'true self-map slots'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
print('[post] all must-strings present')
for gone in ('Only the v25 RT driver runs the', 'the v25 RT driver ^(v25-RT = 141154 bytes^).'):
    if gone in text:
        print(f'[post] FATAL: stale text survived: {gone!r}')
        sys.exit(1)
print('[post] stale v25 guard texts removed')

DST.write_text(text, encoding='utf-8', newline='')
import hashlib
h = hashlib.sha256(DST.read_bytes()).hexdigest()
print()
print(f'[make-v34-bat] wrote {DST} ({DST.stat().st_size} bytes)')
print(f'[make-v34-bat] sha256 {h}')
print('[make-v34-bat] ALL EDITS + POST-CHECKS PASS')
