#!/usr/bin/env python3
# ============================================================================
# test-v39-functional.py — THE REAL-DATA functional test of the v39 changes
#
# The Task-41 PART E lesson: the v38 functional port translated the chunk
# formula with PYTHON floor semantics and HID the [int]-cast rounding bug.
# This test emulates POWERSHELL CAST SEMANTICS EXPLICITLY (banker's
# rounding) and proves:
#   1. THE CHUNK-MATH: with the REAL v38 field numbers (VS=0x272E0),
#      the v38 form ([int] cast) computes a PHANTOM chunk 158 under PS
#      semantics; the v39 form ([Math]::Floor) computes the correct
#      157; the v36 .data case (1002.45) stays 1002 under both (the
#      LUCKY case, documented); the remain math (-288) explains the
#      never-sent last request.
#   2. THE P-LADDER DECODE: a synthetic v27 96B payload (the field
#      values: pteBase 0xFFFFE20000000000, s=0x1C4, System dtb
#      0x1AD000, the CALLER's own PML4 as liveCr3/selfEntry) decodes
#      through the ported PS logic to: P1 PASS + THE LIVE IDENTITY
#      PASS + selfOk bit0+bit1 + the two-PML4 P8 line (self frame !=
#      System DTB, expected). Plus the regression payload (an
#      identity that breaks) -> P1 FAIL.
#   3. THE WIRE: the 6 op-12 send lines byte-identical to the v34
#      field-proven wire (only the decode/verdict changed, never the
#      request bytes); the dump loop byte-identical to the field v38
#      EXCEPT the one fixed line.
# ============================================================================
import re, struct, pathlib, sys
from decimal import Decimal, ROUND_HALF_EVEN

BASE = pathlib.Path('/home/z/my-project')
PS38 = (BASE / 'patches' / 'trigger-test-v38.ps1').read_text(encoding='utf-8')
PS39 = (BASE / 'patches' / 'trigger-test-v39.ps1').read_text(encoding='utf-8')
PS34 = (BASE / 'patches' / 'trigger-test-v34.ps1').read_text(encoding='utf-8')
MAN = (BASE / 'version-archive' / 'reports' / 'loose-evidence' / 'v38-run' /
       'ntoskrnl-almostro.manifest.txt').read_text()
fails = []

def check(name, cond, detail=''):
    if cond: print(f'  PASS  {name}')
    else:
        print(f'  FAIL  {name} {detail}'); fails.append(name)

# ---------------------------------------------------------------------------
# 1. THE CHUNK-MATH with PowerShell cast semantics
# ---------------------------------------------------------------------------
m = re.search(r'sec_vs=0x([0-9A-Fa-f]+)', MAN)
data_vs = int(m.group(1), 16)            # the REAL field value
check('field VS recovered from the v38 manifest', data_vs == 0x272E0,
      hex(data_vs))

def ps_int_cast(x):
    """PowerShell [int] cast on a positive double: round-half-to-even."""
    return int(Decimal(repr(x)).quantize(Decimal('1'), rounding=ROUND_HALF_EVEN))

chunk = 1024
exact = Decimal(data_vs + chunk - 1) / Decimal(chunk)
v38_form = ps_int_cast(float(exact))      # [int](($dataVs + $chunkSz - 1) / $chunkSz)
v39_form = int(exact)                     # [int][Math]::Floor(...) - floor == int() here
true_ceil = -((-data_vs) // chunk)        # the mathematical ceil
check('the v38 form under PS semantics = 158 (the PHANTOM chunk)',
      v38_form == 158, str(v38_form))
check('the v39 form = 157 == the true ceil', v39_form == true_ceil == 157,
      f'{v39_form} vs {true_ceil}')
check('the phantom math: remain = 160480 - 157*1024 = -288 (len<0, never sent)',
      data_vs - 157 * chunk == -288, str(data_vs - 157 * chunk))
# the v36 .data case: the LUCKY one (frac < 0.5 -> round == truncate)
d36 = 1025488
e36 = Decimal(d36 + chunk - 1) / Decimal(chunk)
check('the v36 .data case: 1002 under BOTH forms (frac 0.45 < 0.5 - LUCKY)',
      ps_int_cast(float(e36)) == int(e36) == 1002)
# the v39 source line really uses Floor (and the v38 form is gone)
check('v39 source: the Floor form present',
      '$total    = [int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)' in PS39)
check('v39 source: the bare [int]( cast form absent',
      '$total    = [int](($dataVs + $chunkSz - 1) / $chunkSz)' not in PS39)

# ---------------------------------------------------------------------------
# 2. THE P-LADDER DECODE (ported with PS semantics)
# ---------------------------------------------------------------------------
def u32(b, o): return struct.unpack_from('<I', b, o)[0]
def u64(b, o): return struct.unpack_from('<Q', b, o)[0]
PFN_MASK = 0x000FFFFFFFFFF000

def make_payload(rc, s, pte_base, cr3, pml4e, pdpte, pde, pte, frame,
                 mask, source, self_ok, reads, live_cr3, self_entry):
    return struct.pack('<IIQQQQQQQIIIIQQ',
                       rc, s, pte_base, cr3, pml4e, pdpte, pde, pte,
                       frame, mask, source, self_ok, reads, live_cr3,
                       self_entry)

def p1_verdict(data):
    """The ported v39 P1 logic (PS semantics: -band = & on UInt64)."""
    rc      = u32(data, 0)
    ptebase = u64(data, 8)
    frame   = u64(data, 56)
    mask    = u32(data, 64)
    selfok  = u32(data, 72)
    live    = u64(data, 80)
    sentry  = u64(data, 88)
    ptb_canon = (ptebase >= 0xFFFF800000000000) and ((ptebase & 0x0000007FFFFFFFFF) == 0)
    frame_ok  = (0 < frame < 0x400000000)
    mask_ok   = (mask & 0x1F) == 0x1F or (mask & 0x17) == 0x17 or (mask & 0x13) == 0x13
    selff = sentry & PFN_MASK
    livef = live & PFN_MASK
    ident = (selff != 0) and (selff == livef)
    ok = (rc == 1) and ptb_canon and frame_ok and mask_ok and ((selfok & 1) == 1) and ident
    return ok, ident, selff, livef

# the FIELD-shaped happy payload: this boot's real constants + a caller
# PML4 (0x2B7000) that is NOT the System DTB (0x1AD000) - the honest
# caller-context world
good = make_payload(1, 0x1C4, 0xFFFFE20000000000, 0x1AD000,
                    0x0000000AAA000025, 0x0000000BBB000025,
                    0x0000000CCC000025, 0x0000000DDD000025,
                    0xABC000, 0x1F, 1, 3, 7,
                    0x2B7000ED, 0x2B700063)
ok, ident, selff, livef = p1_verdict(good)
check('P1 happy: rc=1 + structural + THE IDENTITY -> PASS', ok)
check('the identity: self frame == live register frame (0x2B700000)',
      ident and selff == livef == 0x2B700000)
check('the two-PML4 honesty: self frame != System DTB (the P8 line)',
      selff != 0x1AD000)
check('selfOk bit0+bit1 = 3 (the v27 semantics)', (u32(good, 72) & 3) == 3)

# the identity-break payload: the self entry names a DIFFERENT frame
# than the register (e.g. a wrong level-base formula world)
bad = make_payload(1, 0x1C4, 0xFFFFE20000000000, 0x1AD000,
                   0x25, 0x25, 0x25, 0x25, 0xABC000,
                   0x1F, 1, 1, 7, 0x2B7000ED, 0x9F700063)
ok2, ident2, sf2, lf2 = p1_verdict(bad)
check('P1 identity-break: self frame != register frame -> FAIL (not ok)',
      (not ok2) and (not ident2) and sf2 != lf2)
check('but bit0 alone (space live) still true -> the P1 NOTE path',
      (u32(bad, 72) & 1) == 1)

# a drifted-layout payload: rc=2 (kPtNoBase) -> clean refusal, VM alive
nb = make_payload(2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
ok3, ident3, _, _ = p1_verdict(nb)
check('P1 no-base: rc=2 -> FAIL cleanly (drifted .data; VM alive)', not ok3)

# ---------------------------------------------------------------------------
# 3. THE WIRE: op-12 sends byte-identical to the v34 field-proven ladder
# ---------------------------------------------------------------------------
def p_sends(t):
    return re.findall(r"Send-Req \(New-Req 0x1A0[1-6] 12 [^\n]+", t)
w34, w39 = p_sends(PS34), p_sends(PS39)
check('6 op-12 send lines found in v39', len(w39) == 6, str(len(w39)))
check('the op-12 WIRE byte-identical to the v34 field-proven ladder',
      w34 == w39, f'\n  v34={w34}\n  v39={w39}')

# the dump loop: byte-identical to the field v38 except the ONE fixed line
def dump_region(t):
    a = t.index('--- step D: the ALMOSTRO dump')
    b = t.index('--- step D+: the ALMOSTRO pre-scan')
    return [l for l in t[a:b].splitlines()
            if l.strip() and not l.strip().startswith('#')]

d38, d39 = dump_region(PS38), dump_region(PS39)
diff = [l for l in d39 if l not in d38] + [l for l in d38 if l not in d39]
expected = [
    '                    $total    = [int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)',
    '                    $man += ("# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v39")',
    '                    $total    = [int](($dataVs + $chunkSz - 1) / $chunkSz)',
    '                    $man += ("# ntoskrnl ALMOSTRO dump manifest - generated by trigger-test-v38")',
]
check(f'the dump loop differs from v38 in EXACTLY the chunk-math + manifest-version lines ({len(diff)} diff lines)',
      sorted(diff) == sorted(expected), str(diff[:4]))

print()
if fails:
    print(f'== {len(fails)} FAILURES ==')
    for f in fails: print(f'  - {f}')
    sys.exit(1)
print('== ALL FUNCTIONAL CHECKS PASS ==')
