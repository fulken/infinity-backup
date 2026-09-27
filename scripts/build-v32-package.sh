#!/bin/bash
# ============================================================================
# build-v32-package.sh - build the v32 field kit (driver v24 + script v32):
#   1. GUARDS: the v24 driver hashes, the v32 script audit, the bat paren
#      audit, host-test re-run (66/66) + class-kill proof (the test must
#      FAIL on a v23-copy of the header - SysEprocessFromSymbol with the
#      deref redacted = the exact v23 op-11 behavior)
#   2. infinity-v24-driver-swap.zip (usb-d/memory.efi v24-RT +
#      usb-d/trigger-test-v32.ps1 + phase-d.bat + README-V32-FA.md +
#      VERSION.txt)
#   3. infinity-qemu-test-v24.zip (full bundle on the v23 package template,
#      driver v24 everywhere, trigger v32 in all 3 locations, new bat +
#      README + VERSION)
#   4. archive mirrors (hash-identical)
# ============================================================================
set -euo pipefail
cd /home/z/my-project

BASE=version-archive/packages/infinity-qemu-test-v23.zip   # the v23 full bundle = template
SWAP=download/infinity-v24-driver-swap.zip
FULL=download/infinity-qemu-test-v24.zip
ARCH=version-archive/packages
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

echo "== [1/7] GUARDS: the v24 binaries + the v32 audits"
RT=patches/v24-memory-RT.efi
SAFE=patches/v24-memory-SAFE.efi
[ "$(stat -c%s $RT)" = "134842" ]   || { echo "FATAL: v24-RT size $(stat -c%s $RT) != 134842"; exit 1; }
[ "$(stat -c%s $SAFE)" = "105032" ] || { echo "FATAL: v24-SAFE size $(stat -c%s $SAFE) != 105032"; exit 1; }
RT_SHA=$(sha256sum "$RT" | cut -d' ' -f1)
SAFE_SHA=$(sha256sum "$SAFE" | cut -d' ' -f1)
echo "   v24-RT   sha256 $RT_SHA"
echo "   v24-SAFE sha256 $SAFE_SHA"
[ "$RT_SHA" = "f8a01814f4ffeb9a9b1595a722c733b0dbf92d5eb5710b25d88d7818dbcf5846" ] \
  || { echo "FATAL: v24-RT hash drift"; exit 1; }
cmp -s "$RT" build-v20-tree/UEFI/build/build/memory.efi \
  || { echo "FATAL: RT != current tree build"; exit 1; }
python3 scripts/audit-v32-ps1.py | tail -1
python3 scripts/audit-bat-parens.py patches/phase-d-v32.bat | tail -1

echo "== [2/7] host-test re-run (66/66) + class-kill proof (the v23-copy deref)"
g++ -std=c++11 -I build-v20-tree/UEFI/include -o "$STAGE/host24" scripts/host-test-v24.c
"$STAGE/host24" | tail -1
grep -q "66 PASS / 0 FAIL" <("$STAGE/host24" | tail -1) || { echo "FATAL: host-test not 66/66"; exit 1; }
mkdir -p "$STAGE/v23inc"
cp build-v20-tree/UEFI/include/KernelExports.h "$STAGE/v23inc/"
# v23-copy ProcessWalk.h: SysEprocessFromSymbol with the deref REDACTED -
# it returns the symbol VA as the "eproc" (the exact v23 op-11 behavior)
python3 - << PYEOF
import pathlib
t = pathlib.Path('build-v20-tree/UEFI/include/ProcessWalk.h').read_text()
old = """        u32 rva = (u32)(s1.resolved_va - c->base);  // < c->size
        u32 lo = 0, hi = 0;
        if (!kx::Rd32(c, rva, &lo))     return false;
        if (!kx::Rd32(c, rva + 4, &hi)) return false;
        if (out_sym_va) *out_sym_va = s1.resolved_va;
        if (out_eproc)  *out_eproc  = (u64)lo | ((u64)hi << 32);
        return true;"""
new = """        // V23-COPY CLASS-KILL: the deref REDACTED (the v23 behavior)
        if (out_sym_va) *out_sym_va = s1.resolved_va;
        if (out_eproc)  *out_eproc  = s1.resolved_va;
        return true;"""
assert t.count(old) == 1, 'class-kill anchor not found'
pathlib.Path('$STAGE/v23inc/ProcessWalk.h').write_text(t.replace(old, new))
print('   v23-copy header built (deref redacted)')
PYEOF
g++ -std=c++11 -I "$STAGE/v23inc" -o "$STAGE/host23bug" scripts/host-test-v24.c
# NOTE: the deref-less binary EXITS 1 BY DESIGN (T23 fails) - capture, inspect.
set +e
CK_OUT=$("$STAGE/host23bug" 2>&1)
set -e
echo "   v23-copy run: $(echo "$CK_OUT" | tail -1)"
N_T23_FAIL=$(echo "$CK_OUT" | grep -c 'FAIL  T23')
if [ "${N_T23_FAIL:-0}" -ge 5 ]; then
  echo "   class-kill PROVEN: the v23-copy header fails $N_T23_FAIL T23 checks (the deref can never be dropped again)"
else
  echo "FATAL: class-kill does not catch the missing deref ($N_T23_FAIL T23 fails)"; exit 1
fi

echo "== [3/7] hashes for VERSION.txt"
SC_SHA=$(sha256sum patches/trigger-test-v32.ps1 | cut -d' ' -f1)
BAT_SHA=$(sha256sum patches/phase-d-v32.bat | cut -d' ' -f1)
echo "   script ${SC_SHA:0:16}...  bat ${BAT_SHA:0:16}..."

echo "== [4/7] build the swap package"
rm -rf "$STAGE/swap" && mkdir -p "$STAGE/swap/usb-d"
cp "$RT"                            "$STAGE/swap/usb-d/memory.efi"
cp patches/trigger-test-v32.ps1     "$STAGE/swap/usb-d/trigger-test-v32.ps1"
cp patches/phase-d-v32.bat          "$STAGE/swap/phase-d.bat"
cp patches/README-V32-FA.md         "$STAGE/swap/README-V32-FA.md"
cat > "$STAGE/swap/VERSION.txt" <<EOF
INFINITY SWAP KIT v32 / F3-deref-fix (2026-09-27) - DRIVER v24 + script v32
Driver : memory.efi v24 RT  134842 bytes  SHA256 $(echo $RT_SHA | tr 'a-f' 'A-F')
         (= v23 + THE DEREF FIX: op 11 now resolve -> deref the in-image
         PsInitialSystemProcess pointer slot (gated kx::Rd32 x2) -> walk
         from the true System EPROCESS. The v31 field run: M1..M4 green
         (the export fix proven) but W refused payload status=4 not-System
         walk=0 - the v23 walk started at the SYMBOL VA. Host-tested 66/66
         incl. the T23 chain class-kill; disasm-verified; bench A=13/13 B=5/5.)
         v23-RT/v22-RT are BOTH 134330 bytes - the older builds; this file
         is 134842 = v24 (sizes differ again). The bat checks size + hash.
Script : trigger-test-v32.ps1  SHA256 $(echo $SC_SHA | tr 'a-f' 'A-F')
         (the same K/L/M/J/W wire as the field-run v31; the W1 success
         expectations CORRECTED to the v24 semantics: sysEntry@1032 = the
         DEREF'd EPROCESS - canonical, OUTSIDE the image, == entries[0])
Bat    : phase-d.bat (EIGHT-way guard: sizes 120678/121253/125450/128010/
         131709/134330(v23|v22 named by hash)/134842 + the THREE-WAY
         SHA-256 HASH GUARD v24 GO / v23 REFUSE / v22 REFUSE)
         SHA256 $(echo $BAT_SHA | tr 'a-f' 'A-F')
Change : DRIVER v24 (replace memory.efi!) + SCRIPT v32 + BAT v32.
         This is a FULL swap, not script-only.
Require: REPLACE usb-d\memory.efi (v24-RT 134842, sha256 f8a01814...) +
         usb-d\trigger-test-v32.ps1 (delete v31) + phase-d.bat.
EOF
( cd "$STAGE/swap" && zip -q -r -X "$OLDPWD/$SWAP" . ) && echo "   $SWAP: $(stat -c%s "$SWAP") bytes"

echo "== [5/7] build the FULL bundle (v24 driver everywhere + v32 kit)"
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
cp patches/trigger-test-v32.ps1 "$STAGE/full/trigger-test-v32.ps1"
cp patches/trigger-test-v32.ps1 "$STAGE/full/transfer/trigger-test-v32.ps1"
cp patches/trigger-test-v32.ps1 "$STAGE/full/usb-d/trigger-test-v32.ps1"
cp patches/phase-d-v32.bat      "$STAGE/full/phase-d.bat"
cp patches/README-V32-FA.md     "$STAGE/full/README-V32-FA.md"
mv "$STAGE/swap/VERSION.txt"    "$STAGE/full/VERSION.txt"
# sanity inside the staged full bundle
[ "$(stat -c%s "$STAGE/full/usb-d/memory.efi")" = "134842" ] || { echo "FATAL: full usb-d driver wrong"; exit 1; }
[ "$(stat -c%s "$STAGE/full/usb/memory.efi")" = "134842" ]   || { echo "FATAL: full usb driver wrong"; exit 1; }
[ "$(sha256sum "$STAGE/full/usb-c/memory.efi" | cut -d' ' -f1)" = "$RT_SHA" ] || { echo "FATAL: usb-c driver hash wrong"; exit 1; }
grep -q "trigger test v32" "$STAGE/full/usb-d/trigger-test-v32.ps1"
grep -q "trigger-test-v32.ps1" "$STAGE/full/phase-d.bat"
grep -q "f8a01814" "$STAGE/full/phase-d.bat"
[ -z "$(find "$STAGE/full" -name 'trigger-test-v*.ps1' ! -name 'trigger-test-v32.ps1')" ] \
  || { echo "FATAL: a stale trigger script survived"; exit 1; }
( cd "$STAGE/full" && zip -q -r -X "$OLDPWD/$FULL.new" . ) && mv "$FULL.new" "$FULL"
echo "   $FULL: $(stat -c%s "$FULL") bytes"

echo "== [6/7] archive mirrors"
cp "$SWAP" "$ARCH/infinity-v24-driver-swap.zip"
cp "$FULL" "$ARCH/infinity-qemu-test-v24.zip"
cmp -s "$SWAP" "$ARCH/infinity-v24-driver-swap.zip" && cmp -s "$FULL" "$ARCH/infinity-qemu-test-v24.zip" \
  && echo "   mirrors hash-identical"

echo "== [7/7] final report"
echo "   swap: $SWAP  ($(stat -c%s "$SWAP") B)"
echo "   full: $FULL  ($(stat -c%s "$FULL") B)"
echo "   driver v24-RT sha256: $RT_SHA"
echo "   script sha256: $SC_SHA"
echo "   bat    sha256: $BAT_SHA"
echo "BUILD OK"
