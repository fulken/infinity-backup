#!/bin/bash
# build-v26-package.sh — assemble infinity-qemu-test-v20.zip (full stick
# bundle: v20 driver + v26 script) + infinity-v26-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v25-package.sh; differences:
#   - DRIVER CHANGES: v20 RT (128010, the containing-walk) / v20 SAFE (105032)
#   - script = trigger-test-v26.ps1 (v25 logic + v20 K expectations)
#   - bat = phase-d-v20.bat (NEW: guard 128010 + v19/v18/v17 detection)
#   - README = README-V26-FA.md
#   - the build runs audit-v26-ps1.py FIRST and refuses on failure
#   - NEW: audit-bat-parens.py runs on the packaged bat (the v25 field
#     incident: unescaped paren inside an if-block closed the cmd window;
#     the user fixed it in the field - the class is now machine-gated)
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v20
SCR=$BASE/infinity-qemu-test/trigger-test-v26.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v20.bat
DOC=$BASE/infinity-qemu-test/README-V26-FA.md
RT=$BASE/patches/v20-memory-RT.efi
SAFE=$BASE/patches/v20-memory-SAFE.efi

echo "== [0/8] audits - refuse to package on failure =="
python3 "$BASE/scripts/audit-v26-ps1.py" | tail -2
python3 "$BASE/scripts/audit-bat-parens.py" "$BAT"

echo "== [1/8] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/8] binaries (v20 - THE CONTAINING-WALK BUILD) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/8] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v26.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V26-FA.md"
sed -i 's/package v9+/package v20+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/8] guard simulations =="
grep -q "trigger test v26" "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v26' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v26.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "128010" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 128010 (v20-RT)"; exit 1; }
echo "  PASS  usb-d memory.efi = 128010 bytes (v20-RT)"
grep -q "128010" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v20 size guard"; exit 1; }
grep -q '"125450"' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v19 stale-driver detection"; exit 1; }
grep -q 'trigger-test-v26.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v26 script"; exit 1; }
grep -q 'trigger test v26' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not check the v26 marker"; exit 1; }
echo "  PASS  phase-d.bat: size guard 128010 + v19/v18/v17 detection + v26 refs"
# the F1 core promises: op-9 anchors request + L reads + verdicts
grep -q "New-Req 0x1701 9 '00000000' 32 '0000000000000000'" "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: K anchors request (op 9) missing"; exit 1; }
grep -q 'F1 PROVEN: ANCHORS CONVERGED' "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: F1 PROVEN verdict missing"; exit 1; }
grep -q 'F1 FAIL-CLOSED' "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: F1 FAIL-CLOSED verdict missing"; exit 1; }
grep -q '(\$peBase - \[uint64\]0x1000)' "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: L4 below-range address math missing"; exit 1; }
grep -q 'EXPECTED with v20' "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: the v20 K expectation text missing"; exit 1; }
echo "  PASS  K (op 9) + L verdicts + L4/L5 range negatives + v20 expectations present"
# the J regression must be intact
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = 'FFFFF78000000260'" "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: ladder J2 kernel-alias address missing"; exit 1; }
echo "  PASS  J-ladder regression addresses intact"
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v26.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  v22 slip still eradicated"
# the v25 fixture fix must survive
grep -q 'for (\$i = 0; \$i -lt 8; \$i++) { \$stU64\[\$i\] = \[byte\]((\$stBase -shr (8 \* \$i)) -band 0xFF) }' \
  "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: the v25 derived-fixture loop missing"; exit 1; }
grep -q '\$stBase = \[uint64\]18446603336489631744' "$PKGDIR/usb-d/trigger-test-v26.ps1" \
  || { echo "FATAL: the canonical-base decimal literal missing"; exit 1; }
echo "  PASS  v25 fixture fix survives (derived from the literal)"
if find "$PKGDIR" -name 'trigger-test-v2[012345].ps1' | grep -q .; then
  echo "FATAL: stale v20..v25 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[012345].ps1'; exit 1
fi
echo "  PASS  no stale v20..v25 scripts in the bundle"
# driver lineage: v20-RT hash must equal the vaulted patches/ binary
A=$(sha256sum "$RT" | awk '{print $1}'); B=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print $1}')
[ "$A" = "$B" ] || { echo "FATAL: usb-d driver hash != patches/v20-memory-RT.efi"; exit 1; }
echo "  PASS  usb-d driver hash-identical to patches/v20-memory-RT.efi"
# bat paren safety (the v25 field incident class)
python3 "$BASE/scripts/audit-bat-parens.py" "$PKGDIR/phase-d.bat"

echo "== [5/8] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v26.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v20 (2026-09-26)
Driver : memory.efi v20 RT  (usb-d)  128010 bytes  [THE CONTAINING-WALK]
         SHA256 $SHA_RT
         memory.efi v20 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v26.ps1
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v20 driver guard 128010 + v26 script marker
         + v19/v18/v17 stale-driver detection + paren-audited)
         SHA256 $SHA_BAT
Change : DRIVER v20 = v19 + the containing-walk. The v25 field run
         proved the whole stack EXCEPT convergence: all three walks
         agreed on a NESTED PE (0xFFFFF8046BD60000) that does not
         contain the anchors, and V4 containment correctly
         fail-closed (reason=6, zero crashes). v20 accepts a walk
         candidate only if the image CONTAINS the anchor; false PEs
         are skipped + counted ([AN] walk vN skipped/lastskip lines).
         SCRIPT v26 = v25 logic + the v20 K expectations (converged
         is now the EXPECTED outcome). Host-proven 42/42 incl. the
         exact v25 field replay; bench RT 13/13 + SAFE 5/5.
Require: REPLACE usb-d\memory.efi (v20-RT 128010 - the driver
         changes this time!) + usb-d\trigger-test-v26.ps1 (delete
         v25) + phase-d.bat.
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/8] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v20.zip" "$BASE/download/infinity-v26-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v20.zip" "$(basename "$PKGDIR")"
SWAP=$BASE/build/v26-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v26.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V26-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v26-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v20.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v26-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/8] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v20.zip infinity-v26-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] || { echo "FATAL: mirror mismatch for $Z"; exit 1; }
  echo "  PASS  $Z mirrored hash-identical ($(stat -c%s "$BASE/download/$Z") bytes)"
done

echo "== [8/8] verdict =="
echo
echo "V26 PACKAGE BUILD: ALL STEPS PASS"
