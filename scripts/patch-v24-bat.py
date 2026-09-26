#!/usr/bin/env python3
"""patch-v24-bat.py — create phase-d-v19.bat from phase-d-v18.bat.

The DRIVER GENERATION CHANGES (v18 RT -> v19 RT, the F1 anchor build,
125450 bytes), so this bat takes the v19 name. Changes:
  - header: the v19/F1 story (anchors + validated reads, fail-closed)
  - every script reference: trigger-test-v23.ps1 -> trigger-test-v24.ps1
  - findstr marker: "trigger test v23" -> "trigger test v24"
  - DRIVER SIZE GUARD: 121253 -> 125450 (v19-RT), with BOTH stale
    branches: 120678 (v17 = the CR3 killer) and 121253 (v18 = no
    anchors, op 9 unsupported -> K/L fail-closed, J regression only)
  - package refs v18b -> v19; old-files note v17..v22 -> v17..v23
  - banner expectation: memory.efi v19 RT (kernel data path:
    direct reads + anchors)
Anchored/counted edits; anything unexpected -> abort, no write.
Output: infinity-qemu-test/phase-d-v19.bat (LF-only, like the source).
"""
import sys

BASE = '/home/z/my-project/infinity-qemu-test'
SRC = BASE + '/phase-d-v18.bat'
DST = BASE + '/phase-d-v19.bat'
src = open(SRC, encoding='utf-8').read()
fails = []


def rep(old, new, label, expect=1):
    global src
    c = src.count(old)
    if c != expect:
        fails.append(label)
        print(f'  FAIL  {label}: expected {expect}, found {c}')
        return
    src = src.replace(old, new)
    print(f'  PASS  {label} ({expect}x)')


# ---- 1) header story (lines 3-9 block) ----
rep("""rem INFINITY Phase D v18: boot installed Windows WITH the v18 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads - the v19/v20 VM
rem killer is fixed: v17's kernel read switched CR3 to the boot
rem firmware tables, which under Windows map neither our hook
rem code nor the OS IDT/stack - fault storm. v18 reads the
rem KUSER_SHARED_DATA windows directly in the hook context; the
rem read can never fault. Test script: trigger-test-v23.ps1.)""",
    """rem INFINITY Phase D v19: boot installed Windows WITH the v19 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE F1 ANCHOR
rem STACK). v18's proven direct reads are unchanged; v19 adds
rem SIDT + IDT + LSTAR anchors, 3 walk-backs, 4 converging
rem validators and a FAIL-CLOSED gate: outside the KUSD windows
rem only the VALIDATED kernel image range unlocks, and only while
rem all validators agree. New request: op 9 (ReqOp_Anchors).
rem Test script: trigger-test-v24.ps1 (K/L steps + J regression).""",
    'header v19 story')

# ---- 2) the size-guard prelude comment ----
rep("""rem NEW in v18 pre-flight: the DRIVER SIZE GUARD. The v23 ladder
rem is safe ONLY with the v18 driver (121253 bytes). With the v17
rem driver (120678 bytes) still on the stick, J1..J5 WILL KILL
rem THE VM (the v20 crash class). The guard refuses to start.""",
    """rem DRIVER SIZE GUARD (kept from v18, retargeted): the v24 K/L
rem steps need the v19 driver (125450 bytes). With the v17 driver
rem (120678 bytes) J1..J5 WILL KILL THE VM (the v20 crash class);
rem with the v18 driver (121253 bytes) the K/L anchor steps cannot
rem run (op 9 unsupported -> fail-closed) and the run is degraded.
rem The guard refuses to start either way.""",
    'guard prelude comment')

# ---- 3) the v23 script-update comment -> v24 note ----
rep("""rem v23 SCRIPT UPDATE (2026-09-26): the ladder's USER-alias rungs
rem now send the REAL addresses (0x7FFE0260 / 0x7FFE0308). In v22
rem they were mis-assembled and the v18 gate rejected them as
rem out-of-window - J1/J3/J5 never reached the page. The DRIVER is
rem UNCHANGED (v18 RT, 121253 bytes - the size guard still applies).""",
    """rem v24 SCRIPT (2026-09-26): K = ReqOp_Anchors (op 9) runs the
rem discovery ONCE and reports state/reason/pe_base/pe_size; L1..L3
rem read REAL kernel bytes through the validated range (MZ, PE
rem header, entry code); L4/L5 prove the gate stays CLOSED outside
rem the range. If anchors fail, everything fails CLOSED (L4/L5
rem still run and MUST be rejected). J1..J7 = the v23 regression.""",
    'v24 script note')

# ---- 4) script filename, everywhere (the header edit above already
#          carried one reference, so 8 remain) ----
rep('trigger-test-v23.ps1', 'trigger-test-v24.ps1', 'script filename v24', expect=8)

# ---- 5) findstr marker + first-line note ----
rep('findstr /I /C:"trigger test v23"', 'findstr /I /C:"trigger test v24"', 'findstr marker v24')
rep('Its FIRST line must say: trigger test v23.', 'Its FIRST line must say: trigger test v24.', 'first-line note v24')

# ---- 6) stale-copy + package-fix wordings ----
rep("""  echo A stale copy cannot run the v18 ladder - wrong verdict.
  echo Fix: extract the NEW v18b package zip over this folder.""",
    """  echo A stale copy cannot run the v24 K/L steps - wrong verdict.
  echo Fix: extract the NEW v19 package zip over this folder.""",
    'stale-copy wording')

# ---- 7) the driver size guard block ----
rep("""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v18-RT = 121253) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="121253" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v18 RT driver ^(v18-RT = 121253 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v23 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    echo Unknown driver build. Only the v18 RT driver is safe for
    echo the v23 ladder.
  )
  echo Fix: copy memory.efi from this package over usb-d\\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
echo [Phase D] memory.efi verified - v18 RT build ^(121253 bytes^).""",
    """rem ---- pre-flight 1b: DRIVER SIZE GUARD (v19-RT = 125450) ----
set DRIVERSIZE=
for %%A in (usb-d\\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="125450" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v19 RT driver ^(v19-RT = 125450 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v24 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v24 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v19 driver.
    ) else (
      echo Unknown driver build. Only the v19 RT driver runs the
      echo v24 K/L anchor steps.
    )
  )
  echo Fix: copy memory.efi from this package over usb-d\\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
echo [Phase D] memory.efi verified - v19 RT build ^(125450 bytes^).""",
    'driver size guard v19')

# ---- 8) old-files note ----
rep('Old trigger files ^(v17..v22^) may stay', 'Old trigger files ^(v17..v23^) may stay', 'old-files note')

# ---- 9) run banner lines ----
rep('echo [Phase D] package v18b - Windows + memory.efi v18 RT boot test. Mode %MODE%.',
    'echo [Phase D] package v19 - Windows + memory.efi v19 RT boot test ^(F1 anchors^). Mode %MODE%.',
    'package banner line')
rep('echo [Phase D] The banner must say: memory.efi v18 RT (kernel data path: direct KUSD reads).',
    'echo [Phase D] The banner must say: memory.efi v19 RT (kernel data path: direct reads + anchors).',
    'banner expectation line')

# ---- 10) send-back transcript name ----
rep('send the trigger-test-v23 output .txt', 'send the trigger-test-v24 output .txt', 'send-back transcript name')

# ---- final checks ----
if fails:
    print('\nPATCH FAILED:', ', '.join(fails)); sys.exit(1)
for good, want in [('trigger-test-v24.ps1', 9), ('125450', 5), ('trigger test v24', 2),
                   ('v19 RT build', 1), ('direct reads + anchors', 1)]:
    c = src.count(good)
    if c != want:
        print(f'  FAIL final: "{good}" count {c} != {want}'); sys.exit(1)
# 121253 must remain EXACTLY TWICE: the prelude comment + the
# v18-stale detection branch - both INTENTIONAL v18 references
c = src.count('121253')
if c != 2:
    print(f'  FAIL final: 121253 count {c} != 2 (prelude + v18-stale branch)'); sys.exit(1)
for bad in ['trigger-test-v23.ps1', 'v18b', 'v18-RT = 121253', 'package v18b']:
    if bad in src:
        print(f'  FAIL final: stale "{bad}" still present'); sys.exit(1)
if '\r' in src:
    print('  FAIL final: CR present (must stay LF-only)'); sys.exit(1)
open(DST, 'w', encoding='utf-8', newline='\n').write(src)
print(f'\n[patch-v24-bat] ALL EDITS APPLIED -> {DST} ({len(src)} bytes)')
