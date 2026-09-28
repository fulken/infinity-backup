#!/usr/bin/env python3
"""make-v28-bat.py - build phase-d-v21.bat (v28 script + v21 driver).

Reads the CURRENT phase-d-v20.bat (v27 refs, paren-safe) and writes a
NEW phase-d-v21.bat. Driver generation CHANGES this time:
  - guard size 128010 (v20-RT) -> 131709 (v21-RT)
  - v20 (128010) joins the detected-OLD ladder with its own message
    (v20 is F1-proven but has NO export resolution - the v28 M steps
    cannot run; op 10 answers ErrUnsupported)
  - v17 (120678) still refuses to start (the CR3 killer); v18
    (121253) no anchors; v19 (125450) the nested-PE trap
  - banner expectation: v21 RT "direct reads + export resolution"
Script refs v27 -> v28; old-files range v17..v26 -> v17..v27.
Line endings stay LF-only (field-proven format since v9).
After this script, run scripts/audit-bat-parens.py on the result -
the v25 field incident (window closed: unescaped paren in a block)
must never ship again.
"""
import hashlib

SRC = '/home/z/my-project/infinity-qemu-test/phase-d-v20.bat'
DST = '/home/z/my-project/infinity-qemu-test/phase-d-v21.bat'

d = open(SRC, 'rb').read().decode('ascii')
assert '\r' not in d, 'source bat must be LF-only'

def rep(old, new, tag, count=1):
    global d
    got = d.count(old)
    assert got == count, f'{tag}: found {got}x (want {count})'
    d = d.replace(old, new)

# ---- 1. header identity: v20 -> v21 + the F2 export story ----
rep(
    """rem INFINITY Phase D v20: boot installed Windows WITH the v20 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE F1 ANCHOR
rem STACK + THE CONTAINING-WALK). v19's stack is unchanged; v20
rem fixes ONE walk rule: a candidate image is accepted only if it
rem CONTAINS the anchor it was walked from (the v25 field run
rem fail-closed on a nested PE that did not contain the anchors -
rem correct, but no convergence). Skipped candidates are counted
rem and named in the [AN] serial lines. op 9 payload unchanged.
rem Test script: trigger-test-v27.ps1 (K/L steps + J regression).
""",
    """rem INFINITY Phase D v21: boot installed Windows WITH the v21 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE ANCHOR STACK
rem + THE CONTAINING-WALK + THE EXPORT RESOLUTION). v20's stack is
rem unchanged; v21 adds op 10 (ReqOp_ResolveSymbol): symbols are
rem resolved from the VALIDATED image's own export table - every
rem parse read in-image bounds-checked, fail-closed on any corrupt
rem intermediate value. No per-build offset tables ever again. The
rem op-9 wire, the read gate and the K/L/J semantics are UNTOUCHED.
rem Test script: trigger-test-v28.ps1 (K/L/M steps + J regression).
""", 'hdr-identity')

# ---- 2. the v27 note -> the v28 note ----
rep(
    """rem v27 SCRIPT (2026-09-26): the L2b read-back fix. The v26 field
rem run CONVERGED - K state=1 reason=0, all three walks skipped the
rem v25 nested PE and unlocked the TRUE ntoskrnl range; L1 (MZ) and
rem L2a (e_lfanew) came back green - but the script read L2b's
rem 88-byte PE header back through a 64-BYTE buffer: Win32=122
rem (ERROR_INSUFFICIENT_BUFFER), "[DT] absent", verdict F1 PARTIAL
rem with the driver blameless (serial [RD] ok=1 - the bytes WERE
rem delivered). v27 sizes the read-back buffer to the driver cap
rem (4096). The v20 driver STAYS: memory.efi 128010, untouched.
""",
    """rem v28 SCRIPT (2026-09-26): STEP M - the F2 export-resolution
rem proof. The v27 field run was FULL GREEN: F1 PROVEN (converged
rem + MZ/PE-header/entry-code reads + both range negatives + J
rem 100% + INFCNT 17 exact). v28 adds M1 resolve
rem PsInitialSystemProcess (the F3 walk entry), M2 resolve
rem NtBuildNumber + read it (must equal the KUSD 19045 ground
rem truth), M3 resolve KeBugCheckEx + read 8 code bytes, M4 the
rem not-found negative (status 7). INFCNT 23 converged / 13
rem fail-closed. Stat-Name fixed to the driver enum (7=ErrNotFound).
""", 'hdr-v28-note')

# ---- 3. guard note: retarget to v21 + the five-way ladder ----
rep(
    """rem DRIVER SIZE GUARD (retargeted to v20-RT = 128010 bytes): with
rem the v17 driver (120678) J1..J5 WILL KILL THE VM (CR3 class);
rem with v18 (121253) there are no anchors at all; with v19 (125450)
rem the walk stops at the FIRST valid PE - the v25 field run hit
rem the nested-PE trap and fail-closed. The guard refuses all three
rem old generations.
""",
    """rem DRIVER SIZE GUARD (retargeted to v21-RT = 131709 bytes): with
rem the v17 driver (120678) J1..J5 WILL KILL THE VM (CR3 class);
rem with v18 (121253) there are no anchors at all; with v19 (125450)
rem the walk stops at the FIRST valid PE (the nested-PE trap); with
rem v20 (128010) everything runs EXCEPT the new M steps (no export
rem resolution - op 10 answers ErrUnsupported). The guard refuses
rem all four old generations.
""", 'hdr-guard-note')

# ---- 4. pre-flight 1: script marker v27 -> v28 ----
rep('rem ---- pre-flight 1: the trigger test script must be v27 ----',
    'rem ---- pre-flight 1: the trigger test script must be v28 ----', 'pf1-rem')
rep('if not exist usb-d\\trigger-test-v27.ps1 (',
    'if not exist usb-d\\trigger-test-v28.ps1 (', 'pf1-exist')
rep('  echo [ERROR] usb-d\\trigger-test-v27.ps1 not found.',
    '  echo [ERROR] usb-d\\trigger-test-v28.ps1 not found.', 'pf1-err')
rep('findstr /I /C:"trigger test v27" usb-d\\trigger-test-v27.ps1 >nul 2>&1',
    'findstr /I /C:"trigger test v28" usb-d\\trigger-test-v28.ps1 >nul 2>&1', 'pf1-findstr')
rep(
    """  echo [ERROR] usb-d\\trigger-test-v27.ps1 is NOT the v27 script.
  echo A stale v26 copy still runs and converges, but L2b^'s 88-byte
  echo PE header never reaches the checks ^(64-byte read-back^) -
  echo the verdict stays PARTIAL. Replace it with the v27 script.
  echo Fix: extract the NEW v27 swap package over this folder.
""",
    """  echo [ERROR] usb-d\\trigger-test-v28.ps1 is NOT the v28 script.
  echo A stale v27 copy still runs and is F1-green, but the M steps
  echo ^(export resolution^) never run - the verdict stops at
  echo F1 PROVEN. Replace it with the v28 script.
  echo Fix: extract the NEW v28 swap package over this folder.
""", 'pf1-stale-msg')
rep('echo [Phase D] trigger-test-v27.ps1 verified - pre-placed on the boot disk.',
    'echo [Phase D] trigger-test-v28.ps1 verified - pre-placed on the boot disk.', 'pf1-ok')

# ---- 5. pre-flight 1b: DRIVER SIZE GUARD -> 131709 with the v20 branch ----
rep('rem ---- pre-flight 1b: DRIVER SIZE GUARD (v20-RT = 128010) ----',
    'rem ---- pre-flight 1b: DRIVER SIZE GUARD (v21-RT = 131709) ----', 'pf1b-rem')
rep('if not "%DRIVERSIZE%"=="128010" (',
    'if not "%DRIVERSIZE%"=="131709" (', 'pf1b-guard')
rep(
    """  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v20 RT driver ^(v20-RT = 128010 bytes^).
""",
    """  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v21 RT driver ^(v21-RT = 131709 bytes^).
""", 'pf1b-err-head')
rep(
    """      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20
        echo containing-walk converges on the true image.
      ) else (
        echo Unknown driver build. Only the v20 RT driver runs the
        echo v27 K/L anchor steps.
      )
""",
    """      if "%DRIVERSIZE%"=="125450" (
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
          echo v28 K/L/M steps.
        )
      )
""", 'pf1b-v20-branch')
rep('echo [Phase D] memory.efi verified - v20 RT build ^(128010 bytes^).',
    'echo [Phase D] memory.efi verified - v21 RT build ^(131709 bytes^).', 'pf1b-ok')

# ---- 6. pristine list + old-files range ----
rep('echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v27.ps1',
    'echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v28.ps1', 'pf2-list')
rep('echo [Phase D] Old trigger files ^(v17..v26^) may stay in the ROOT of',
    'echo [Phase D] Old trigger files ^(v17..v27^) may stay in the ROOT of', 'old-files')

# ---- 7. run lines + banner expectation ----
rep('echo [Phase D] package v20 - Windows + memory.efi v20 RT boot test ^(F2 containing-walk^). Mode %MODE%.',
    'echo [Phase D] package v21 - Windows + memory.efi v21 RT boot test ^(F2 export resolution^). Mode %MODE%.', 'run-pkg-line')
rep('echo [Phase D] The banner must say: memory.efi v20 RT ^(kernel data path: direct reads + containing anchors^).',
    'echo [Phase D] The banner must say: memory.efi v21 RT ^(kernel data path: direct reads + export resolution^).', 'run-banner')
rep('echo [Phase D]        D:\\trigger-test-v27.ps1',
    'echo [Phase D]        D:\\trigger-test-v28.ps1', 'run-d-line')
rep('echo   EFI  memory.efi  startup.nsh  trigger-test-v27.ps1',
    'echo   EFI  memory.efi  startup.nsh  trigger-test-v28.ps1', 'pf2-list-2')
rep('echo   2. send the trigger-test-v27 output .txt ^(Desktop, via transfer stick^)',
    'echo   2. send the trigger-test-v28 output .txt ^(Desktop, via transfer stick^)', 'send-back-line')
rep('echo [Phase D]      Its FIRST line must say: trigger test v27.',
    'echo [Phase D]      Its FIRST line must say: trigger test v28.', 'run-first-line')

# ---- 8. sanity: no stale v27/v20 runtime refs left ----
for stale in ['trigger-test-v27.ps1', 'trigger test v27', 'v20 RT build',
              'v17..v26']:
    assert d.count(stale) == 0, f'stale ref remains: {stale} x{d.count(stale)}'
# 128010 may appear ONLY in the detection ladder (the v20 branch names
# the old size); the GUARD TARGET and the verify line must be 131709
assert 'if not "%DRIVERSIZE%"=="131709"' in d, 'guard target is not 131709'
assert 'v21 RT build ^(131709 bytes^)' in d, 'verify line is not v21/131709'
assert 'v20-RT = 128010 bytes^)' not in d, 'old refuse-target text remains'
n128010 = d.count('128010')
assert n128010 == 2, f'128010 appears {n128010}x (want 2: guard-note comment + detection branch)'

open(DST, 'wb').write(d.encode('ascii'))
import os
assert '\r' not in open(DST, 'rb').read().decode('ascii')
h = hashlib.sha256(open(DST, 'rb').read()).hexdigest()
print(f'written: {DST}')
print(f'size: {os.path.getsize(DST)} bytes  sha256: {h[:16]}...')
print('next: python3 scripts/audit-bat-parens.py (the class-kill gate)')
