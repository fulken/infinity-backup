#!/usr/bin/env python3
"""patch-v23.py — build trigger-test-v23.ps1 from trigger-test-v22.ps1.

v23 = v22 + THE USER-ALIAS HEX FIX (script-only; driver v18 unchanged).

WHAT WAS WRONG (found in the 2026-09-22 Phase-E run analysis):
  The ladder's USER-alias rungs sent '00007FFE00000260' where the
  intended address was 0x000000007FFE0260 (KUSD+0x260 via the user
  window). A hex-string assembly slip: the string has the same 16-char
  length so nothing structural caught it. The v18 gate correctly
  rejected all three as out-of-window (J1/J3/J5 = accidental extra
  negatives; J7 also carried it). The kernel-alias strings
  ('FFFFF78000000260' / 'FFFFF78000000308') were CORRECT, which is why
  J2 still proved the kernel data path (19045) = PHASE E COMPLETE.

WHAT v23 CHANGES (8 anchored edits, everything else byte-identical):
  1-2) the four bad addr= strings -> the real user-alias addresses
  3)   banner v22 -> v23
  4)   transcript name -> trigger-test-v23-output-
  5)   end marker -> ==== END v23 ====
  6)   J7 why-text: updated to v18-proven semantics (pid check,
       not the attach fatality, is what J7 documents now)
  7)   v23 header block (stacked on the v21/v22 headers, house style)
  8)   self-test: NEW user-alias round-trip check — this class of
       slip can never again reach the driver (fails pre-flight)

Expected v23 ladder outcome with the v18 driver:
  J1 Success+19045 (user alias via request — the last unproven cell)
  J2 Success+19045 / J3 Success+0 / J4 Success+0 / J5 Success+19045
  J6 ErrAccess(4) non-canonical / J7 ErrAccess(4) real pid, no attach
  N  INFCNT = G+8 (unchanged)
"""
import sys

BASE = '/home/z/my-project/infinity-qemu-test/trigger-test-v22.ps1'
OUT = '/home/z/my-project/infinity-qemu-test/trigger-test-v23.ps1'

src = open(BASE, encoding='utf-8').read()
orig_len = len(src)
fails = []


def rep(old, new, label, expect=1):
    global src
    c = src.count(old)
    if c != expect:
        fails.append(f'{label}: expected {expect} occurrence(s), found {c}')
        print(f'  FAIL  {label}: expected {expect}, found {c}')
        return
    src = src.replace(old, new)
    print(f'  PASS  {label}')


# ----------------------------------------------------------------------
# 1) J1 / J5 / J7 user-alias address fix (3 identical bad strings)
# ----------------------------------------------------------------------
rep("addr = '00007FFE00000260'", "addr = '000000007FFE0260'",
    'J1/J5/J7 user-alias hex 0x7FFE0260', expect=3)

# 2) J3 user-alias address fix
rep("addr = '00007FFE00000308'", "addr = '000000007FFE0308'",
    'J3 user-alias hex 0x7FFE0308', expect=1)

# ----------------------------------------------------------------------
# 3) runtime banner (the phase-d.bat marker greps this)
# ----------------------------------------------------------------------
rep("==== INFINITY trigger test v22 (v18 driver: direct KUSD reads - the proof ladder J1..J7) ====",
    "==== INFINITY trigger test v23 (v18 driver: direct KUSD reads - the proof ladder J1..J7) ====",
    'banner v22 -> v23')

# 4) transcript file name
rep('trigger-test-v22-output-', 'trigger-test-v23-output-',
    'transcript name v23')

# 5) end marker
rep('==== END v22 ====', '==== END v23 ====', 'end marker v23')

# ----------------------------------------------------------------------
# 6) J7 why-text: v18-proven semantics (J7's reject is the pid check)
# ----------------------------------------------------------------------
rep("why = 'per-pid read WITHOUT attach: expect clean ErrAccess(4) - per-pid reads still need a (currently fatal) attach; honest negative'",
    "why = 'per-pid read WITHOUT attach, VALID window address: expect clean ErrAccess(4) pre-read, NO [RD] on serial - isolates the pid check; honest negative'",
    'J7 why-text v18 semantics')

# ----------------------------------------------------------------------
# 7) v23 header block (stacked after the v22 header, house style)
# ----------------------------------------------------------------------
rep("""# ============================================================

$ErrorActionPreference = 'Continue'""",
    """# ============================================================
# INFINITY bridge trigger test v23  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v23 = v22 + THE USER-ALIAS HEX FIX. Script-only; the driver is
# UNCHANGED (memory.efi v18 RT, 121253 bytes). In the v22 ladder
# the USER-alias rungs carried a mis-assembled hex string
# (0x00007FFE00000260 - the intended 0x7FFE0260 shifted up 32
# bits - instead of 0x000000007FFE0260) - the v18 gate
# correctly rejected them as out-of-window (J1/J3/J5 became
# accidental extra negatives; the 2026-09-22 run still PROVED the
# kernel alias: J2 -> 19045 = PHASE E COMPLETE). v23 sends the
# REAL user-alias addresses, so the last unproven cell runs:
#     J1/J5/J7  0x000000007FFE0260  (KUSD+0x260, user window)
#     J3        0x000000007FFE0308  (KUSD+0x308, user window)
# Expected with the v18 driver:
#     J1 Success + 19045   <- user-alias read via request
#     J2 Success + 19045   (re-confirm the kernel alias)
#     J3 Success + 0
#     J4 Success + 0       (re-confirm)
#     J5 Success + dword[0] = 19045
#     J6 ErrAccess(4)  non-canonical, gate reject, NO crash
#     J7 ErrAccess(4)  real pid without attach = pre-read reject
#                      (with the VALID address this now isolates
#                      the pid check; NO [RD] on serial = the pid
#                      check fires BEFORE the window gate)
#     N  INFCNT = G+8 (unchanged)
# The self-test now ALSO round-trips the user-alias hex string,
# so this class of slip can never again reach the driver.
# ============================================================

$ErrorActionPreference = 'Continue'""",
    'v23 header block')

# ----------------------------------------------------------------------
# 8) self-test: user-alias round-trip (the v22-slip class, never again)
# ----------------------------------------------------------------------
rep("""ST-Check $stOk 'New-Req header bytes (seq/op/pid/len/addr) must round-trip'""",
    """ST-Check $stOk 'New-Req header bytes (seq/op/pid/len/addr) must round-trip'
$stReq2 = $null
try { $stReq2 = New-Req 0x1338 1 'FFFFFFFF' 4 '000000007FFE0260' $null }
catch { $stReq2 = $null }
$stOk2 = ($null -ne $stReq2 -and $stReq2.Length -eq 48 -and
    $stReq2[16] -eq 0x60 -and $stReq2[17] -eq 0x02 -and $stReq2[18] -eq 0xFE -and $stReq2[19] -eq 0x7F -and
    $stReq2[20] -eq 0x00 -and $stReq2[21] -eq 0x00 -and $stReq2[22] -eq 0x00 -and $stReq2[23] -eq 0x00)
ST-Check $stOk2 'New-Req user alias 000000007FFE0260 -> bytes 60 02 FE 7F 00 00 00 00 (the v22 slip, never again)'""",
    'selftest user-alias round-trip')

if fails:
    print('\nPATCH FAILED — nothing written:')
    for f in fails:
        print(' -', f)
    sys.exit(1)

open(OUT, 'w', encoding='utf-8', newline='\n').write(src)

# ----------------------------------------------------------------------
# verification summary
# ----------------------------------------------------------------------
print()
print(f'wrote {OUT}')
print(f'  bytes : {len(src)} (v22 base: {orig_len}, delta: {len(src) - orig_len:+d})')
print(f'  lines : {src.count(chr(10)) + 1}')
checks = [
    ("NO rung carries the bad pattern (addr = '00007FFE...)",
     src.count("addr = '00007FFE") == 0),
    ("NO quoted string literal carries the bad address",
     src.count("'00007FFE00000260'") == 0),
    ("exactly 7 ladder rungs survived",
     src.count("addr = '") == 7),
    ("user-alias 0260: J1/J5/J7 + selftest(x2) + header(x2)",
     src.count('000000007FFE0260') == 7),
    ("user-alias 0308: J3 + header",
     src.count('000000007FFE0308') == 2),
    ("kernel alias 0260 unchanged (v21-header x2 + selftest + J2 addr+atxt)",
     src.count('FFFFF78000000260') == 5),
    ("kernel alias 0308 unchanged (J4 addr+atxt)",
     src.count('FFFFF78000000308') == 2),
    ("non-canonical rung unchanged (J6)",
     src.count('0000800000000000') == 1),
    ('v23 banner', src.count('==== INFINITY trigger test v23') == 1),
    ('v23 transcript name', src.count('trigger-test-v23-output-') == 1),
    ('v23 end marker', src.count('==== END v23 ====') == 1),
    ('stale v22 banner gone', src.count('==== INFINITY trigger test v22') == 0),
    ('stale v22 transcript gone', src.count('trigger-test-v22-output-') == 0),
    ('stale v22 end gone', src.count('==== END v22 ====') == 0),
    ('pure ASCII', all(ord(c) < 128 for c in src)),
    ('LF only', '\r' not in src),
]
bad = [lbl for lbl, ok in checks if not ok]
for lbl, ok in checks:
    print(f'  {"PASS" if ok else "FAIL"}  {lbl}')
if bad:
    print('\nPOST-BUILD CHECKS FAILED:', bad)
    sys.exit(1)
print('\nPATCH v23: ALL ANCHORS + CHECKS PASSED')
