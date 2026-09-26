#!/bin/bash
# build-v24-package.sh — assemble infinity-qemu-test-v19.zip (full stick
# bundle: v19 driver + v24 script) + infinity-v24-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v23-package.sh; differences:
#   - DRIVER GENERATION CHANGES: v19 RT (125450) / v19 SAFE (105032)
#   - script = trigger-test-v24.ps1 (K anchors + L validated reads + J regression)
#   - bat = phase-d-v19.bat (size guard 125450 + v18/v17 stale detection)
#   - README = README-V24-FA.md
#   - this time usb-d\memory.efi IS the swap (the driver changed)
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v19
SCR=$BASE/infinity-qemu-test/trigger-test-v24.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v19.bat
DOC=$BASE/infinity-qemu-test/README-V24-FA.md
RT=$BASE/patches/v19-memory-RT.efi
SAFE=$BASE/patches/v19-memory-SAFE.efi

echo "== [1/7] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/7] binaries (v19 — THE F1 ANCHOR BUILD) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/7] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v24.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V24-FA.md"
sed -i 's/package v9+/package v19+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/7] guard simulations =="
grep -q "trigger test v24" "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v24' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v24.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "125450" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 125450 (v19-RT)"; exit 1; }
echo "  PASS  usb-d memory.efi = 125450 bytes (v19-RT)"
grep -q "125450" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v19 size guard"; exit 1; }
grep -q 'trigger-test-v24.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v24 script"; exit 1; }
echo "  PASS  phase-d.bat: size guard 125450 + v24 references"
# the F1 core promises: op-9 anchors request + L reads + verdicts
grep -q "New-Req 0x1701 9 '00000000' 32 '0000000000000000'" "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: K anchors request (op 9) missing"; exit 1; }
grep -q 'F1 PROVEN: ANCHORS CONVERGED' "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: F1 PROVEN verdict missing"; exit 1; }
grep -q 'F1 FAIL-CLOSED' "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: F1 FAIL-CLOSED verdict missing"; exit 1; }
grep -q '(\$peBase - \[uint64\]0x1000)' "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: L4 below-range address math missing"; exit 1; }
echo "  PASS  K (op 9) + L verdicts + L4/L5 range negatives present"
# the J regression must be intact
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = 'FFFFF78000000260'" "$PKGDIR/usb-d/trigger-test-v24.ps1" \
  || { echo "FATAL: ladder J2 kernel-alias address missing"; exit 1; }
echo "  PASS  J-ladder regression addresses intact"
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v24.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  v22 slip still eradicated"
if find "$PKGDIR" -name 'trigger-test-v2[0123].ps1' | grep -q .; then
  echo "FATAL: stale v20/v21/v22/v23 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[0123].ps1'; exit 1
fi
echo "  PASS  no stale v20..v23 scripts in the bundle"
# driver lineage: v19-RT hash must equal the vaulted patches/ binary
A=$(sha256sum "$RT" | awk '{print $1}'); B=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print $1}')
[ "$A" = "$B" ] || { echo "FATAL: usb-d driver hash != patches/v19-memory-RT.efi"; exit 1; }
echo "  PASS  usb-d driver hash-identical to patches/v19-memory-RT.efi"

echo "== [5/7] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v24.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v19 (2026-09-26)
Driver : memory.efi v19 RT  (usb-d)  125450 bytes  [F1 ANCHOR BUILD]
         SHA256 $SHA_RT
         memory.efi v19 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v24.ps1  57371 bytes
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v19 driver guard 125450 + v24 script marker
         + v18/v17 stale-driver detection)
         SHA256 $SHA_BAT
Change : DRIVER v19 = v18 + KernelAnchor.h (F1): SIDT + IDT#PF/#BP
         + LSTAR anchors, 3x walk-back (64KB steps, 32MB bound, full
         PE validation per candidate), 4 converging validators,
         9 fail-closed reason codes. Gate: KUSD windows (always) +
         the validated kernel-image range (only while converged).
         New request op 9 (ReqOp_Anchors) reports state/reason/
         pe_base/pe_size/idt_base. Host logic tests 29/29 ALL PASS
         (incl. the nested-PE and corrupt-PE traps); QEMU bench
         RT 13/13 + SAFE 5/5; disasm verified (op-9 dispatch,
         rdmsr/sidr, all PE constants, KUSD gates untouched).
Require: THIS TIME THE DRIVER CHANGES - replace usb-d\memory.efi
         (v19 RT, 125450 bytes) + usb-d\trigger-test-v24.ps1
         (delete old v23) + phase-d.bat on the stick.
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/7] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v19.zip" "$BASE/download/infinity-v24-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v19.zip" "$(basename "$PKGDIR")"
SWAP=$BASE/build/v24-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v24.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V24-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v24-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v19.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v24-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/7] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v19.zip infinity-v24-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] && echo "  PASS  $Z mirror identical" || { echo "  FAIL  $Z mirror differs"; exit 1; }
done
echo "-- download/ --"; ls -la "$BASE/download/" | grep -E "v19|v24"
echo "DONE"
