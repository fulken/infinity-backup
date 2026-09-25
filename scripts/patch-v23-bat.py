#!/usr/bin/env python3
"""patch-v23-bat.py — update phase-d-v18.bat for the v23 script.

The DRIVER generation is unchanged (v18 RT, 121253 bytes - the size
guard stays), so the bat keeps its phase-d-v18 name; what changes:
  - every script reference: trigger-test-v22.ps1 -> trigger-test-v23.ps1
  - the findstr marker: "trigger test v22" -> "trigger test v23"
  - "the v22 ladder" texts -> v23 ladder
  - old-files note (v17..v21) -> (v17..v22)
  - package references v18 -> v18b (this bundle generation)
  - a v23 header note documenting the user-alias hex fix
Anchored/counted edits; anything unexpected -> abort, no write.
"""
import sys

BASE = '/home/z/my-project/infinity-qemu-test/phase-d-v18.bat'
src = open(BASE, encoding='utf-8').read()
orig_len = len(src)
fails = []


def rep(old, new, label, expect=1):
    global src
    c = src.count(old)
    if c != expect:
        fails.append(f'{label}: expected {expect}, found {c}')
        print(f'  FAIL  {label}: expected {expect}, found {c}')
        return
    src = src.replace(old, new)
    print(f'  PASS  {label} ({expect}x)')


# 1) script file name, everywhere it appears
rep('trigger-test-v22.ps1', 'trigger-test-v23.ps1',
    'script filename v23', expect=9)

# 2) transcript reference in the "send back" list
rep('trigger-test-v22 output .txt', 'trigger-test-v23 output .txt',
    'send-back transcript name')

# 3) the findstr marker + the "first line" instruction
rep('trigger test v22', 'trigger test v23',
    'runtime marker v23', expect=2)

# 4) "the v22 ladder" texts (size-guard explanation)
rep('v22 ladder', 'v23 ladder', 'ladder wording v23', expect=3)

# 5) pre-flight heading + stale-copy error
rep('the trigger test script must be v22', 'the trigger test script must be v23',
    'pre-flight 1 heading')
rep('is NOT the v22 script', 'is NOT the v23 script',
    'stale-copy error text')

# 6) old-files note: the previous generation is now v17..v22
rep('Old trigger files ^(v17..v21^)', 'Old trigger files ^(v17..v22^)',
    'old-files note covers v22')

# 7) package generation references (this bundle = v18b: v18 driver + v23 script)
rep('extract the NEW v18 package zip', 'extract the NEW v18b package zip',
    'fix hint package v18b')
rep('package v18 - Windows + memory.efi v18 RT boot test',
    'package v18b - Windows + memory.efi v18 RT boot test',
    'run banner package v18b')

# 8) v23 header note (after the size-guard paragraph)
rep("""rem NEW in v18 pre-flight: the DRIVER SIZE GUARD. The v23 ladder
rem is safe ONLY with the v18 driver (121253 bytes). With the v17
rem driver (120678 bytes) still on the stick, J1..J5 WILL KILL
rem THE VM (the v20 crash class). The guard refuses to start.
""",
    """rem NEW in v18 pre-flight: the DRIVER SIZE GUARD. The v23 ladder
rem is safe ONLY with the v18 driver (121253 bytes). With the v17
rem driver (120678 bytes) still on the stick, J1..J5 WILL KILL
rem THE VM (the v20 crash class). The guard refuses to start.
rem
rem v23 SCRIPT UPDATE (2026-09-26): the ladder's USER-alias rungs
rem now send the REAL addresses (0x7FFE0260 / 0x7FFE0308). In v22
rem they were mis-assembled and the v18 gate rejected them as
rem out-of-window - J1/J3/J5 never reached the page. The DRIVER is
rem UNCHANGED (v18 RT, 121253 bytes - the size guard still applies).
""", 'v23 header note')

if fails:
    print('\nPATCH FAILED — nothing written:')
    for f in fails:
        print(' -', f)
    sys.exit(1)

# The shipped bat is LF-only (field-proven format) - keep it LF-only.
if '\r' in src:
    print('FATAL: bat unexpectedly contains CR - aborting to preserve proven format')
    sys.exit(1)

open(BASE, 'w', encoding='utf-8', newline='').write(src)

print()
print(f'wrote {BASE}')
print(f'  bytes : {len(src)} (base: {orig_len}, delta: {len(src) - orig_len:+d})')
checks = [
    ('no v22 filename left', src.count('trigger-test-v22.ps1') == 0),
    ('no v22 marker left', src.count('trigger test v22') == 0),
    ('v23 filename present', src.count('trigger-test-v23.ps1') == 9),
    ('v23 marker present', src.count('trigger test v23') == 2),
    ('size guard intact (121253 x6: guard+banner+notes)', src.count('121253') == 6),
    ('v17 size explained (120678 x2: comment+guard)', src.count('120678') == 2),
    ('v23 header note present', src.count('v23 SCRIPT UPDATE') == 1),
    ('pure ASCII', all(ord(c) < 128 for c in src)),
]
bad = [lbl for lbl, ok in checks if not ok]
for lbl, ok in checks:
    print(f'  {"PASS" if ok else "FAIL"}  {lbl}')
if bad:
    print('\nPOST-BUILD CHECKS FAILED:', bad)
    sys.exit(1)
print('\nPATCH v23-bat: ALL ANCHORS + CHECKS PASSED')
