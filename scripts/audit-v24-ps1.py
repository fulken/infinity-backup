#!/usr/bin/env python3
"""Audit trigger-test-v24.ps1 (v23 audit + v24/F1-specific checks):
1. automatic/read-only PowerShell variable usage ($pid/$args/$input; $PID
   allowed ONLY as the read '[uint32]$PID')
2. brace/paren/bracket balance + quote pairing outside comments/strings
3. hex-literal cast trap scan - [uint32]0x... >= 0x80000000 and
   [uint64]0x... >= 0x8000000000000000 parse NEGATIVE and the cast throws
   (the v21 line-444 class)
4. v23 spot checks: ladder J1..J7 integrity with the FIXED user-alias
   addresses (exact per-rung counts), the v22 bad pattern GONE in every
   code form, self-test user-alias round-trip, canaries, post-mortem,
   no stale v22 runtime markers, ASCII/LF
"""
import re, sys

PATH = '/home/z/my-project/infinity-qemu-test/trigger-test-v24.ps1'
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
def one(needle, label):
    c = src.count(needle)
    print(('  PASS  ' if c == 1 else f'  FAIL({c}) ') + label)
    if c != 1: fails.append(label)

print('SPOT CHECKS:')
def one(needle, label):
    c = src.count(needle)
    print(('  PASS  ' if c == 1 else f'  FAIL({c}) ') + label)
    if c != 1: fails.append(label)

one("==== INFINITY trigger test v24", "v24 banner")
one("trigger-test-v24-output-", "v24 transcript name")
one("==== END v24 ====", "v24 end marker")
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
# driver size documentation: v19-RT 125450 (v24 header + decision table + warning)
c = src.count('125450')
print(('  PASS  ' if c == 3 else f'  FAIL({c}, want 3) ') + 'v19-RT driver size documented x3')
if c != 3: fails.append('v19 size doc')
for s in ['0x1601', '0x1602', '0x1603', '0x1604', '0x1605', '0x1606', '0x1607']:
    one(s, f"J-ladder seq {s} (v23 regression, untouched)")
print('F1 SEQUENCE SPACE (K + L1..L5):')
for s, label in [('0x1701', 'K anchors'), ('0x1702', 'L1 MZ'), ('0x1703', 'L2a e_lfanew'),
                 ('0x1704', 'L2b PE header'), ('0x1705', 'L3 entry bytes'),
                 ('0x1706', 'L4 below-range negative'), ('0x1707', 'L5 above-range negative')]:
    one(s, label)
# K request: op 9 with neutral pid/addr
one("New-Req 0x1701 9 '00000000' 32 '0000000000000000' $null", "K request build (op=9, len=32, addr=0)")
# K payload parse offsets
for off, label in [("U32 $K.Data 0", "K payload state@0"), ("U32 $K.Data 4", "K payload reason@4"),
                   ("U64 $K.Data 8", "K payload pe_base@8"), ("U64 $K.Data 16", "K payload pe_size@16"),
                   ("U64 $K.Data 24", "K payload idt_base@24")]:
    one(off, label)
# L verdict constants
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
one("ST-Check ((U64 $stU64 0) -eq [uint64]18446603336489631744)", "selftest canonical kernel base (DECIMAL, no hex-cast trap)")

print('STALE MARKERS GONE:')
for stale in ['==== INFINITY trigger test v23', '==== END v23 ====', 'trigger-test-v23-output-',
              'expect G+8: H +1 and J1..J7 +7) ---', '[uint32]0xFFFFFFFF']:
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

print()
if fails:
    print('AUDIT FAILED:', ', '.join(fails)); sys.exit(1)
print('AUDIT: ALL CHECKS PASSED')
