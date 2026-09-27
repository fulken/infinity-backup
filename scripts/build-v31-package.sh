#!/bin/bash
# ============================================================================
# build-v31-package.sh - build the v31 field kit (driver v23 + script v31):
#   1. GUARDS: the v23 driver hashes, the v31 script audit, the bat paren
#      audit, host-test re-run, class-kill proof (the test must FAIL on a
#      v22-copy of the header)
#   2. infinity-v23-driver-swap.zip (usb-d/memory.efi v23-RT +
#      usb-d/trigger-test-v31.ps1 + phase-d.bat + README-V31-FA.md +
#      VERSION.txt)
#   3. infinity-qemu-test-v23.zip (full bundle on the v22 package template,
#      driver v23 everywhere, trigger v31 in all 3 locations, new bat +
#      README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v22.zip   # the v22 full bundle = template
SWAP=download/infinity-v23-driver-swap.zip
FULL=download/infinity-qemu-test-v23.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/7] GUARDS: the v23 binaries + the v31 audits"
RT=patches/v23-memory-RT.efi
SAFE=patches/v23-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "134330" ]   || { echo "FATAL: v23-RT size $(stat -c%s $RT) != 134330"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v23-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v23-RT   sha256 $RT_SHA"
echo "   v23-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "d7562a7dddc4227844036f7e397f1580338be74015715419b757bfac0577c5e8" ] \
  || { echo "FATAL: v23-RT hash drift"; exit 1; }
cmp -s "$RT" build-v20-tree/UEFI/build/build/memory.efi \
  || { echo "FATAL: RT != current tree build"; exit 1; }
python3 scripts/audit-v31-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v31.bat | tail -1

echo "== [2/7] host-test re-run (55/55) + class-kill proof"
g++ -std=c++11 -I build-v20-tree/UEFI/include -o "$STAGE/host23" scripts/host-test-v23.c
"$STAGE/host23" | tail -1
grep -q "55 PASS / 0 FAIL" <("$STAGE/host23" | tail -1) || { echo "FATAL: host-test not 55/55"; exit 1; }
mkdir -p "$STAGE/v22inc"
cp build-v20-tree/UEFI/include/{KernelExports.h,ProcessWalk.h,KernelAnchor.h} "$STAGE/v22inc/" 2>/dev/null || true
cp patches/KernelExports.h "$STAGE/v22inc/KernelExports.h"
sed -i 's/exp_size >= 0x100000/exp_size >= 0x10000/' "$STAGE/v22inc/KernelExports.h"
grep -q "exp_size >= 0x10000)" "$STAGE/v22inc/KernelExports.h" || { echo "FATAL: v22-copy not buggy"; exit 1; }
g++ -std=c++11 -I "$STAGE/v22inc" -o "$STAGE/host22bug" scripts/host-test-v23.c
# NOTE: the buggy-header binary EXITS 1 BY DESIGN (9 fails) - do not let
# pipefail turn that into a script death; capture, then inspect.
set +e
CK_OUT=$("$STAGE/host22bug" 2>&1)
set -e
echo "   v22-copy run: $(echo "$CK_OUT" | tail -1)"
if echo "$CK_OUT" | grep -q "9 FAIL"; then
  echo "   class-kill PROVEN: the v22-copy header fails 9 checks (the field signature)"
else
  echo "FATAL: class-kill does not catch the v22 bug"; exit 1
fi

echo "== [3/7] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v31.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v31.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [4/7] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v31.ps1     "$STAGE/swap/usb-d/trigger-test-v31.ps1"
cp patches/phase-d-v31.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V31-FA.md         "$STAGE/swap/README-V31-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v31 / F3-fix (2026-09-27) - DRIVER v23 + script v31
Driver : memory.efi v23 RT  134330 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         (= v22 + THE ONE-CONSTANT FIX: export-size gate 0x10000 -> 0x100000,
         the v21 field-binary truth @10fbb. The v30 run refused every M/W
         resolve on the wrong 64 KiB bound - fail-closed, zero crashes.
         Host-tested 55/55 incl. the realistic-directory class-kill that
         FAILS on v22 by construction; bench A=13/13 B=5/5.)
         !!! v22-RT is ALSO 134330 bytes - sha256 276b744c... is the BUGGY
         one. This file is d7562a7d... - the bat checks it for you.
Script : trigger-test-v31.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         (the same K/L/M/J/W wire as the field-run v30; only the driver-ID
         texts + the both-134330 hash guidance changed)
Bat    : phase-d.bat (SEVEN-way guard: sizes 120678/121253/125450/128010/
         131709/134330 + THE NEW SHA-256 HASH GUARD for the v22/v23 size
         collision)  SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : DRIVER v23 (replace memory.efi!) + SCRIPT v31 + BAT v31.
         This is a FULL swap, not script-only.
Require: REPLACE usb-d\memory.efi (v23-RT 134330, sha256 d7562a7d...) +
         usb-d\trigger-test-v31.ps1 (delete v30) + phase-d.bat.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [5/7] build the FULL bundle (v23 driver everywhere + v31 kit)"
rm -rf "$STAGE/full" && mkdir -p "$STAGE/full"
rm -rf "$STAGE/tmpl" && mkdir -p "$STAGE/tmpl"
unzip -q "$BASE" -d "$STAGE/tmpl"
cp -r "$STAGE/tmpl/." "$STAGE/full/"
# strip every stale script/readme/version from the template
find "$STAGE/full" -name 'trigger-test-v*.ps1' -delete
rm -f "$STAGE/full/README-V"*"-FA.md" "$STAGE/full/VERSION.txt"
cp "$RT"                        "$STAGE/full/usb-d/memory.efi"
cp "$RT"                        "$STAGE/full/usb/memory.efi"
cp "$RT"                        "$STAGE/full/usb-c/memory.efi"
cp patches/trigger-test-v31.ps1 "$STAGE/full/trigger-test-v31.ps1"
cp patches/trigger-test-v31.ps1 "$STAGE/full/transfer/trigger-test-v31.ps1"
cp patches/trigger-test-v31.ps1 "$STAGE/full/usb-d/trigger-test-v31.ps1"
cp patches/phase-d-v31.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V31-FA.md     "$STAGE/full/README-V31-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "134330" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "134330" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v31" "$STAGE/full/usb-d/trigger-test-v31.ps1"
grep -q "trigger-test-v31.ps1" "$STAGE/full/phase-d.bat"
grep -q "d7562a7d" "$STAGE/full/phase-d.bat"
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v31.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [6/7] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v23-driver-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v23.zip"
cmp -s "$SWAP" "$ARCH/infinity-v23-driver-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v23.zip" \
  && echo "   mirrors hash-identical"

echo "== [7/7] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v23-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
