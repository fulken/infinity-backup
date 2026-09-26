#!/bin/bash
# build-v27-package.sh — assemble infinity-qemu-test-v20.zip (full stick
# bundle: v20 driver + v27 script) + infinity-v27-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v26-package.sh; differences:
#   - DRIVER UNCHANGED: v20 RT (128010, field-proven convergent in v26)
#   - script = trigger-test-v27.ps1 (the L2b read-back fix: the InfinityData
#     buffer 64 -> 4096 = the driver cap; the Win32=122 class is dead)
#   - bat = phase-d-v20.bat retargeted to v27 refs (guards UNTOUCHED)
#   - README = README-V27-FA.md
#   - the build runs audit-v27-ps1.py FIRST and refuses on failure
#   - audit-bat-parens.py runs on the packaged bat (the v25 field incident)
#   - NEW GUARD: the 4096 data buffer must be in the shipped script and no
#     undersized data-path buffer may exist (the v26 field incident class)
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v20
SCR=$BASE/infinity-qemu-test/trigger-test-v27.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v20.bat
DOC=$BASE/infinity-qemu-test/README-V27-FA.md
RT=$BASE/patches/v20-memory-RT.efi
SAFE=$BASE/patches/v20-memory-SAFE.efi

echo "== [0/8] audits - refuse to package on failure =="
python3 "$BASE/scripts/audit-v27-ps1.py" | tail -2
python3 "$BASE/scripts/audit-bat-parens.py" "$BAT"

echo "== [1/8] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/8] binaries (v20 - UNCHANGED, the v26 field-proven convergent build) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/8] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v27.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V27-FA.md"
sed -i 's/package v9+/package v20+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/8] guard simulations =="
grep -q "trigger test v27" "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v27' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v27.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "128010" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 128010 (v20-RT)"; exit 1; }
echo "  PASS  usb-d memory.efi = 128010 bytes (v20-RT, field-proven in v26)"
grep -q "128010" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v20 size guard"; exit 1; }
grep -q '"125450"' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v19 stale-driver detection"; exit 1; }
grep -q 'trigger-test-v27.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v27 script"; exit 1; }
grep -q 'trigger test v27' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not check the v27 marker"; exit 1; }
echo "  PASS  phase-d.bat: size guard 128010 + v19/v18/v17 detection + v27 refs"
# THE V27 CLASS-KILL: the read-back buffer must be the driver cap
grep -q '\$db = New-Object byte\[\] 4096' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: the 4096 data read-back buffer missing"; exit 1; }
if grep -q '\$db = New-Object byte\[\] 64' "$PKGDIR/usb-d/trigger-test-v27.ps1"; then
  echo "FATAL: an undersized data-path buffer is still present"; exit 1
fi
echo "  PASS  the L2b class-kill: data read-back buffer = 4096 (the driver cap)"
# the F1 core promises: op-9 anchors request + L reads + verdicts
grep -q "New-Req 0x1701 9 '00000000' 32 '0000000000000000'" "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: K anchors request (op 9) missing"; exit 1; }
grep -q 'F1 PROVEN: ANCHORS CONVERGED' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: F1 PROVEN verdict missing"; exit 1; }
grep -q 'F1 FAIL-CLOSED' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: F1 FAIL-CLOSED verdict missing"; exit 1; }
grep -qF '($peBase - [uint64]0x1000)' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: L4 below-range address math missing"; exit 1; }
grep -qF '$L2b.Data.Length -ge 0x58' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: L2b length gate missing"; exit 1; }
echo "  PASS  K (op 9) + L verdicts + L2b 0x58 gate + L4/L5 range negatives present"
# the J regression must be intact
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = 'FFFFF78000000260'" "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: ladder J2 kernel-alias address missing"; exit 1; }
echo "  PASS  J-ladder regression addresses intact"
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v27.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  v22 slip still eradicated"
# the v25 fixture fix must survive
grep -q 'for (\$i = 0; \$i -lt 8; \$i++) { \$stU64\[\$i\] = \[byte\]((\$stBase -shr (8 \* \$i)) -band 0xFF) }' \
  "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: the v25 derived-fixture loop missing"; exit 1; }
grep -q '\$stBase = \[uint64\]18446603336489631744' "$PKGDIR/usb-d/trigger-test-v27.ps1" \
  || { echo "FATAL: the canonical-base decimal literal missing"; exit 1; }
echo "  PASS  v25 fixture fix survives (derived from the literal)"
if find "$PKGDIR" -name 'trigger-test-v2[0123456].ps1' | grep -q .; then
  echo "FATAL: stale v20..v26 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[0123456].ps1'; exit 1
fi
echo "  PASS  no stale v20..v26 scripts in the bundle"
# driver lineage: v20-RT hash must equal the vaulted patches/ binary
A=$(sha256sum "$RT" | awk '{print $1}'); B=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print $1}')
[ "$A" = "$B" ] || { echo "FATAL: usb-d driver hash != patches/v20-memory-RT.efi"; exit 1; }
echo "  PASS  usb-d driver hash-identical to patches/v20-memory-RT.efi (the v26 field-proven binary)"
# bat paren safety (the v25 field incident class)
python3 "$BASE/scripts/audit-bat-parens.py" "$PKGDIR/phase-d.bat"

echo "== [5/8] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v27.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v20 (2026-09-26, script kit v27)
Driver : memory.efi v20 RT  (usb-d)  128010 bytes  [UNCHANGED - FIELD-PROVEN
         CONVERGENT in the v26 run: the containing-walk skipped the v25
         nested PE and unlocked the TRUE ntoskrnl range]
         SHA256 $SHA_RT
         memory.efi v20 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v27.ps1
         SHA256 $SHA_SCR
Bat    : phase-d.bat (v20 driver guard 128010 + v27 script marker
         + v19/v18/v17 stale-driver detection + paren-audited)
         SHA256 $SHA_BAT
Change : SCRIPT v27 = the L2b read-back fix. The v26 field run CONVERGED
         (K state=1 reason=0, L1 MZ + L2a green, J regression 100%, zero
         crashes) but the script read L2b's 88-byte PE header back through
         a 64-BYTE buffer -> Win32=122 (ERROR_INSUFFICIENT_BUFFER) -> the
         checks never saw the bytes the driver HAD delivered (serial [RD]
         va=0xFFFFF8046BC00118 ok=1) -> verdict F1 PARTIAL. v27 sizes the
         read-back buffer to the DRIVER CAP (4096): the class is dead.
         DRIVER v20 UNTOUCHED (sha256 identical to the field-proven run).
Require: REPLACE usb-d\trigger-test-v27.ps1 (delete v26) + phase-d.bat.
         memory.efi STAYS (128010 - unchanged this time).
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/8] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v20.zip" "$BASE/download/infinity-v27-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v20.zip" "$(basename "$PKGDIR")"
SWAP=$BASE/build/v27-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v27.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V27-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v27-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v20.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v27-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/8] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v20.zip infinity-v27-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] || { echo "FATAL: mirror mismatch for $Z"; exit 1; }
  echo "  PASS  $Z mirrored hash-identical ($(stat -c%s "$BASE/download/$Z") bytes)"
done

echo "== [8/8] verdict =="
echo
echo "V27 PACKAGE BUILD: ALL STEPS PASS"
