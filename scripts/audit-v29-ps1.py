#!/usr/bin/env python3
"""Audit trigger-test-v29.ps1 (v27 audit core + v29-specific checks):
1. automatic/read-only PowerShell variable usage ($pid/$args/$input; $PID
   allowed ONLY as the read '[uint32]$PID')
2. brace/paren/bracket balance + quote pairing outside comments/strings
3. hex-literal cast trap scan - [uint32]0x... >= 0x80000000 and
   [uint64]0x... >= 0x8000000000000000 parse NEGATIVE and the cast
   throws (the v21 line-444 class - v29's M2r canonical compare MUST
   use the decimal literal 4026540901, never [uint32]0xF0004A65)
4. v23..v28 spot checks: ladder J1..J7 integrity, K/L sequence space,
   M wire integrity, verdicts, canaries, v22-slip eradication, stale
   markers (incl. the v24..v28 runtime markers), ASCII/LF
5. FIXTURE EMULATOR (the v24 field-abort class) - unchanged from v27
6. NEW (v29) - THE M2R EXPECTATION FIX (the v28 field incident,
   2026-09-26 21:11): the v28 run read the CANONICAL NtBuildNumber
   dword 0xF0004A65 (build in the LOW WORD 0x4A65 = 19045 = the KUSD
   J1 ground truth; QFE flags above) and printed FAIL because it
   masked 0x7FFFFFFF and compared against bare 19045. The audit now
   EMULATES the v29 M2r predicate in Python against THREE inputs:
   the field value 0xF0004A65 (must PASS), a bare 19045 (must PASS),
   and a wrong dword (must FAIL).
7. NEW (v29) - THE INFCNT FULL-ARITHMETIC EMULATOR: the v28 print
   said "expect G+8+ = 23" ({4} pointed at an EMPTY argument and
   the 4 M-side symbol-NAME writes were missing). v29 counts
   G+8+anSent+mNameWrites with the name-write counter incremented
   inside Send-Resolve. The audit emulates the expectation line and
   the -f format slots against BOTH scenarios: fully-converged
   (G2+H1+J7+KL7+name4+req6 = 27 - the field-proven count) and
   fail-closed (2+8+3+0 = 13).
"""
import re, sys

PATH = '/home/z/my-project/patches/trigger-test-v29.ps1'
raw = open(PATH, 'rb').read()
src = raw.decode('utf-8')
lines = src.split('\n')
print(f'file: {PATH}')
print(f'lines: {len(lines)}, bytes: {len(raw)}, non-ascii: {sum(1 for c in src if ord(c) > 127)}, NULs: {src.count(chr(0))}')
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
    print('HEX-LITERAL CAST SCAN: CLEAN (the M2r canonical compare is decimal 4026540901)')

# ---- 4. spot checks ----
print('SPOT CHECKS:')
def one(needle, label):
    c = src.count(needle)
    print(('  PASS  ' if c == 1 else f'  FAIL({c}) ') + label)
    if c != 1: fails.append(label)

one("==== INFINITY trigger test v29", "v29 banner")
one("trigger-test-v29-output-", "v29 transcript name")
one("==== END v29 ====", "v29 end marker")
one("v21 driver: F1+F2 PROVEN IN THE FIELD; M export resolution - the M2r build-mask fix + full INFCNT arithmetic", "v29 banner names the v21 driver + both fixes")
one("(v20/v21 containing-walk)", "K step names v20/v21")
one("[uint32]4294967295", "decimal max literal")
one("function Canary", "canary helper")
one("Canary 'pre-M1'", "canary pre-M1")
one("Canary 'pre-M2'", "canary pre-M2")
one("Canary 'pre-M2r'", "canary pre-M2r")
one("Canary 'pre-M3r'", "canary pre-M3r")
one("Canary 'pre-M4'", "canary pre-M4")
one("Microsoft-Windows-WER-SystemErrorReporting", "BugCheck 1001 query")
one("Microsoft-Windows-Kernel-Power", "Kernel-Power 41 query")
one("Canary 'pre-A", "canary pre-A")
one("Canary 'pre-E", "canary pre-E")
one("Canary (\"pre-\" + $v.n)", "canary per-Jn")
one("Canary 'post-ladder", "canary post-ladder")
one("Canary 'pre-K'", "canary pre-K (the F1 discovery)")
one("Canary 'pre-L4'", "canary pre-L4 (the first range negative)")

# driver-size documentation counts (headers are history; only the
# decision table is operative)
for pat, want, label in [
    ('125450', 2, 'v19-RT size x2 (historical v24/v25 headers only)'),
    ('121253', 2, 'v18-RT size x2 (historical v22/v23 headers only)'),
    ('128010', 4, 'v20-RT size x4 (historical v26/v27/v28 headers + one header note)'),
    ('131709', 4, 'v21-RT size x4 (v28+v29 headers + decision table x2 - OPERATIVE)'),
    ('v21-RT = 131709 bytes', 1, 'decision table names the v21 driver size (fixed from 128010)'),
    ('(size 131709)', 1, 'J1 rerun hint names 131709 (fixed from 128010)'),
]:
    c = src.count(pat)
    print(('  PASS  ' if c == want else f'  FAIL({c}, want {want}) ') + label)
    if c != want: fails.append(label)

for s in ['0x1601', '0x1602', '0x1603', '0x1604', '0x1605', '0x1606', '0x1607']:
    one(s, f"J-ladder seq {s} (v23 regression, untouched)")
print('F1 SEQUENCE SPACE (K + L1..L5):')
for s, label in [('0x1701', 'K anchors'), ('0x1702', 'L1 MZ'), ('0x1703', 'L2a e_lfanew'),
                 ('0x1704', 'L2b PE header'), ('0x1705', 'L3 entry bytes'),
                 ('0x1706', 'L4 below-range negative'), ('0x1707', 'L5 above-range negative')]:
    one(s, label)
one("New-Req 0x1701 9 '00000000' 32 '0000000000000000' $null", "K request build (op=9, len=32, addr=0)")

print('F2 M WIRE (op=10 ResolveSymbol - byte-identical to the v28 field run):')
for s, label in [('0x1801', 'M1 PsInitialSystemProcess'), ('0x1802', 'M2 NtBuildNumber'),
                 ('0x1803', 'M2r read@resolved'), ('0x1804', 'M3 KeBugCheckEx'),
                 ('0x1805', 'M3r read@resolved'), ('0x1806', 'M4 not-found')]:
    one(s, label)
one("New-Req $rseq 10 'FFFFFFFF' $nb.Length '0000000000000000' $null", "Send-Resolve op-10 request build")
one("Send-Resolve 0x1801 'PsInitialSystemProcess'", "M1 wire")
one("Send-Resolve 0x1802 'NtBuildNumber'", "M2 wire")
one("Send-Resolve 0x1804 'KeBugCheckEx'", "M3 wire")
one("Send-Resolve 0x1806 'NoSuchSymbolV28'", "M4 wire")
one("Send-Req (New-Req 0x1803 1 'FFFFFFFF' 4 ('{0:X16}' -f $nbVa) $null)", "M2r read wire (len=4)")
one("Send-Req (New-Req 0x1805 1 'FFFFFFFF' 8 ('{0:X16}' -f $kbVa) $null)", "M3r read wire (len=8)")

print('VERDICTS + COUNTERS:')
one("$anSent = 1", "anSent counter starts at K")
c = src.count("$anSent++")
print(('  PASS  ' if c == 12 else f'  FAIL({c}, want 12) ') + 'anSent increments x12 (L1/L2a/L2b/L3/L4/L5 + M1..M4 + M2r/M3r)')
if c != 12: fails.append('anSent count')
one("$mNameWrites = 0", "mNameWrites counter initialized beside the M flags")
one("$script:mNameWrites = $script:mNameWrites + 1", "mNameWrites incremented inside Send-Resolve (script scope)")
one("$f1Ok = $anOk -and $mzOk -and $peOk -and $sizeMatch -and $epOk -and ($lNegTxt -like 'OK*')", "F1 verdict condition")
one("F1 PROVEN: ANCHORS CONVERGED", "F1 PROVEN verdict line")
one("F1 FAIL-CLOSED (the gate never opened)", "F1 FAIL-CLOSED verdict line")
one("$f2Ok = $anOk -and $m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok", "F2 verdict condition")
one("F2 PROVEN: EXPORT-RESOLVED SYMBOLS", "F2 PROVEN verdict line")
one("F2 PARTIAL: anchors converged but an M-step failed", "F2 PARTIAL verdict line")

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

print('V27 READ-BUFFER CLASS-KILL STILL ENFORCED:')
c = src.count('$db = New-Object byte[] 4096')
print(('  PASS  ' if c == 1 else f'  FAIL({c}, want 1) ') + 'Send-Req InfinityData read-back buffer = 4096 (the driver cap)')
if c != 1: fails.append('data buffer 4096')
c = src.count('$db = New-Object byte[] 64')
print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + 'no undersized data-path buffer remains')
if c != 0: fails.append('data buffer 64')
c = len(re.findall(r'New-Object byte\[\] 64', src))
print(('  PASS  ' if c == 4 else f'  FAIL({c}, want 4) ') + 'the four NON-data 64-byte buffers stay 64')
if c != 4: fails.append('other 64 buffers')

print('STALE MARKERS GONE (runtime texts; historical header blocks stay):')
for stale in ['==== INFINITY trigger test v28', '==== END v28 ====', 'trigger-test-v28-output-',
              '==== INFINITY trigger test v27', '==== END v27 ====', 'trigger-test-v27-output-',
              '==== INFINITY trigger test v26', '==== END v26 ====', 'trigger-test-v26-output-',
              '==== INFINITY trigger test v25', '==== END v25 ====', 'trigger-test-v25-output-',
              '==== INFINITY trigger test v24', '==== END v24 ====', 'trigger-test-v24-output-',
              '==== INFINITY trigger test v23', '==== END v23 ====', 'trigger-test-v23-output-',
              'band 0x7FFFFFFF', '$stU64[2] = 0x10', '[uint32]0xFFFFFFFF',
              '-eq [uint32]0xF0004A65', 'died HERE']:
    c = src.count(stale)
    print(('  PASS  ' if c == 0 else f'  FAIL({c}) ') + f'stale-gone: {stale[:45]}')
    if c != 0: fails.append(f'stale {stale[:30]}')
if any(ord(c) > 127 for c in src):
    fails.append('ascii'); print('  FAIL  non-ascii characters present')
else:
    print('  PASS  pure ASCII (the two PE\\0\\0 NULs are documented bytes, not text)')
if '\r' in src:
    fails.append('crlf'); print('  FAIL  CR present (CRLF)')
else:
    print('  PASS  LF only')
if src.count(chr(0)) != 2:
    fails.append('nuls'); print(f'  FAIL  NUL count {src.count(chr(0))} != 2 (the PE\\0\\0 string bytes)')
else:
    print('  PASS  NUL count == 2 (the sig PE\\0\\0 display string, unchanged)')

# ============================================================
# ---- 6. THE V29 M2R EMULATOR (three inputs, one predicate) ----
# ============================================================
print('V29 M2R EMULATOR (the v28 field incident - build-mask + canonical):')
m_build = re.search(r'\$nbBuild = \[uint32\]\(\$nbVal -band (0x[0-9A-Fa-f]+)\)', src)
m_canon = re.search(r'\$nbCanon = \(\$nbVal -eq (\d+)\)', src)
m_ok = re.search(r'\$m2ReadOk = \(\$nbBuild -eq (\d+)\) -or \$nbCanon', src)
if not (m_build and m_canon and m_ok):
    print('  FAIL  M2r predicate not found in the expected shape'); fails.append('m2r shape')
else:
    mask = int(m_build.group(1), 16); canon = int(m_canon.group(1)); build_exp = int(m_ok.group(1))
    assert canon == 0xF0004A65, 'canonical literal is not 4026540901'
    print(f'  mask={hex(mask)}  canonical={hex(canon)}  build-expected={build_exp}')
    cases = [
        (0xF0004A65, True,  'the v28 FIELD value (QFE flags + build 19045)'),
        (0x00004A65, True,  'a bare build dword (19045 with zero flags)'),
        (0x00000000, True,  'degenerate all-zero dword still masks to 0 - must FAIL', True),
        (0x12345678, False, 'a wrong dword (build 0x5678, no canonical match)'),
    ]
    for rawv, want_pass, label, *star in cases:
        if star:  # the degenerate case override
            want_pass = False
        build = rawv & mask
        got = (build == build_exp) or (rawv == canon)
        ok = (got == want_pass)
        print(('  PASS  ' if ok else '  FAIL  ') +
              f'raw=0x{rawv:08X} build={build} canonical={rawv == canon} -> {"PASS" if got else "FAIL"} '
              f'({label})')
        if not ok: fails.append(f'm2r emu 0x{rawv:08X}')

# ============================================================
# ---- 7. THE V29 INFCNT FULL-ARITHMETIC EMULATOR -----------------
# ============================================================
print('V29 INFCNT ARITHMETIC EMULATOR (the expect line + format slots):')
m_exp = re.search(r'\$expFinal = if \(\$cntVal -ge 0\) \{ \$cntVal \+ 8 \+ \$anSent \+ \$mNameWrites \} else \{ \'\?\' \}', src)
if not m_exp:
    print('  FAIL  the expFinal line not found verbatim'); fails.append('expFinal shape')
else:
    print('  PASS  expect = G(cntVal) + 8 + anSent + mNameWrites (every term counted)')
m_fmt = re.search(r'Write-Host \("    INFCNT final = \{0\}   \(expect G\+8\+\{4\}\+\{5\} = \{1\}: H\'s InfinityData write \(\+1\)," -f \$cntFinal, \$expFinal, \'\', \'\', \$anSent, \$mNameWrites\)', src)
if not m_fmt:
    print('  FAIL  the INFCNT format line not found verbatim'); fails.append('infcnt fmt shape')
else:
    # emulate the -f call: slots {4}=anSent, {5}=mNameWrites, {1}=expFinal
    for label, cntVal, anSent, mNameWrites, want in [
        ('fully converged (the v28 field: G2 + KL7 + M-req6 + name4)', 2, 13, 4, 27),
        ('fail-closed (K only + L4/L5, M skipped)', 2, 3, 0, 13),
        ('converged but M2r+M3r both cascade-skipped', 2, 11, 4, 25),
    ]:
        expFinal = cntVal + 8 + anSent + mNameWrites
        rendered = f'expect G+8+{anSent}+{mNameWrites} = {expFinal}'
        ok = (expFinal == want)
        print(('  PASS  ' if ok else '  FAIL  ') + f'{label}: {rendered}')
        if not ok: fails.append(f'infcnt emu {label[:20]}')
    # the {4} slot must NOT point at an empty argument (the v28 bug)
    args = re.search(r"-f \$cntFinal, \$expFinal, '', '', \$anSent, \$mNameWrites\)", src)
    if args:
        print('  PASS  slots {4}->{anSent}, {5}->{mNameWrites} - no empty-argument slot remains (v28 bug dead)')
    else:
        print('  FAIL  the -f argument list changed shape'); fails.append('fmt args shape')

# ============================================================
# ---- 5. FIXTURE EMULATOR (the v24 field-abort class) ------------
# ============================================================
print('FIXTURE EMULATOR (byte fixtures <-> literals <-> labels):')
scalars = {}
arrays = {}
derive_src = {}

ASGN  = re.compile(r'\$(\w+)\[(\d+)\]\s*=\s*(0x[0-9A-Fa-f]+|\d+)\b')
SCAL  = re.compile(r'\$(\w+)\s*=\s*\[uint(?:32|64)\]\s*(\d{1,20})\b')
DERIV = re.compile(r'\$(\w+)\[\$i\]\s*=\s*\[byte\]\(\(\$(\w+)\s*-shr\s*\(8\s*\*\s*\$i\)\)\s*-band\s*0xFF\)')
STRE  = re.compile(r'ST-Check\s*\(\((U32|U64)\s+\$(\w+)\s+(\d+)\)\s*-eq\s*'
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
    for m in SCAL.finditer(cl):
        scalars[m.group(1)] = int(m.group(2))
    for m in DERIV.finditer(cl):
        derive_src[m.group(1)] = m.group(2)
        src_v = scalars.get(m.group(2))
        if src_v is None:
            print(f'  FAIL  line {n}: derivation source ${m.group(2)} not yet defined'); fails.append('fixture')
        else:
            arrays[m.group(1)] = {i: (src_v >> (8 * i)) & 0xFF for i in range(8)}
    for m in ASGN.finditer(cl):
        arrays.setdefault(m.group(1), {})[int(m.group(2))] = int(m.group(3), 0)
    m = STRE.search(cl)
    if not m:
        continue
    fn, arr, lit = m.group(1), m.group(2), m.group(4)
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

for n, line in enumerate(lines, 1):
    lm = re.search(r"ST-Check .*'([^']*)'\s*$", line.strip())
    cm = STRE.search(line)
    if not lm or not cm:
        continue
    lit = cm.group(4)
    exp = scalars[lit[1:]] if lit.startswith('$') else int(lit, 0)
    label = lm.group(1)
    toks = [int(t, 16) for t in re.findall(r'0x[0-9A-Fa-f]{4,16}', label)]
    if toks and exp not in toks:
        print(f'  FAIL  line {n}: label hex {[hex(t) for t in toks]} does not contain expected 0x{exp:X}'
              f'  <-- LABEL/LITERAL MISMATCH'); fails.append(f'label line {n}')
    elif toks:
        print(f'  PASS  line {n}: label 0x{exp:X} consistent with compared literal')

if scalars.get('stBase') != 0xFFFF800010000000:
    print(f'  FAIL  $stBase = {scalars.get("stBase")} is not 0xFFFF800010000000'); fails.append('stBase value')
else:
    print('  PASS  $stBase = 18446603336489631744 = 0xFFFF800010000000 (canonical kernel base)')

CALLRE = re.compile(r"\$(\w+)\s*=\s*New-Req\s+(0x[0-9A-Fa-f]+|\d+)\s+(\d+)\s+'([0-9A-Fa-f]{8})'\s+(\d+)\s+'([0-9A-Fa-f]{16})'")
for call in CALLRE.finditer(src):
    var = call.group(1)
    if not var.startswith('st'):
        continue
    seq, op, pid, ln, addr = (int(call.group(2), 0), int(call.group(3)), int(call.group(4), 16),
                              int(call.group(5)), int(call.group(6), 16))
    hdr = seq.to_bytes(4, 'little') + op.to_bytes(4, 'little') + pid.to_bytes(4, 'little') \
        + ln.to_bytes(4, 'little') + addr.to_bytes(8, 'little')
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
