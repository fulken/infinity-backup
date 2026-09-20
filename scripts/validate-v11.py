#!/usr/bin/env python3
"""Validate trigger-test-v11.ps1: ASCII, cast traps, brace balance,
byte-builder simulation, CRLF conversion."""
import re, sys

P = '/home/z/my-project/infinity-qemu-test/trigger-test-v11.ps1'
raw = open(P, 'rb').read()

# 1) ASCII-only
non_ascii = [(i, b) for i, b in enumerate(raw) if b > 127]
print(f"[1] non-ASCII bytes: {len(non_ascii)}", "OK" if not non_ascii else f"FAIL {non_ascii[:5]}")

text = raw.decode('ascii')

# 2) dangerous casts: [uint32] / [int] / [int64] on hex literals with top bit
danger = []
for m in re.finditer(r'\[(u?int(?:32|64)?)\]\s*(0x[0-9A-Fa-f]+)', text):
    typ, lit = m.group(1), m.group(2)
    val = int(lit, 16)
    if typ == 'uint32' and val >= 0x80000000: danger.append(m.group(0))
    if typ in ('int', 'int32') and val > 0x7FFFFFFF: danger.append(m.group(0))
    if typ == 'int64' and val >= 0x8000000000000000: danger.append(m.group(0))
print(f"[2] dangerous numeric casts: {danger if danger else 'none OK'}")
# list ALL casts for eyeball
print("    all casts:", re.findall(r'\[\w+\]\s*0x[0-9A-Fa-f]+', text))

# 3) brace/paren balance (ignoring strings/comments roughly)
depth_b = depth_p = 0
in_squote = in_dquote = False
i = 0
while i < len(text):
    c = text[i]
    if in_squote:
        if c == "'": in_squote = False
    elif in_dquote:
        if c == '`': i += 1  # escape
        elif c == '"': in_dquote = False
    else:
        if c == "'": in_squote = True
        elif c == '"': in_dquote = True
        elif c == '<' and text[i:i+2] == '<#':  # block comment
            j = text.find('#>', i); i = j + 1
        elif c == '#':
            j = text.find('\n', i); i = j if j != -1 else len(text)
        elif c == '{': depth_b += 1
        elif c == '}': depth_b -= 1
        elif c == '(': depth_p += 1
        elif c == ')': depth_p -= 1
    i += 1
print(f"[3] brace balance: {depth_b}, paren balance: {depth_p}",
      "OK" if depth_b == 0 and depth_p == 0 else "CHECK (nonzero may be OK inside here-strings)")

# 4) simulate HexLe4('DEADBEEF')
def hex_le4(h):
    h = h.zfill(8)
    return [int(h[6-2*i:6-2*i+2], 16) for i in range(4)]
got = hex_le4('DEADBEEF')
want = [0xEF, 0xBE, 0xAD, 0xDE]
print(f"[4] HexLe4('DEADBEEF') = {' '.join(f'{b:02X}' for b in got)}",
      "OK" if got == want else f"FAIL want {' '.join(f'{b:02X}' for b in want)}")
import struct
seq = list(struct.pack('<I', 0x1337))
print(f"    seq bytes = {' '.join(f'{b:02X}' for b in seq)}", "OK" if seq == [0x37,0x13,0,0] else "FAIL")

# 5) verify expected-bytes check in script matches simulation
assert '0x37' in text and '0xEF' in text and '0xBE' in text and '0xAD' in text and '0xDE' in text
print("[5] packet self-check constants present OK")

# 6) CRLF conversion
text = text.replace('\r\n', '\n')  # normalize first
crlf = text.replace('\n', '\r\n')
open(P, 'wb').write(crlf.encode('ascii'))
nl = crlf.count('\r\n'); lone = crlf.count('\n') - nl
print(f"[6] CRLF: {nl} lines converted, lone-LF remaining: {lone}", "OK" if lone == 0 else "FAIL")

# 7) line count + key structure presence
lines = crlf.split('\r\n')
print(f"[7] total lines: {len(lines)}")
for token in ['PrivilegeCount', '"EfiVarBridge" -as [type]', 'INFPROBE', 'INFTRIGGER',
              'HexLe4', 'InfinityResp', 'SUMMARY (photo this block)', 'END v11']:
    print(f"    contains '{token}':", token in crlf)
print("ALL CHECKS DONE")
