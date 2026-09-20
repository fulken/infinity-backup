#!/bin/bash
# ============================================================================
# push-infinity-backup.sh — mirror critical project artifacts to the user's
# private GitHub repo (default: fulken/infinity-backup).
#
# Usage:
#   GITHUB_TOKEN='github_pat_...' bash scripts/push-infinity-backup.sh
#   (or no env var: falls back to /home/z/my-project/.secrets/github-token,
#    which the user explicitly authorized for on-disk storage on 2026-09-21,
#    7-day fine-grained PAT, admin perms. NEVER mirror .secrets/ anywhere.)
#
# Design rules (same as fetch-infinity-repo.sh):
#   - Token comes from env var OR the local .secrets file; it is NEVER
#     written to .git/config, remotes, or COMMITTED TO THE VAULT REPO
#     (staging leak-check aborts the push if the token value appears in
#     any mirrored file).
#   - Idempotent: creates the repo if missing, clones its history, mirrors
#     the CURRENT workspace artifacts on top, commits the delta, pushes.
#   - Staging lives under backups/ (gitignored, disposable) — it is rebuilt
#     from tracked workspace files on every run, so losing staging to a
#     session rollback is harmless.
#   - Mirrored set is an EXPLICIT list — nothing accidental, no secrets.
# ============================================================================
set -euo pipefail

# Token resolution: env var wins; else the user-authorized local secrets file.
BASE=/home/z/my-project
if [ -z "${GITHUB_TOKEN:-}" ] && [ -f "$BASE/.secrets/github-token" ]; then
  GITHUB_TOKEN="$(head -1 "$BASE/.secrets/github-token" | tr -d '[:space:]')"
fi
TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN is not set and $BASE/.secrets/github-token is missing}"
OWNER="${GITHUB_OWNER:-fulken}"
REPO="${REPO_NAME:-infinity-backup}"
API="https://api.github.com"
URL="https://github.com/$OWNER/$REPO.git"
BACKUPS="$BASE/backups"
STAGE="$BACKUPS/$REPO-staging"
AUTH="Authorization: Basic $(printf "x-access-token:%s" "$TOKEN" | base64 -w0)"

redact() { sed "s|$TOKEN|<REDACTED>|g"; }

mkdir -p "$BACKUPS"
REPOJSON="$BACKUPS/.repo-check.json"
CREATEJSON="$BACKUPS/.repo-create.json"

echo "== [1/6] Ensure repo $OWNER/$REPO exists"
code="$(curl -s -o "$REPOJSON" -w '%{http_code}' -H "$AUTH" "$API/repos/$OWNER/$REPO")"
if [ "$code" = "404" ]; then
  echo "  not found — creating private repo..."
  code2="$(curl -s -o "$CREATEJSON" -w '%{http_code}' -H "$AUTH" "$API/user/repos" \
    -d "{\"name\":\"$REPO\",\"private\":true,\"description\":\"Infinity QEMU test - durable backup: packages v1-v9 + trigger v11, test reports, driver binaries (v4-v8), source patches, worklog\"}")"
  if [ "$code2" != "201" ]; then
    echo "FATAL: repo creation failed (HTTP $code2)"; redact < "$CREATEJSON"; exit 1
  fi
  echo "  created: $(grep -o '"full_name": *"[^"]*"' "$CREATEJSON" | head -1)"
elif [ "$code" = "200" ]; then
  echo "  exists — $(grep -o '"private":[a-z]*' "$REPOJSON" | head -1)"
else
  echo "FATAL: API returned HTTP $code"; redact < "$REPOJSON"; exit 1
fi

echo
echo "== [2/6] Clone existing history into staging (keeps backup history)"
rm -rf "$STAGE"
git -c "http.https://github.com/.extraheader=$AUTH" clone "$URL" "$STAGE" 2>&1 | redact | tail -2
cd "$STAGE"
git config user.name "Super Z (auto-backup)"
git config user.email "superz-auto-backup@users.noreply.github.com"
if git rev-parse --verify --quiet main >/dev/null; then
  git checkout -q main
else
  git symbolic-ref HEAD refs/heads/main
fi

echo
echo "== [3/6] Mirror current workspace artifacts (explicit list)"
rm -rf version-archive patches scripts validation-evidence worklog.md edk2_Runtime.c README.md
cp -r "$BASE/version-archive" .
cp -r "$BASE/patches" .
cp -r "$BASE/scripts" .
cp    "$BASE/worklog.md" .
cp    "$BASE/edk2_Runtime.c" .
mkdir -p validation-evidence/test-v7
cp -r "$BASE/test-v7/artifacts" validation-evidence/test-v7/
cp    "$BASE/scripts/infinity-backup-README.md" README.md
echo "  mirrored: $(find . -path ./.git -prune -o -type f -print | wc -l) files, $(du -sh --exclude=.git . | cut -f1)"

echo
echo "== [4/6] Leak checks before commit"
if rg -q --fixed-strings "$TOKEN" --hidden --glob '!.git' . 2>/dev/null; then
  echo "FATAL: token found in staged files"; exit 1
fi
case "$(cat .git/config)" in
  *"$TOKEN"*) echo "FATAL: token in .git/config"; exit 1 ;;
esac
echo "  staged content + .git/config clean"

echo
echo "== [5/6] Commit + push (ephemeral header; remote URL stays tokenless)"
git add -A
if git diff --cached --quiet; then
  echo "  no changes since last backup — nothing to push"
else
  WS_SHA="$(git -C "$BASE" rev-parse --short HEAD)"
  git commit -q -m "backup $(date -u '+%Y-%m-%d %H:%M') UTC — workspace ${WS_SHA}: packages v1-v9+v11, reports, binaries v4-v8, patches, scripts, worklog"
  git -c "http.https://github.com/.extraheader=$AUTH" push origin main 2>&1 | redact | grep -v "^$" | tail -3
fi

echo
echo "== [6/6] Post-push verification"
RURL="$(git remote get-url origin)"
case "$RURL" in
  *"$TOKEN"*) echo "FATAL: token leaked into remote URL"; exit 1 ;;
  *) echo "  remote url clean: $RURL" ;;
esac
if rg -q --fixed-strings "$TOKEN" .git 2>/dev/null; then
  echo "FATAL: token found somewhere under .git/"; exit 1
fi
echo "  .git/ clean — token was ephemeral only"
echo
echo "BACKUP DONE: $URL"
echo "  branch main, HEAD $(git rev-parse --short HEAD), $(git rev-list --count HEAD) commit(s)"
