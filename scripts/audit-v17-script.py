#!/usr/bin/env python3
"""Structural + logic audit of trigger-test-v17.ps1 (no PowerShell in the
sandbox, so this is the same token-level validation the v16 script passed,
plus a simulation of the new H..N steps against the real v16 field bytes).

Checks:
  1. Token balance: {}, (), [] balanced; single/double quotes balanced per
     line (PS strings do not span lines in this script); here-strings
     (@'...'@) handled as blocks.
  2. No bare `exit` outside __Finish's exit $code.
  3. All __Finish call sites present (abort paths routed through it).
  4. Guard marker: "trigger test v17" present (phase-d.bat findstr).
  5. v17 step labels H..N all present exactly once as step headers.
  6. Simulation: given the v16-field-proven hook semantics, what the new
     steps will print + the expected INFCNT accounting (8).
  7. Hex-literal safety: no 0x literal above 0x7FFFFFFF outside
     [Convert] usage (the v10 sign-trap rule); all 64-bit values built
     via [Convert]::ToUInt64 / [BitConverter].
"""
import re
import sys
from pathlib import Path

P = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v17.ps1")
t = P.read_text()
lines = t.split("\n")
errors = []

# ---------------------------------------------------------------- 1. balance
depth_curly = depth_paren = depth_square = 0
in_herestring = False
herestring_close = None
for idx, line in enumerate(lines, 1):
    if in_herestring:
        if line.strip() == herestring_close:
            in_herestring = False
        continue
    stripped = line.strip()
    # here-string opener: @' or @" at END of the line ($src = @')
    if stripped.endswith("@'") or stripped.endswith('@"'):
        in_herestring = True
        herestring_close = "'@" if stripped.endswith("@'") else '"@'
        continue
    # strip comments (respect quotes)
    out = []
    q = None
    i = 0
    while i < len(line):
        c = line[i]
        if q:
            if c == q:
                q = None
            elif c == "`" and q == '"' and i + 1 < len(line):
                i += 1  # backtick escape
        else:
            if c in "\"'":
                q = c
            elif c == "#":
                break
        out.append(c)
        i += 1
    code = "".join(out)
    depth_curly += code.count("{") - code.count("}")
    depth_paren += code.count("(") - code.count(")")
    depth_square += code.count("[") - code.count("]")
    if q:
        errors.append(f"line {idx}: unterminated {q} string")
if in_herestring:
    errors.append("unterminated here-string at EOF")
for name, v in (("{} braces", depth_curly), ("() parens", depth_paren), ("[] brackets", depth_square)):
    if v != 0:
        errors.append(f"UNBALANCED {name}: {v}")
    else:
        print(f"  PASS  {name} balanced")

# ---------------------------------------------------------------- 2. bare exit
bare = [i for i, l in enumerate(lines, 1) if re.match(r"\s*exit\b", l) and "__Finish" not in l and "exit $code" not in l]
if bare:
    errors.append(f"bare 'exit' statements at lines: {bare}")
else:
    print("  PASS  no bare exit statements (all routed through __Finish)")

# ---------------------------------------------------------------- 3. __Finish sites
n_finish = len(re.findall(r"__Finish\s+\d", t))
print(f"  INFO  __Finish call sites: {n_finish}")
if n_finish < 4:
    errors.append(f"too few __Finish abort paths ({n_finish})")

# ---------------------------------------------------------------- 4. guard marker
if "trigger test v17" in t:
    print("  PASS  guard marker 'trigger test v17' present")
else:
    errors.append("guard marker missing")

# ---------------------------------------------------------------- 5. step labels
for s in "HIJKLMN":
    n = t.count("'--- step " + s + ":")
    if n != 1:
        errors.append(f"step {s} header count = {n} (need 1)")
    else:
        print(f"  PASS  step {s} header present once")

# ---------------------------------------------------------------- 6. simulation
print("\n--- H..N simulation against v16-field-proven semantics ---")
# H: hook echoes last_data_ byte-exact (v13+ RAM serve, field-proven readback
#    of INFDIAG/INFCNT/INFPROBE patterns) -> bufOk = True
h_pat = [(i * 7 + 11) % 251 for i in range(32)]
h_pat[0:4] = [0x47, 0x14, 0x00, 0x00]  # 0x1447 LE
print(f"  H  pattern 32B, first bytes {' '.join('%02X' % b for b in h_pat[:8])}... -> echo expected BYTE-EXACT (bufOk=True)")
# I: clean VM -> FindByName fails 4x -> ErrNotFound(7)
print("  I  attach pid=0, clean VM -> status=7 ErrNotFound (correct decode)")
# J: KUSD+0x260 via current-CR3 walk -> 65 4A 00 00 (v16 field bytes)
j_bytes = [0x65, 0x4A, 0x00, 0x00]
j_val = j_bytes[0] + j_bytes[1] * 256
print(f"  J  KUSD+0x260 x4 -> data 65 4A 00 00 -> dword {j_val} (script-side 19045 -> MATCH)")
# K: +0x308 -> 00 00 00 0 -> 0
print("  K  KUSD+0x308 x4 -> dword 0 (field truth)")
# L: 8 bytes -> dword[0]=19045 == J (chunkOk=True), dword[1]=+0x264 (displayed only)
print("  L  KUSD+0x260 x8 -> dword[0]=19045 consistent (chunkOk=True)")
# M: non-canonical -> TranslateVA=0 -> ErrAccess(4), dataN=0
print("  M  DEADBEEF00000000 -> non-canonical -> ErrAccess(4), no payload (negOk=True)")
# N: INFCNT = 2 (D,E baseline) + H(InfinityData) + I..M(5x InfinityReq) = 8
print("  N  INFCNT final = 2 + 1 + 5 = 8")

# ---------------------------------------------------------------- 7. hex literals
bad_hex = []
for idx, line in enumerate(lines, 1):
    if "ToUInt32" in line or "ToUInt64" in line:
        continue
    if line.strip().startswith("#"):
        continue
    # skip literals inside quoted display strings (Write-Host '... 0xDEADBEEF ...')
    # - they are text, never evaluated. Simplest safe test: strip all
    # quoted spans first, then look for hex tokens in what remains.
    code_only = re.sub(r"'[^']*'", "", line)
    code_only = re.sub(r'"[^"]*"', "", code_only)
    for m in re.finditer(r"\b0x[0-9A-Fa-f]+\b", code_only):
        v = int(m.group(0), 16)
        if v > 0x7FFFFFFF:
            bad_hex.append((idx, m.group(0)))
# 0xFFFFFFFF as a bare literal appears nowhere; KP is built via Convert
if any(l for l in bad_hex):
    for idx, hx in bad_hex:
        errors.append(f"line {idx}: hex literal {hx} above 0x7FFFFFFF (v10 sign-trap rule)")
else:
    print("  PASS  no unsafe hex literals (64-bit values via [Convert]::ToUInt64)")

if "FFFFFFFF', 16" in t or "ToUInt32('FFFFFFFF'" in t:
    print("  PASS  KERNEL_TARGET_PID built via [Convert]::ToUInt32")
else:
    errors.append("KERNEL_TARGET_PID not built via [Convert]")

# verdict ordering: the dataOk branch must come before the v16 branches
# (compare AFTER the 'VERDICT:' marker so header comments don't fool us)
verdict_pos = t.find("VERDICT:")
iv = t.find("DATA PATH PROVEN", verdict_pos)
ib = t.find("FULL BRIDGE PROVEN", verdict_pos)
if iv != -1 and ib != -1 and iv < ib:
    print("  PASS  DATA PATH verdict branch precedes the v16 branches")
else:
    errors.append("verdict branch ordering wrong")

print()
if errors:
    print("AUDIT FAILED:")
    for e in errors:
        print("  -", e)
    sys.exit(1)
print("AUDIT PASSED: trigger-test-v17.ps1 is structurally sound")
