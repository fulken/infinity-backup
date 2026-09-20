#!/bin/bash
# ============================================================================
# fetch-infinity-repo.sh — clone the private Infinity repo + permanent cache
#
# Usage:
#   GITHUB_TOKEN='github_pat_...' \
#   REPO_URL='https://github.com/fulken/Infinity.git' \
#   BRANCH='uefi-full-migration' \
#   bash /home/z/my-project/scripts/fetch-infinity-repo.sh
#
# Design rules (agreed with user):
#   - Token is passed ONLY as an ephemeral git http header. It is never
#     written to .git/config, remotes, files, or the workspace git repo.
#   - Permanent cache: git bundle (all refs) + tarball of the full clone
#     under /home/z/my-project/backups/ — recovery needs NO token.
#   - Auto-commit the cache artifacts into the workspace git repo.
# ============================================================================
set -euo pipefail

TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN is not set}"
REPO_URL="${REPO_URL:-https://github.com/fulken/Infinity.git}"
BRANCH="${BRANCH:-uefi-full-migration}"

BASE=/home/z/my-project
CLONE_DIR="$BASE/infinity-repo"
BACKUPS="$BASE/backups"
STAMP="$(date -u +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUPS"

echo "== [1/6] Fresh clone of $REPO_URL (branch: $BRANCH)"
rm -rf "$CLONE_DIR"
git -c "http.https://github.com/.extraheader=Authorization: Basic $(printf "x-access-token:%s" "$TOKEN" | base64 -w0)" \
    clone --branch "$BRANCH" "$REPO_URL" "$CLONE_DIR" 2>&1 | sed "s|$TOKEN|<REDACTED>|g"

echo
echo "== [2/6] Verify HEAD and branch"
cd "$CLONE_DIR"
echo "HEAD:   $(git rev-parse HEAD)"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Count:  $(git rev-list --count HEAD) commits on this branch"
git log -3 --format="  %h %ad %s" --date=short

echo
echo "== [3/6] Token-leak safety checks"
URL="$(git remote get-url origin)"
case "$URL" in
  *"$TOKEN"*) echo "FATAL: token leaked into remote URL"; exit 1 ;;
  *) echo "remote url clean: $URL" ;;
esac
if rg -q --fixed-strings "$TOKEN" .git 2>/dev/null; then
  echo "FATAL: token found somewhere under .git/"
  exit 1
fi
echo ".git/ clean — token was ephemeral only"

echo
echo "== [4/6] Build permanent cache (bundle + tarball)"
BUNDLE="$BACKUPS/infinity-${BRANCH}-$(git rev-parse --short HEAD)-${STAMP}.bundle"
git bundle create "$BUNDLE" --all 2>&1 | tail -2
TARBALL="$BACKUPS/infinity-${BRANCH}-$(git rev-parse --short HEAD)-${STAMP}.tar.gz"
tar -czf "$TARBALL" -C "$BASE" infinity-repo
echo "bundle:  $BUNDLE ($(du -h "$BUNDLE" | cut -f1))"
echo "tarball: $TARBALL ($(du -h "$TARBALL" | cut -f1))"

echo
echo "== [5/6] Verify bundle integrity"
git bundle verify "$BUNDLE" 2>&1 | tail -3

echo
echo "== [6/6] Recovery README"
cat > "$BACKUPS/README.md" <<EOF
# Infinity repo — permanent cache

Cache contents (created $STAMP, branch \`$BRANCH\`, HEAD \`$(git rev-parse HEAD)\`):

- \`*.bundle\`  — git bundle with all refs. Restore (no token needed):
  \`git clone <bundle> infinity-repo\`
- \`*.tar.gz\`  — full snapshot of the clone including .git. Restore:
  \`tar xzf <tarball> -C /home/z/my-project\`

The live clone lives at /home/z/my-project/infinity-repo (gitignored by the
workspace repo on purpose; rebuild it any time from the bundle).
EOF

echo
echo "FETCH DONE. Cache artifacts:"
ls -lh "$BACKUPS" | tail -6
