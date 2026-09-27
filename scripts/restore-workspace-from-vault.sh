#!/bin/bash
# ============================================================================
# restore-workspace-from-vault.sh — full workspace restore from the GitHub
# vault clone (rollback-recovery procedure, proven in recoveries 1-6).
#
# Usage:
#   bash /home/z/my-project/scripts/restore-workspace-from-vault.sh [clone-dir]
#
# Default clone-dir: /home/z/my-project/backups/vault-restore-6
# The clone must already exist (created with the ephemeral-header clone from
# scripts/push-infinity-backup.sh lineage). SAFETY: this script verifies the
# vault is a superset of the current workspace for every mirrored dir BEFORE
# touching anything, and refuses to --delete if a dir has local-only files.
# ============================================================================
set -euo pipefail

BASE=/home/z/my-project
V="${1:-$BASE/backups/vault-restore-6}"

[ -d "$V/.git" ] || { echo "FATAL: $V is not a vault clone"; exit 1; }
[ -f "$V/worklog.md" ] || { echo "FATAL: $V/worklog.md missing"; exit 1; }

echo "== [1/5] Pre-restore superset safety check + [2/5] restore"
for d in version-archive patches scripts validation-evidence addons; do
  FLAG="--delete"
  if [ -d "$BASE/$d" ] && [ -d "$V/$d" ]; then
    N=$(comm -23 <(cd "$BASE/$d" && find . -type f | sort) \
                  <(cd "$V/$d" && find . -type f | sort) | wc -l)
    if [ "$N" -gt 0 ]; then
      echo "  WARNING: $d has $N local-only file(s) — rsyncing WITHOUT --delete"
      FLAG=""
    else
      echo "  $d: vault is superset — safe"
    fi
  else
    echo "  $d: absent locally — plain copy"
  fi
  mkdir -p "$BASE/$d"
  rsync -a $FLAG "$V/$d/" "$BASE/$d/"
  echo "  restored $d/"
done
cp "$V/worklog.md" "$BASE/worklog.md"
echo "  restored worklog.md ($(wc -l < "$BASE/worklog.md") lines)"
[ -f "$V/edk2_Runtime.c" ] && cp "$V/edk2_Runtime.c" "$BASE/edk2_Runtime.c" && echo "  restored edk2_Runtime.c"

echo
echo "== [3/5] Rebuild download/ deliverables from version-archive/packages"
mkdir -p "$BASE/download"
ADDED=0
for z in "$BASE"/version-archive/packages/*.zip; do
  name=$(basename "$z")
  if [ ! -f "$BASE/download/$name" ]; then
    cp "$z" "$BASE/download/$name"
    ADDED=$((ADDED+1))
    echo "  + $name"
  fi
done
echo "  $ADDED package(s) added to download/ (existing files untouched)"

echo
echo "== [4/5] Post-restore verification"
FAIL=0
[ "$(wc -l < "$BASE/worklog.md")" -gt 900 ] || { echo "  FAIL: worklog too short"; FAIL=1; }
LAST_TASK=$(grep "^Task ID:" "$BASE/worklog.md" | tail -1)
echo "  worklog last entry: $LAST_TASK"
for f in version-archive/packages/infinity-v24-driver-swap.zip \
         version-archive/packages/infinity-qemu-test-v24.zip \
         scripts/make-v32.py scripts/host-test-v24.c patches/v24-memory-RT.efi; do
  if [ -f "$BASE/$f" ]; then echo "  OK  $f"; else echo "  MISSING $f"; FAIL=1; fi
done
[ "$FAIL" -eq 0 ] || { echo "VERIFICATION FAILED — inspect before committing"; exit 1; }

echo
echo "== [5/5] Summary"
echo "  vault HEAD: $(git -C "$V" log --oneline -1 | head -c 100)"
echo "  next: git add -A && git commit (restore snapshot), then resume work"
