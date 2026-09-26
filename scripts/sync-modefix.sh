#!/bin/bash
# ============================================================================
# sync-modefix.sh — after the /tmp snapshot rsync: restore files whose CONTENT
# is identical to HEAD (mode-only flips) so the commit carries only the real
# content delta. Content-changed and untracked files are left untouched.
# ============================================================================
set -euo pipefail
cd /home/z/my-project

modeonly=/tmp/modeonly-real.txt
: > "$modeonly"
restored=0
checked=0

while IFS= read -r -d '' f; do
  checked=$((checked+1))
  # blob identical to HEAD? -> mode-only flip
  if git cat-file blob "HEAD:$f" 2>/dev/null | cmp -s - "$f"; then
    echo "$f" >> "$modeonly"
  fi
done < <(git diff --name-only -z)

# restore mode-only files to git's recorded modes
if [ -s "$modeonly" ]; then
  tr '\n' '\0' < "$modeonly" | xargs -0 git checkout --
  restored=$(wc -l < "$modeonly")
fi

echo "checked=$checked restored_mode_only=$restored"
echo "=== REMAINING REAL CONTENT CHANGES ==="
git diff --name-only | head -50
echo "=== COUNTS ==="
echo "content_changed=$(git diff --name-only | wc -l)"
echo "untracked=$(git status --porcelain | grep -c '^??')"
