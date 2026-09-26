#!/usr/bin/env python3
"""make-v25-bat.py - build phase-d-v19.bat with v25 script references.

Driver guard is UNTOUCHED (v19-RT 125450). Only the script-side
references move v24 -> v25, plus:
  - the stale-copy error message gets correct v25 wording (the v24
    bat still said "NOT the v23 script" - a leftover typo)
  - a v25 note line in the header (selftest fixture fix)
  - old-trigger-files range v17..v23 -> v17..v24
Line endings stay LF-only (field-proven format since v9).
"""
import re

SRC = '/home/z/my-project/infinity-qemu-test/phase-d-v19.bat'
d = open(SRC, 'rb').read().decode('ascii')
assert '\r' not in d, 'bat must stay LF-only'

# 1. header: test-script line + v25 note
d = d.replace(
    'rem Test script: trigger-test-v24.ps1 (K/L steps + J regression).',
    'rem Test script: trigger-test-v25.ps1 (K/L steps + J regression).\n'
    'rem\n'
    'rem v25 SCRIPT (2026-09-26): the v24 selftest fixture fix - the\n'
    'rem canonical-kernel-base bytes are now DERIVED from the decimal\n'
    'rem literal (the v24 run aborted AT the gate: hand-assembled bytes\n'
    'rem were wrong; driver untouched, zero [RD], no crash). K/L/J steps\n'
    'rem are byte-identical to v24.')

# 2. pre-flight marker check + messages
d = d.replace('rem ---- pre-flight 1: the trigger test script must be v23 ----',
              'rem ---- pre-flight 1: the trigger test script must be v25 ----')
d = d.replace('findstr /I /C:"trigger test v24" usb-d\\trigger-test-v24.ps1 >nul 2>&1',
              'findstr /I /C:"trigger test v25" usb-d\\trigger-test-v25.ps1 >nul 2>&1')
d = d.replace(
    '  echo [ERROR] usb-d\\trigger-test-v24.ps1 is NOT the v23 script.\n'
    '  echo A stale copy cannot run the v24 K/L steps - wrong verdict.',
    '  echo [ERROR] usb-d\\trigger-test-v25.ps1 is NOT the v25 script.\n'
    '  echo A stale v24 copy aborts at its own selftest fixture\n'
    '  echo (2026-09-26 field run) - the K/L ladder never runs.')

# 3. remaining plain filename refs (usb-d list x2, D:\\ run line, final send line)
d = d.replace('usb-d\\trigger-test-v24.ps1', 'usb-d\\trigger-test-v25.ps1')
d = d.replace('usb-d\\trigger-test-v25.ps1 not found', 'usb-d\\trigger-test-v25.ps1 not found')  # idempotent no-op
d = d.replace('trigger-test-v24.ps1', 'trigger-test-v25.ps1')  # usb-d ONLY-list x2 + any leftover
d = d.replace('D:\\trigger-test-v24.ps1', 'D:\\trigger-test-v25.ps1')
d = d.replace('send the trigger-test-v24 output .txt', 'send the trigger-test-v25 output .txt')
d = d.replace('echo [Phase D] trigger-test-v24.ps1 verified', 'echo [Phase D] trigger-test-v25.ps1 verified')

# 4. banner expectation line
d = d.replace('echo [Phase D]      Its FIRST line must say: trigger test v24.',
              'echo [Phase D]      Its FIRST line must say: trigger test v25.')

# 5. old-trigger-files range
d = d.replace('Old trigger files ^(v17..v23^)', 'Old trigger files ^(v17..v24^)')

# 6. driver-guard message wording: "the v24 K/L steps" -> "the v25 K/L steps"
d = d.replace('the v24 K/L\nrem steps need', 'the v25 K/L\nrem steps need')
d = d.replace('The v24 ladder with the', 'The v25 ladder with the')
d = d.replace('The v24 K/L\n', 'The v25 K/L\n')
d = d.replace('v24 K/L anchor steps.', 'v25 K/L anchor steps.')
d = d.replace('rem v24 SCRIPT (2026-09-26): K =', 'rem v24 SCRIPT basis (2026-09-26): K =')

# ---- verify: v24 may remain ONLY in explanatory comments/messages ----
bad = []
for l in d.split('\n'):
    if 'v24' not in l:
        continue
    ok = (l.lstrip().startswith('rem ')              # comment lines
          or 'stale v24 copy' in l                    # the stale-copy error message (must name v24)
          or 'v17..v24' in l)                         # old-files range (must include v24)
    if not ok:
        bad.append(l)
assert not bad, bad
assert 'trigger-test-v25.ps1' in d
assert 'trigger test v25' in d
assert '125450' in d  # driver guard untouched
assert '120678' in d and '121253' in d  # stale-driver detection untouched

open(SRC, 'wb').write(d.encode('ascii'))
import hashlib
print('written:', SRC)
print('bytes  :', len(d))
print('sha256 :', hashlib.sha256(d.encode('ascii')).hexdigest())
print('remaining v24 mentions (expected, comments only):', d.count('v24'))
