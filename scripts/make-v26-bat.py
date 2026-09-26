#!/usr/bin/env python3
"""make-v26-bat.py - build phase-d-v20.bat (v26 script + v20 driver).

Reads the CURRENT phase-d-v19.bat (v25 refs, paren-safe) and writes a
NEW phase-d-v20.bat. Driver generation CHANGES this time:
  - guard size 125450 (v19-RT) -> 128010 (v20-RT)
  - v19 (125450) joins v18 (121253) as a detected OLD driver with its
    own message (v19's walk stops at the first valid PE - the v25
    field run fail-closed on the nested-PE trap; v20 contains it)
  - v17 (120678) still refuses to start (the CR3 killer)
  - banner expectation: v20 RT "direct reads + containing anchors"
Script refs v25 -> v26; old-files range v17..v24 -> v17..v25.
Line endings stay LF-only (field-proven format since v9).
After this script, run scripts/audit-bat-parens.py on the result -
the v25 field incident (window closed: unescaped paren in a block)
must never ship again.
"""
import re, hashlib

SRC = '/home/z/my-project/infinity-qemu-test/phase-d-v19.bat'
DST = '/home/z/my-project/infinity-qemu-test/phase-d-v20.bat'

d = open(SRC, 'rb').read().decode('ascii')
assert '\r' not in d, 'source bat must be LF-only'

def rep(old, new, tag, count=1):
    global d
    got = d.count(old)
    assert got == count, f'{tag}: found {got}x (want {count})'
    d = d.replace(old, new)

# ---- 1. header block: v20 identity + v26 script + guard note ----
rep(
    """rem INFINITY Phase D v19: boot installed Windows WITH the v19 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE F1 ANCHOR
rem STACK). v18's proven direct reads are unchanged; v19 adds
rem SIDT + IDT + LSTAR anchors, 3 walk-backs, 4 converging
rem validators and a FAIL-CLOSED gate: outside the KUSD windows
rem only the VALIDATED kernel image range unlocks, and only while
rem all validators agree. New request: op 9 (ReqOp_Anchors).
rem Test script: trigger-test-v25.ps1 (K/L steps + J regression).
""",
    """rem INFINITY Phase D v20: boot installed Windows WITH the v20 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE F1 ANCHOR
rem STACK + THE CONTAINING-WALK). v19's stack is unchanged; v20
rem fixes ONE walk rule: a candidate image is accepted only if it
rem CONTAINS the anchor it was walked from (the v25 field run
rem fail-closed on a nested PE that did not contain the anchors -
rem correct, but no convergence). Skipped candidates are counted
rem and named in the [AN] serial lines. op 9 payload unchanged.
rem Test script: trigger-test-v26.ps1 (K/L steps + J regression).
""", 'hdr-identity')

rep(
    """rem v25 SCRIPT (2026-09-26): the v24 selftest fixture fix - the
rem canonical-kernel-base bytes are now DERIVED from the decimal
rem literal (the v24 run aborted AT the gate: hand-assembled bytes
rem were wrong; driver untouched, zero [RD], no crash). K/L/J steps
rem are byte-identical to v24.
""",
    """rem v26 SCRIPT (2026-09-26): v25 logic byte-identical (it already
rem handles converged AND fail-closed dynamically); only the K-step
rem expectations moved: with the v20 driver CONVERGED is the
rem EXPECTED outcome (state=1 reason=0 + the real pe_base/pe_size).
""",
    'hdr-v26-note')

rep(
    """rem DRIVER SIZE GUARD (kept from v18, retargeted): the v25 K/L
rem steps need the v19 driver (125450 bytes). With the v17 driver
rem (120678 bytes) J1..J5 WILL KILL THE VM (the v20 crash class);
rem with the v18 driver (121253 bytes) the K/L anchor steps cannot
rem run (op 9 unsupported -> fail-closed) and the run is degraded.
rem The guard refuses to start either way.
""",
    """rem DRIVER SIZE GUARD (retargeted to v20-RT = 128010 bytes): with
rem the v17 driver (120678) J1..J5 WILL KILL THE VM (CR3 class);
rem with v18 (121253) there are no anchors at all; with v19 (125450)
rem the walk stops at the FIRST valid PE - the v25 field run hit
rem the nested-PE trap and fail-closed. The guard refuses all three
rem old generations.
""",
    'hdr-guard-note')

# ---- 2. pre-flight 1: script marker v25 -> v26 ----
rep('rem ---- pre-flight 1: the trigger test script must be v25 ----',
    'rem ---- pre-flight 1: the trigger test script must be v26 ----', 'pf1-rem')
rep('if not exist usb-d\\trigger-test-v25.ps1 (',
    'if not exist usb-d\\trigger-test-v26.ps1 (', 'pf1-exist')
rep('  echo [ERROR] usb-d\\trigger-test-v25.ps1 not found.',
    '  echo [ERROR] usb-d\\trigger-test-v26.ps1 not found.', 'pf1-err')
rep('findstr /I /C:"trigger test v25" usb-d\\trigger-test-v25.ps1 >nul 2>&1',
    'findstr /I /C:"trigger test v26" usb-d\\trigger-test-v26.ps1 >nul 2>&1', 'pf1-findstr')
rep(
    """  echo [ERROR] usb-d\\trigger-test-v25.ps1 is NOT the v25 script.
  echo A stale v24 copy aborts at its own selftest fixture
  echo ^(2026-09-26 field run^) - the K/L ladder never runs.
  echo Fix: extract the NEW v19 package zip over this folder.
""",
    """  echo [ERROR] usb-d\\trigger-test-v26.ps1 is NOT the v26 script.
  echo A stale v25 copy still runs, but its K expectations predate
  echo the v20 containing-walk - replace it with the v26 script.
  echo Fix: extract the NEW v20 package zip over this folder.
""", 'pf1-stale-msg')
rep('echo [Phase D] trigger-test-v25.ps1 verified - pre-placed on the boot disk.',
    'echo [Phase D] trigger-test-v26.ps1 verified - pre-placed on the boot disk.', 'pf1-ok')

# ---- 3. pre-flight 1b: DRIVER SIZE GUARD -> 128010 with v19 branch ----
rep('rem ---- pre-flight 1b: DRIVER SIZE GUARD (v19-RT = 125450) ----',
    'rem ---- pre-flight 1b: DRIVER SIZE GUARD (v20-RT = 128010) ----', 'pf1b-rem')
rep('if not "%DRIVERSIZE%"=="125450" (',
    'if not "%DRIVERSIZE%"=="128010" (', 'pf1b-cond')
rep('  echo the v19 RT driver ^(v19-RT = 125450 bytes^).',
    '  echo the v20 RT driver ^(v20-RT = 128010 bytes^).', 'pf1b-not-v20')
rep('    echo That size is the v17 RT driver. The v25 ladder with the',
    '    echo That size is the v17 RT driver. The v26 ladder with the', 'pf1b-v17')
rep(
    """    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v25 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v19 driver.
    ) else (
      echo Unknown driver build. Only the v19 RT driver runs the
      echo v25 K/L anchor steps.
    )
""",
    """    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v26 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v20 driver.
    ) else (
      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20
        echo containing-walk converges on the true image.
      ) else (
        echo Unknown driver build. Only the v20 RT driver runs the
        echo v26 K/L anchor steps.
      )
    )
""", 'pf1b-else-tree')
rep('echo [Phase D] memory.efi verified - v19 RT build ^(125450 bytes^).',
    'echo [Phase D] memory.efi verified - v20 RT build ^(128010 bytes^).', 'pf1b-ok')

# ---- 4. usb-d pristine lists: script name ----
rep('    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v25.ps1',
    '    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v26.ps1', 'list-1')
rep('    echo   EFI  memory.efi  startup.nsh  trigger-test-v25.ps1',
    '    echo   EFI  memory.efi  startup.nsh  trigger-test-v26.ps1', 'list-2')

# ---- 5. old-files range + run instructions + banner ----
rep('echo [Phase D] Old trigger files ^(v17..v24^) may stay in the ROOT of',
    'echo [Phase D] Old trigger files ^(v17..v25^) may stay in the ROOT of', 'old-range')
rep('echo [Phase D] package v19 - Windows + memory.efi v19 RT boot test ^(F1 anchors^). Mode %MODE%.',
    'echo [Phase D] package v20 - Windows + memory.efi v20 RT boot test ^(F2 containing-walk^). Mode %MODE%.', 'banner-pkg')
rep('echo [Phase D] The banner must say: memory.efi v19 RT ^(kernel data path: direct reads + anchors^).',
    'echo [Phase D] The banner must say: memory.efi v20 RT ^(kernel data path: direct reads + containing anchors^).', 'banner-say')
rep('echo [Phase D]        D:\\trigger-test-v25.ps1',
    'echo [Phase D]        D:\\trigger-test-v26.ps1', 'run-line')
rep('echo [Phase D]      Its FIRST line must say: trigger test v25.',
    'echo [Phase D]      Its FIRST line must say: trigger test v26.', 'run-first')
rep('echo   2. send the trigger-test-v25 output .txt ^(Desktop, via transfer stick^)',
    'echo   2. send the trigger-test-v26 output .txt ^(Desktop, via transfer stick^)', 'send-line')

# ---- 6. the v24-basis header note: keep as history, retag nothing ----

# ---- verify ----
assert '128010' in d, 'new driver size missing'
assert d.count('128010') >= 3, '128010 must appear in guard+verified+header'
assert '"125450"' in d, 'v19 detection branch missing'
assert '"121253"' in d and '"120678"' in d, 'old driver detection missing'
assert 'trigger-test-v26.ps1' in d and 'trigger test v26' in d
assert 'v17..v25' in d
# v25/v24/v19 may remain ONLY in comments and the guard's user-facing
# old-driver explanation messages (every executable line was replaced
# above with exactly-once asserts)
bad = []
for l in d.split('\n'):
    if ('v25' not in l) and ('v24' not in l) and ('v19' not in l):
        continue
    ok = (l.lstrip().startswith('rem ')
          or l.lstrip().startswith('echo ')     # guard messages name old drivers
          or '"125450"' in l                     # the v19 detection condition
          or 'v17..v25' in l)
    if not ok:
        bad.append(l)
assert not bad, bad

open(DST, 'wb').write(d.encode('ascii'))
h = hashlib.sha256(d.encode('ascii')).hexdigest()
print('written:', DST)
print('bytes  :', len(d))
print('sha256 :', h)
print('history mentions kept (v19/v24/v25 in comments):',
      d.count('v19'), d.count('v24'), d.count('v25'))
print('ALL SHAPE CHECKS PASS')
