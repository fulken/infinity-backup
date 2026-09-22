#!/bin/bash
# build-v18-package.sh — assemble infinity-qemu-test-v18.zip (full stick
# bundle) + infinity-v18-swap.zip (3-file mini swap) + VERSION.txt
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v18
SCR=$BASE/infinity-qemu-test/trigger-test-v22.ps1
RT=$BASE/patches/v18-memory-RT.efi
SAFE=$BASE/patches/v18-memory-SAFE.efi

echo "== [1/6] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip template leftovers (v17 packaging list + old scripts)
rm -f "$PKGDIR/trigger-test.ps1" "$PKGDIR/usb-d/trigger-test.ps1" \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR/trigger-test-v16.ps1" "$PKGDIR/usb-d/trigger-test-v16.ps1" \
      "$PKGDIR/trigger-test-v17.ps1" "$PKGDIR/usb-d/trigger-test-v17.ps1"

echo "== [2/6] binaries (v18) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/6] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v22.ps1"; done
cp "$BASE/infinity-qemu-test/phase-d-v18.bat" "$PKGDIR/phase-d.bat"
cp "$BASE/infinity-qemu-test/README-V18-FA.md" "$PKGDIR/README-V18-FA.md"
sed -i 's/package v9+/package v18+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/6] guard simulations =="
grep -q "trigger test v22" "$PKGDIR/usb-d/trigger-test-v22.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v22' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v22.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "121253" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 121253"; exit 1; }
echo "  PASS  usb-d memory.efi = 121253 bytes (v18-RT)"
grep -q "121253" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the size guard"; exit 1; }
echo "  PASS  phase-d.bat has the driver size guard"

echo "== [5/6] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi"      | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi"      | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v22.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat"          | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v18 (2026-09-22)
Driver : memory.efi v18 RT  (usb-d)  121253 bytes
         SHA256 $SHA_RT
         memory.efi v18 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v22.ps1  43521 bytes
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v18: driver size guard 121253)
         SHA256 $SHA_BAT
Change : v18 driver = direct KUSD-window reads (the v17 ReadPhysical
         CR3-switch that killed the v19/v20 VMs is gone from the
         kernel-read path). v22 script = step-0 Event-Log post-mortem,
         serial canaries, literal fix, ladder J1..J7.
Require: replace usb-d\memory.efi + usb-d\trigger-test-v22.ps1 +
         phase-d.bat on the stick. Old root trigger files are harmless.
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/6] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v18.zip" "$BASE/download/infinity-v18-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v18.zip" "$(basename "$PKGDIR")"
# mini swap zip: exactly what to replace on an existing stick
SWAP=$BASE/build/v18-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v22.ps1"
cp "$BASE/infinity-qemu-test/phase-d-v18.bat" "$SWAP/phase-d.bat"
cp "$BASE/infinity-qemu-test/README-V18-FA.md" "$SWAP/README-V18-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v18-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v18.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v18-swap.zip"      "$BASE/version-archive/packages/"
echo "-- download/ --"; ls -la "$BASE/download/" | grep -E "v18|v22"
echo "-- mirror check --"
A=$(sha256sum "$BASE/download/infinity-qemu-test-v18.zip" | awk '{print $1}')
B=$(sha256sum "$BASE/version-archive/packages/infinity-qemu-test-v18.zip" | awk '{print $1}')
[ "$A" = "$B" ] && echo "  PASS  archive mirror identical (the v18.1 lesson)" || { echo "  FAIL mirror differs"; exit 1; }
echo "DONE"
