#!/bin/bash
# ============================================================================
# build-v29-package.sh - build the v29 field kit ON TOP of the recovered
# v21 package (driver UNCHANGED, script v29, bat retargeted):
#   1. GUARDS: driver hashes (v21-RT/v21-SAFE identical to the field-proven
#      binaries), the v29 script audit, the bat paren audit
#   2. infinity-v29-swap.zip   (usb-d/memory.efi + usb-d/trigger-test-v29.ps1
#                               + phase-d.bat + README-V29-FA.md)
#   3. infinity-qemu-test-v21.zip REBUILT (full bundle, trigger v29 inside:
#                               root + transfer/ + usb-d/, new bat + README +
#                               VERSION.txt v29-kit)
#   4. archive mirrors (hash-identical) + the v28-era full snapshot preserved
#      as infinity-qemu-test-v21-with-trigger-v28.zip
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=upload/infinity-qemu-test-v21/pkg-v21
SWAP=download/infinity-v29-swap.zip
FULL=download/infinity-qemu-test-v21.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/6] GUARDS: the field-proven binaries + the v29 audits"
RT_SHA=$(sha256sum "$BASE/usb-d/memory.efi" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$BASE/usb/memory.efi" | cut -d' ' -f1)
[ "$RT_SHA" = "90bc3bdffd1d823df35c39f3a88af5078b73c02bd5ebb8f89a44f3bb4b671232" ] || { echo "FATAL: v21-RT hash mismatch"; exit 1; }
[ "$SAFE_SHA" = "c66d022566982d0c203f42cd2aabece5742fe96325f8e11a70c667a4bfe8d327" ] || { echo "FATAL: v21-SAFE hash mismatch"; exit 1; }
cmp -s "$BASE/usb-d/memory.efi" patches/v21-memory-RT.efi || { echo "FATAL: patches/v21-memory-RT.efi != package"; exit 1; }
python3 scripts/audit-v29-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v29.bat | tail -1
echo "   driver v21-RT 131709 + v21-SAFE 105032: hash-identical to the field run"
echo "   script v29 audit + bat paren audit: PASS"

echo "== [2/6] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v29.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v29.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [3/6] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$BASE/usb-d/memory.efi"        "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v29.ps1    "$STAGE/swap/usb-d/trigger-test-v29.ps1"
cp patches/phase-d-v29.bat         "$STAGE/swap/phase-d.bat"
cp patches/README-V29-FA.md        "$STAGE/swap/README-V29-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v29 (2026-09-27) - script-only, driver v21 STAYS
Driver : memory.efi v21 RT  131709 bytes  (UNCHANGED - the field-proven
         binary, SHA256 90BC3BDFFD1D823DF35C39F3A88AF5078B73C02BD5EBB8F89A44F3BB4B671232;
         copy only if the stick differs - hash-identical to the v28 run)
Script : trigger-test-v29.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
Bat    : phase-d.bat (v21 driver guard 131709 + FIVE-way stale-driver
         detection unchanged; script refs v28 -> v29; the stale-v28
         message names the M2r/INFCNT story)  SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : SCRIPT v29 = the M2r expectation fix (BUILD mask 0xFFFF + the
         canonical dword accepted via DECIMAL literal 4026550885 - a
         [uint32]0xF0004A65 cast would re-trigger the v21 line-444
         hex-cast trap) + the FULL INFCNT arithmetic (the new
         mNameWrites counter; expect 27 converged / 13 fail-closed,
         every term named) + stale era texts refreshed (ladder table
         128010->131709 x2, pre-A canary, step-0 hints, step K titles).
         K/L/M/J request logic BYTE-IDENTICAL (audit-v29-ps1: ALL PASS
         incl. the M2r emulator x4 + the INFCNT emulator x3 + the
         fixture emulator).
Require: REPLACE usb-d\trigger-test-v29.ps1 FIRST (delete the v28 copy)
         + phase-d.bat. memory.efi STAYS 131709.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [4/6] rebuild the FULL bundle (v21 driver + v29 kit)"
rm -rf "$STAGE/full" && mkdir -p "$STAGE/full"
cp -r "$BASE/." "$STAGE/full/"
rm -f "$STAGE/full/trigger-test-v28.ps1" "$STAGE/full/transfer/trigger-test-v28.ps1" \
      "$STAGE/full/usb-d/trigger-test-v28.ps1" "$STAGE/full/README-V28-FA.md"
cp patches/trigger-test-v29.ps1 "$STAGE/full/trigger-test-v29.ps1"
cp patches/trigger-test-v29.ps1 "$STAGE/full/transfer/trigger-test-v29.ps1"
cp patches/trigger-test-v29.ps1 "$STAGE/full/usb-d/trigger-test-v29.ps1"
cp patches/phase-d-v29.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V29-FA.md     "$STAGE/full/README-V29-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "131709" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ ! -f "$STAGE/full/usb-d/trigger-test-v28.ps1" ] || { echo "FATAL: v28 script survived in usb-d"; exit 1; }
grep -q "trigger test v29" "$STAGE/full/usb-d/trigger-test-v29.ps1"
grep -q "trigger-test-v29.ps1" "$STAGE/full/phase-d.bat"
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [5/6] archive (preserve the v28-era snapshot, mirror the new zips)"
if [ -f "$ARCH/infinity-qemu-test-v21.zip" ] && [ ! -f "$ARCH/infinity-qemu-test-v21-with-trigger-v28.zip" ]; then
  mv "$ARCH/infinity-qemu-test-v21.zip" "$ARCH/infinity-qemu-test-v21-with-trigger-v28.zip"
  echo "   preserved: infinity-qemu-test-v21-with-trigger-v28.zip (the as-received snapshot)"
fi
cp "$SWAP" "$ARCH/infinity-v29-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v21.zip"
cmp -s "$SWAP" "$ARCH/infinity-v29-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v21.zip" \
  && echo "   mirrors hash-identical"

echo "== [6/6] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
