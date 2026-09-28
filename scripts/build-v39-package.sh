#!/bin/bash
# ============================================================================
# build-v39-package.sh - build the v39 field kit (driver v27 - A REAL
# GENERATION CHANGE + script v39 - THE WALK kit, F4 attempt 6):
#   1. GUARDS: the v27 binary hashes + sizes, the v39 script audit
#      (~120 checks incl. THE op-12 un-retirement: exactly 6 sends +
#      the 96B payload decode + THE LIVE-CR3 IDENTITY), the bat audits,
#      ps-structcheck, the REAL-DATA functional test (PS cast semantics:
#      the phantom-chunk reproduced + the Floor fix + the P-ladder
#      decode + the v34 wire identity), the host test 103/103, BOTH
#      class-kills (the old-formula death replay + the S1-redacted)
#   2. infinity-v39-swap.zip (THE 4-FILE SWAP: usb-d/memory.efi v27-RT +
#      usb-d/trigger-test-v39.ps1 + phase-d.bat + README-V39-FA.md +
#      VERSION.txt) - the driver CHANGES this time
#   3. infinity-qemu-test-v27.zip (the full bundle on the v26e template:
#      v27 driver everywhere, trigger v39 in all 3 locations, the new
#      bat + README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v26e.zip  # the v26e full bundle = template
SWAP=download/infinity-v39-swap.zip
FULL=download/infinity-qemu-test-v27.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/5] GUARDS: the v27 binaries + the v39 audits"
RT=patches/v27-memory-RT.efi
SAFE=patches/v27-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "141041" ]   || { echo "FATAL: v27-RT size $(stat -c%s $RT) != 141041"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v27-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v27-RT   sha256 $RT_SHA"
echo "   v27-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "e13f9f24b9b5b9df2f68c19a8a713b75dd2b09833d00d0ce5af8802911c5ecaf" ] \
  || { echo "FATAL: v27-RT hash drift"; exit 1; }
[ "$SAFE_SHA" = "3ce751014190607f90a52c56f5b12332b724c3e4761c39ca525b7cc44deba737" ] \
  || { echo "FATAL: v27-SAFE hash drift"; exit 1; }
echo "   v27-SAFE hash verified (banner-only vs v26-SAFE)"

# the v39 script audit + structcheck + functional test
python3 scripts/audit-v39-ps1.py | tail -1
python3 scripts/ps-structcheck.py patches/trigger-test-v39.ps1 | tail -1
python3 scripts/test-v39-functional.py > /dev/null && echo "   REAL-DATA functional test (PS cast + P-decode + wire): PASS"
# the bat audits
python3 scripts/audit-bat-parens.py patches/phase-d-v39.bat | tail -1
# *** THE FLIPPED CLASS-CHECK: op-12 sends == 6 (UN-RETIRED with v27) ***
N12=$(grep -a -c "New-Req 0x1A0[1-6] 12 " patches/trigger-test-v39.ps1 || true)
[ "${N12:-0}" = "6" ] || { echo "FATAL: expected 6 op-12 P-sends, found $N12"; exit 1; }
echo "   op-12 P-sends: 6 (UN-RETIRED - the v27 engine, [PT]-traced)"
# *** THE v39 target checks ***
grep -q -F -- '[int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)' patches/trigger-test-v39.ps1 \
  || { echo "FATAL: the chunk-math Floor fix missing"; exit 1; }
grep -q -F -- '$total    = [int]((' patches/trigger-test-v39.ps1 \
  && { echo "FATAL: the bare [int]( cast form survived"; exit 1; }
grep -q -F -- '$pIdentityOk = ($selfFrame -ne 0) -and ($selfFrame -eq $liveFrame)' patches/trigger-test-v39.ps1 \
  || { echo "FATAL: THE LIVE-CR3 IDENTITY check missing"; exit 1; }
grep -q -F -- '>>> F4 PROVEN: PAGE-TABLE TRANSLATION VIA THE SELFMAP - GROUND-TRUTHED BY THE LIVE-CR3 IDENTITY <<<' patches/trigger-test-v39.ps1 \
  || { echo "FATAL: the F4 PROVEN verdict missing"; exit 1; }
grep -q -F -- '$P1.Data.Length -ge 96' patches/trigger-test-v39.ps1 \
  || { echo "FATAL: the 96B payload gate missing"; exit 1; }
echo "   Floor fix + the identity + the F4 verdict + 96B payload: PRESENT"

# the host test (103/103) + BOTH class-kills against the CURRENT tree
echo "== [1b/5] the host test + the class-kills"
g++ -std=c++11 -I build-v20-tree/UEFI/include -o "$STAGE/host27" scripts/host-test-v27.c
"$STAGE/host27" | tail -1
grep -q "103 PASS / 0 FAIL" <("$STAGE/host27" | tail -1) || { echo "FATAL: host-test not 103/103"; exit 1; }
# class-kill (a): the OLD-FORMULA v25 engine vs the true-semantics world
mkdir -p "$STAGE/v25old"
cp scripts/v25-PageTableWalk.h "$STAGE/v25old/PageTableWalk.h"
cat >> "$STAGE/v25old/PageTableWalk.h" <<'EOF'

// ==== TEST-SIDE SHIMS (class-kill build only; walk logic 100% v25) ====
namespace UEFIBridge { namespace pt {
static inline u64 PdeBaseOf(u64 pte_base, u32 s) { return pte_base + ((u64)s << 30); }
static inline u64 PpeBaseOf(u64 pte_base, u32 s) { return PdeBaseOf(pte_base, s) + ((u64)s << 21); }
static inline u64 PxeBaseOf(u64 pte_base, u32 s) { return PpeBaseOf(pte_base, s) + ((u64)s << 12); }
}} // namespace
EOF
g++ -std=c++11 -I "$STAGE/v25old" -I build-v20-tree/UEFI/include -o "$STAGE/host25old" scripts/host-test-v26.c
set +e
OLD_OUT=$("$STAGE/host25old" 2>&1); OLD_RC=$?
set -e
if [ "$OLD_RC" = "2" ] && echo "$OLD_OUT" | grep -q "PT_R8 OUT-OF-MAP read at 0xffffd58000000d58"; then
  echo "   class-kill (a) PROVEN: the v25 engine dies at 0xffffd58000000d58 (the field BSOD replayed)"
else
  echo "FATAL: old-formula class-kill did not reproduce"; exit 1
fi
# class-kill (b): the S1-redacted constants
mkdir -p "$STAGE/v27bad"
cp build-v20-tree/UEFI/include/{KernelExports.h,ProcessWalk.h,PageTableWalk.h} "$STAGE/v27bad/"
[ "$(grep -c '0xCFB358, 0xCFA358,' "$STAGE/v27bad/PageTableWalk.h")" = "1" ] \
  || { echo "FATAL: redact anchor not unique"; exit 1; }
sed -i 's/0xCFB358, 0xCFA358,/0x1, 0x2,/' "$STAGE/v27bad/PageTableWalk.h"
grep -q -- '0x1, 0x2,' "$STAGE/v27bad/PageTableWalk.h" \
  || { echo "FATAL: the redaction did not apply"; exit 1; }
echo "   S1-redacted header built (wrong MmPteBase constants)"
g++ -std=c++11 -I "$STAGE/v27bad" -o "$STAGE/host27bad" scripts/host-test-v27.c
set +e
CK_OUT=$("$STAGE/host27bad" 2>&1)
set -e
N_PT_FAIL=$(echo "$CK_OUT" | grep -cE 'FAIL  T(2[4-9]|3[0-9]|4[01])')
if [ "${N_PT_FAIL:-0}" -ge 5 ]; then
  echo "   class-kill (b) PROVEN: the redacted header fails $N_PT_FAIL PT checks"
else
  echo "FATAL: class-kill does not catch wrong S1 constants"; exit 1
fi

echo "== [2/5] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v39.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v39.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [3/5] build the swap package (THE 4-FILE SWAP - the driver CHANGES)"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v39.ps1     "$STAGE/swap/usb-d/trigger-test-v39.ps1"
cp patches/phase-d-v39.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V39-FA.md         "$STAGE/swap/README-V39-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v39 / F4 ATTEMPT 6 - THE WALK (2026-09-28) - driver v27 + script v39
Driver : memory.efi v27 RT  141041 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         *** THE DRIVER CHANGES THIS TIME - COPY IT OVER usb-d\memory.efi ***
         v27 = chain B (the _MMPFN deref behind BOTH F4-era BSODs) DELETED
         from the binary + [PT] serial traces BEFORE every PTE-space read +
         the LIVE-CR3 identity + the op-12 payload 80->96B (additive:
         liveCr3@80 + selfEntry@88). Host-proven 103/103 (incl. the
         poison-immunity kill + the old-formula class-kill + the s=0x1FF
         edge); bench RT 13/13 + SAFE.
         v26-RT = 140582 (the 13-green workhorse - clean REFUSE in this
         kit: its op-12 answers 80B, the P-ladder needs the 96B tail).
         v25-RT = 141154 (THE F4 BSOD BINARY - DO NOT RUN).
Script : trigger-test-v39.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         THE WALK ITSELF (op-12 UN-RETIRED with the v27 engine): the
         P-ladder (P1 pe_base + THE LIVE IDENTITY, P2 EPROCESS, P3 KUSD,
         P4 IDT, P5/P6 negatives, P7 the System-DTB cross-check, P8 the
         two-PML4 informational) + THE CHUNK-MATH FIX (v38's only flaw:
         [int] cast ROUNDS -> phantom chunk 158 -> "PARTIAL 157/158"
         over a complete dump; [Math]::Floor fixes it -> the dump
         completes + the in-script pre-scan finally runs). Everything
         else byte-identical to the field-proven v38.
Bat    : phase-d.bat SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
         The SIX-way hash guard: v27 GO / v26 refuse-obsolete / v25
         DO-NOT-RUN / v24 / v23 / v22 / unknown. The script marker check
         demands 'trigger test v39'.
Change : THE FULL 3-FILE SWAP: usb-d\memory.efi (v27!) +
         usb-d\trigger-test-v39.ps1 + phase-d.bat.
Send   : the output .txt + serial + boot/PS photos + the dump trio
         (ntoskrnl-almostro-*.bin/.manifest.txt/.marker - all land on
         the Desktop next to the transcript).
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [4/5] build the FULL bundle (v27 driver everywhere + the v39 kit)"
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
cp patches/trigger-test-v39.ps1 "$STAGE/full/trigger-test-v39.ps1"
cp patches/trigger-test-v39.ps1 "$STAGE/full/transfer/trigger-test-v39.ps1"
cp patches/trigger-test-v39.ps1 "$STAGE/full/usb-d/trigger-test-v39.ps1"
cp patches/phase-d-v39.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V39-FA.md     "$STAGE/full/README-V39-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "141041" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "141041" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v39" "$STAGE/full/usb-d/trigger-test-v39.ps1"
grep -q "trigger-test-v39.ps1" "$STAGE/full/phase-d.bat"
grep -q "e13f9f24" "$STAGE/full/phase-d.bat"
grep -q "c8f79b95" "$STAGE/full/phase-d.bat"
grep -q "022e6d1c" "$STAGE/full/phase-d.bat"
# *** the in-zip v39-specific asserts: the fix must be INSIDE the shipped zip ***
grep -q -F -- '[int][Math]::Floor(($dataVs + $chunkSz - 1) / $chunkSz)' "$STAGE/full/usb-d/trigger-test-v39.ps1" \
  || { echo "FATAL: the Floor fix missing inside the shipped zip"; exit 1; }
grep -q -F -- '$pIdentityOk' "$STAGE/full/usb-d/trigger-test-v39.ps1" \
  || { echo "FATAL: the identity missing inside the shipped zip"; exit 1; }
grep -q "New-Req 0x1A01 12 " "$STAGE/full/usb-d/trigger-test-v39.ps1" \
  || { echo "FATAL: the P-ladder send missing inside the shipped zip"; exit 1; }
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v39.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [5/5] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v39-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v27.zip"
cmp -s "$SWAP" "$ARCH/infinity-v39-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v27.zip" \
  && echo "   mirrors hash-identical"

echo
echo "== FINAL REPORT =="
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B) - THE 4-FILE SWAP (driver + script + bat + README)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v27-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
