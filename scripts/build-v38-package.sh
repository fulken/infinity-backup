#!/bin/bash
# ============================================================================
# build-v38-package.sh - build the v38 field kit (driver v26 UNCHANGED +
# script v38 - THE 0x2E-GUARD-FIX kit: the ALMOSTRO dump that v37 could
# never start):
#   1. GUARDS: the v26 binary hashes (the UNCHANGED field-proven driver,
#      12-times proven after v37), the v38 script audit (169 checks incl.
#      THE op-12 zero-send class-kill + THE NO-0x2E-GUARD checks + the
#      census fallback + the stale-label fix), the v38 bat audits, the
#      REAL-DATA functional test (the fix validated against the ACTUAL
#      v37 field section table), the pre-scan algorithm test (carried)
#   2. infinity-v38-swap.zip (usb-d/memory.efi v26-RT [identical] +
#      usb-d/trigger-test-v38.ps1 + phase-d.bat + README-V38-FA.md +
#      VERSION.txt) - the 2-file swap (memory.efi is byte-identical)
#   3. infinity-qemu-test-v26e.zip (the full bundle on the v26 package
#      template: v26 driver everywhere, trigger v38 in all 3 locations,
#      the new bat + README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v26.zip   # the v26 full bundle = template
SWAP=download/infinity-v38-swap.zip
FULL=download/infinity-qemu-test-v26e.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/5] GUARDS: the UNCHANGED v26 binaries + the v38 audits"
RT=patches/v26-memory-RT.efi
SAFE=patches/v26-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "140582" ]   || { echo "FATAL: v26-RT size $(stat -c%s $RT) != 140582"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v26-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v26-RT   sha256 $RT_SHA (UNCHANGED - the 12-times-field-proven binary)"
echo "   v26-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb" ] \
  || { echo "FATAL: v26-RT hash drift"; exit 1; }
[ "$SAFE_SHA" = "ab3659b08bd6b2f672b6a464f639c42ac1777428b70c226a022e53d64e9f8bfd" ] \
  || { echo "FATAL: v26-SAFE hash drift"; exit 1; }
# the shipped swap driver must equal the field-run v26c-kit driver bit-for-bit
cmp -s "$RT" <(unzip -p "$BASE" usb-d/memory.efi) \
  || { echo "FATAL: patches/v26-RT != the v26-kit template driver"; exit 1; }
python3 scripts/audit-v38-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v38.bat | tail -1
python3 scripts/ps-structcheck.py patches/trigger-test-v38.ps1 | tail -1
python3 scripts/test-v38-functional.py > /dev/null && echo "   REAL-DATA functional test (v37 field table): PASS"
python3 scripts/test-v37-prescan.py > /dev/null && echo "   pre-scan algorithm test (carried, unchanged): PASS"
# THE class-kill of this kit: op-12 must appear ZERO times as a send
N12=$(grep -a -c "New-Req \$seqR 12\|New-Req 0x1[0-9A-Fa-f]* 12\|New-Req (New-Req.* 12 " patches/trigger-test-v38.ps1 || true)
[ "${N12:-0}" = "0" ] || { echo "FATAL: $N12 op-12 sends found in the v38 script"; exit 1; }
echo "   op-12 sends in the script: 0 (STILL RETIRED - the class-kill)"
# *** THE v38 target checks: the guard GONE + the census + the target ***
grep -q -- "-eq 'ALMOSTRO'" patches/trigger-test-v38.ps1 || { echo "FATAL: ALMOSTRO filter missing"; exit 1; }
grep -q -- "-eq 0x2E" patches/trigger-test-v38.ps1 && { echo "FATAL: the 0x2E first-byte guard SURVIVED"; exit 1; }
grep -q "THE 0x2E-GUARD FIX" patches/trigger-test-v38.ps1 || { echo "FATAL: guard-fix comment missing"; exit 1; }
grep -q "\[D2\] census of all" patches/trigger-test-v38.ps1 || { echo "FATAL: census fallback missing"; exit 1; }
grep -q "no .data section / bounds" patches/trigger-test-v38.ps1 && { echo "FATAL: the stale .data skip label survived"; exit 1; }
grep -q "ntoskrnl-almostro" patches/trigger-test-v38.ps1 || { echo "FATAL: dump basename missing"; exit 1; }
grep -q '\$r9Base = 0xCFC4C0' patches/trigger-test-v38.ps1 || { echo "FATAL: R9 window missing"; exit 1; }
grep -q 'LATTICE WINDOW dump' patches/trigger-test-v38.ps1 || { echo "FATAL: pre-scan lattice print missing"; exit 1; }
echo "   THE GUARD FIX + census + ALMOSTRO target + R9 + pre-scan: PRESENT"

echo "== [2/5] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v38.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v38.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [3/5] build the swap package (the 2-file swap; memory.efi identical)"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v38.ps1     "$STAGE/swap/usb-d/trigger-test-v38.ps1"
cp patches/phase-d-v38.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V38-FA.md         "$STAGE/swap/README-V38-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v38 / F4-ALMOSTRO-dump-fix (2026-09-28) - DRIVER v26 UNCHANGED + script v38
Driver : memory.efi v26 RT  140582 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         UNCHANGED from the v34/v35/v36/v37 kits - the SAME 12-times-field-
         proven binary. v38 (like v35/v36/v37) NEVER SENDS op-12 (the op
         that killed the VM twice - both BSODs fingerprint-confirmed as
         chain B's pdb + pfn*0x30 + 8 deref). If your usb-d\memory.efi is
         already the v26 RT (140582 bytes), you do NOT need to recopy it
         - but the swap zip ships it anyway so the stick is always
         self-consistent.
         v25-RT = 141154 (THE FIRST F4 BSOD BINARY - DO NOT RUN).
Script : trigger-test-v38.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         THE 0x2E-GUARD FIX + the ALMOSTRO dump. The v37 run was the 12th
         green regression + R9 live, but its dump never started: a
         v36-era fast-path guard (only '.'-prefixed section names were
         decoded) made the ALMOSTRO match impossible - the section WAS in
         the field-read table (RVA 0xCFB000 VS=0x272E0, proven by
         byte-parsing the v37 transcript). v38 removes the guard (every
         name decoded - the fix, validated offline against the REAL v37
         field table: v38 logic finds it, v37 logic provably cannot) +
         a census fallback (on any name miss the transcript alone lists
         ALL section names) + the stale .data-era skip label fixed.
         Everything else is byte-identical to the field-run v37: the
         ALMOSTRO dump (~160480 B = 157 chunks, ~4-5 min, resumable,
         image-gated), R9, the in-script PRE-SCAN (candidates + lattice
         windows + 2 echo checks - zero driver reads), op-12 RETIRED.
Bat    : phase-d.bat (the FIVE-way hash guard unchanged: v26 GO /
         v25 REFUSE (the first BSOD binary) / v24 / v23 / v22; the
         script marker check now demands 'trigger test v38'; the
         stale-script taxonomy: v33/v34 = DO-NOT-RUN (op-12 senders),
         v35/v36/v37 = safe but obsolete (v35 gate-refuses the legal
         33; v36 re-dumps the ALREADY-captured .data; v37 SKIPS its
         ALMOSTRO dump on the 0x2E name-guard bug))
         SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : SCRIPT-ONLY. Replace usb-d\trigger-test-v37.ps1 (the v37 script
         produced no .bin - nothing to keep) + phase-d.bat.
         memory.efi is byte-identical to the v34/v35/v36/v37 kits'.
Send   : the output .txt + serial + boot/PS photos + THE DUMP:
         ntoskrnl-almostro-*.bin + ntoskrnl-almostro-*.manifest.txt
         (both land on the Desktop next to the transcript).
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [4/5] build the FULL bundle (v26 driver everywhere + the v38 kit)"
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
cp patches/trigger-test-v38.ps1 "$STAGE/full/trigger-test-v38.ps1"
cp patches/trigger-test-v38.ps1 "$STAGE/full/transfer/trigger-test-v38.ps1"
cp patches/trigger-test-v38.ps1 "$STAGE/full/usb-d/trigger-test-v38.ps1"
cp patches/phase-d-v38.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V38-FA.md     "$STAGE/full/README-V38-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "140582" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "140582" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v38" "$STAGE/full/usb-d/trigger-test-v38.ps1"
grep -q "trigger-test-v38.ps1" "$STAGE/full/phase-d.bat"
grep -q "c8f79b95" "$STAGE/full/phase-d.bat"
grep -q "022e6d1c" "$STAGE/full/phase-d.bat"
grep -q "DO NOT RUN v33/v34 SCRIPTS" "$STAGE/full/phase-d.bat"
grep -q -- '-le 96' "$STAGE/full/usb-d/trigger-test-v38.ps1"
grep -q -- "-eq 'ALMOSTRO'" "$STAGE/full/usb-d/trigger-test-v38.ps1"
# *** the in-zip v38-specific asserts: the fix must be INSIDE the shipped zip ***
grep -q -- "-eq 0x2E" "$STAGE/full/usb-d/trigger-test-v38.ps1" && { echo "FATAL: the 0x2E guard inside the shipped zip"; exit 1; }
grep -q "THE 0x2E-GUARD FIX" "$STAGE/full/usb-d/trigger-test-v38.ps1" || { echo "FATAL: guard fix missing inside the shipped zip"; exit 1; }
grep -q "\[D2\] census of all" "$STAGE/full/usb-d/trigger-test-v38.ps1" || { echo "FATAL: census missing inside the shipped zip"; exit 1; }
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v38.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [5/5] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v38-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v26e.zip"
cmp -s "$SWAP" "$ARCH/infinity-v38-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v26e.zip" \
  && echo "   mirrors hash-identical"

echo
echo "== FINAL REPORT =="
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v26-RT sha256: $RT_SHA (UNCHANGED - 6th script run)"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
