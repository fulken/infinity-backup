#!/usr/bin/env python3
"""make-v27-bat.py - retarget phase-d-v20.bat to the v27 script.

Driver generation is UNCHANGED (v20-RT 128010 - the file keeps its
phase-d-v20.bat name, like the v25 script-only precedent kept
phase-d-v19.bat). Script-side references move v26 -> v27:
  - the "current script" header note (v26 note -> the v27 story:
    the v26 field run CONVERGED; L2b's 88-byte PE header came back
    Win32=122 through a 64-byte read-back buffer - driver blameless)
  - pre-flight 1 marker + stale-copy message (a stale v26 copy
    converges but the verdict stays PARTIAL)
  - old-trigger-files range v17..v25 -> v17..v26
  - the D:\\ run line, the FIRST-line expectation, the send-back line
  - the three driver-guard ladder messages say v27 (guards UNTOUCHED:
    128010 refuse-target + 125450/121253/120678 detection)
Line endings stay LF-only (field-proven format since v9).
After this script, run scripts/audit-bat-parens.py on the result -
the class-kill from the v25 field incident (unescaped paren in a
block) stays machine-gated.
"""
import hashlib

PATH = '/home/z/my-project/infinity-qemu-test/phase-d-v20.bat'

d = open(PATH, 'rb').read().decode('ascii')
assert '\r' not in d, 'bat must stay LF-only'

def rep(old, new, tag, count=1):
    global d
    got = d.count(old)
    assert got == count, f'{tag}: found {got}x (want {count})'
    d = d.replace(old, new)

# ---- 1. header: script identity + the v27 note (replaces the v26 note) ----
rep('rem Test script: trigger-test-v26.ps1 (K/L steps + J regression).',
    'rem Test script: trigger-test-v27.ps1 (K/L steps + J regression).', 'hdr-script-line')

rep(
    """rem v26 SCRIPT (2026-09-26): v25 logic byte-identical (it already
rem handles converged AND fail-closed dynamically); only the K-step
rem expectations moved: with the v20 driver CONVERGED is the
rem EXPECTED outcome (state=1 reason=0 + the real pe_base/pe_size).
""",
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
    'hdr-v27-note')

# ---- 2. pre-flight 1: marker v26 -> v27 ----
rep('rem ---- pre-flight 1: the trigger test script must be v26 ----',
    'rem ---- pre-flight 1: the trigger test script must be v27 ----', 'pf1-rem')
rep('if not exist usb-d\\trigger-test-v26.ps1 (',
    'if not exist usb-d\\trigger-test-v27.ps1 (', 'pf1-exist')
rep('  echo [ERROR] usb-d\\trigger-test-v26.ps1 not found.',
    '  echo [ERROR] usb-d\\trigger-test-v27.ps1 not found.', 'pf1-err')
rep('findstr /I /C:"trigger test v26" usb-d\\trigger-test-v26.ps1 >nul 2>&1',
    'findstr /I /C:"trigger test v27" usb-d\\trigger-test-v27.ps1 >nul 2>&1', 'pf1-findstr')
rep(
    """  echo [ERROR] usb-d\\trigger-test-v26.ps1 is NOT the v26 script.
  echo A stale v25 copy still runs, but its K expectations predate
  echo the v20 containing-walk - replace it with the v26 script.
  echo Fix: extract the NEW v20 package zip over this folder.
""",
    """  echo [ERROR] usb-d\\trigger-test-v27.ps1 is NOT the v27 script.
  echo A stale v26 copy still runs and converges, but L2b^'s 88-byte
  echo PE header never reaches the checks ^(64-byte read-back^) -
  echo the verdict stays PARTIAL. Replace it with the v27 script.
  echo Fix: extract the NEW v27 swap package over this folder.
""",
    'pf1-stale-msg')
rep('echo [Phase D] trigger-test-v26.ps1 verified - pre-placed on the boot disk.',
    'echo [Phase D] trigger-test-v27.ps1 verified - pre-placed on the boot disk.', 'pf1-ok')

# ---- 3. driver-guard ladder messages: v26 -> v27 wording (guards UNTOUCHED) ----
rep('    echo That size is the v17 RT driver. The v26 ladder with the',
    '    echo That size is the v17 RT driver. The v27 ladder with the', 'guard-v17-msg')
rep('      echo That size is the v18 RT driver ^(no anchors^). The v26 K/L',
    '      echo That size is the v18 RT driver ^(no anchors^). The v27 K/L', 'guard-v18-msg')
rep('        echo Unknown driver build. Only the v20 RT driver runs the\n        echo v26 K/L anchor steps.',
    '        echo Unknown driver build. Only the v20 RT driver runs the\n        echo v27 K/L anchor steps.', 'guard-unknown-msg')

# ---- 4. usb-d ONLY-lists (x2) ----
rep('    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v26.ps1',
    '    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v27.ps1', 'only-list-1')
rep('    echo   EFI  memory.efi  startup.nsh  trigger-test-v26.ps1',
    '    echo   EFI  memory.efi  startup.nsh  trigger-test-v27.ps1', 'only-list-2')

# ---- 5. old-trigger-files range + the run instructions ----
rep('echo [Phase D] Old trigger files ^(v17..v25^) may stay in the ROOT of',
    'echo [Phase D] Old trigger files ^(v17..v26^) may stay in the ROOT of', 'old-files-range')
rep('echo [Phase D]        D:\\trigger-test-v26.ps1',
    'echo [Phase D]        D:\\trigger-test-v27.ps1', 'run-line')
rep('echo [Phase D]      Its FIRST line must say: trigger test v26.',
    'echo [Phase D]      Its FIRST line must say: trigger test v27.', 'first-line-msg')
rep('echo   2. send the trigger-test-v26 output .txt ^(Desktop, via transfer stick^)',
    'echo   2. send the trigger-test-v27 output .txt ^(Desktop, via transfer stick^)', 'sendback-line')

# ---- post-edit verification ----
assert d.count('trigger-test-v27.ps1') == 9, d.count('trigger-test-v27.ps1')
assert d.count('trigger test v27') == 2  # findstr + FIRST-line message
assert 'trigger-test-v26.ps1' not in d
# v26 may remain ONLY in explanatory comments/messages (rem lines + the stale-copy message)
bad = []
for l in d.split('\n'):
    if 'v26' not in l:
        continue
    ok = (l.lstrip().startswith('rem ')          # comment lines (the v27 note names the v26 run)
          or 'stale v26 copy' in l               # the stale-copy error message must name v26
          or 'v17..v26' in l)                    # old-files range (must include v26)
    if not ok:
        bad.append(l)
assert not bad, bad
# guards UNTOUCHED
assert d.count('128010') == 6, d.count('128010')   # guard rem x2 + refuse-if + v20-RT pair + verified echo + the v27 note
assert '"125450"' in d and '"121253"' in d and '"120678"' in d
assert 'v17..v26' in d
# paren policy on the new stale-copy message: escaped
assert 'L2b^\'s 88-byte' in d and '^(64-byte read-back^)' in d

open(PATH, 'wb').write(d.encode('ascii'))
import hashlib
h = hashlib.sha256(d.encode('ascii')).hexdigest()
print(f'written: {PATH}')
print(f'bytes  : {len(d.encode("ascii"))}')
print(f'sha256 : {h}')
print('ALL SHAPE CHECKS PASS')
