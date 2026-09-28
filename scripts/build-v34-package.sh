#!/bin/bash
# ============================================================================
# build-v34-package.sh - build the v34 field kit (driver v26 + script v34):
#   1. GUARDS: the v26 driver hashes, the v34 script audit, the bat paren
#      audit, host-test re-run (101/101) + BOTH class-kill proofs:
#      (a) the OLD-FORMULA v25 engine must ABORT at 0xffffd58000000d58
#          (= PTE_BASE + s*8 - the EXACT read that BSOD'd the field VM)
#      (b) the S1-redacted constants build must FAIL >= 5 PT checks
#          (wrong MmPteBase RVAs can never pass the harness)
#   2. infinity-v26-driver-swap.zip (usb-d/memory.efi v26-RT +
#      usb-d/trigger-test-v34.ps1 + phase-d.bat + README-V34-FA.md +
#      VERSION.txt)
#   3. infinity-qemu-test-v26.zip (full bundle on the v25 package template,
#      driver v26 everywhere, trigger v34 in all 3 locations, new bat +
#      README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v25.zip   # the v25 full bundle = template
SWAP=download/infinity-v26-driver-swap.zip
FULL=download/infinity-qemu-test-v26.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/7] GUARDS: the v26 binaries + the v34 audits"
RT=patches/v26-memory-RT.efi
SAFE=patches/v26-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "140582" ]   || { echo "FATAL: v26-RT size $(stat -c%s $RT) != 140582"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v26-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v26-RT   sha256 $RT_SHA"
echo "   v26-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb" ] \
  || { echo "FATAL: v26-RT hash drift"; exit 1; }
[ "$SAFE_SHA" = "ab3659b08bd6b2f672b6a464f639c42ac1777428b70c226a022e53d64e9f8bfd" ] \
  || { echo "FATAL: v26-SAFE hash drift"; exit 1; }
cmp -s "$RT" build-v20-tree/UEFI/build/build/memory.efi \
  || { echo "FATAL: RT != current tree build (rebuild RT: make RT=1)"; exit 1; }
python3 scripts/audit-v34-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v34.bat | tail -1

echo "== [2/7] host-test re-run (101/101) + BOTH class-kill proofs"
g++ -std=c++11 -I build-v20-tree/UEFI/include -o "$STAGE/host26" scripts/host-test-v26.c
"$STAGE/host26" | tail -1
grep -q "101 PASS / 0 FAIL" <("$STAGE/host26" | tail -1) || { echo "FATAL: host-test not 101/101"; exit 1; }

# --- class-kill (a): the OLD-FORMULA v25 engine vs the true-semantics world
mkdir -p "$STAGE/v25old"
cp scripts/v25-PageTableWalk.h "$STAGE/v25old/PageTableWalk.h"
cat >> "$STAGE/v25old/PageTableWalk.h" <<'EOF'

// ==== TEST-SIDE SHIMS (the class-kill build only): the level-base
// helpers the v26 test calls directly; the OLD walk logic under test
// stays 100% v25. ====
namespace UEFIBridge { namespace pt {
static inline u64 PdeBaseOf(u64 pte_base, u32 s) {
    return pte_base + ((u64)s << 30);
}
static inline u64 PpeBaseOf(u64 pte_base, u32 s) {
    return PdeBaseOf(pte_base, s) + ((u64)s << 21);
}
static inline u64 PxeBaseOf(u64 pte_base, u32 s) {
    return PpeBaseOf(pte_base, s) + ((u64)s << 12);
}
}} // namespace
EOF
g++ -std=c++11 -I "$STAGE/v25old" -I build-v20-tree/UEFI/include -o "$STAGE/host25old" scripts/host-test-v26.c
set +e
OLD_OUT=$("$STAGE/host25old" 2>&1)
OLD_RC=$?
set -e
echo "   old-engine run: exit=$OLD_RC"
if [ "$OLD_RC" = "2" ] && echo "$OLD_OUT" | grep -q "PT_R8 OUT-OF-MAP read at 0xffffd58000000d58"; then
  echo "   class-kill (a) PROVEN: the v25 engine dies at 0xffffd58000000d58 = PTE_BASE+s*8"
  echo "   - the EXACT read that BSOD'd the field VM (0x50), replayed on the host"
else
  echo "FATAL: old-formula class-kill did not reproduce the field death"; exit 1
fi

# --- class-kill (b): the S1-redacted constants
mkdir -p "$STAGE/v26bad"
cp build-v20-tree/UEFI/include/{KernelExports.h,ProcessWalk.h,PageTableWalk.h} "$STAGE/v26bad/"
python3 - << PYEOF
import pathlib
t = pathlib.Path('$STAGE/v26bad/PageTableWalk.h').read_text()
old = """    static const u32 kS1PteBaseRvas[kPtS1RvaCount] = {
        0xCFB358, 0xCFA358,
    };"""
new = """    static const u32 kS1PteBaseRvas[kPtS1RvaCount] = {
        0x1, 0x2,
    };"""
assert t.count(old) == 1, 'class-kill anchor not found'
pathlib.Path('$STAGE/v26bad/PageTableWalk.h').write_text(t.replace(old, new))
print('   S1-redacted header built (wrong MmPteBase constants)')
PYEOF
g++ -std=c++11 -I "$STAGE/v26bad" -o "$STAGE/host26bad" scripts/host-test-v26.c
# the redacted binary EXITS 1 BY DESIGN (the PT tests fail) - capture, inspect.
set +e
CK_OUT=$("$STAGE/host26bad" 2>&1)
set -e
echo "   S1-redacted run: $(echo "$CK_OUT" | tail -1)"
N_PT_FAIL=$(echo "$CK_OUT" | grep -cE 'FAIL  T(2[4-9]|3[0-9]|4[01])')
if [ "${N_PT_FAIL:-0}" -ge 5 ]; then
  echo "   class-kill (b) PROVEN: the redacted header fails $N_PT_FAIL PT checks (wrong constants can never pass)"
else
  echo "FATAL: class-kill does not catch wrong S1 constants ($N_PT_FAIL fails)"; exit 1
fi

echo "== [3/7] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v34.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v34.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [4/7] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v34.ps1     "$STAGE/swap/usb-d/trigger-test-v34.ps1"
cp patches/phase-d-v34.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V34-FA.md         "$STAGE/swap/README-V34-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v34 / F4-attempt-2 (2026-09-28) - DRIVER v26 + script v34
Driver : memory.efi v26 RT  140582 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         (= v25 + THE FORMULA FIX: the v33 field run BSOD'd 0x50 on
         op-12's first PTE-space read - v25 addressed the upper levels
         at PTE_BASE + shifted-vpn*8 = LOW-USER PTE slots. v26 computes
         the TRUE level bases PDE/PPE/PXE_BASE = PTE_BASE + s<<30 /
         +s<<21 / +s<<12 (exact vs the published classic s=0x1ED
         constants 0xFFFFF6FB40000000 / 0xFFFFF6FB7DA00000 /
         0xFFFFF6FB7DBED000), reads PML4E[s] at PXE_BASE+s*8, fixes the
         chain-B identity (== PXE_BASE+s*8), makes selfOk a bitmask
         (bit0 = the PTE space LIVE; bit1 = frame==System CR3, expected
         0 in the trigger-script caller context) and the PtRd64 range
         gate wrap-free (s=0x1FF). Host-tested 101/101 on a
         TRUE-SEMANTICS world (a REAL 4-level hierarchy + an independent
         hardware walk) + BOTH class-kills (the v25 engine dies at
         0xffffd58000000d58 = the exact field read; redacted constants
         fail 15 checks); disasm-verified; bench A=13/13 B=5/5.)
         v25-RT = 141154 (THE F4 BSOD BINARY - DO NOT RUN); this
         file is 140582 = v26. The bat checks size + hash.
Script : trigger-test-v34.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         (the field-run v33 wire + the corrected selfOk BIT semantics +
         the corrected F4 proof language; the P ladder P1..P7 and the
         DTB cross-check unchanged)
Bat    : phase-d.bat (FIVE-way hash guard: v26 GO / v25 REFUSE (the F4
         BSOD binary) / v24 REFUSE (no page tables) / v23 REFUSE
         (missing deref) / v22 REFUSE (export gate))
         SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : DRIVER v26 (replace memory.efi!) + SCRIPT v34 + BAT v34.
         This is a FULL swap, not script-only.
Require: REPLACE usb-d\memory.efi (v26-RT 140582, sha256 c8f79b95...) +
         usb-d\trigger-test-v34.ps1 (delete v33) + phase-d.bat.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [5/7] build the FULL bundle (v26 driver everywhere + v34 kit)"
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
cp patches/trigger-test-v34.ps1 "$STAGE/full/trigger-test-v34.ps1"
cp patches/trigger-test-v34.ps1 "$STAGE/full/transfer/trigger-test-v34.ps1"
cp patches/trigger-test-v34.ps1 "$STAGE/full/usb-d/trigger-test-v34.ps1"
cp patches/phase-d-v34.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V34-FA.md     "$STAGE/full/README-V34-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "140582" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "140582" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v34" "$STAGE/full/usb-d/trigger-test-v34.ps1"
grep -q "trigger-test-v34.ps1" "$STAGE/full/phase-d.bat"
grep -q "c8f79b95" "$STAGE/full/phase-d.bat"
grep -q "022e6d1c" "$STAGE/full/phase-d.bat"
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v34.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [6/7] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v26-driver-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v26.zip"
cmp -s "$SWAP" "$ARCH/infinity-v26-driver-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v26.zip" \
  && echo "   mirrors hash-identical"

echo "== [7/7] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v26-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
