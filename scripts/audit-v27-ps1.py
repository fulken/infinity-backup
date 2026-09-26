#!/usr/bin/env python3
"""Audit trigger-test-v27.ps1 (v26 audit + v27-specific checks: the L2b
read-back buffer class-kill):
1. automatic/read-only PowerShell variable usage ($pid/$args/$input; $PID
   allowed ONLY as the read '[uint32]$PID')
2. brace/paren/bracket balance + quote pairing outside comments/strings
3. hex-literal cast trap scan - [uint32]0x... >= 0x80000000 and
   [uint64]0x... >= 0x8000000000000000 parse NEGATIVE and the cast throws
   (the v21 line-444 class)
4. v23..v26 spot checks: ladder J1..J7 integrity, K/L sequence space,
   verdicts, canaries, v22-slip eradication, stale markers (incl. the
   v24/v25/v26 runtime markers), ASCII/LF
5. FIXTURE EMULATOR (the v24 field-abort class, 2026-09-26):
   the v24 script hand-assembled the canonical-kernel-base selftest
   bytes WRONG (00 00 10 80 FF FF FF FF = 0xFFFFFFFF80100000, not
   0xFFFF800010000000) and only the field run caught it. This audit
   now EMULATES the selftest in Python, SEQUENTIALLY (array state
   evolves line by line - $stb is reassigned between checks):
     - $st* byte-array assignments -> LE-parse with U32/U64 semantics
     - derived fixtures ($stBase -> for-loop bytes) -> derived + re-parsed
     - label hex tokens <-> compared literals cross-checked
     - New-Req selftest byte expectations emulated from the call args
   A fixture/literal/label disagreement now fails the audit BEFORE
   anything ships to the field.
6. NEW (v27) - THE 122 CLASS-KILL (the v26 field incident, 2026-09-26
   08:16): the v26 script read InfinityData back through a 64-byte
   buffer; L2b's 88-byte PE header came back Win32=122
   (ERROR_INSUFFICIENT_BUFFER) and the F1 verdict degraded to PARTIAL
   although the driver HAD delivered the bytes (serial [RD] ok=1).
   The audit now enforces: the Send-Req data buffer is exactly
   4096 (the driver's hard read cap), no other data-path buffer
   exists, and the 122 diagnostic hint is present.
"""
import re, sys

PATH = '/home/z/my-project/infinity-qemu-test/trigger-test-v27.ps1'
src = open(PATH, encoding='utf-8').read()
lines = src.split('\n')
print(f'file: {PATH}')
print(f'lines: {len(lines)}, bytes: {len(src)}, non-ascii: {sum(1 for c in src if ord(c) > 127)}')
fails = []

# ---- 1. automatic variable scan ----
def strip_line(line):
    out, i, n = [], 0, len(line)
    while i < n:
        c = line[i]
        if c == '#':
            break
        elif c == '`':
            out.append('  ' if i + 1 < n else ' '); i += 2
        elif c in '"\'':
            q, j = c, i + 1
            while j < n:
                if q == '"' and line[j] == '`':
                    j += 2; continue
                if line[j] == q:
                    if j + 1 < n and line[j+1] == q:
                        j += 2; continue
                    break
                j += 1
            out.append('S'); i = j + 1
        else:
            out.append(c); i += 1
    return ''.join(out)

problems = []
for n, line in enumerate(lines, 1):
    cl = strip_line(line)
    for m in re.finditer(r'\$(pid|args|input)\b', cl, re.I):
        tok = m.group(0)
        pre = cl[max(0, m.start()-9):m.start()]
        if tok.lower() == '$pid' and pre.lstrip().endswith('[uint32]'):
            continue
        problems.append(f'  line {n}: {tok}: {line.strip()[:90]}')
if problems:
    fails.append('autovars'); print('AUTOMATIC-VARIABLE PROBLEMS:'); print('\n'.join(problems))
else:
    print('AUTOMATIC-VARIABLE SCAN: CLEAN ([uint32]$PID read is the only legal exception)')

# ---- 2. balance ----
def strip_text(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '#':
            j = text.find('\n', i)
            i = n if j < 0 else j
        elif c == '`':
            out.append('  ' if i + 1 < n else ' '); i += 2
        elif c == '<' and text[i:i+2] == '<#':
            j = text.find('#>', i)
            out.append('\n' * text.count('\n', i, j if j >= 0 else n)); i = (j + 2) if j >= 0 else n
        elif c in '"\'':
            q, j = c, i + 1
            while j < n:
                if q == '"' and text[j] == '`':
                    j += 2; continue
                if text[j] == q:
                    if j + 1 < n and text[j+1] == q:
                        j += 2; continue
                    break
                j += 1
            out.append('S'); i = j + 1
        else:
            out.append(c); i += 1
    return ''.join(out)

code = strip_text(src)
pairs = {'(': ')', '{': '}', '[': ']'}
errs = []
stack = []
for i, c in enumerate(code):
    if c in pairs:
        stack.append((c, i))
    elif c in pairs.values():
        if not stack or pairs[stack[-1][0]] != c:
            errs.append(f'  unmatched {c} at line {code[:i].count(chr(10))+1}')
        else:
            stack.pop()
for c, i in stack:
    errs.append(f'  unclosed {c} at line {code[:i].count(chr(10))+1}')
if errs:
    fails.append('balance'); print('BALANCE PROBLEMS:'); print('\n'.join(errs))
else:
    print('BALANCE: OK (braces/parens/brackets + quotes paired)')

# ---- 3. hex-literal cast trap scan ----
traps = []
for n, line in enumerate(lines, 1):
    cl = strip_line(line)
    for m in re.finditer(r'\[(?:uint32|uint64|u32|u64)\]\s*(0x[0-9A-Fa-f]+)', cl):
        lit = int(m.group(1), 16)
        width = 64 if '64' in m.group(0)[:8] else 32
        if lit >= (1 << (width - 1)):
            traps.append(f'  line {n}: {m.group(0)} -> parses negative, cast THROWS')
if traps:
    fails.append('hexpliteral'); print('HEX-LITERAL CAST TRAPS:'); print('\n'.join(traps))
else:
    print('HEX-LITERAL CAST SCAN: CLEAN (no [uintNN]0x... literal that parses negative)')

# ---- 4. spot checks ----
print('SPOT CHECKS:')
def one(needle, label):
    c = src.count(needle)
    print(('  PASS  ' if c == 1 else f'  FAIL({c}) ') + label)
    if c != 1: fails.append(label)

one("==== INFINITY trigger test v27", "v27 banner")
one("trigger-test-v27-output-", "v27 transcript name")
one("==== END v27 ====", "v27 end marker")
one("v20 driver: K CONVERGED in the field; L validated reads - the L2b 88-byte read-back fixed", "v27 banner names the v20 driver + the fix")
one("(v20 containing-walk)", "K step names v20")
one("[uint32]4294967295", "decimal max literal")
one("function Canary", "canary helper")
one("Microsoft-Windows-WER-SystemErrorReporting", "BugCheck 1001 query")
one("Microsoft-Windows-Kernel-Power", "Kernel-Power 41 query")
one("Canary 'pre-A", "canary pre-A")
one("Canary 'pre-E", "canary pre-E")
one("Canary (\"pre-\" + $v.n)", "canary per-Jn")
one("Canary 'post-ladder", "canary post-ladder")
one("Canary 'pre-K'", "canary pre-K (the F1 discovery)")
one("Canary 'pre-L4'", "canary pre-L4 (the first range negative)")
c = src.count('125450')
print(('  PASS  ' if c == 2 else f'  FAIL({c}, want 2) ') + 'v19-RT size documented x2 (historical v24+v25 headers only - the v27 decision table now says v20-RT 128010)')
if c != 2: fails.append('v19 size doc')
c20 = src.count('128010')
print(('  PASS  ' if c20 == 5 else f'  FAIL({c20}, want 5) ') + 'v20-RT size 128010 documented x5 (v26+v27 headers, decision table x2, bat-guard doc)')
if c20 != 5: fails.append('v20 size doc')
one("v20-RT = 128010 bytes", "decision table names the v20 driver size")
for s in ['0x1601', '0x1602', '0x1603', '0x1604', '0x1605', '0x1606', '0x1607']:
    one(s, f"J-ladder seq {s} (v23 regression, untouched)")
print('F1 SEQUENCE SPACE (K + L1..L5):')
for s, label in [('0x1701', 'K anchors'), ('0x1702', 'L1 MZ'), ('0x1703', 'L2a e_lfanew'),
                 ('0x1704', 'L2b PE header'), ('0x1705', 'L3 entry bytes'),
                 ('0x1706', 'L4 below-range negative'), ('0x1707', 'L5 above-range negative')]:
    one(s, label)
one("New-Req 0x1701 9 '00000000' 32 '0000000000000000' $null", "K request build (op=9, len=32, addr=0)")
for off, label in [("U32 $K.Data 0", "K payload state@0"), ("U32 $K.Data 4", "K payload reason@4"),
                   ("U64 $K.Data 8", "K payload pe_base@8"), ("U64 $K.Data 16", "K payload pe_size@16"),
                   ("U64 $K.Data 24", "K payload idt_base@24")]:
    one(off, label)
one("$L1.Data[0] -eq 0x4D -and $L1.Data[1] -eq 0x5A", "L1 MZ byte check (4D 5A)")
one("$L2b.Data[0] -eq 0x50 -and $L2b.Data[1] -eq 0x45", "L2b PE sig byte check (50 45)")
one("([uint64]$sizeImg -eq $peSize)", "L2b size-match cross-validation")
one("$anSent = 1", "anSent counter starts at K")
c = src.count("$anSent++")
print(('  PASS  ' if c == 6 else f'  FAIL({c}, want 6) ') + 'anSent increments x6 (L1/L2a/L2b/L3/L4/L5)')
if c != 6: fails.append('anSent count')
one("$f1Ok = $anOk -and $mzOk -and $peOk -and $sizeMatch -and $epOk -and ($lNegTxt -like 'OK*')", "F1 verdict condition")
one("F1 PROVEN: ANCHORS CONVERGED", "F1 PROVEN verdict line")
one("F1 FAIL-CLOSED (the gate never opened)", "F1 FAIL-CLOSED verdict line")
one("$l4AddrStr = '{0:X16}' -f ($peBase - [uint64]0x1000)", "L4 below-range address math")
one("$l5AddrStr = '{0:X16}' -f ($peBase + $peSize)", "L5 above-range address math")
one("'FFFFF80002000000'", "fail-closed L4 fixed VA fallback")
one("'FFFFF80004000000'", "fail-closed L5 fixed VA fallback")
one("INFCNT = G+8+7 = G+15 when converged", "INFCNT converged expectation documented")
one("G+8+3 when fail-closed", "INFCNT fail-closed expectation documented")

print('LADDER ADDRESS MATRIX (v23 regression, exact per-rung counts):')
rungs = [
    ("addr = '000000007FFE0260'", 3, "user alias 0x7FFE0260 rungs J1/J5/J7"),
    ("addr = '000000007FFE0308'", 1, "J3 user alias 0x7FFE0308"),
    ("addr = 'FFFFF78000000260'", 1, "J2 kernel alias (field-proven 2026-09-22)"),
    ("addr = 'FFFFF78000000308'", 1, "J4 kernel alias"),
    ("addr = '0000800000000000'", 1, "J6 non-canonical negative"),
]
for needle, want, label in rungs:
    c = src.count(needle)
    print(('  PASS  ' if c == want else f'  FAIL({c}, want {want}) ') + label)
    if c != want: fails.append(f'rung {label}')

print('V22-SLIP STILL ERADICATED:')
for needle in ["addr = '00007FFE", "'00007FFE00000260'", "'00007FFE00000308'"]:
    c = src.count(needle)
    print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + needle[:40])
    if c != 0: fails.append(f'bad pattern {needle[:30]}')

print('SELF-TEST ROUND-TRIPS:')
one("New-Req 0x1338 1 'FFFFFFFF' 4 '000000007FFE0260' $null", "selftest user-alias build")
one("ST-Check ((U32 $stb 0) -eq [uint32]0x00005A4D)", "selftest MZ dword (L1 constant)")
one("ST-Check ((U32 $stb 0) -eq [uint32]0x00004550)", "selftest PE dword (L2 constant)")
one("ST-Check ((U64 $stU64 0) -eq $stBase)", "selftest canonical base (derived fixture)")
one("$stBase = [uint64]18446603336489631744", "selftest base literal = 0xFFFF800010000000")
one("$stU64[$i] = [byte](($stBase -shr (8 * $i)) -band 0xFF)", "fixture derivation loop (no hand-assembled bytes)")

print('V27 READ-BUFFER CLASS-KILL (the v26 field incident, Win32=122):')
c = src.count('$db = New-Object byte[] 4096')
print(('  PASS  ' if c == 1 else f'  FAIL({c}, want 1) ') + 'Send-Req InfinityData read-back buffer = 4096 (the driver cap)')
if c != 1: fails.append('data buffer 4096')
c = src.count('$db = New-Object byte[] 64')
print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + 'no undersized data-path buffer remains')
if c != 0: fails.append('data buffer 64')
c = len(re.findall(r'New-Object byte\[\] 64', src))
print(('  PASS  ' if c == 4 else f'  FAIL({c}, want 4) ') + 'the four NON-data 64-byte buffers stay 64 (INFDIAG x1, InfinityResp x2, VarBack x1 - all fixed-size 32B-or-less structs/vars)')
if c != 4: fails.append('other 64 buffers')
one("122 = the payload exceeded the 4096-byte buffer", "the 122 diagnostic hint line")
one("v27: size the buffer to the DRIVER CAP", "the fix comment names the class")

print('STALE MARKERS GONE:')
for stale in ['==== INFINITY trigger test v26', '==== END v26 ====', 'trigger-test-v26-output-',
              '==== INFINITY trigger test v25', '==== END v25 ====', 'trigger-test-v25-output-',
              '==== INFINITY trigger test v24', '==== END v24 ====', 'trigger-test-v24-output-',
              '==== INFINITY trigger test v23', '==== END v23 ====', 'trigger-test-v23-output-',
              '$stU64[2] = 0x10', '[uint32]0xFFFFFFFF']:
    c = src.count(stale)
    print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + f'stale-gone: {stale[:45]}')
    if c != 0: fails.append(f'stale {stale[:30]}')
if any(ord(c) > 127 for c in src):
    fails.append('ascii'); print('  FAIL  non-ascii characters present')
else:
    print('  PASS  pure ASCII')
if '\r' in src:
    fails.append('crlf'); print('  FAIL  CR present (CRLF)')
else:
    print('  PASS  LF only')
sc = len(re.findall(r'Send-Req\s*\(', strip_text(src)))
print(f'  INFO  Send-Req call sites: {sc} (K/L1/L2a/L2b/L3/L4/L5 + the J-ladder loop)')
if sc < 2:
    fails.append('sendreq'); print('  FAIL  Send-Req barely called')

# ============================================================
# ---- 5. FIXTURE EMULATOR (the v24 field-abort class) ----
# ============================================================
print('FIXTURE EMULATOR (byte fixtures <-> literals <-> labels):')

# emulator state - the walk is SEQUENTIAL: $stb is REASSIGNED between
# checks, so a final-snapshot emulation would test the LAST fixture
# against EVERY check. We evolve the state line by line instead.
scalars = {}          # $name = [uintNN]<decimal>
arrays = {}           # current byte state per array name (idx -> int)
derive_src = {}       # array -> the scalar its bytes are derived from

ASGN  = re.compile(r'\$(\w+)\[(\d+)\]\s*=\s*(0x[0-9A-Fa-f]+|\d+)\b')
SCAL  = re.compile(r'\$(\w+)\s*=\s*\[uint(?:32|64)\]\s*(\d{1,20})\b')
DERIV = re.compile(r'\$(\w+)\[\$i\]\s*=\s*\[byte\]\(\(\$(\w+)\s*-shr\s*\(8\s*\*\s*\$i\)\)\s*-band\s*0xFF\)')
STRE  = re.compile(r'ST-Check\s*\(\((U32|U64)\s+\$(\w+)\s+(\d+)\)\s*-eq\s+'
                   r'(?:\[uint(?:32|64)\]\s*)?(\$?\w+|\d{1,20})\)')

def emu_u32(arr):
    v = 0
    for i in range(3, -1, -1):
        v = (v << 8) | arr[i]
    return v & 0xFFFFFFFF

def emu_u64(arr):
    v = 0
    for i in range(7, -1, -1):
        v = (v << 8) | arr[i]
    return v & 0xFFFFFFFFFFFFFFFF

checked = 0
for n, line in enumerate(lines, 1):
    cl = strip_line(line)
    # scalars first ($stBase = [uint64]18446603336489631744)
    for m in SCAL.finditer(cl):
        scalars[m.group(1)] = int(m.group(2))
    # a derivation loop materializes the whole array from its source
    for m in DERIV.finditer(cl):
        derive_src[m.group(1)] = m.group(2)
        src_v = scalars.get(m.group(2))
        if src_v is None:
            print(f'  FAIL  line {n}: derivation source ${m.group(2)} not yet defined'); fails.append('fixture')
        else:
            arrays[m.group(1)] = {i: (src_v >> (8 * i)) & 0xFF for i in range(8)}
    # byte assignments update CURRENT state (partials allowed - the
    # PE-dword check rewrites only bytes 0 and 1 of the MZ fixture)
    for m in ASGN.finditer(cl):
        arrays.setdefault(m.group(1), {})[int(m.group(2))] = int(m.group(3), 0)
    # then evaluate any ST-Check on this line against CURRENT state
    m = STRE.search(cl)
    if not m:
        continue
    fn, arr, lit = m.group(1), m.group(2), m.group(4)   # 3 = offset, 4 = literal
    if arr not in arrays:
        continue
    a = arrays[arr]
    need = 4 if fn == 'U32' else 8
    if any(i not in a for i in range(need)):
        print(f'  FAIL  line {n}: {fn}(${arr}) fixture incomplete'); fails.append(f'fixture line {n}'); continue
    got = emu_u32(a) if fn == 'U32' else emu_u64(a)
    if lit.startswith('$'):
        if lit[1:] not in scalars:
            print(f'  FAIL  line {n}: literal {lit} unresolved'); fails.append(f'fixture line {n}'); continue
        exp = scalars[lit[1:]]
    else:
        exp = int(lit, 0)
    checked += 1
    if got != exp:
        print(f'  FAIL  line {n}: {fn}(${arr}) emulates 0x{got:X} but the check expects 0x{exp:X}'
              f'  <-- THE V24 CLASS'); fails.append(f'fixture line {n}')
    else:
        print(f'  PASS  line {n}: {fn}(${arr}) -> 0x{got:X} == expected')

# 5d. label hex tokens must be consistent with the compared literal
for n, line in enumerate(lines, 1):
    lm = re.search(r"ST-Check .*'([^']*)'\s*$", line.strip())
    cm = STRE.search(line)
    if not lm or not cm:
        continue
    lit = cm.group(4)  # group 1=fn, 2=array, 3=offset, 4=literal
    exp = scalars[lit[1:]] if lit.startswith('$') else int(lit, 0)
    label = lm.group(1)
    toks = [int(t, 16) for t in re.findall(r'0x[0-9A-Fa-f]{4,16}', label)]
    if toks and exp not in toks:
        print(f'  FAIL  line {n}: label hex {[hex(t) for t in toks]} does not contain expected 0x{exp:X}'
              f'  <-- LABEL/LITERAL MISMATCH'); fails.append(f'label line {n}')
    elif toks:
        print(f'  PASS  line {n}: label 0x{exp:X} consistent with compared literal')

# 5e. $stBase literal must BE the canonical kernel base the label names
if scalars.get('stBase') != 0xFFFF800010000000:
    print(f'  FAIL  $stBase = {scalars.get("stBase")} is not 0xFFFF800010000000'); fails.append('stBase value')
else:
    print('  PASS  $stBase = 18446603336489631744 = 0xFFFF800010000000 (canonical kernel base)')

# 5f. New-Req SELFTEST byte expectations, emulated from the call args
#     layout: [seq:4][op:4][pid:4][len:4][addr:8] little-endian
#     only $st*-assigned calls are selftest calls (runtime uses $req/$K)
CALLRE = re.compile(r"\$(\w+)\s*=\s*New-Req\s+(0x[0-9A-Fa-f]+|\d+)\s+(\d+)\s+'([0-9A-Fa-f]{8})'\s+(\d+)\s+'([0-9A-Fa-f]{16})'")
for call in CALLRE.finditer(src):
    var = call.group(1)
    if not var.startswith('st'):
        continue  # runtime call (K/L/J), not a selftest fixture
    seq, op, pid, ln, addr = (int(call.group(2), 0), int(call.group(3)), int(call.group(4), 16),
                              int(call.group(5)), int(call.group(6), 16))
    hdr = seq.to_bytes(4, 'little') + op.to_bytes(4, 'little') + pid.to_bytes(4, 'little') \
        + ln.to_bytes(4, 'little') + addr.to_bytes(8, 'little')
    # assertions reference this EXACT variable name
    seg = src[call.end():call.end() + 1400]
    exps = {int(i): int(v, 0) for i, v in
            re.findall(r'\$' + re.escape(var) + r'\[(\d+)\]\s+-eq\s+(0x[0-9A-Fa-f]+|\d+)', seg)}
    if not exps:
        print(f'  FAIL  New-Req ${var}: no byte assertions found after the call')
        fails.append(f'newreq noassert ${var}'); continue
    bad = [(i, v, hdr[i]) for i, v in exps.items() if hdr[i] != v]
    if bad:
        for i, v, g in bad:
            print(f'  FAIL  New-Req ${var} seq {seq:#x}: byte[{i}] asserted 0x{v:X} but layout says 0x{g:X}')
        fails.append(f'newreq bytes ${var}')
    else:
        print(f'  PASS  New-Req ${var} seq {seq:#x}: all {len(exps)} asserted bytes match the emulated layout')

if checked == 0:
    print('  FAIL  no ST-Check fixtures emulated - emulator regex broke'); fails.append('emulator broken')

print()
if fails:
    print('AUDIT FAILED:', ', '.join(fails)); sys.exit(1)
print('AUDIT: ALL CHECKS PASSED')
