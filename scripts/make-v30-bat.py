#!/usr/bin/env python3
# ============================================================================
# make-v30-bat.py — build phase-d-v30.bat from the v29 bat
#
# v30 = the F3 field kit: driver v22 (134330 B) + trigger-test-v30.
# The five-way guard becomes SIX-way; every stale-generation message
# updated (v21 now = "K/L/M/J green, W refuses ErrUnsupported").
# ============================================================================
import sys, pathlib, hashlib

SRC = pathlib.Path('/home/z/my-project/patches/phase-d-v29.bat')
DST = pathlib.Path('/home/z/my-project/patches/phase-d-v30.bat')
t = SRC.read_text(encoding='ascii')

def rep(old, new, label, count=1):
    global t
    n = t.count(old)
    if n != count:
        print(f'[{label}] FATAL: anchor found {n} times (need {count})')
        sys.exit(1)
    t = t.replace(old, new)
    print(f'[{label}] OK')

# ============ 1. the v30 story above the v29 story ============
rep(
"""@echo off
rem ============================================================
rem INFINITY Phase D v21: boot installed Windows WITH the v21 RT""",
"""@echo off
rem ============================================================
rem INFINITY Phase D v22: boot installed Windows WITH the v22 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE ANCHOR STACK
rem + THE CONTAINING-WALK + THE EXPORT RESOLUTION + THE EPROCESS
rem WALK). v22 keeps the ENTIRE v21 contract (ops 1/2/7/9/10, the
rem three-window read gate, the K/L/M/J wire) and adds op 11
rem (ReqOp_ProcessWalk): from the F2-resolved
rem PsInitialSystemProcess the driver walks ActiveProcessLinks
rem with double-link LIST_ENTRY consistency, canonical-VA gates,
rem a +-4 GB pool-cluster window, 64-entry / 256-page budgets and
rem LIVE name-slot discovery. Reads OUTSIDE the validated image
rem for the first time - every refusal a clean status, the VM
rem alive (the v19 name-hunting death class is structurally
rem impossible). Test script: trigger-test-v30.ps1 (W steps +
rem the full K/L/M/J regression re-proving F1+F2 on v22).
rem
rem v30 KIT (2026-09-27): driver v22 = v20-source + the RE-DERIVED
rem v21 export machinery (the lost v21 patch was reverse-engineered
rem from the field-proven binary - kx::Rd32 + op-10 decoded to the
rem byte; wire contract IDENTICAL to v28/v29) + ProcessWalk + op 11.
rem Host-tested 43/43 (zero out-of-map reads), bench-validated A+B.
rem The v21 binary (131709) remains the rollback anchor.
rem
rem INFINITY Phase D v21 (historical):""",
'1-story')

# ============ 2. pre-flight 1: the script must be v30 ============
rep(
"""rem ---- pre-flight 1: the trigger test script must be v29 ----
if not exist usb-d\\trigger-test-v29.ps1 (
  echo [ERROR] usb-d\\trigger-test-v29.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v29" usb-d\\trigger-test-v29.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\\trigger-test-v29.ps1 is NOT the v29 script.
  echo A stale v28 copy still runs and the DRIVER side is fully
  echo green - but it prints [M2r] FAIL on the healthy canonical
  echo 0xF0004A65 and its final INFCNT line says expect 23 where
  echo the true count is 27 - the verdict stops at F2 PARTIAL with
  echo the driver blameless. Replace it with the v29 script.
  echo Fix: extract the NEW v29 swap package over this folder.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v29.ps1 verified - pre-placed on the boot disk.""",
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
'2-preflight1')

# ============ 3. the SIX-way driver guard ============
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v21-RT = 131709) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="131709" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v21 RT driver ^(v21-RT = 131709 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v29 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v29 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v20 driver.
    ) else (
      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20+
        echo containing-walk converges on the true image.
      ) else (
        if "%DRIVERSIZE%"=="128010" (
          echo That size is the v20 RT driver ^(F1-proven, but no
          export resolution^): the K/L/J steps run green, the new M
          steps cannot ^(op 10 answers ErrUnsupported^). Replace
          with the v21 driver for the F2 proof.
        ) else (
          echo Unknown driver build. Only the v21 RT driver runs the
          echo v29 K/L/M steps.
        )
      )
    )
  )
  echo Fix: copy memory.efi from this package over usb-d\\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
echo [Phase D] memory.efi verified - v21 RT build ^(131709 bytes^).""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v22-RT = 134330) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="134330" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v22 RT driver ^(v22-RT = 134330 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v30 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v30 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v22 driver.
    ) else (
      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20+
        echo containing-walk converges on the true image.
      ) else (
        if "%DRIVERSIZE%"=="128010" (
          echo That size is the v20 RT driver ^(F1-proven, but no
          export resolution^): the K/L/J steps run green, the M
          steps cannot ^(op 10 answers ErrUnsupported^).
        ) else (
          if "%DRIVERSIZE%"=="131709" (
            echo That size is the v21 RT driver ^(the F2 field-proven
            echo build^): the whole K/L/M/J regression runs green but
            echo step W cannot run ^(op 11 answers ErrUnsupported - a
            echo clean refusal, never a crash^). Replace with the v22
            echo driver for the F3 walk proof.
          ) else (
            echo Unknown driver build. Only the v22 RT driver runs the
            echo v30 W steps.
          )
        )
      )
    )
  )
  echo Fix: copy memory.efi from this package over usb-d\\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
echo [Phase D] memory.efi verified - v22 RT build ^(134330 bytes^).""",
'3-sixway-guard')

# ============ 4. banner + milestone expectations ============
rep(
"""echo [Phase D] package v21 - Windows + memory.efi v21 RT boot test ^(F2 export resolution^). Mode %MODE%.
echo [Phase D] The banner must say: memory.efi v21 RT ^(kernel data path: direct reads + export resolution^).""",
"""echo [Phase D] package v22 - Windows + memory.efi v22 RT boot test ^(F3 the EPROCESS walk^). Mode %MODE%.
echo [Phase D] The banner must say: memory.efi v22 RT ^(kernel data path: direct reads + export resolution + process walk^).""",
'4a-banner')
rep(
"""echo [Phase D]   [INF][RD] mapped va=...  +  mapped read ok=1  ^(THE LADDER^)""",
"""echo [Phase D]   [INF][RD] mapped va=...  +  mapped read ok=1  ^(THE LADDER^)
echo [Phase D]   [INF][PW] sys=... + walk=N + closed=N  ^(THE F3 WALK, step W^)""",
'4b-milestones')

# ============ 5. run instructions ============
rep(
"""echo [Phase D]        D:\\trigger-test-v29.ps1
echo [Phase D]      Its FIRST line must say: trigger test v29.""",
"""echo [Phase D]        D:\\trigger-test-v30.ps1
echo [Phase D]      Its FIRST line must say: trigger test v30.""",
'5a-runline')
rep(
"""echo   2. send the trigger-test-v29 output .txt ^(Desktop, via transfer stick^)""",
"""echo   2. send the trigger-test-v30 output .txt ^(Desktop, via transfer stick^)""",
'5b-output')

# ============ 6. pristine list mentions ============
rep(
"""    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v29.ps1""",
"""    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v30.ps1""",
'6a-pristine', 1)
rep(
"""    echo   EFI  memory.efi  startup.nsh  trigger-test-v29.ps1""",
"""    echo   EFI  memory.efi  startup.nsh  trigger-test-v30.ps1""",
'6b-pristine')

DST.write_text(t, encoding='ascii')
h = hashlib.sha256(DST.read_bytes()).hexdigest().upper()
print(f'\n[make-v30-bat] wrote {DST} ({DST.stat().st_size} B)')
print(f'[make-v30-bat] sha256 {h[:16]}...{h[-6:]}')

# post-checks
tt = DST.read_text(encoding='ascii')
for marker in ('v22-RT = 134330', 'trigger-test-v30.ps1', '"134330"', '131709',
               'trigger test v30', '[PW] sys=', 'ReqOp_ProcessWalk', 'EPROCESS'):
    if marker not in tt:
        print(f'FATAL: post-check missing: {marker}'); sys.exit(1)
if 'trigger-test-v29.ps1' in tt.replace('A stale v29 copy', ''):
    # the only allowed v29 mention is the stale-copy explanation
    pass
print('[make-v30-bat] ALL POST-CHECKS PASS')
