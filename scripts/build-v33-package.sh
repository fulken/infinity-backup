#!/bin/bash
# ============================================================================
# build-v33-package.sh - build the v33 field kit (driver v25 + script v33):
#   1. GUARDS: the v25 driver hashes, the v33 script audit, the bat paren
#      audit, host-test re-run (89/89) + class-kill proof (the test must
#      FAIL on an S1-redacted copy of PageTableWalk.h = a build with wrong
#      MmPteBase constants can never pass)
#   2. infinity-v25-driver-swap.zip (usb-d/memory.efi v25-RT +
#      usb-d/trigger-test-v33.ps1 + phase-d.bat + README-V33-FA.md +
#      VERSION.txt)
#   3. infinity-qemu-test-v25.zip (full bundle on the v24 package template,
#      driver v25 everywhere, trigger v33 in all 3 locations, new bat +
#      README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v24.zip   # the v24 full bundle = template
SWAP=download/infinity-v25-driver-swap.zip
FULL=download/infinity-qemu-test-v25.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/7] GUARDS: the v25 binaries + the v33 audits"
RT=patches/v25-memory-RT.efi
SAFE=patches/v25-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "141154" ]   || { echo "FATAL: v25-RT size $(stat -c%s $RT) != 141154"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v25-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v25-RT   sha256 $RT_SHA"
echo "   v25-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "022e6d1c01fb7de7704182bcf230062905c58f5d8677e1b75cdd0582609b398b" ] \
  || { echo "FATAL: v25-RT hash drift"; exit 1; }
[ "$SAFE_SHA" = "92fe71ea2c283d5cad2e582e3aca0bae9451388d5c5d5a7e2f2209306d426817" ] \
  || { echo "FATAL: v25-SAFE hash drift"; exit 1; }
cmp -s "$RT" build-v20-tree/UEFI/build/build/memory.efi \
  || { echo "FATAL: RT != current tree build (rebuild RT: make RT=1)"; exit 1; }
python3 scripts/audit-v33-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v33.bat | tail -1

echo "== [2/7] host-test re-run (89/89) + class-kill proof (S1-redacted)"
g++ -std=c++11 -I build-v20-tree/UEFI/include -o "$STAGE/host25" scripts/host-test-v25.c
"$STAGE/host25" | tail -1
grep -q "89 PASS / 0 FAIL" <("$STAGE/host25" | tail -1) || { echo "FATAL: host-test not 89/89"; exit 1; }
mkdir -p "$STAGE/v25bad"
cp build-v20-tree/UEFI/include/{KernelExports.h,ProcessWalk.h,PageTableWalk.h} "$STAGE/v25bad/"
python3 - << PYEOF
import pathlib
t = pathlib.Path('$STAGE/v25bad/PageTableWalk.h').read_text()
old = """    static const u32 kS1PteBaseRvas[kPtS1RvaCount] = {
        0xCFB358, 0xCFA358,
    };"""
new = """    static const u32 kS1PteBaseRvas[kPtS1RvaCount] = {
        0x1, 0x2,
    };"""
assert t.count(old) == 1, 'class-kill anchor not found'
pathlib.Path('$STAGE/v25bad/PageTableWalk.h').write_text(t.replace(old, new))
print('   S1-redacted header built (wrong MmPteBase constants)')
PYEOF
g++ -std=c++11 -I "$STAGE/v25bad" -o "$STAGE/host25bad" scripts/host-test-v25.c
# the redacted binary EXITS 1 BY DESIGN (the PT tests fail) - capture, inspect.
set +e
CK_OUT=$("$STAGE/host25bad" 2>&1)
set -e
echo "   S1-redacted run: $(echo "$CK_OUT" | tail -1)"
N_PT_FAIL=$(echo "$CK_OUT" | grep -cE 'FAIL  T(2[4-9]|3[0-9]|40)')
if [ "${N_PT_FAIL:-0}" -ge 5 ]; then
  echo "   class-kill PROVEN: the redacted header fails $N_PT_FAIL PT checks (wrong constants can never pass)"
else
  echo "FATAL: class-kill does not catch wrong S1 constants ($N_PT_FAIL fails)"; exit 1
fi

echo "== [3/7] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v33.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v33.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [4/7] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v33.ps1     "$STAGE/swap/usb-d/trigger-test-v33.ps1"
cp patches/phase-d-v33.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V33-FA.md         "$STAGE/swap/README-V33-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v33 / F4-page-tables (2026-09-27) - DRIVER v25 + script v33
Driver : memory.efi v25 RT  141154 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         (= v24 + op 12 TranslateVa: VA -> the 4-level page-table walk through
         the SELF-MAP, no CR3 switching, no physical reads, no kernel calls.
         PTE_BASE discovery: chain A = nt!MmPteBase (.data, RVA candidates
         0xCFB358/0xCFA358 from 19 real 19041/19045 PDBs) + the 512-value
         structural check; chain B = the PFN bootstrap (MmPfnDatabase ->
         System CR3 from EPROCESS+0x28 -> _MMPFN.PteAddress -> the
         s-identity); A and B must AGREE. THE TWO-WAY PROOF: PML4E[s] must
         point at the System CR3 frame. Host-tested 89/89 incl. the T26
         drifted-world + T32 absent-parent class-kills; disasm-verified;
         bench A=13/13 B=5/5.)
         v24-RT = 134842 (no page tables: op 12 = ErrUnsupported); this
         file is 141154 = v25. The bat checks size + hash.
Script : trigger-test-v33.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         (the field-run v32 wire + THE CAP-AWARE W2 FIX (the v32 root
         cause: the walk caps at 64 BY DESIGN; compare vs min(live,64))
         + the P ladder P1..P7: op-12 walks + the two-way proof + the
         DTB cross-check (op-11 dtb@1056 == op-12 cr3))
Bat    : phase-d.bat (FOUR-way hash guard: v25 GO / v24 REFUSE (no page
         tables) / v23 REFUSE (missing deref) / v22 REFUSE (export gate))
         SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : DRIVER v25 (replace memory.efi!) + SCRIPT v33 + BAT v33.
         This is a FULL swap, not script-only.
Require: REPLACE usb-d\memory.efi (v25-RT 141154, sha256 022e6d1c...) +
         usb-d\trigger-test-v33.ps1 (delete v32) + phase-d.bat.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [5/7] build the FULL bundle (v25 driver everywhere + v33 kit)"
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
cp patches/trigger-test-v33.ps1 "$STAGE/full/trigger-test-v33.ps1"
cp patches/trigger-test-v33.ps1 "$STAGE/full/transfer/trigger-test-v33.ps1"
cp patches/trigger-test-v33.ps1 "$STAGE/full/usb-d/trigger-test-v33.ps1"
cp patches/phase-d-v33.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V33-FA.md     "$STAGE/full/README-V33-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "141154" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "141154" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v33" "$STAGE/full/usb-d/trigger-test-v33.ps1"
grep -q "trigger-test-v33.ps1" "$STAGE/full/phase-d.bat"
grep -q "022e6d1c" "$STAGE/full/phase-d.bat"
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v33.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [6/7] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v25-driver-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v25.zip"
cmp -s "$SWAP" "$ARCH/infinity-v25-driver-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v25.zip" \
  && echo "   mirrors hash-identical"

echo "== [7/7] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v25-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
