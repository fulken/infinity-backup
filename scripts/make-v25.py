#!/usr/bin/env python3
"""make-v25.py - build trigger-test-v25.ps1 from the v24 script.

v25 = v24 + THE SELFTEST FIXTURE FIX (script-only, driver v19 UNCHANGED).

The v24 field run (2026-09-26 04:07) aborted AT the selftest gate: its
canonical-kernel-base fixture was hand-assembled wrong - bytes
00 00 10 80 FF FF FF FF encode 0xFFFFFFFF80100000, not the intended
0xFFFF800010000000 (decimal 18446603336489631744). The gate refused to
touch the driver (correct fail-closed behavior; zero [RD], no crash).

The class fix: DERIVE the fixture bytes from the decimal literal inside
the script itself, so bytes and expectation can never disagree again.

Edits applied to a copy of v24:
  1. insert the v25 header block above the v24 header block
  2. transcript filename  trigger-test-v24-output-  -> v25
  3. banner line          '==== INFINITY trigger test v24 ...' -> v25
  4. END marker           '==== END v24 ====' -> v25
  5. selftest fixture     hand-assembled bytes -> derived from literal
"""
import re, sys, hashlib

SRC = '/home/z/my-project/infinity-qemu-test/trigger-test-v24.ps1'
DST = '/home/z/my-project/infinity-qemu-test/trigger-test-v25.ps1'

src = open(SRC, 'rb').read().decode('utf-8')  # keep the PE\0\0 NULs as-is

def must_count(pat, n, flags=0):
    got = len(re.findall(pat, src, flags))
    assert got == n, f'pattern {pat!r}: expected {n} hits, got {got}'

# ---- pre-edit sanity: the v24 shapes we rely on are present ----
must_count(r'trigger-test-v24-output-\$stamp', 1)
must_count(r"==== INFINITY trigger test v24 \(v19 driver: anchors", 1)
must_count(r"==== END v24 ====", 1)
must_count(re.escape('$stU64[0] = 0x00; $stU64[1] = 0x00; $stU64[2] = 0x10; $stU64[3] = 0x80'), 1)
must_count(re.escape("$stU64[4] = 0xFF; $stU64[5] = 0xFF; $stU64[6] = 0xFF; $stU64[7] = 0xFF"), 1)
must_count(re.escape("ST-Check ((U64 $stU64 0) -eq [uint64]18446603336489631744) 'U64 must parse a canonical kernel base"), 1)

# ---- 1. v25 header block, inserted above the v24 header block ----
V25HDR = '''# ============================================================
# INFINITY bridge trigger test v25  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v25 = v24 + THE SELFTEST FIXTURE FIX. Script-only; the driver
# is UNCHANGED (memory.efi v19 RT, 125450 bytes). The v24 field
# run (2026-09-26 04:07) aborted AT the selftest gate - by design:
# its canonical-kernel-base fixture was hand-assembled wrong
# (bytes 00 00 10 80 FF FF FF FF encode 0xFFFFFFFF80100000, not
# the intended 0xFFFF800010000000 = decimal 18446603336489631744),
# so the U64 round-trip check failed and the script REFUSED to
# touch the driver: serial showed ZERO [RD] lines, INFCNT unmoved,
# no crash - the cleanest possible failure, exactly what the gate
# is for. v25 DERIVES the fixture bytes from the decimal literal
# itself, so bytes and expectation can never disagree again - the
# slip class is eliminated, not patched. Everything else (K anchor
# discovery + L validated reads + J regression) is byte-identical
# to v24. The F1 ladder still awaits its field run.
# ============================================================
# INFINITY bridge trigger test v24  (run INSIDE the Windows VM,'''

anchor = '# INFINITY bridge trigger test v24  (run INSIDE the Windows VM,'
assert src.count(anchor) == 1
src = src.replace(anchor, V25HDR, 1)

# ---- 2/3/4. the three runtime version strings ----
src = src.replace('trigger-test-v24-output-$stamp', 'trigger-test-v25-output-$stamp')
src = src.replace(
    "Write-Host '==== INFINITY trigger test v24 (v19 driver: anchors - the F1 proof ladder K,L + J regression) ===='",
    "Write-Host '==== INFINITY trigger test v25 (v19 driver: anchors - the F1 proof ladder K,L + J regression; v24 selftest fixture fixed) ===='")
src = src.replace("Write-Host '==== END v24 ===='", "Write-Host '==== END v25 ===='")

# ---- 5. the selftest fixture: derive, don't hand-assemble ----
OLD = '''$stU64 = New-Object byte[] 8
$stU64[0] = 0x00; $stU64[1] = 0x00; $stU64[2] = 0x10; $stU64[3] = 0x80
$stU64[4] = 0xFF; $stU64[5] = 0xFF; $stU64[6] = 0xFF; $stU64[7] = 0xFF
ST-Check ((U64 $stU64 0) -eq [uint64]18446603336489631744) 'U64 must parse a canonical kernel base 0xFFFF800010000000 (DECIMAL literal - the v21 hex-cast trap class)\''''
NEW = '''$stU64 = New-Object byte[] 8
# v25 FIX (the v24 field abort, 2026-09-26 04:07): these bytes were
# hand-assembled WRONG (00 00 10 80 FF FF FF FF encodes
# 0xFFFFFFFF80100000, not 0xFFFF800010000000) so the gate refused
# to start - CORRECTLY; nothing was touched. The class fix is not
# "better hand-assembly": the fixture is now DERIVED from the
# decimal literal itself, so bytes and expectation can never
# disagree again.
$stBase = [uint64]18446603336489631744   # = 0xFFFF800010000000
for ($i = 0; $i -lt 8; $i++) { $stU64[$i] = [byte](($stBase -shr (8 * $i)) -band 0xFF) }
ST-Check ((U64 $stU64 0) -eq $stBase) 'U64 must round-trip the canonical kernel base 0xFFFF800010000000 (fixture DERIVED from the decimal literal - no hand-assembled bytes)\''''
assert src.count(OLD) == 1, 'fixture block not found verbatim'
src = src.replace(OLD, NEW, 1)

# ---- post-edit verification ----
assert 'trigger-test-v25-output-' in src
assert "trigger test v25 (v19 driver" in src
assert '==== END v25 ====' in src
assert '$stBase -shr (8 * $i)' in src
# the bad hand-assembled pattern must be GONE from code (comments may mention it)
assert '$stU64[2] = 0x10' not in src

data = src.encode('utf-8')
open(DST, 'wb').write(data)
h = hashlib.sha256(data).hexdigest()
print(f'written: {DST}')
print(f'bytes  : {len(data)}')
print(f'sha256 : {h}')
print('ALL SHAPE CHECKS PASS')
