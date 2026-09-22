#!/usr/bin/env python3
"""Audit trigger-test-v21.ps1:
1. automatic/read-only PowerShell variable usage ($pid/$args/$input; $PID allowed
   ONLY as the read '[uint32]$PID' - v21 needs the live process id for the ladder)
2. brace/paren/bracket balance + quote pairing outside comments/strings
3. v21-specific spot checks (ladder integrity, seq ladder, no stale v18 strings)
"""
import re, sys

PATH = '/home/z/my-project/infinity-qemu-test/trigger-test-v21.ps1'
src = open(PATH, encoding='utf-8').read()
lines = src.split('\n')
print(f'file: {PATH}')
print(f'lines: {len(lines)}, bytes: {len(src)}, non-ascii: {sum(1 for c in src if ord(c) > 127)}')

# ---- 1. automatic variable scan (comments stripped first) ----
def strip_strings_comments_line(line):
    out, i, n = [], 0, len(line)
    while i < n:
        c = line[i]
        if c == '#':          # line comment - rest of line ignored
            break
        elif c == '`':
            out.append('  ' if i + 1 < n else ' ')
            i += 2
        elif c == '"' or c == "'":
            q, j = c, i + 1
            while j < n:
                if q == '"' and line[j] == '`':
                    j += 2
                    continue
                if line[j] == q:
                    if j + 1 < n and line[j+1] == q:
                        j += 2
                        continue
                    break
                j += 1
            out.append('S')
            i = j + 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)

problems = []
for n, line in enumerate(lines, 1):
    codeline = strip_strings_comments_line(line)
    for m in re.finditer(r'\$(pid|args|input)\b', codeline, re.I):
        tok = m.group(0)
        # the ONLY legal use: reading the live process id -> '[uint32]$PID'
        pre = codeline[max(0, m.start()-9):m.start()]
        if tok.lower() == '$pid' and pre.lstrip().endswith('[uint32]'):
            continue
        problems.append(f'  line {n}: {tok} usage: {line.strip()[:90]}')
if problems:
    print('AUTOMATIC-VARIABLE PROBLEMS:')
    print('\n'.join(problems))
else:
    print('AUTOMATIC-VARIABLE SCAN: CLEAN ($pid/$args/$input absent; [uint32]$PID read is the only exception and is legal)')

# ---- 2. balance check with comment/string awareness ----
def strip_strings_comments(text):
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '<' and text.startswith('<#', i):
            j = text.find('#>', i + 2)
            i = n if j < 0 else j + 2
            out.append(' ')
        elif c == '#':
            j = text.find('\n', i)
            i = n if j < 0 else i
            # keep the newline handling below; skip to end of line
            j2 = text.find('\n', i)
            i = n if j2 < 0 else j2
        elif c == '`':
            out.append('  ' if i + 1 < n else ' ')
            i += 2
        elif c == '"' or c == "'":
            q, j = c, i + 1
            while j < n:
                if q == '"' and text[j] == '`':
                    j += 2
                    continue
                if text[j] == q:
                    if j + 1 < n and text[j+1] == q:
                        j += 2
                        continue
                    break
                j += 1
            out.append('S')
            i = j + 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)

code = strip_strings_comments(src)
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
ladder_variants = ['J1','J2','J3','J4','J5','J6','J7','J8','J9']
seqs = ['0x1601','0x1602','0x1603','0x1604','0x1605','0x1606','0x1607','0x1608','0x1609']
checks = {
    'banner v21': '==== INFINITY trigger test v21' in src,
    'END v21 marker': '==== END v21 ====' in src,
    'selftest gate + ABORT': '[SELFTEST][ABORT]' in src and 'U32/U64/HexLe4/New-Req all passed' in src,
    'U32 accumulator form': '$v = ($v -shl 8) -bor [uint32]$b[$o+$i]' in src,
    'U64 accumulator form': '$v = ($v -shl 8) -bor [uint64]$b[$o+$i]' in src,
    'old v18 U32 gone': '-bor ($b[$o+1] -shl 8)' not in src,
    'attach SKIPPED note': 'ReqOp_Attach -- SKIPPED' in src,
    'attach never sends op 7': '0x1555 7' not in src and 'New-Req 0x1555' not in src,
    'all 9 ladder variants': all(f"n = '{v}'" in src for v in ladder_variants),
    'all 9 ladder seqs': all(s in src for s in seqs),
    'user alias 0x7FFE0260': '00007FFE00000260' in src,
    'user alias 0x7FFE0308': '00007FFE00000308' in src,
    'kernel alias 0x260': 'FFFFF78000000260' in src,
    'non-canonical VA': '0000800000000000' in src,
    'pre-send crash marker': 'if the VM dies NOW, the killer is' in src,
    'decision table on screen': 'LADDER DECISION TABLE' in src,
    'Phase E verdict line': 'KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE' in src,
    'live pid captured': '$myPid = [uint32]$PID' in src,
    'per-variant result log': 'ladder detail (each line = one variant' in src,
    'J9 negative test wiring': "if ($v.n -eq 'J9')" in src,
    'stale v18 output name gone': 'trigger-test-v18-output' not in src,
    'stale v18 banner gone': '==== INFINITY trigger test v18' not in src,
    'stale v18 AB note gone': "v18: reads are answered LIVE" not in src,
    'stale END v18 gone': '==== END v18 ====' not in src,
    'stale $mTxt gone': '$mTxt' not in src,
    'stale $kTxt gone': '$kTxt' not in src,
    'no CRLF': '\r' not in src,
}
bad = [k for k, v in checks.items() if not v]
print('SPOT CHECKS:', f'ALL {len(checks)} OK' if not bad else 'FAILED: ' + ', '.join(bad))

# ---- 4. sanity: every Send-Req in the ladder polls + dumps (inherited) ----
send_count = src.count('Send-Req (New-Req')
print(f'ladder Send-Req call sites: {send_count} (expect 1 generic site inside the foreach loop)')
if send_count != 1:
    problems.append(f'  unexpected Send-Req call-site count: {send_count}')

sys.exit(1 if (problems or errs or bad) else 0)
