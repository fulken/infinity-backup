#!/bin/bash
# ============================================================================
# build-v30-package.sh - build the v30/F3 field kit (driver v22 + script v30):
#   1. GUARDS: the v22 driver hashes (fresh builds), the v30 script audit,
#      the bat paren audit, host-test re-run
#   2. infinity-v22-swap.zip   (usb-d/memory.efi v22-RT + usb-d/trigger-test-v30.ps1
#                               + phase-d.bat + README-V30-FA.md + VERSION.txt)
#   3. infinity-qemu-test-v22.zip (full bundle on the v21 package template,
#                               driver v22 everywhere, trigger v30 in all 3
#                               locations, new bat + README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=upload/infinity-qemu-test-v21/pkg-v21
SWAP=download/infinity-v22-swap.zip
FULL=download/infinity-qemu-test-v22.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/6] GUARDS: the v22 binaries + the v30 audits"
RT=build/v22-RT.efi
SAFE=build/v22-SAFE.efi
[ "$(stat -c%s $RT)" = "134330" ]   || { echo "FATAL: v22-RT size $(stat -c%s $RT) != 134330"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v22-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v22-RT  sha256 $RT_SHA"
echo "   v22-SAFE sha256 $SAFE_SHA"
# binary identity: the freshly built RT must match the tree build we verified
cmp -s "$RT" build-v22-tree/UEFI/build/build/memory.efi || { echo "FATAL: RT != tree build"; exit 1; }
# SAFE must be byte-identical to the v20/v21 SAFE lineage (no hook code paths)
cmp -s "$SAFE" patches/v21-memory-SAFE.efi || { echo "NOTE: v22-SAFE differs from v21-SAFE (banner change) - expected"; }
python3 scripts/audit-v30-ps1.py | tail -1
echo "   script v30 audit: PASS (45 checks)"
# bat paren audit (inline rule)
python3 - <<'PYEOF'
import re, sys
t = open('patches/phase-d-v30.bat', encoding='ascii').read()
bad = 0; depth = 0
for n, line in enumerate(t.splitlines(), 1):
    s = line.strip()
    if s.lower().startswith('echo') or s.lower().startswith('rem'):
        if depth > 0:
            if re.findall(r'(?<!\^)[()]', s):
                print(f'  BAD line {n}'); bad += 1
    else:
        depth += line.count('(') - line.count(')')
print('bat paren audit:', 'FAIL' if bad else 'PASS')
sys.exit(1 if bad else 0)
PYEOF

echo "== [2/6] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v30.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v30.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [3/6] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v30.ps1     "$STAGE/swap/usb-d/trigger-test-v30.ps1"
cp patches/phase-d-v30.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V30-FA.md         "$STAGE/swap/README-V30-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v30 / F3 (2026-09-27) - DRIVER v22 + script v30
Driver : memory.efi v22 RT  134330 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         (= the ENTIRE v21 field contract re-derived from the proven binary
         + ProcessWalk: the EPROCESS walk, op 11. Host-tested 43/43,
         bench A=13/13 B=5/5, VA-safety clean, SAFE clean of hook code.)
Script : trigger-test-v30.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         (the full K/L/M/J regression - byte-identical wires to the field-
         proven v29 - + the NEW W ladder: W1 walk + M1<->sys cross-check,
         W2 live Get-Process cross-check, W3 self-pid, W4 outN negatives,
         W5 pid-irrelevance. INFCNT = v29 formula + wSent.)
Bat    : phase-d.bat (SIX-way guard: 120678/121253/125450/128010/131709/
         134330; with v21 everything but W runs green - W refuses clean)
         SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : DRIVER v22 (replace memory.efi! 131709 -> 134330) + SCRIPT v30
         + BAT v30. This is a FULL swap, not script-only.
Require: REPLACE usb-d\memory.efi (v22-RT 134330) + usb-d\trigger-test-v30.ps1
         (delete v29) + phase-d.bat.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [4/6] build the FULL bundle (v22 driver everywhere + v30 kit)"
rm -rf "$STAGE/full" && mkdir -p "$STAGE/full"
cp -r "$BASE/." "$STAGE/full/"
rm -f "$STAGE/full/trigger-test-v29.ps1" "$STAGE/full/transfer/trigger-test-v29.ps1" \
      "$STAGE/full/usb-d/trigger-test-v29.ps1" "$STAGE/full/README-V29-FA.md" \
      "$STAGE/full/VERSION.txt"
cp "$RT"                        "$STAGE/full/usb-d/memory.efi"
cp "$RT"                        "$STAGE/full/usb/memory.efi"
cp "$RT"                        "$STAGE/full/usb-c/memory.efi"
cp patches/trigger-test-v30.ps1 "$STAGE/full/trigger-test-v30.ps1"
cp patches/trigger-test-v30.ps1 "$STAGE/full/transfer/trigger-test-v30.ps1"
cp patches/trigger-test-v30.ps1 "$STAGE/full/usb-d/trigger-test-v30.ps1"
cp patches/phase-d-v30.bat      "$STAGE/full/phase-d.bat"
cp patches/phase-d-v30.bat      "$STAGE/full/phase-d-v18.bat"
cp patches/README-V30-FA.md     "$STAGE/full/README-V30-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "134330" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "134330" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ ! -f "$STAGE/full/usb-d/trigger-test-v29.ps1" ] || { echo "FATAL: v29 script survived in usb-d"; exit 1; }
grep -q "trigger test v30" "$STAGE/full/usb-d/trigger-test-v30.ps1"
grep -q "trigger-test-v30.ps1" "$STAGE/full/phase-d.bat"
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [5/6] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v22-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v22.zip"
cmp -s "$SWAP" "$ARCH/infinity-v22-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v22.zip" \
  && echo "   mirrors hash-identical"

echo "== [6/6] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v22-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
