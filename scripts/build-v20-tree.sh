#!/bin/bash
# ============================================================================
# build-v20-tree.sh — rebuild the v20 driver source tree from the pinned
# recipe and PROVE it reproduces the field-proven binaries byte-for-byte.
#
#   repo (a8e41b3) -> +v7 diff -> v7 source -> patch-v13..v20 chain
#   -> v20 source -> build SAFE + RT (gnuefi-jammy 3.0.13)
#   -> TRUST ANCHOR: sha256(RT) == 8513da5f... (128010 B)
#                     sha256(SAFE) == c244ace2... (105032 B)
#     (the exact binaries the v26/v27 field runs proved convergent)
#
# This tree is the base for F2 proper (v21 = PE parse + exports +
# validated-offsets + PTE base).
#
# Usage: bash scripts/build-v20-tree.sh [--only tree|build|verify]
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v20-tree
PIN=a8e41b3
V7DIFF=$BASE/patches/v7-on-a8e41b3.diff
GNUEFI=${GNUEFI:-$BASE/gnuefi-jammy}
ONLY=""

for a in "$@"; do case "$a" in --only) : ;; *) ONLY="$a" ;; esac; done
step() { echo; echo "== $*"; echo "--------------------------------------------------"; }
want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# ---------------------------------------------------------------- tree
if want tree; then
step "[1/3] v7 tree + patch chain v13..v20"
[ -d "$REPO/.git" ] || { echo "FATAL: $REPO missing (run the shallow clone first)"; exit 1; }
git -C "$REPO" rev-parse --verify -q "$PIN^{commit}" >/dev/null || {
  # shallow clone: HEAD must BE the pin
  [ "$(git -C "$REPO" rev-parse HEAD)" = "$(git -C "$REPO" rev-parse --quiet --verify 2>/dev/null || echo x)" ] || true
}
if ! git -C "$REPO" rev-parse -q --verify HEAD >/dev/null; then echo "FATAL: repo not usable"; exit 1; fi
HEADSHA=$(git -C "$REPO" rev-parse HEAD)
echo "repo HEAD: $HEADSHA (expect $PIN for the shallow single-branch clone)"
[ "${HEADSHA#$(git -C "$REPO" rev-parse --short "$PIN")}" != "$HEADSHA" ] || true

git -C "$REPO" worktree remove --force "$WORK" 2>/dev/null || true
rm -rf "$WORK"
git -C "$REPO" worktree add --detach "$WORK" "$PIN" 2>/dev/null \
  || git -C "$REPO" worktree add --detach "$WORK" HEAD
echo "tree at $(git -C "$WORK" rev-parse --short HEAD)"
git -C "$WORK" apply "$V7DIFF"
echo "v7 diff applied"
for v in 13 14 15 16 17 18 19 20; do
  python3 "$BASE/scripts/patch-v$v.py" "$WORK"
  echo "v$v patch applied"
done
echo "TREE READY: $WORK (exact v20 source)"
fi

# ---------------------------------------------------------------- build
if want build; then
step "[2/3] build SAFE + RT (gnu-efi: $GNUEFI)"
cd "$WORK/UEFI/build"
EFI_ARGS="EFI_LIB_DIR=$GNUEFI/usr/lib EFI_INC_DIR=$GNUEFI/usr/include/efi"
if [ ! -f "$GNUEFI/usr/include/efi/efi.h" ]; then
  echo "gnu-efi tree missing at $GNUEFI — falling back to gnuefi-local"
  GNUEFI=$BASE/gnuefi-local
  EFI_ARGS="EFI_LIB_DIR=$GNUEFI/usr/lib EFI_INC_DIR=$GNUEFI/usr/include/efi"
fi
OUT=$WORK/UEFI/build/build/memory.efi

echo "--- SAFE ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS 2>&1 | tail -4
cp "$OUT" "$WORK/v20-memory-SAFE.efi"
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -5
cp "$OUT" "$WORK/v20-memory-RT.efi"
ls -la "$WORK"/v20-memory-*.efi
fi

# ---------------------------------------------------------------- verify
if want verify; then
step "[3/3] TRUST ANCHOR: byte-identical v20 rebuild"
fail=0
for v in RT SAFE; do
  REBUILT=$WORK/v20-memory-$v.efi
  FIELD=$BASE/patches/v20-memory-$v.efi
  if [ ! -f "$REBUILT" ] || [ ! -f "$FIELD" ]; then
    echo "  FATAL: missing file ($REBUILT or $FIELD)"; exit 1; fi
  RH=$(sha256sum "$REBUILT" | cut -d' ' -f1)
  FH=$(sha256sum "$FIELD" | cut -d' ' -f1)
  RS=$(stat -c%s "$REBUILT"); FS=$(stat -c%s "$FIELD")
  if [ "$RH" = "$FH" ] && [ "$RS" = "$FS" ]; then
    echo "  PASS  v20-$v: $RS bytes, sha256 $RH == field-proven"
  else
    echo "  FAIL  v20-$v: rebuilt $RS/$RH vs field $FS/$FH"; fail=1
  fi
done
[ $fail -eq 0 ] && echo "TRUST ANCHOR VERIFIED — the tree is the exact field-proven v20 source" || {
  echo "TRUST ANCHOR FAILED — do NOT develop on this tree"; exit 1; }
fi
