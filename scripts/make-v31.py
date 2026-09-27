#!/usr/bin/env python3
# ============================================================================
# make-v31.py — build trigger-test-v31.ps1 from the FIELD-RUN v30 script
#
# v31 story (what this patch encodes):
#   v30 field run (2026-09-27 17:50): F1 + J-matrix 100% re-proven on the
#   v22 binary, but EVERY M/W resolve refused with rc=4/resolve-failed.
#   Root cause (disassembly of the field-proven v21 binary @10fbb):
#   the export-size gate's true bound is 0x100000, not 0x10000 - the
#   f3-design hand-RE dropped a zero and v22 coded it. ntoskrnl 19045's
#   export directory (~0x11000-0x13000 bytes) tripped the wrong bound.
#   Fail-closed held everywhere (zero crashes, negatives clean).
#   driver v23 = v22 + the one-constant fix (0x10000 -> 0x100000),
#   host-proven 55/55 incl. the new REALISTIC-directory class-kill,
#   bench-proven 13/13 + 5/5.
#
# v31 CHANGES (script-only, anchored on the v30 text):
#   1. v31 header block above the v30 historical block
#   2. transcript name v30 -> v31
#   3. banner: the v31 story
#   4. driver identification carries the SHA-256 (v22-RT and v23-RT
#      are BOTH 134330 bytes - size alone cannot tell them apart)
#   5. decision table + W1 refusal text updated for v22-vs-v23
#   6. K-step label v20..v22 -> v20..v23
#   7. END marker v31
#
# THE WIRE CONTRACT IS UNCHANGED: K/L/M/J/W steps, expectations,
# INFCNT arithmetic - exactly as the field-run v30.
#
# Usage: python3 scripts/make-v31.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v30.ps1'
DST = BASE / 'patches' / 'trigger-test-v31.ps1'

V23_SHA = 'd7562a7dddc4227844036f7e397f1580338be74015715419b757bfac0577c5e8'
V22_SHA = '276b744c069389aa1d3ee649be56a4ee1e4ff0292ca8475af7529e9cf1cb9cc2'

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
# 1. v31 header above the v30 header
# =========================================================
rep(
"""# ============================================================
# INFINITY bridge trigger test v30  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v31  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v23 DRIVER (memory.efi v23 RT - "anchors + exports
# + process walk (F3)", 134330 bytes, sha256 d7562a7d...7c5e8).
# v23 = v22 + THE ONE-CONSTANT FIX: the export-size gate bound
# 0x10000 -> 0x100000 (the v21 field-binary truth @10fbb: lea
# edx,[rax-0x28]; cmp edx,0xfffd8 - the f3-design hand-RE had
# dropped a zero). The v30 run refused every M/W resolve because
# ntoskrnl 19045's export directory (~0x12000 bytes) tripped the
# wrong 64 KiB bound - fail-closed, zero crashes, F1 + the whole
# J matrix green on the very same v22 binary.
#
# CAUTION: v22-RT and v23-RT are BOTH 134330 bytes - size alone
# CANNOT tell them apart. v23 sha256 = d7562a7d...7c5e8
# (v22 = 276b744c...cb9cc2 - the buggy one). phase-d.bat checks
# the hash for you before every run.
#
# v31 CHANGES (script-only): header/transcript/banner/END marker
# v31 + the driver-ID texts below. THE WIRE CONTRACT, THE STEPS,
# THE EXPECTATIONS, THE INFCNT ARITHMETIC: UNCHANGED from v30.
# ============================================================
# ============================================================
# INFINITY bridge trigger test v30  (run INSIDE the Windows VM,""",
'H31-header')

# =========================================================
# 2. transcript name
# =========================================================
rep(
'''("trigger-test-v30-output-$stamp.txt")''',
'''("trigger-test-v31-output-$stamp.txt")''',
'H31-transcript')

# =========================================================
# 3. banner
# =========================================================
rep(
"Write-Host '==== INFINITY trigger test v30 (v22 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression re-proves F1+F2 on v22) ===='",
"Write-Host '==== INFINITY trigger test v31 (v23 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression + the v23 export-gate fix 0x10000 -> 0x100000) ===='",
'H31-banner')

# =========================================================
# 4. K-step label
# =========================================================
rep(
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v22 containing-walk) ---'",
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v23 containing-walk) ---'",
'H31-klabel')

# =========================================================
# 5. decision table: W lines + size check
# =========================================================
rep(
"""Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v22-only; v21 refuses op-11 = ErrUnsupported, never a crash).' +
                     '  Check size: v22-RT = 134330.'
Write-Host '                  Check usb-d\\memory.efi size: v22-RT = 134330 bytes (v21-RT = 131709 runs F1+F2 but not W).'""",
"""Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v23; v22 = same 134330 bytes but its export gate refuses W with status 7;' +
                     '  v21 = ErrUnsupported(8)). Never a crash by construction.'
Write-Host '                  v22-RT and v23-RT are BOTH 134330 bytes - only the sha256 tells them apart:' +
                     '  v23 = d7562a7d...7c5e8 (phase-d.bat checks it; v22 = 276b744c...cb9cc2 is the buggy one).'""",
'H31-decision-w')

# =========================================================
# 6. W-step comment + W1 refusal message
# =========================================================
rep(
"# (v22 driver only; with v21 the op refuses ErrUnsupported cleanly)",
"# (v23 driver; v22 = same size but its export gate refuses the walk; v21 = ErrUnsupported cleanly)",
'H31-wcomment')

rep(
'''Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v22 build (134330 B)? With v21 op 11 is ErrUnsupported(8)" -f $W1.Status, (Stat-Name $W1.Status))''',
'''Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v23 build? (v23 = 134330 B sha256 d7562a7d...; v22 = SAME SIZE but the export-gate bug refuses W; v21 = ErrUnsupported(8))" -f $W1.Status, (Stat-Name $W1.Status))''',
'H31-w1refusal')

# =========================================================
# 7. END marker
# =========================================================
rep(
"Write-Host '==== END v30 ===='",
"Write-Host '==== END v31 ===='",
'H31-end')

# =========================================================
# post checks
# =========================================================
n_v31 = text.count('v31')
n_v30_left = text.count('v30')
print()
print(f'[post] v31 mentions: {n_v31}')
print(f'[post] v30 mentions left (historical headers/notes only): {n_v30_left}')
for must in ('trigger-test-v31-output', '==== INFINITY trigger test v31',
             '==== END v31 ====', 'd7562a7d', 'v20..v23 containing-walk'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
    print(f'[post] present: {must!r}')
# the wire steps must be untouched
for wire in ("--- step W: ReqOp_ProcessWalk (op=11, pid ignored, outN=32) - THE F3 WALK ---",
             '$W1 = Send-Req (New-Req 0x1901 11',
             'INFCNT final', 'wSent'):
    if wire not in text:
        print(f'[post] FATAL: wire anchor missing: {wire!r}')
        sys.exit(1)
    print(f'[post] wire intact: {wire!r}')

DST.write_text(text, encoding='utf-8', newline='')
h = hashlib.sha256(DST.read_bytes()).hexdigest()
print()
print(f'[make-v31] wrote {DST} ({DST.stat().st_size} bytes)')
print(f'[make-v31] sha256 {h}')
print('[make-v31] ALL EDITS + POST-CHECKS PASS')
