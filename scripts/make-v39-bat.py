#!/usr/bin/env python3
# ============================================================================
# make-v39-bat.py — build phase-d-v39.bat from the field-run v38 bat
#
# v39 bat = the v38 bat with THE DRIVER GENERATION FLIP: v27-RT is the
# GO binary (141041 bytes, sha256 e13f9f24... — chain B deleted + the
# [PT]-before-read traces + the LIVE-CR3 identity + the 96B op-12
# payload). The v26 hash moves from GO to a clean REFUSE with the
# honest explanation (its op-12 returns the 80B payload: the v39
# P-ladder would fail P1 cleanly, never crash — but F4 cannot prove
# on v26). The SIX-way hash guard: v27 GO / v26 refuse-obsolete /
# v25 DO-NOT-RUN (the BSOD exhibit) / v24 / v23 / v22 / unknown.
# Script checks retargeted to v39; milestone = F4 ATTEMPT 6 / THE
# WALK; the v38 script joins the safe-but-obsolete taxonomy (its
# dump prints "PARTIAL 157/158" over a complete dump + no P-ladder).
# ============================================================================
import sys, pathlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'phase-d-v38.bat'
DST = BASE / 'patches' / 'phase-d-v39.bat'

text = SRC.read_text(encoding='utf-8')

def rep(old, new, label, count=1):
    global text
    n = text.count(old)
    if n != count:
        print(f'[{label}] FATAL: anchor found {n} times (need {count})')
        sys.exit(1)
    text = text.replace(old, new)
    print(f'[{label}] OK')

# =========================================================
# 1. the v39 header block (the v38 header demoted to history)
# =========================================================
rep(
"""rem INFINITY Phase D v38: SCRIPT-ONLY - the v26 driver UNCHANGED.""",
"""rem INFINITY Phase D v39: F4 ATTEMPT 6 - THE WALK ITSELF. A REAL
rem DRIVER GENERATION CHANGE: v27-RT (141041 bytes, sha256
rem e13f9f24...) - chain B (the _MMPFN deref behind BOTH F4-era
rem BSODs) DELETED at the binary level, [PT] serial traces BEFORE
rem every PTE-space read, the LIVE-CR3 identity (selfOk bit1 =
rem self frame == the CR3 register frame - expected 1 in ANY
rem caller context), and the op-12 payload grows 80 -> 96B
rem (additive: liveCr3@80 + selfEntry@88). Host-proven 103/103
rem against a true-semantics world (incl. the POISON-IMMUNITY
rem kill + the old-formula class-kill + the s=0x1FF edge);
rem bench-validated RT 13/13 + SAFE.
rem
rem The v38 field run (2026-09-28 20:04, 5th consecutive
rem crash-proof) captured the COMPLETE ALMOSTRO dump (160480 B,
rem echo-verified) - the offline analysis PINNED the F4 constants
rem (MmPteBase slot 0xCFB358, live 0xFFFFE20000000000, s=0x1C4;
rem all 5 researched MmPfnDatabase RVAs proven WRONG: 3 dead + 2
rem poison = the BSOD fingerprint class). v39 = the payoff run:
rem the P-ladder (op-12) walks the kernel image, the EPROCESS,
rem the KUSD window and the IDT page through the self-map, and
rem THE LIVE-CR3 IDENTITY is the ground truth that proves the
rem translation formulas with zero extra assumptions.
rem
rem PLUS the one-line CHUNK-MATH FIX (v38's only flaw): [int]
rem cast -> [Math]::Floor. The [int] cast ROUNDS (157.72 -> 158
rem = a phantom chunk; remain<0; $dumpOk never set - "PARTIAL
rem 157/158" printed over a COMPLETE dump). With Floor: the dump
rem completes, the sha256 lands, and the in-script PRE-SCAN
rem (shipped in v38 but never reached) finally runs.
rem
rem === HISTORY: v38 was SCRIPT-ONLY - the v26 driver UNCHANGED.""",
'1-header')

# =========================================================
# 2. the findstr needle + script-name refs
# =========================================================
rep(
"""findstr /I /C:"trigger test v38" usb-d\\trigger-test-v38.ps1 >nul 2>&1""",
"""findstr /I /C:"trigger test v39" usb-d\\trigger-test-v39.ps1 >nul 2>&1""",
'2a-findstr-needle')

n = text.count('trigger-test-v38.ps1')
text = text.replace('trigger-test-v38.ps1', 'trigger-test-v39.ps1')
print(f'[2b-script-refs] OK ({n} refs)')

n = text.count('v38 script')
text = text.replace('v38 script', 'v39 script')
print(f'[2c-script-labels] OK ({n})')

# =========================================================
# 3. the size guard: GO size 141041 + the v26 branch
# =========================================================
rep(
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v26-RT = 140582) ----""",
"""rem ---- pre-flight 1b: DRIVER SIZE GUARD (v27-RT = 141041) ----""",
'3a-guard-title')

rep(
"""if not "%DRIVERSIZE%"=="140582" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v26 RT driver ^(v26-RT = 140582 bytes^).""",
"""if not "%DRIVERSIZE%"=="141041" (
  echo [ERROR] usb-d\\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v27 RT driver ^(v27-RT = 141041 bytes^).""",
'3b-go-size')

rep(
"""  if "%DRIVERSIZE%"=="120678" (""",
"""  if "%DRIVERSIZE%"=="140582" (
    echo That size is the v26 RT driver ^(F1-F4-attempt-2-era, the
    echo 13-green-run workhorse^). It answers op-12 with the 80B
    echo payload - the v39 P-ladder expects the 96B v27 tail
    ^(liveCr3@80 + selfEntry@88^), so P1 would fail cleanly
    ^(never crash^) and F4 cannot prove. Replace with this
    echo package's v27 driver.
  ) else (
  if "%DRIVERSIZE%"=="120678" (""",
'3c-v26-branch')

# close the extra else paren after the v17 branch chain: the final
# "Unknown driver build" else needs one more closing paren
rep(
"""                ) else (
                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v38 R9/D steps.
                )
              )
            )
          )
        )
      )
    )
  )""",
"""                ) else (
                  echo Unknown driver build. Only the v27 RT driver runs
                  echo the v39 P-ladder.
                )
              )
            )
          )
        )
      )
    )
  )
  )""",
'3d-close-paren')

# the fix line after the size guard
rep(
"""  echo Fix: copy memory.efi from this package over usb-d\\memory.efi,
  echo then run phase-d.bat again.""",
"""  echo Fix: copy this package's v27 memory.efi over usb-d\\memory.efi,
  echo then run phase-d.bat again.""",
'3e-fix-line')

# =========================================================
# 4. the hash guard: v27 GO + v26 refuse
# =========================================================
rep(
"""set ISV26=0
set ISV25=0
set ISV24=0
set ISV23=0
set ISV22=0""",
"""set ISV27=0
set ISV26=0
set ISV25=0
set ISV24=0
set ISV23=0
set ISV22=0""",
'4a-flags')

rep(
"""certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV26=1""",
"""certutil -hashfile usb-d\\memory.efi SHA256 > "%TEMP%\\inf-drv-hash.txt" 2>nul
findstr /I /C:"e13f9f24b9b5b9df2f68c19a8a713b75dd2b09833d00d0ce5af8802911c5ecaf" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV27=1
findstr /I /C:"c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb" "%TEMP%\\inf-drv-hash.txt" >nul 2>&1 && set ISV26=1""",
'4b-v27-hash')

rep(
"""if "%ISV26%"=="1" (
  echo [Phase D] memory.efi verified - v26 RT build ^(140582 bytes, sha256 c8f79b95...^).
) else (
  if "%ISV25%"=="1" (""",
"""if "%ISV27%"=="1" (
  echo [Phase D] memory.efi verified - v27 RT build ^(141041 bytes, sha256 e13f9f24...^).
  echo Chain B deleted, [PT] traces before every PTE-space read, the
  echo LIVE-CR3 identity, the 96B op-12 payload. THE WALK IS ARMED.
) else (
  if "%ISV26%"=="1" (
    echo [ERROR] usb-d\\memory.efi is the v26 driver ^(140582 bytes,
    echo sha256 c8f79b95...^) - the 13-green-run workhorse, but THIS
    echo kit needs v27: its op-12 answers the 80B payload ^(no
    echo liveCr3@80 / selfEntry@88^), so the v39 P-ladder would fail
    echo P1 cleanly and F4 cannot prove. No crash - just replace it:
    echo copy this package's memory.efi over usb-d\\memory.efi.
    pause
    exit /b 1
  ) else (
  if "%ISV25%"=="1" (""",
'4c-verdict-head')

rep(
"""        ) else (
          echo [ERROR] the sha256 matches NEITHER v26 ^(c8f79b95...^) NOR
          echo v25 ^(022e6d1c...^) NOR v24 ^(f8a01814...^) NOR v23
          echo ^(d7562a7d...^) NOR v22 ^(276b744c...^) - unknown build.
          echo Replace usb-d\\memory.efi with this package's v26 driver.
          pause
          exit /b 1
        )
      )
    )
  )
)""",
"""        ) else (
          echo [ERROR] the sha256 matches NEITHER v27 ^(e13f9f24...^) NOR
          echo v26 ^(c8f79b95...^) NOR v25 ^(022e6d1c...^) NOR v24
          echo ^(f8a01814...^) NOR v23 ^(d7562a7d...^) NOR v22
          echo ^(276b744c...^) - unknown build.
          echo Replace usb-d\\memory.efi with this package's v27 driver.
          pause
          exit /b 1
        )
      )
    )
  )
  )
)""",
'4d-verdict-tail')

# the DO-NOT-RUN v25 text mentions "replace with this package's v26"
rep(
"""    echo DO NOT RUN IT AGAIN - replace with this package's v26.""",
"""    echo DO NOT RUN IT AGAIN - replace with this package's v27.""",
'4e-v25-text')

# =========================================================
# 5. package refs + milestone + version strings
# =========================================================
n = text.count('infinity-qemu-test-v26e')
text = text.replace('infinity-qemu-test-v26e', 'infinity-qemu-test-v27')
print(f'[5a-package-refs] OK ({n})')

n = text.count('v26e package')
text = text.replace('v26e package', 'v27 package')
print(f'[5b-package-label] OK ({n})')

n = text.count('Phase D v38')
text = text.replace('Phase D v38', 'Phase D v39')
print(f'[5c-phase-labels] OK ({n})')

# stale taxonomy: v38 joins the obsolete list
rep(
"""rem v33/v34 = DO-NOT-RUN (the op-12 BSOD scripts); v35/v36/v37""",
"""rem v33/v34 = DO-NOT-RUN (the op-12 BSOD scripts); v35/v36/v37/v38""",
'5d-taxonomy') if """rem v33/v34 = DO-NOT-RUN (the op-12 BSOD scripts); v35/v36/v37""" in text else print('[5d-taxonomy] anchor absent - SKIP (checked below)')

# milestone text if present
if 'F4 ATTEMPT 5' in text:
    text = text.replace('F4 ATTEMPT 5', 'F4 ATTEMPT 6')
    print('[5e-milestone] OK')

DST.write_text(text, encoding='utf-8', newline='\n')
sz = len(text.encode('utf-8'))
print(f'\\n[make-v39-bat] wrote {DST} ({sz} bytes)')

# =========================================================
# final checks
# =========================================================
ok = True
for probe, label in (
    ('e13f9f24b9b5b9df2f68c19a8a713b75dd2b09833d00d0ce5af8802911c5ecaf', 'v27 GO hash'),
    ('c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb', 'v26 hash'),
    ('trigger-test-v39.ps1', 'v39 script refs'),
    ('trigger test v39', 'findstr needle'),
    ('141041', 'GO size'),
    ('140582', 'v26 size branch'),
    ('THE WALK IS ARMED', 'GO banner'),
):
    if probe not in text:
        print(f'FINAL CHECK FAIL: {label} missing'); ok = False
# paren balance (crude but the bat is mostly balanced parens)
po, pc = text.count('('), text.count(')')
po_e, pc_e = text.count('^('), text.count('^)')
code_o, code_c = po - po_e, pc - pc_e
print(f'[make-v39-bat] parens: raw {po}/{pc}, escaped {po_e}/{pc_e}, code {code_o}/{code_c} (delta {code_o - code_c})')
if not ok:
    sys.exit(1)
print('[make-v39-bat] ALL FINAL CHECKS PASS')
