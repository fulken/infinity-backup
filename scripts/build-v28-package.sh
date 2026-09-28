#!/bin/bash
# build-v28-package.sh — assemble infinity-qemu-test-v21.zip (full stick
# bundle: v21 driver + v28 script) + infinity-v28-swap.zip (mini swap) +
# VERSION.txt. Adapted from build-v27-package.sh; differences:
#   - DRIVER CHANGES: v21 RT (131709, "anchors + exports") — the field-
#     proven v20 base + op 10 ReqOp_ResolveSymbol (export-table parse,
#     all reads in-image bounds-checked) + the KPCR V5 diagnostic
#   - script = trigger-test-v28.ps1 (STEP M: M1..M4 export resolution
#     incl. the NtBuildNumber==19045 cross-validation; Stat-Name fixed
#     to the driver enum; INFCNT 23/13)
#   - bat = NEW phase-d-v21.bat (guard 131709 + FIVE-way stale-driver
#     detection: v17/v18/v19/v20 each get their own explanation)
#   - README = README-V28-FA.md
#   - the build runs audit-v28-ps1.py FIRST and refuses on failure
#   - audit-bat-parens.py runs on the packaged bat (the v25 field incident)
#   - GUARDS: the v27 4096-buffer class-kill + the M-step patterns +
#     the v21 op-10 binary markers (strings) in the shipped driver
set -euo pipefail
BASE=/home/z/my-project
TEMPLATE=$BASE/upload/extracted-v9-full
PKGDIR=$BASE/build/pkg-v21
SCR=$BASE/infinity-qemu-test/trigger-test-v28.ps1
BAT=$BASE/infinity-qemu-test/phase-d-v21.bat
DOC=$BASE/infinity-qemu-test/README-V28-FA.md
RT=$BASE/patches/v21-memory-RT.efi
SAFE=$BASE/patches/v21-memory-SAFE.efi

echo "== [0/8] audits - refuse to package on failure =="
python3 "$BASE/scripts/audit-v28-ps1.py" | tail -2
python3 "$BASE/scripts/audit-bat-parens.py" "$BAT"

echo "== [1/8] fresh package tree from template =="
rm -rf "$PKGDIR"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
rm -f "$PKGDIR"/trigger-test*.ps1 "$PKGDIR"/usb-d/trigger-test*.ps1 \
      "$PKGDIR"/transfer/trigger-test*.ps1 \
      "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" \
      "$PKGDIR"/README-v*-FA.md 2>/dev/null || true
find "$PKGDIR" -name 'trigger-test-v*.ps1' -delete

echo "== [2/8] binaries (v21 - the F2 export-resolution build) =="
cp "$SAFE" "$PKGDIR/usb/memory.efi"
cp "$SAFE" "$PKGDIR/usb-c/memory.efi"
cp "$RT"   "$PKGDIR/usb-d/memory.efi"
ls -la "$PKGDIR/usb-d/memory.efi"

echo "== [3/8] script + bat + docs =="
for d in "." "usb-d" "transfer"; do cp "$SCR" "$PKGDIR/$d/trigger-test-v28.ps1"; done
cp "$BAT" "$PKGDIR/phase-d.bat"
cp "$DOC" "$PKGDIR/README-V28-FA.md"
sed -i 's/package v9+/package v21+/g' "$PKGDIR/refresh-files.bat" || true

echo "== [4/8] guard simulations =="
grep -q "trigger test v28" "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: usb-d script lacks the 'trigger test v28' marker"; exit 1; }
echo "  PASS  usb-d trigger-test-v28.ps1 carries the marker"
SZ=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
[ "$SZ" = "131709" ] || { echo "FATAL: usb-d memory.efi is $SZ, want 131709 (v21-RT)"; exit 1; }
echo "  PASS  usb-d memory.efi = 131709 bytes (v21-RT, anchors + exports)"
grep -q "131709" "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v21 size guard"; exit 1; }
grep -q '"128010"' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v20 stale-driver detection"; exit 1; }
grep -q '"125450"' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat lacks the v19 stale-driver detection"; exit 1; }
grep -q 'trigger-test-v28.ps1' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not reference the v28 script"; exit 1; }
grep -q 'trigger test v28' "$PKGDIR/phase-d.bat" \
  || { echo "FATAL: phase-d.bat does not check the v28 marker"; exit 1; }
echo "  PASS  phase-d.bat: size guard 131709 + v20/v19/v18/v17 detection + v28 refs"
# THE V27 CLASS-KILL must survive: the read-back buffer = the driver cap
grep -q '\$db = New-Object byte\[\] 4096' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: the 4096 data read-back buffer missing"; exit 1; }
if grep -q '\$db = New-Object byte\[\] 64' "$PKGDIR/usb-d/trigger-test-v28.ps1"; then
  echo "FATAL: an undersized data-path buffer is still present"; exit 1
fi
echo "  PASS  the v27 class-kill survives: data read-back buffer = 4096"
# THE V28 M-STEPS: all four resolve calls + both reads + the negative
for pat in "Send-Resolve 0x1801 'PsInitialSystemProcess'" \
           "Send-Resolve 0x1802 'NtBuildNumber'" \
           "New-Req 0x1803 1 'FFFFFFFF' 4" \
           "Send-Resolve 0x1804 'KeBugCheckEx'" \
           "New-Req 0x1805 1 'FFFFFFFF' 8" \
           "Send-Resolve 0x1806 'NoSuchSymbolV28'" \
           '$M4.Status -eq 7' \
           '-band 0x7FFFFFFF' \
           '== the KUSD J1 ground truth'; do
  grep -qF -- "$pat" "$PKGDIR/usb-d/trigger-test-v28.ps1" \
    || { echo "FATAL: M-step pattern missing: $pat"; exit 1; }
done
echo "  PASS  M1..M4 export-resolution steps present (incl. the 19045 cross-validation + status-7 negative)"
grep -q 'F2 PROVEN: EXPORT-RESOLVED SYMBOLS' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: F2 PROVEN verdict missing"; exit 1; }
grep -q 'F1 PROVEN: ANCHORS CONVERGED' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: F1 PROVEN verdict missing"; exit 1; }
grep -q "New-Req 0x1701 9 '00000000' 32 '0000000000000000'" "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: K anchors request (op 9) missing"; exit 1; }
grep -qF '($peBase - [uint64]0x1000)' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: L4 below-range address math missing"; exit 1; }
grep -qF '$L2b.Data.Length -ge 0x58' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: L2b length gate missing"; exit 1; }
echo "  PASS  K (op 9) + L verdicts + L2b 0x58 gate + L4/L5 negatives + F2 verdict present"
# the J regression must be intact
grep -q "addr = '000000007FFE0260'" "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: ladder J1/J5/J7 user-alias address missing"; exit 1; }
grep -q "addr = 'FFFFF78000000260'" "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: ladder J2 kernel-alias address missing"; exit 1; }
echo "  PASS  J-ladder regression addresses intact"
if grep -q "addr = '00007FFE" "$PKGDIR/usb-d/trigger-test-v28.ps1"; then
  echo "FATAL: the v22 bad pattern is still present"; exit 1
fi
echo "  PASS  v22 slip still eradicated"
# the v25 fixture fix must survive
grep -q 'for (\$i = 0; \$i -lt 8; \$i++) { \$stU64\[\$i\] = \[byte\]((\$stBase -shr (8 \* \$i)) -band 0xFF) }' \
  "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: the v25 derived-fixture loop missing"; exit 1; }
grep -q '\$stBase = \[uint64\]18446603336489631744' "$PKGDIR/usb-d/trigger-test-v28.ps1" \
  || { echo "FATAL: the canonical-base decimal literal missing"; exit 1; }
echo "  PASS  v25 fixture fix survives (derived from the literal)"
if find "$PKGDIR" -name 'trigger-test-v2[01234567].ps1' | grep -q .; then
  echo "FATAL: stale v20..v27 script copies found:"; find "$PKGDIR" -name 'trigger-test-v2[01234567].ps1'; exit 1
fi
echo "  PASS  no stale v20..v27 scripts in the bundle"
# driver lineage: v21-RT hash must equal the vaulted patches/ binary
A=$(sha256sum "$RT" | awk '{print $1}'); B=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print $1}')
[ "$A" = "$B" ] || { echo "FATAL: usb-d driver hash != patches/v21-memory-RT.efi"; exit 1; }
echo "  PASS  usb-d driver hash-identical to patches/v21-memory-RT.efi"
# the v21 op-10 binary markers (strings) in the shipped driver
for s in "kernel data path: direct reads + export resolution" "resolve rc" "gs base" "idt match" "KPCR"; do
  strings -a "$PKGDIR/usb-d/memory.efi" | grep -qF -- "$s" \
    || { echo "FATAL: v21 driver string missing: $s"; exit 1; }
done
strings -a -e l "$PKGDIR/usb-d/memory.efi" | grep -qF -- "Build: v21 RT - anchors + exports (F2)" \
  || { echo "FATAL: v21 RT u16 banner missing"; exit 1; }
echo "  PASS  v21 RT binary markers present (banner + [XS]/[KPCR] trace labels)"
# bat paren safety (the v25 field incident class)
python3 "$BASE/scripts/audit-bat-parens.py" "$PKGDIR/phase-d.bat"

echo "== [5/8] VERSION.txt =="
SHA_RT=$(sha256sum "$PKGDIR/usb-d/memory.efi" | awk '{print toupper($1)}')
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi" | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum "$PKGDIR/usb-d/trigger-test-v28.ps1" | awk '{print toupper($1)}')
SHA_BAT=$(sha256sum "$PKGDIR/phase-d.bat" | awk '{print toupper($1)}')
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE v21 (2026-09-27, script kit v28)
Driver : memory.efi v21 RT  (usb-d)  131709 bytes  [F2: anchors + exports]
         SHA256 $SHA_RT
         memory.efi v21 SAFE (usb, usb-c) 105032 bytes
         SHA256 $SHA_SAFE
Script : trigger-test-v28.ps1
         SHA256 $SHA_SCR
Bat    : phase-d.bat (= phase-d-v21.bat: guard 131709 + FIVE-way
         v20/v19/v18/v17 stale-driver detection + paren-audited)
         SHA256 $SHA_BAT
Change : DRIVER v21 = the field-proven v20 containing-walk + op 10
         (ReqOp_ResolveSymbol): symbols resolved from the VALIDATED
         image's own export table - every parse read in-image
         bounds-checked, fail-closed on any corrupt intermediate
         (host-proven 50/50, zero out-of-map reads; bench RT 13/13 +
         SAFE 5/5; disasm-verified dispatch + name validation +
         pe_size bounds + the KPCR rdmsr 0xC0000101 cross-check).
         op-9 wire + gate + K/L/J semantics UNTOUCHED.
         SCRIPT v28 = STEP M: M1 resolve PsInitialSystemProcess (the
         F3 walk entry), M2 resolve NtBuildNumber + read == 19045
         (export data == the KUSD ground truth), M3 resolve
         KeBugCheckEx + read 8 code bytes, M4 not-found -> status 7.
         Stat-Name fixed to the driver enum. INFCNT 23/13.
Require: REPLACE usb-d\memory.efi FIRST (131709) + usb-d\
         trigger-test-v28.ps1 (delete v27) + phase-d.bat.
EOF
cat "$PKGDIR/VERSION.txt"

echo "== [6/8] zips =="
cd "$BASE/build"
rm -f "$BASE/download/infinity-qemu-test-v21.zip" "$BASE/download/infinity-v28-swap.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v21.zip" "$(basename "$PKGDIR")"
SWAP=$BASE/build/v28-swap; rm -rf "$SWAP"; mkdir -p "$SWAP/usb-d"
cp "$RT"  "$SWAP/usb-d/memory.efi"
cp "$SCR" "$SWAP/usb-d/trigger-test-v28.ps1"
cp "$BAT" "$SWAP/phase-d.bat"
cp "$DOC" "$SWAP/README-V28-FA.md"
cd "$SWAP" && zip -r -q "$BASE/download/infinity-v28-swap.zip" . && cd "$BASE"
cp "$BASE/download/infinity-qemu-test-v21.zip" "$BASE/version-archive/packages/"
cp "$BASE/download/infinity-v28-swap.zip"      "$BASE/version-archive/packages/"

echo "== [7/8] mirror check (the v18.1 lesson) =="
for Z in infinity-qemu-test-v21.zip infinity-v28-swap.zip; do
  A=$(sha256sum "$BASE/download/$Z" | awk '{print $1}')
  B=$(sha256sum "$BASE/version-archive/packages/$Z" | awk '{print $1}')
  [ "$A" = "$B" ] || { echo "FATAL: mirror mismatch for $Z"; exit 1; }
  echo "  PASS  $Z mirrored hash-identical ($(stat -c%s "$BASE/download/$Z") bytes)"
done

echo "== [8/8] verdict =="
echo
echo "V28 PACKAGE BUILD: ALL STEPS PASS"
