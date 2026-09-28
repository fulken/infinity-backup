#!/bin/bash
# ============================================================================
# audit-vault-coverage.sh — what is on the workspace but NOT on the vault?
# Compares the live workspace against the freshly-cloned staging tree
# (= the exact remote state of fulken/infinity-backup).
# Usage: bash scripts/audit-vault-coverage.sh
# ============================================================================
set -uo pipefail
BASE=/home/z/my-project
STAGE="$BASE/backups/infinity-backup-staging"

[ -d "$STAGE/.git" ] || { echo "FATAL: staging missing — run push-infinity-backup.sh first"; exit 1; }

echo "== [1] Vault areas present in staging (= on GitHub):"
for d in version-archive patches scripts uefi-src validation-evidence; do
  if [ -d "$STAGE/$d" ]; then
    echo "  OK  $d  ($(find "$STAGE/$d" -type f | wc -l) files)"
  else
    echo "  !!  $d  ABSENT"
  fi
done
for f in worklog.md edk2_Runtime.c README.md; do
  [ -f "$STAGE/$f" ] && echo "  OK  $f" || echo "  !!  $f ABSENT"
done

echo
echo "== [2] upload/ zips — every field report/kit must exist in the vault (reports/ or packages/):"
miss=0; tot=0
for z in "$BASE"/upload/*.zip; do
  [ -e "$z" ] || continue
  tot=$((tot+1)); b=$(basename "$z")
  if [ ! -f "$STAGE/version-archive/reports/$b" ] && [ ! -f "$STAGE/version-archive/packages/$b" ]; then
    echo "  MISSING: $b"; miss=$((miss+1))
  fi
done
echo "  -> $((tot-miss))/$tot covered"

echo
echo "== [3] download/ packages vs version-archive/packages:"
miss=0; tot=0
for z in "$BASE"/download/*.zip; do
  [ -e "$z" ] || continue
  tot=$((tot+1)); b=$(basename "$z")
  [ -f "$STAGE/version-archive/packages/$b" ] || { echo "  MISSING: $b"; miss=$((miss+1)); }
done
echo "  -> $((tot-miss))/$tot covered"

echo
echo "== [4] uefi-src snapshot freshness vs local build-v20-tree/UEFI:"
diffs=0
srclist="$(find "$BASE/build-v20-tree/UEFI/src" "$BASE/build-v20-tree/UEFI/include" -type f; find "$BASE/build-v20-tree/UEFI/build" -maxdepth 1 -type f)"
while IFS= read -r f; do
  rel="${f#$BASE/build-v20-tree/UEFI/}"
  if ! cmp -s "$f" "$STAGE/uefi-src/$rel"; then echo "  DIFFERS/ABSENT: $rel"; diffs=$((diffs+1)); fi
done <<< "$srclist"
[ $diffs -eq 0 ] && echo "  ALL source files byte-identical with the vault snapshot"

echo
echo "== [5] infinity-qemu-test/ (kit dir) vs patches/ + kits template zip (vaulted):"
KITZIP="$STAGE/version-archive/kits/infinity-qemu-test-template.zip"
# NOTE: precompute the listing ONCE. A per-file `unzip -l | grep -q` pipeline is
# racy under `set -o pipefail`: grep -q exits at first match -> SIGPIPE to unzip
# -> pipeline status 141 -> a PRESENT file reads as missing.
ziplist=""
[ -f "$KITZIP" ] && ziplist="$(unzip -l "$KITZIP" 2>/dev/null || true)"
miss=0; tot=0; viapt=0; viazip=0
for f in "$BASE"/infinity-qemu-test/*; do
  [ -f "$f" ] || continue
  tot=$((tot+1)); b=$(basename "$f")
  if [ -f "$STAGE/patches/$b" ]; then
    viapt=$((viapt+1))
  elif printf '%s\n' "$ziplist" | grep -q "infinity-qemu-test/$b\$"; then
    viazip=$((viazip+1))
  else
    echo "  NOT-IN-VAULT: $b"; miss=$((miss+1))
  fi
done
echo "  -> $viapt by patches/, $viazip by kit template zip, $miss truly missing (of $tot)"

echo
echo "== [6] Workspace areas NOT on the vault (informational):"
du -sh "$BASE"/gnuefi-jammy "$BASE"/infinity-repo "$BASE"/backups "$BASE"/upload "$BASE"/.git "$BASE"/build-v20-tree 2>/dev/null | sed 's/^/  /'
