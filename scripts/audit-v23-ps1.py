#!/usr/bin/env python3
"""Audit trigger-test-v23.ps1 (v22 audit + v23-specific checks):
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

PATH = '/home/z/my-project/infinity-qemu-test/trigger-test-v23.ps1'
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
one("==== INFINITY trigger test v23", "v23 banner")
one("trigger-test-v23-output-", "v23 transcript name")
one("==== END v23 ====", "v23 end marker")
one("[uint32]4294967295", "decimal max literal")
one("function Canary", "canary helper")
c = src.count("Try-Del 'INFTRIGGER'")   # cleanup list + canary helper
print(('  PASS  ' if c == 2 else f'  FAIL({c}) ') + 'canary target INFTRIGGER (cleanup + helper)')
if c != 2: fails.append('INFTRIGGER count')
c = src.count('Get-WinEvent')           # BugCheck + Kernel-Power queries
print(('  PASS  ' if c == 2 else f'  FAIL({c}) ') + 'post-mortem present (2 queries)')
if c != 2: fails.append('Get-WinEvent count')
one("Microsoft-Windows-WER-SystemErrorReporting", "BugCheck 1001 query")
one("Microsoft-Windows-Kernel-Power", "Kernel-Power 41 query")
one('Canary \'pre-A', "canary pre-A")
one('Canary \'pre-E', "canary pre-E")
one("Canary (\"pre-\" + $v.n)", "canary per-Jn")
one("Canary 'post-ladder", "canary post-ladder")
c = src.count('121253')                 # headers + driver-size documentation
print(('  PASS  ' if c >= 2 else f'  FAIL({c}) ') + 'v18-RT driver size documented')
if c < 2: fails.append('driver size doc')
for s in ['0x1601', '0x1602', '0x1603', '0x1604', '0x1605', '0x1606', '0x1607']:
    one(s, f"ladder seq {s}")

# THE v23 CORE: per-rung exact address counts (addr = '... form only)
print('LADDER ADDRESS MATRIX (exact per-rung counts):')
rungs = [
    ("addr = '000000007FFE0260'", 3, "J1/J5/J7 user alias 0x7FFE0260 (THE FIX)"),
    ("addr = '000000007FFE0308'", 1, "J3 user alias 0x7FFE0308 (THE FIX)"),
    ("addr = 'FFFFF78000000260'", 1, "J2 kernel alias (proven 2026-09-22)"),
    ("addr = 'FFFFF78000000308'", 1, "J4 kernel alias"),
    ("addr = '0000800000000000'", 1, "J6 non-canonical negative"),
]
for needle, want, label in rungs:
    c = src.count(needle)
    print(('  PASS  ' if c == want else f'  FAIL({c}, want {want}) ') + label)
    if c != want: fails.append(f'rung {label}')

# the v22 bad pattern must be gone from every CODE form
print('V22-SLIP ERADICATION:')
for needle, label in [
    ("addr = '00007FFE", "no rung uses the bad pattern"),
    ("'00007FFE00000260'", "no quoted literal uses the bad address"),
    ("'00007FFE00000308'", "no quoted literal uses the bad 0x308 address"),
]:
    c = src.count(needle)
    print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + label)
    if c != 0: fails.append(f'bad pattern: {label}')
# the header DOCUMENTS the slip (0x-prefixed, unquoted) - exactly once
c = src.count('0x00007FFE00000260')
print(('  PASS  ' if c == 1 else f'  FAIL({c}) ') + 'header documents the slip exactly once (0x form)')
if c != 1: fails.append('slip doc count')

# self-test must round-trip BOTH aliases
one("New-Req 0x1338 1 'FFFFFFFF' 4 '000000007FFE0260' $null", "selftest user-alias build")
one("ST-Check $stOk2 'New-Req user alias 000000007FFE0260", "selftest user-alias verdict")
one("New-Req 0x1337 1 'FFFFFFFF' 4 'FFFFF78000000260' $null", "selftest kernel-alias build (kept)")

# stale v22 runtime markers gone (header history blocks are fine)
for stale in ['==== INFINITY trigger test v22', '==== END v22 ====', 'trigger-test-v22-output-',
              '[uint32]0xFFFFFFFF']:
    c = src.count(stale)
    print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + f'stale-gone: {stale[:40]}')
    if c != 0: fails.append(f'stale {stale[:30]}')
# ASCII + LF only
if any(ord(c) > 127 for c in src):
    fails.append('ascii'); print('  FAIL  non-ascii characters present')
else:
    print('  PASS  pure ASCII')
if '\r' in src:
    fails.append('crlf'); print('  FAIL  CR present (CRLF)')
else:
    print('  PASS  LF only')
# Send-Req call sites (ladder loop uses it; PING uses Write-Var directly)
sc = len(re.findall(r'Send-Req\s*\(', strip_text(src)))
print(f'  INFO  Send-Req call sites: {sc} (ladder loop)')
if sc < 1:
    fails.append('sendreq'); print('  FAIL  Send-Req never called')

print()
if fails:
    print('AUDIT FAILED:', ', '.join(fails)); sys.exit(1)
print('AUDIT: ALL CHECKS PASSED')
