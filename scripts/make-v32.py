#!/usr/bin/env python3
# ============================================================================
# make-v32.py — build trigger-test-v32.ps1 from the FIELD-RUN v31 script
#
# v32 story (what this patch encodes):
#   v31 field run (2026-09-27 19:51): the v23 export fix FIELD-PROVEN —
#   M1..M4 all green (M1 == the v29 value 0xFFFFF8071A4FC420, M2r 19045,
#   M3 real code bytes, M4 the correct rc=7), F1+F2 re-proven for the
#   5th time, J 100%, INFCNT 31 exact — but W refused: payload
#   status@1024=4 (not-System), walk=0, closed=0, name slot=0, pages=0,
#   serial [PW] sys=0xFFFFF8071A4FC420.
#   Root cause (source-level, confirmed by disasm of the built v24):
#   op-11 passed the RESOLVED SYMBOL VA to WalkCore — the missing DEREF.
#   PsInitialSystemProcess is a POINTER VARIABLE; *(u64*)slot is the
#   System EPROCESS (pool, OUTSIDE the image). driver v24 = the deref
#   chain (pw::SysEprocessFromSymbol: kx::Resolve -> gated kx::Rd32 x2
#   -> WalkCore(eproc)), host-proven 66/66 incl. the T23 chain
#   class-kill, disasm-verified (11919 call Resolve -> 1195e range gate
#   -> 1196f budget 0xF4240 -> 119b4 call Rd32 -> [PW] eproc -> walk).
#   The 0x5A8 name window was RULED OUT as a cause (web-verified:
#   ImageFileName @ 0x5A8 is correct for 19041-19045).
#
# v32 CHANGES (script-only, anchored on the v31 text):
#   1. v32 header block above the v31 historical block
#   2. transcript name v31 -> v32
#   3. banner: the v32 story
#   4. K-step label v20..v23 -> v20..v24
#   5. decision table + W1 refusal text updated for v24 (sizes now
#      DIFFER: v24-RT = 134842 bytes, v23/v22 = 134330)
#   6. *** THE W1 SUCCESS EXPECTATIONS CORRECTED *** — v31 expected
#      entries[0].eproc == M1's VA (the symbol-VA misconception that
#      caused the driver bug); v24 semantics: payload sysEntry@1032 =
#      the DEREF'd EPROCESS — canonical, OUTSIDE the image range,
#      == entries[0].eproc, pid 4. The symbol cross-check (== M1)
#      lives on the serial [PW] sys= line.
#   7. verdict + summary texts: "System at the pool EPROCESS"
#   8. END marker v32
#
# THE WIRE CONTRACT IS UNCHANGED: steps, request bytes, payload layout,
# INFCNT arithmetic - exactly as the field-run v31 (the INFCNT formula
# computes wSent dynamically: with W green it prints G+8+13+4+6 = 33).
#
# Usage: python3 scripts/make-v32.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v31.ps1'
DST = BASE / 'patches' / 'trigger-test-v32.ps1'

V24_SHA = 'f8a01814f4ffeb9a9b1595a722c733b0dbf92d5eb5710b25d88d7818dbcf5846'
V23_SHA = 'd7562a7dddc4227844036f7e397f1580338be74015715419b757bfac0577c5e8'

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
# 1. v32 header above the v31 header
# =========================================================
rep(
"""# ============================================================
# INFINITY bridge trigger test v31  (run INSIDE the Windows VM,""",
"""# ============================================================
# INFINITY bridge trigger test v32  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v24 DRIVER (memory.efi v24 RT - "anchors + exports
# + process walk (F3)", 134842 bytes, sha256 f8a01814...dbcf5846).
# v24 = v23 + THE DEREF FIX: the v31 run proved the v23 export fix
# (M1..M4 all green) but the WALK still refused with payload
# status=4 (not-System): op-11 was passing the RESOLVED SYMBOL VA
# (0xFFFFF8071A4FC420 - the in-image .data slot) to the walk
# instead of the EPROCESS it POINTS AT. v24 derefs the slot via
# the same gated in-image reads (no new trust root) and walks
# from the true System EPROCESS - a pool object OUTSIDE the image.
# Host-proven 66/66 incl. the T23 chain class-kill; disasm-verified.
#
# DRIVER SIZE CHECK: v24-RT = 134842 bytes. v23-RT and v22-RT are
# BOTH 134330 (v23 = the missing-deref bug: W refuses status=4
# not-System with walk=0; v22 = additionally refuses every M).
# v24 sha256 = f8a01814...dbcf5846. phase-d.bat checks all of it.
#
# W1 SUCCESS NOW MEANS (v24 semantics, corrected from v31):
#   payload.status=0(Ok), count 1..64, sysEntry@1032 = the DEREF'd
#   EPROCESS: canonical (>= 0xFFFF800000000000) AND OUTSIDE
#   [pe_base, pe_base+pe_size) AND == entries[0].eproc with pid 4.
#   The symbol cross-check (serial [PW] sys= == M1's va) is read
#   from serial-phase-d.log, not the payload.
#
# v32 CHANGES (script-only): header/transcript/banner/END marker
# v32 + driver-ID texts + the corrected W1 success expectations.
# THE WIRE CONTRACT, THE STEPS, THE PAYLOAD LAYOUT, THE INFCNT
# ARITHMETIC: UNCHANGED from the field-run v31.
# ============================================================
# ============================================================
# INFINITY bridge trigger test v31  (run INSIDE the Windows VM,""",
'H32-header')

# =========================================================
# 2. transcript name
# =========================================================
rep(
'''("trigger-test-v31-output-$stamp.txt")''',
'''("trigger-test-v32-output-$stamp.txt")''',
'H32-transcript')

# =========================================================
# 3. banner
# =========================================================
rep(
"Write-Host '==== INFINITY trigger test v31 (v23 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression + the v23 export-gate fix 0x10000 -> 0x100000) ===='",
"Write-Host '==== INFINITY trigger test v32 (v24 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression + the v24 DEREF fix: walk from the EPROCESS the symbol points at, not the symbol slot) ===='",
'H32-banner')

# =========================================================
# 4. K-step label
# =========================================================
rep(
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v23 containing-walk) ---'",
"Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v24 containing-walk) ---'",
'H32-klabel')

# =========================================================
# 5. decision table: W lines
# =========================================================
rep(
"""Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v23; v22 = same 134330 bytes but its export gate refuses W with status 7;' +
                     '  v21 = ErrUnsupported(8)). Never a crash by construction.'
Write-Host '                  v22-RT and v23-RT are BOTH 134330 bytes - only the sha256 tells them apart:' +
                     '  v23 = d7562a7d...7c5e8 (phase-d.bat checks it; v22 = 276b744c...cb9cc2 is the buggy one).'""",
"""Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v24; v23 = 134330 B and its MISSING DEREF refuses W with payload status=4' +
                     '  not-System walk=0 - the v31 field signature; v22 = also refuses every M). Never a crash by construction.'
Write-Host '                  Sizes now differ: v24-RT = 134842 bytes (sha256 f8a01814...dbcf5846); v23/v22 = 134330.' +
                     '  phase-d.bat checks size + hash before every run.'""",
'H32-decision-w')

# =========================================================
# 6. W-step comment + W1 refusal message
# =========================================================
rep(
"# (v23 driver; v22 = same size but its export gate refuses the walk; v21 = ErrUnsupported cleanly)",
"# (v24 driver: resolve -> DEREF the pointer slot -> walk the EPROCESS; v23 = missing deref, refuses not-System; v21 = ErrUnsupported)",
'H32-wcomment')

rep(
'''Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v23 build? (v23 = 134330 B sha256 d7562a7d...; v22 = SAME SIZE but the export-gate bug refuses W; v21 = ErrUnsupported(8))" -f $W1.Status, (Stat-Name $W1.Status))''',
'''Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v24 build? (v24 = 134842 B sha256 f8a01814...; v23 = 134330 B, the missing-deref bug, refuses W with payload status=4 not-System; v22 = refuses every M too)" -f $W1.Status, (Stat-Name $W1.Status))''',
'H32-w1refusal')

# =========================================================
# 7. THE W1 SUCCESS EXPECTATIONS (the v24 semantics)
# =========================================================
rep(
'''        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} sys=0x{6:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys)''',
'''        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} eproc=0x{6:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys)''',
'H32-payloadlabel')

rep(
"""            # the F2<->F3 cross-check: sys MUST equal M1's resolved VA
            $sysEcho = ($wSys -eq $mVa)
            $e0pid = U32 $W1.Data 0
            $e0eproc = U64 $W1.Data 8
            $e0flags = U32 $W1.Data 4
            $e0name = [System.Text.Encoding]::ASCII.GetString($W1.Data, 16, 8)
            Write-Host ("     [W1] entries[0]: pid={0} eproc=0x{1:X} flags={2} name='{3}'" -f $e0pid, $e0eproc, $e0flags, $e0name)
            $w1Ok = ($wCount -ge 1) -and $sysEcho -and ($e0pid -eq 4) -and ($e0eproc -eq $mVa)
            if ($w1Ok) {
                Write-Host '     [W1] PASS: System entry self-echo at the M1-resolved VA (F2<->F3 cross-check) - list head proven'
            } else {
                Write-Host '     [W1] FAIL: sys!=M1-va or entries[0] is not System@S1 (see above + serial [PW])'
            }""",
"""            # v24 semantics (corrected from v31): sysEntry@1032 is the
            # DEREF-ed System EPROCESS - the value the in-image
            # PsInitialSystemProcess slot points at - NOT the symbol VA.
            # (v31 expected entries[0].eproc == M1's VA: the very
            # misconception that caused the v23 driver bug. The symbol
            # cross-check - serial [PW] sys= == M1's va - is read from
            # serial-phase-d.log, not the payload.) HERE we prove F3's
            # actual claim: the EPROCESS is DYNAMIC POOL DATA OUTSIDE
            # the validated image, and the walk starts there.
            $kPwMinKernel = [UInt64]'0xFFFF800000000000'
            $eprocCanon   = ($wSys -ge $kPwMinKernel)
            $eprocOutside = ($wSys -lt $peBase) -or ($wSys -ge ($peBase + $peSize))
            $e0pid = U32 $W1.Data 0
            $e0eproc = U64 $W1.Data 8
            $e0flags = U32 $W1.Data 4
            $e0name = [System.Text.Encoding]::ASCII.GetString($W1.Data, 16, 8)
            Write-Host ("     [W1] eproc=0x{0:X} (canonical={1} outside-image={2}) - serial [PW] sys= must equal the M1 va 0x{3:X}" -f $wSys, $eprocCanon, $eprocOutside, $mVa)
            Write-Host ("     [W1] entries[0]: pid={0} eproc=0x{1:X} flags={2} name='{3}'" -f $e0pid, $e0eproc, $e0flags, $e0name)
            $w1Ok = ($wCount -ge 1) -and ($wCount -le 64) -and $eprocCanon -and $eprocOutside -and ($e0pid -eq 4) -and ($e0eproc -eq $wSys)
            if ($w1Ok) {
                Write-Host '     [W1] PASS: entries[0] = System pid 4 AT THE EPROCESS - and the EPROCESS sits OUTSIDE [pe_base, pe_base+pe_size)'
                Write-Host '     [W1] PASS: PROCESS DATA OUTSIDE THE IMAGE - the F3 claim itself, reached via the deref chain'
            } else {
                Write-Host '     [W1] FAIL: eproc not canonical/out-of-image, or entries[0] is not System@eproc (see above + serial [PW])'
            }""",
'H32-w1expect')

# =========================================================
# 8. summary + verdict texts
# =========================================================
rep(
'''elseif ($w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok) { "PROVEN - {0} processes walked, System self-echo + live-list cross-check green" -f $wCount }''',
'''elseif ($w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok) { "PROVEN - {0} processes walked, System at the pool EPROCESS + live-list cross-check green" -f $wCount }''',
'H32-wsummary')

rep(
"""    Write-Host ("{0} processes counted, System self-echo at the M1 VA, live-list cross-check green," -f $wCount)""",
"""    Write-Host ("{0} processes counted, System pid 4 at the DEREF-ed pool EPROCESS (serial [PW] sys= equals the M1 VA)," -f $wCount)""",
'H32-verdict')

# =========================================================
# 9. END marker
# =========================================================
rep(
"Write-Host '==== END v31 ===='",
"Write-Host '==== END v32 ===='",
'H32-end')

# =========================================================
# post checks
# =========================================================
n_v32 = text.count('v32')
print()
print(f'[post] v32 mentions: {n_v32}')
for must in ('trigger-test-v32-output', '==== INFINITY trigger test v32',
             '==== END v32 ====', 'f8a01814', '134842',
             'v20..v24 containing-walk',
             '$eprocCanon', '$eprocOutside', '($e0eproc -eq $wSys)',
             'PROCESS DATA OUTSIDE THE IMAGE - the F3 claim itself',
             'DEREF-ed pool EPROCESS'):
    if must not in text:
        print(f'[post] FATAL: missing {must!r}')
        sys.exit(1)
    print(f'[post] present: {must!r}')
# the old misconception must be GONE
for gone in ('($e0eproc -eq $mVa)', '$sysEcho',
             'System self-echo at the M1-resolved VA'):
    if gone in text:
        print(f'[post] FATAL: the v31 symbol-VA expectation survived: {gone!r}')
        sys.exit(1)
    print(f'[post] removed: {gone!r}')
# the wire steps must be untouched
for wire in ("--- step W: ReqOp_ProcessWalk (op=11, pid ignored, outN=32) - THE F3 WALK ---",
             '$W1 = Send-Req (New-Req 0x1901 11',
             'INFCNT final', 'wSent',
             '$W5 = Send-Req (New-Req 0x1904 11'):
    if wire not in text:
        print(f'[post] FATAL: wire anchor missing: {wire!r}')
        sys.exit(1)
    print(f'[post] wire intact: {wire!r}')

DST.write_text(text, encoding='utf-8', newline='')
h = hashlib.sha256(DST.read_bytes()).hexdigest()
print()
print(f'[make-v32] wrote {DST} ({DST.stat().st_size} bytes)')
print(f'[make-v32] sha256 {h}')
print('[make-v32] ALL EDITS + POST-CHECKS PASS')
