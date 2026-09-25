#!/bin/bash
# build-v23-package.sh — assemble infinity-qemu-test-v18b.zip (full stick
# bundle: v18 driver + v23 script) + infinity-v23-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v18-package.sh; differences:
#   - script = trigger-test-v23.ps1 (user-alias hex fix, self-test hardened)
#   - bat = phase-d-v18.bat updated for the v23 marker (driver gen unchanged)
#   - README = README-V23-FA.md
#   - full zip name = v18b (bundle generation b of the v18 driver era)
#   - swap zip name = v23 (what actually changes on the stick)
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v18b
SCR=$BASE/infinity-qemu-test/trigger-test-v23.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v18.bat
DOC=$BASE/infinity-qemu-test/README-V23-FA.md
RT=$BASE/patches/v18-memory-RT.efi
SAFE=$BASE/patches/v18-memory-SAFE.efi

echo "== [1/7] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip ALL trigger scripts + old docs from the template (glob - future-proof);
# we re-place exactly what ships below
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
# also drop any stale vN script copies anywhere else in the tree
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/7] binaries (v18 — UNCHANGED) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/7] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v23.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V23-FA.md"
sed -i 's/package v9+/package v18b+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/7] guard simulations =="
grep -q "trigger test v23" "$PKGDIR/usb-d/trigger-test-v23.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v23' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v23.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "121253" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 121253"; exit 1; }
echo "  PASS  usb-d memory.efi = 121253 bytes (v18-RT)"
grep -q "121253" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the size guard"; exit 1; }
echo "  PASS  phase-d.bat has the driver size guard"
grep -q 'trigger-test-v23.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v23 script"; exit 1; }
echo "  PASS  phase-d.bat references trigger-test-v23.ps1"
# the v23 core promise: the REAL user-alias addresses are in the ladder
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v23.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = '000000007FFE0308'" "$PKGDIR/usb-d/trigger-test-v23.ps1" \
  || { echo "FATAL: ladder J3 user-alias address missing"; exit 1; }
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v23.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  ladder carries the REAL user-alias addresses (v22 slip gone)"
# no stale script copies anywhere in the bundle
if find "$PKGDIR" -name 'trigger-test-v2[012].ps1' | grep -q .; then
  echo "FATAL: stale v20/v21/v22 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[012].ps1'; exit 1
fi
echo "  PASS  no stale v20/v21/v22 scripts in the bundle"

echo "== [5/7] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v23.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v18b (2026-09-26)
Driver : memory.efi v18 RT  (usb-d)  121253 bytes  [UNCHANGED from v18]
         SHA256 $SHA_RT
         memory.efi v18 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v23.ps1  45620 bytes
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v18 driver guard 121253 + v23 script marker)
         SHA256 $SHA_BAT
Change : v23 script = the user-alias hex fix. In v22 the ladder's
         USER-alias rungs sent 0x00007FFE00000260 instead of
         0x000000007FFE0260 - the v18 gate rejected them as
         out-of-window (accidental negatives; Phase E was still
         proven by J2 kernel alias = 19045 on 2026-09-22). v23
         sends the real addresses: J1/J5/J7 = 0x7FFE0260,
         J3 = 0x7FFE0308. New self-test round-trips the user-alias
         string so this slip class can never reach the driver.
         Driver binary UNTOUCHED (same sha256 as package v18).
Require: replace usb-d\trigger-test-v23.ps1 (delete old v22) +
         phase-d.bat on the stick. usb-d\memory.efi is IDENTICAL
         to the v18 package copy (no re-copy needed, shipped for
         the 3-file ritual).
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/7] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v18b.zip" "$BASE/download/infinity-v23-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v18b.zip" "$(basename "$PKGDIR")"
# mini swap zip: exactly what to replace on an existing stick
SWAP=$BASE/build/v23-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v23.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V23-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v23-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v18b.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v23-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/7] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v18b.zip infinity-v23-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] && echo "  PASS  $Z mirror identical" || { echo "  FAIL  $Z mirror differs"; exit 1; }
done
echo "-- download/ --"; ls -la "$BASE/download/" | grep -E "v18b|v23"
echo "DONE"
