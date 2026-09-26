#!/usr/bin/env python3
"""make-v26.py - build trigger-test-v26.ps1 from the v25 script.

v26 = v25 + THE V20 DRIVER STEP (script changes only where the
DRIVER GENERATION moved: v20 = v19 + the containing-walk).

The v25 field run (2026-09-26 07:04) proved everything but the
convergence: anchors perfect (SIDT/IDT/LSTAR), all three walks agreed
- on a nested PE at 0xFFFFF8046BD60000 that does NOT contain them
(the T8 trap, for real) -> V4 containment correctly FAIL-CLOSED
(reason=6). v20 fixes the one rule: a walk candidate is accepted only
if the image CONTAINS the anchor; nested PEs are skipped + counted.

Script-side changes (K/L/J logic byte-identical - it already handles
both outcomes dynamically):
  1. v26 header block above the v25 header block
  2. transcript filename v25 -> v26
  3. banner line: v20 driver + K expected CONVERGED
  4. END marker v25 -> v26
  5. step-K display texts: v20 expectations (converged is now the
     EXPECTED outcome; fail-closed stays a valid documented outcome)
  6. step-L1..L3 'why' lines unchanged (they run on convergence)
"""
import re, hashlib

SRC = '/home/z/my-project/infinity-qemu-test/trigger-test-v25.ps1'
DST = '/home/z/my-project/infinity-qemu-test/trigger-test-v26.ps1'

src = open(SRC, 'rb').read().decode('utf-8')  # keep the PE\0\0 NULs as-is

def must_count(pat, n, flags=0):
    got = len(re.findall(pat, src, flags))
    assert got == n, f'pattern {pat!r}: expected {n} hits, got {got}'

# ---- pre-edit sanity: the v25 shapes we rely on are present ----
must_count(r'trigger-test-v25-output-\$stamp', 1)
must_count(r"==== INFINITY trigger test v25 \(v19 driver: anchors", 1)
must_count(r"==== END v25 ====", 1)
must_count(re.escape("Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery ---'"), 1)
must_count(re.escape("status=1(Success) => CONVERGED: the validated image range unlocks (L1..L3)."), 1)
must_count(re.escape("status=4(ErrAccess) => FAIL-CLOSED: gate stays KUSD-only (L1..L3 skip; L4/L5 still run)."), 1)

# ---- 1. v26 header block, inserted above the v25 header block ----
V26HDR = '''# ============================================================
# INFINITY bridge trigger test v26  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v26 = v25 + THE V20 DRIVER (memory.efi v20 RT, 128010 bytes -
# "anchors + containing walk"). Script logic byte-identical to v25;
# only the K-step expectations moved. WHY: the v25 field run
# (2026-09-26) proved the whole stack EXCEPT convergence: the three
# walks agreed - on a NESTED PE (0xFFFFF8046BD60000) that does not
# contain the anchors, and the V4 containment backstop correctly
# FAIL-CLOSED (reason=6, zero crashes - the architecture worked).
# v20's containing-walk accepts a candidate ONLY if the image
# CONTAINS the anchor; the nested PE is skipped + counted and the
# walks converge on the TRUE ntoskrnl base. With v20 the EXPECTED
# result is: K state=1 reason=0 + the real pe_base/pe_size, then
# L1 MZ / L2 PE header / L3 entry bytes / L4+L5 clean negatives.
# Fail-closed (any reason) remains a valid, documented outcome - the
# new [AN] 'walk vN skipped/lastskip' serial lines name exactly what
# was refused.
# ============================================================
# INFINITY bridge trigger test v25  (run INSIDE the Windows VM,'''

anchor = '# INFINITY bridge trigger test v25  (run INSIDE the Windows VM,'
assert src.count(anchor) == 1
src = src.replace(anchor, V26HDR, 1)

# ---- 2/3/4. the three runtime version strings ----
src = src.replace('trigger-test-v25-output-$stamp', 'trigger-test-v26-output-$stamp')
src = src.replace(
    "Write-Host '==== INFINITY trigger test v25 (v19 driver: anchors - the F1 proof ladder K,L + J regression; v24 selftest fixture fixed) ===='",
    "Write-Host '==== INFINITY trigger test v26 (v20 driver: containing-walk - K expected CONVERGED; L validated reads + J regression) ===='")
src = src.replace("Write-Host '==== END v25 ===='", "Write-Host '==== END v26 ===='")

# ---- 5. step-K display texts: v20 expectations ----
src = src.replace(
    "Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery ---'",
    "Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20 containing-walk) ---'")
src = src.replace(
    "status=1(Success) => CONVERGED: the validated image range unlocks (L1..L3).",
    "status=1(Success) => CONVERGED (EXPECTED with v20): the containing-walk skips")
src = src.replace(
    "status=4(ErrAccess) => FAIL-CLOSED: gate stays KUSD-only (L1..L3 skip; L4/L5 still run).",
    "      nested PEs and the TRUE image range unlocks (L1..L3).\n"
    "      status=4(ErrAccess) => FAIL-CLOSED (valid, documented): gate stays KUSD-only\n"
    "      (L1..L3 skip; L4/L5 still run). Serial [AN] skip lines name the refusal.")

# ---- post-edit verification ----
assert 'trigger-test-v26-output-' in src
assert "trigger test v26 (v20 driver" in src
assert '==== END v26 ====' in src
assert 'containing-walk skips' in src
assert 'v20 containing-walk' in src
# no stale v25 runtime strings (the historical header block may keep v25 words)
assert 'trigger-test-v25-output-$stamp' not in src
assert '==== END v25 ====' not in src
assert "trigger test v25 (v19 driver" not in src
assert '128010' in src  # the v20 driver size named in the v26 header

data = src.encode('utf-8')
open(DST, 'wb').write(data)
h = hashlib.sha256(data).hexdigest()
print(f'written: {DST}')
print(f'bytes  : {len(data)}')
print(f'sha256 : {h}')
print('ALL SHAPE CHECKS PASS')
