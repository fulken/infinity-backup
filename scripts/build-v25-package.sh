#!/bin/bash
# build-v25-package.sh — assemble infinity-qemu-test-v19.zip (full stick
# bundle: v19 driver + v25 script) + infinity-v25-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v24-package.sh; differences:
#   - DRIVER UNCHANGED: v19 RT (125450) / v19 SAFE (105032)
#   - script = trigger-test-v25.ps1 (v24 + the selftest fixture fix:
#     the canonical-base bytes are now DERIVED from the decimal literal)
#   - bat = phase-d-v19.bat retargeted to the v25 script marker
#   - README = README-V25-FA.md
#   - build runs audit-v25-ps1.py FIRST and refuses to package on failure
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v19
SCR=$BASE/infinity-qemu-test/trigger-test-v25.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v19.bat
DOC=$BASE/infinity-qemu-test/README-V25-FA.md
RT=$BASE/patches/v19-memory-RT.efi
SAFE=$BASE/patches/v19-memory-SAFE.efi

echo "== [0/7] audit the v25 script - refuse to package on failure =="
python3 "$BASE/scripts/audit-v25-ps1.py" | tail -3

echo "== [1/7] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/7] binaries (v19 - UNCHANGED, the F1 anchor build) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/7] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v25.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V25-FA.md"
sed -i 's/package v9+/package v19+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/7] guard simulations =="
grep -q "trigger test v25" "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v25' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v25.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "125450" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 125450 (v19-RT)"; exit 1; }
echo "  PASS  usb-d memory.efi = 125450 bytes (v19-RT)"
grep -q "125450" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v19 size guard"; exit 1; }
grep -q 'trigger-test-v25.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v25 script"; exit 1; }
grep -q 'trigger test v25' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not check the v25 marker"; exit 1; }
echo "  PASS  phase-d.bat: size guard 125450 + v25 references"
# the F1 core promises: op-9 anchors request + L reads + verdicts
grep -q "New-Req 0x1701 9 '00000000' 32 '0000000000000000'" "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: K anchors request (op 9) missing"; exit 1; }
grep -q 'F1 PROVEN: ANCHORS CONVERGED' "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: F1 PROVEN verdict missing"; exit 1; }
grep -q 'F1 FAIL-CLOSED' "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: F1 FAIL-CLOSED verdict missing"; exit 1; }
grep -q '(\$peBase - \[uint64\]0x1000)' "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: L4 below-range address math missing"; exit 1; }
echo "  PASS  K (op 9) + L verdicts + L4/L5 range negatives present"
# the J regression must be intact
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = 'FFFFF78000000260'" "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: ladder J2 kernel-alias address missing"; exit 1; }
echo "  PASS  J-ladder regression addresses intact"
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v25.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  v22 slip still eradicated"
# the v25 fix itself must be present: derived fixture, not hand-assembled
grep -q 'for (\$i = 0; \$i -lt 8; \$i++) { \$stU64\[\$i\] = \[byte\]((\$stBase -shr (8 \* \$i)) -band 0xFF) }' \
  "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: the v25 derived-fixture loop missing"; exit 1; }
grep -q '\$stBase = \[uint64\]18446603336489631744' "$PKGDIR/usb-d/trigger-test-v25.ps1" \
  || { echo "FATAL: the canonical-base decimal literal missing"; exit 1; }
echo "  PASS  v25 fixture fix present (derived from the literal)"
if find "$PKGDIR" -name 'trigger-test-v2[01234].ps1' | grep -q .; then
  echo "FATAL: stale v20..v24 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[01234].ps1'; exit 1
fi
echo "  PASS  no stale v20..v24 scripts in the bundle"
# driver lineage: v19-RT hash must equal the vaulted patches/ binary
A=$(sha256sum "$RT" | awk '{print $1}'); B=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print $1}')
[ "$A" = "$B" ] || { echo "FATAL: usb-d driver hash != patches/v19-memory-RT.efi"; exit 1; }
echo "  PASS  usb-d driver hash-identical to patches/v19-memory-RT.efi"

echo "== [5/7] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v25.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v19 (2026-09-26)
Driver : memory.efi v19 RT  (usb-d)  125450 bytes  [F1 ANCHOR BUILD - UNCHANGED]
         SHA256 $SHA_RT
         memory.efi v19 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v25.ps1
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v19 driver guard 125450 + v25 script marker
         + v18/v17 stale-driver detection)
         SHA256 $SHA_BAT
Change : SCRIPT v25 = v24 + the selftest fixture fix. The v24 field
         run (2026-09-26 04:07) aborted AT the selftest gate - by
         design: its canonical-kernel-base fixture was hand-assembled
         wrong (00 00 10 80 FF FF FF FF encodes 0xFFFFFFFF80100000,
         not 0xFFFF800010000000), the gate refused to touch the
         driver (zero [RD], no crash). v25 DERIVES the fixture bytes
         from the decimal literal itself; the audit now emulates
         every selftest fixture sequentially (fixture <-> literal <->
         label). K/L/J steps byte-identical to v24. DRIVER UNTOUCHED.
Require: replace usb-d\trigger-test-v25.ps1 (delete old v24) +
         phase-d.bat. memory.efi v19 RT (125450) stays as-is if
         already placed by the v24 package.
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/7] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v19.zip" "$BASE/download/infinity-v25-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v19.zip" "$(basename "$PKGDIR")"
SWAP=$BASE/build/v25-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v25.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V25-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v25-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v19.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v25-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/7] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v19.zip infinity-v25-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] || { echo "FATAL: mirror mismatch for $Z"; exit 1; }
  echo "  PASS  $Z mirrored hash-identical ($(stat -c%s "$BASE/download/$Z") bytes)"
done
echo
echo "V25 PACKAGE BUILD: ALL STEPS PASS"
