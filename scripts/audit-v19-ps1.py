#!/usr/bin/env python3
"""Audit trigger-test-v19.ps1 for the v18-class bugs:
1. automatic/read-only PowerShell variable usage ($pid, $args, $input, ...)
2. brace/paren/bracket balance and quote pairing (outside comments/strings)
3. quick stats"""
import re, sys

PATH = '/home/z/my-project/infinity-qemu-test/trigger-test-v19.ps1'
src = open(PATH, encoding='utf-8').read()
lines = src.split('\n')
print(f'file: {PATH}')
print(f'lines: {len(lines)}, bytes: {len(src)}, non-ascii: {sum(1 for c in src if ord(c) > 127)}')

# ---- 1. automatic variable scan (case-insensitive, word-boundary) ----
AUTO = ['pid', 'args', 'input', 'error', 'matches', 'myinvocation', 'profile',
        'home', 'host', 'true', 'false', 'null', 'stacktrace', 'foreach',
        'switch', 'this', 'psitem', 'args', 'typeof']
# ^ $true/$false/$null usage is READING (fine) - only flag them as ASSIGNED or
# used as PARAMETER names. Simplest: flag any $pid / $args / $input outright,
# and flag "$X =" or param($X for the others.
problems = []
for n, line in enumerate(lines, 1):
    for v in ('pid', 'args', 'input'):
        for m in re.finditer(r'\$' + v + r'\b', line, re.I):
            problems.append(f'  line {n}: ${v} usage: {line.strip()[:90]}')
    for v in AUTO:
        for m in re.finditer(r'[\$\s,(]\$?' + v + r'\s*(=|\)|,|\])', line, re.I):
            # assignment or parameter-position usage of an automatic name
            if m.group(0).lstrip(' ($').lower().startswith(v) and '=' in m.group(1):
                problems.append(f'  line {n}: possible assignment to ${v}: {line.strip()[:90]}')
if problems:
    print('AUTOMATIC-VARIABLE PROBLEMS:')
    print('\n'.join(problems))
else:
    print('AUTOMATIC-VARIABLE SCAN: CLEAN (no $pid / $args / $input, no assignments to automatic names)')

# ---- 2. balance check with comment/string awareness ----
def strip_strings_comments(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '<' and text.startswith('<#', i):          # block comment
            j = text.find('#>', i + 2)
            i = n if j < 0 else j + 2
            out.append(' ')
        elif c == '#':                                     # line comment
            j = text.find('\n', i)
            i = n if j < 0 else j
        elif c == '`':                                     # backtick escape
            out.append('  ' if i + 1 < n else ' ')
            i += 2
        elif c == '"' or c == "'":                         # string
            q, j = c, i + 1
            while j < n:
                if q == '"' and text[j] == '`':
                    j += 2
                    continue
                if text[j] == q:
                    # doubled quote = escaped
                    if j + 1 < n and text[j+1] == q:
                        j += 2
                        continue
                    break
                j += 1
            out.append('S')                                # string placeholder
            i = j + 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)

code = strip_strings_comments(src)
# here-string bodies were stringified above as one 'S' - good enough for balance
stack, errs = [], []
PAIR = {')': '(', ']': '[', '}': '{'}
for i, c in enumerate(code):
    if c in '([{':
        stack.append((c, i))
    elif c in ')]}':
        if not stack or stack[-1][0] != PAIR[c]:
            errs.append(f'  unmatched {c} at char {i} (line {code[:i].count(chr(10))+1})')
            if stack:
                stack.pop()
        else:
            stack.pop()
if stack:
    for c, i in stack:
        errs.append(f'  unclosed {c} at char {i} (line {code[:i].count(chr(10))+1})')
if errs:
    print('BALANCE ERRORS:')
    print('\n'.join(errs))
else:
    print(f'BALANCE: OK  ( {{ {code.count("{")}  ( {code.count("(")}  [ {code.count("[")} )')

# ---- 3. spot checks ----
checks = {
    "'==== INFINITY trigger test v19'": '==== INFINITY trigger test v19' in src,
    'New-Req defined': 'function New-Req' in src,
    'Send-Req defined': 'function Send-Req' in src,
    'no $pid param in New-Req': re.search(r'function New-Req\([^)]*\$pid', src, re.I) is None,
    'KUSD 0x260 addr present': 'FFFFF78000000260' in src,
    'KUSD 0x308 addr present': 'FFFFF78000000308' in src,
    'bad VA present': '0000800000000000' in src,
    'kernel pid FFFFFFFF': "'FFFFFFFF'" in src,
    'attach op 7': '0x1555 7' in src,
    'seq ladder J..M': all(s in src for s in ('0x1666', '0x1777', '0x1888', '0x1999')),
    'Stop-Transcript present': 'Stop-Transcript' in src,
    'END v19 marker': '==== END v19 ====' in src,
}
bad = [k for k, v in checks.items() if not v]
print('SPOT CHECKS:', 'ALL OK' if not bad else 'FAILED: ' + ', '.join(bad))
sys.exit(1 if (problems or errs or bad) else 0)
