#!/bin/bash
# ============================================================================
# build-v21-tree.sh — reconstruct the v20 source tree from the surviving
# patch chain, and verify the rebuilt v20 binaries are BYTE-IDENTICAL to
# the archived patches/v20-memory-{RT,SAFE}.efi (the proven-lineage check
# that worked for v18).
#
# Chain: repo(a8e41b3) -> +v7diff -> v13 -> v14 -> v15 -> v16 -> v17
#        -> v18 -> v19 -> v20
#
# After this, the (lost) v21 export patch gets re-derived on top of
# build-v20-tree/ and verified against patches/v21-memory-RT.efi
# (the field-proven binary from the user's package, sha256 90bc3bdf...).
#
# Usage: bash scripts/build-v21-tree.sh
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v20-tree
PIN=a8e41b3
V7DIFF=$BASE/patches/v7-on-a8e41b3.diff
GNUEFI=${GNUEFI:-$BASE/gnuefi-jammy}

step() { echo; echo "============================================================"; echo "== $*"; echo "============================================================"; }

step "[1/5] tree at $PIN + v7 diff"
git -C "$REPO" worktree remove --force "$WORK" 2>/dev/null || true
rm -rf "$WORK"
git -C "$REPO" worktree add --detach "$WORK" "$PIN"
echo "tree at $(git -C "$WORK" rev-parse --short HEAD)"
git -C "$WORK" apply "$V7DIFF"
echo "v7 diff applied"

step "[2/5] patch chain v13..v20"
for p in v13 v14 v15 v16 v17 v18 v19 v20; do
  python3 "$BASE/scripts/patch-$p.py" "$WORK"
  echo "patch-$p applied"
done

step "[3/5] build SAFE + RT (gnu-efi: $GNUEFI)"
cd "$WORK/UEFI/build"
EFI_ARGS="EFI_LIB_DIR=$GNUEFI/usr/lib EFI_INC_DIR=$GNUEFI/usr/include/efi"
OUT=$WORK/UEFI/build/build/memory.efi
echo "--- SAFE ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS 2>&1 | tail -4
cp "$OUT" $BASE/build/v20-rebuild-SAFE.efi
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -6
cp "$OUT" $BASE/build/v20-rebuild-RT.efi
cd "$BASE"
mkdir -p build
ls -la build/v20-rebuild-*.efi

step "[4/5] byte-identity vs the archived v20 binaries"
for v in RT SAFE; do
  A=$(sha256sum "build/v20-rebuild-$v.efi" | cut -d' ' -f1)
  B=$(sha256sum "patches/v20-memory-$v.efi" | cut -d' ' -f1)
  if [ "$A" = "$B" ]; then
    echo "  PASS  v20-$v BYTE-IDENTICAL ($A)"
  else
    echo "  FAIL  v20-$v differs: rebuilt $A vs archived $B"
    exit 1
  fi
done

step "[5/5] tree ready for the v21 export re-derivation"
echo "v20 tree: $WORK"
echo "next: re-derive patch-v21.py (exports) on this tree, verify vs"
echo "      patches/v21-memory-RT.efi sha256 90bc3bdf..."
