#!/bin/bash
# ============================================================================
# tag-phase-e-baseline.sh — tag the Phase-E-proven state in BOTH repos:
#   1. local workspace git  @ 6bce0dc (rollback-recovery-3 restore state)
#   2. GitHub vault (fulken/infinity-backup) @ its current HEAD (4447328...)
# The tag marks the EXACT artifact set that proved
# "KERNEL DATA PATH VIA REQUESTS" (driver v18 + script v22 + v22 report).
# Token handling: ephemeral header only, never written anywhere (house rules).
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
TOKEN=$(cat "$BASE/.github-token")
AUTH="http.https://github.com/.extraheader=Authorization: Basic $(printf "x-access-token:%s" "$TOKEN" | base64 -w0)"
URL="https://github.com/fulken/infinity-backup.git"
TAG="phase-E-proven"
MSG="Phase E proven: KERNEL DATA PATH VIA REQUESTS (2026-09-22 run)
Driver: memory.efi v18 RT (121253 B, sha256 9f441788...abcdea)
Script: trigger-test-v22.ps1 (43521 B) - J2 kernel alias 0xFFFFF78000000260 -> 19045
Evidence: version-archive/reports/ v22 zip + loose-evidence/v22-run
Known-good baseline for Phase C+ work."

echo "== [1/4] local workspace tag =="
cd "$BASE"
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "  local tag $TAG already exists: $(git rev-parse --short "$TAG")"
else
  git tag -a "$TAG" -m "$MSG"
  echo "  created local tag $TAG -> $(git rev-parse --short "$TAG")"
fi

echo "== [2/4] clone vault (ephemeral auth) =="
STAGE="$BASE/backups/tag-stage"
rm -rf "$STAGE"
git -c "$AUTH" clone -q "$URL" "$STAGE"
cd "$STAGE"
git config user.name "Super Z (auto-backup)"
git config user.email "superz-auto-backup@users.noreply.github.com"
echo "  vault HEAD: $(git rev-parse --short HEAD)  ($(git log -1 --format=%s | head -c 90))"

echo "== [3/4] tag vault HEAD =="
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "  vault tag $TAG already exists: $(git rev-parse --short "$TAG")"
else
  git tag -a "$TAG" -m "$MSG"
  echo "  created vault tag $TAG -> $(git rev-parse --short "$TAG")"
fi

echo "== [4/4] push tag =="
git -c "$AUTH" push origin "refs/tags/$TAG" 2>&1 | sed "s|$TOKEN|<REDACTED>|g" | tail -2

# verify
git -c "$AUTH" ls-remote origin "refs/tags/$TAG" | sed "s|$TOKEN|<REDACTED>|g"
# leak check on staging .git (paranoia, mirrors push script rules)
if [ -n "$(grep -r "$TOKEN" "$STAGE/.git/config" 2>/dev/null)" ]; then
  echo "FATAL: token in staging .git/config"; exit 1
fi
rm -rf "$STAGE"
echo "DONE: tag $TAG secured in vault"
