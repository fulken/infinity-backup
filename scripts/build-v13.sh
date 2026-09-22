#!/bin/bash
# ============================================================================
# build-v13.sh — the complete v13 pipeline (safe observability build):
#
#   repo (a8e41b3) -> +v7 diff -> v7 source -> patch-v13.py -> v13 source
#   -> build SAFE + RT -> binary checks -> sandbox validation (Alpine)
#   -> package infinity-qemu-test-v13.zip -> commit -> (optional) vault push
#
# Usage:
#   GITHUB_TOKEN='ghp_...' bash scripts/build-v13.sh          # full run
#   bash scripts/build-v13.sh                                  # if infinity-repo/ exists
#   bash scripts/build-v13.sh --skip-sandbox                   # build+package only
#   bash scripts/build-v13.sh --only repo|tree|build|check|sandbox|package|commit
#
# Token rule (same as fetch-infinity-repo.sh): ephemeral env var only,
# never written anywhere. The sandbox QEMU run: A ~1 min, B up to 8 min.
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v13-tree
PKGDIR=$BASE/build/pkg-v13
TEMPLATE=$BASE/upload/extracted-v9-full
PIN=a8e41b3
V7DIFF=$BASE/patches/v7-on-a8e41b3.diff
GNUEFI=${GNUEFI:-$BASE/gnuefi-jammy}       # 3.0.13 (CI parity); fallback: gnuefi-local
SKIP_SANDBOX=0
ONLY=""

for a in "$@"; do
  case "$a" in
    --skip-sandbox) SKIP_SANDBOX=1 ;;
    --only)         : ;;   # value handled below
    *)              ONLY="$a" ;;
  esac
done

step() { echo; echo "============================================================"; echo "== $*"; echo "============================================================"; }

want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# ---------------------------------------------------------------- repo
if want repo; then
step "[1/7] repo source (pin $PIN)"
if [ -d "$REPO/.git" ] && git -C "$REPO" rev-parse --verify -q "$PIN^{commit}" >/dev/null; then
  echo "reusing existing clone at $REPO (commit $PIN present)"
  git -C "$REPO" rev-parse --short "$PIN"
else
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "FATAL: no clone and no GITHUB_TOKEN."
    echo "The driver source lives ONLY in the private repo"
    echo "fulken/Infinity (branch uefi-full-migration, commit $PIN)."
    echo "Export a fresh token and re-run:"
    echo "  GITHUB_TOKEN='...' bash $BASE/scripts/build-v13.sh"
    exit 1
  fi
  bash "$BASE/scripts/fetch-infinity-repo.sh"
  git -C "$REPO" rev-parse --verify -q "$PIN^{commit}" >/dev/null || {
    echo "FATAL: pinned commit $PIN not found in the cloned branch"; exit 1; }
fi
fi

# ---------------------------------------------------------------- tree
if want tree; then
step "[2/7] v7 tree + v13 patch"
git -C "$REPO" worktree remove --force "$WORK" 2>/dev/null || true
rm -rf "$WORK"
git -C "$REPO" worktree add --detach "$WORK" "$PIN"
echo "tree at $(git -C "$WORK" rev-parse --short HEAD)"
git -C "$WORK" apply "$V7DIFF"
echo "v7 diff applied (tree is now the exact v7 source)"
python3 "$BASE/scripts/patch-v13.py" "$WORK"
fi

# ---------------------------------------------------------------- build
if want build; then
step "[3/7] build SAFE + RT (gnu-efi: $GNUEFI)"
cd "$WORK/UEFI/build"
EFI_ARGS="EFI_LIB_DIR=$GNUEFI/usr/lib EFI_INC_DIR=$GNUEFI/usr/include/efi"
if [ ! -f "$GNUEFI/usr/include/efi/efi.h" ]; then
  echo "gnu-efi tree missing at $GNUEFI — falling back to gnuefi-local"
  GNUEFI=$BASE/gnuefi-local
  EFI_ARGS="EFI_LIB_DIR=$GNUEFI/usr/lib EFI_INC_DIR=$GNUEFI/usr/include/efi"
fi
OUT=$WORK/UEFI/build/build/memory.efi   # Makefile places output in build/ subdir

echo "--- SAFE ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS 2>&1 | tail -6
cp "$OUT" $BASE/patches/v13-memory-SAFE.efi
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -8
cp "$OUT" $BASE/patches/v13-memory-RT.efi
cd "$BASE"
ls -la patches/v13-memory-*.efi
fi

# ---------------------------------------------------------------- check
if want check; then
step "[4/7] binary checks"
for v in SAFE RT; do
  f=$BASE/patches/v13-memory-$v.efi
  echo "--- $v ($(stat -c%s "$f") bytes, sha256 $(sha256sum "$f" | cut -c1-16)...) ---"
  if [ "$v" = RT ]; then
    for s in "memory.efi v13 RT" "INFDIAG live" "INFCNT live" "OURVAR" "v13 early"; do
      if strings -a "$f" | grep -q -- "$s"; then echo "  PASS  string: $s"
      else echo "  FAIL  string missing: $s"; exit 1; fi
    done
    # UEFI variable names are UTF-16LE (CHAR16) — plain strings(1) can't see them
    for s in "INFTRIGGER" "INFCNT" "INFDIAG" "InfinityReq"; do
      if strings -a -e l "$f" | grep -q -- "$s"; then echo "  PASS  u16 name: $s"
      else echo "  FAIL  u16 name missing: $s"; exit 1; fi
    done
  else
    if strings -a "$f" | grep -q -- "INFCNT"; then
      echo "  FAIL  SAFE build must not contain INFCNT (hook code)"; exit 1
    else echo "  PASS  SAFE build clean of hook strings"; fi
  fi
done
echo "binary checks passed"
fi

# ---------------------------------------------------------------- sandbox
if want sandbox && [ "$SKIP_SANDBOX" -eq 0 ]; then
step "[5/7] sandbox validation (Alpine EFI-stub boots)"
A_OK=0; B_OK=0
bash "$BASE/scripts/test-v13-linux.sh" A 300 && A_OK=1 || true
bash "$BASE/scripts/test-v13-linux.sh" B 300 && B_OK=1 || true
echo
echo "sandbox: RT=$([ $A_OK -eq 1 ] && echo PASS || echo FAIL)  SAFE=$([ $B_OK -eq 1 ] && echo PASS || echo FAIL)"
if [ $A_OK -ne 1 ] || [ $B_OK -ne 1 ]; then
  echo "FATAL: sandbox validation failed — NOT packaging. Inspect test-v13/serial-l{A,B}.log"
  exit 1
fi
else
  step "[5/7] sandbox validation SKIPPED (--skip-sandbox)"
fi

# ---------------------------------------------------------------- package
if want package; then
step "[6/7] package infinity-qemu-test-v13"
rm -rf "$BASE/build/pkg-v13"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip template leftovers we do not want in v13
rm -f "$PKGDIR/trigger-test.ps1" "$PKGDIR/usb-d/trigger-test.ps1" "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md"
# new binaries
cp "$BASE/patches/v13-memory-SAFE.efi" "$PKGDIR/usb/memory.efi"
cp "$BASE/patches/v13-memory-SAFE.efi" "$PKGDIR/usb-c/memory.efi"
cp "$BASE/patches/v13-memory-RT.efi"   "$PKGDIR/usb-d/memory.efi"
# v13 script + docs everywhere the user might look
for d in "." "usb-d" "transfer"; do
  cp "$BASE/infinity-qemu-test/trigger-test-v13.ps1" "$PKGDIR/$d/trigger-test-v13.ps1"
done
cp "$BASE/infinity-qemu-test/README-V13-FA.md" "$PKGDIR/README-V13-FA.md"
# phase-d.bat: v13 edition — built by scripts/patch-v13-bat.py
python3 "$BASE/scripts/patch-v13-bat.py"
cp "$BASE/infinity-qemu-test/phase-d.bat" "$PKGDIR/phase-d.bat"
# refresh-files hint line
sed -i 's/package v9+/package v13+/g' "$PKGDIR/refresh-files.bat"
# VERSION.txt
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi"    | awk '{print toupper($1)}')
SHA_RT=$(sha256sum   "$PKGDIR/usb-d/memory.efi"  | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum  "$PKGDIR/trigger-test-v13.ps1" | awk '{print toupper($1)}')
SZ_SAFE=$(stat -c%s  "$PKGDIR/usb/memory.efi"); SZ_RT=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE - v13
================================
Date: $(date -u +%Y-%m-%d)

WHAT v13 IS (the safe observability build - the BSOD fix):
  Same boot chain as v9/v12 (early gRT hooks, read-only usb-d,
  transfer flow). v12 proved the desktop READ path reaches our
  hook, but its "freshen" (an NVRAM write from inside the Windows
  GetVariable dispatch) crashed the kernel (KMODE_EXCEPTION).
  v13 hooks NEVER call the original SetVariable at runtime:
    1. INFDIAG reads are ANSWERED FROM LIVE RAM by the hook
       (moving hook_calls, live stage/flags - no NVRAM involved).
    2. INFCNT reads are answered from RAM too: the live count of
       our-namespace writes that reached the hook (0 = writes
       bypass, 2 = INFTRIGGER + InfinityReq both arrived).
    3. Our-variable writes set flag 0x20 + bump the RAM counter
       and are serial-traced ("S OURVAR write/delete") - no NVRAM
       mirror, no original call, no crash class.
  Run trigger-test-v13.ps1 (elevated) after phase-d.bat boots.

KEY FILE HASHES (SHA256):
  memory.efi v13 SAFE ($SZ_SAFE bytes): usb\\memory.efi + usb-c\\memory.efi
    $SHA_SAFE
  memory.efi v13 RT ($SZ_RT bytes): usb-d\\memory.efi
    $SHA_RT
  trigger-test-v13.ps1
    $SHA_SCR

DRIVER SOURCE LINEAGE (reproducible):
  fulken/Infinity @ $PIN (branch uefi-full-migration)
  + patches/v7-on-a8e41b3.diff   (v7 source)
  + scripts/patch-v13.py         (v8 counter policy + v13 safe observability)

WHAT DID NOT CHANGE:
  - firmware/ (OVMF), phase-a/b/c/b-check scripts, refresh-files flow
  - boot chain: phase-d.bat (only the banner text says v13 now)
EOF
# zip (flat structure, same as v9)
cd "$PKGDIR"
rm -f "$BASE/download/infinity-qemu-test-v13.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v13.zip" . -x '.git/*'
cd "$BASE"
cp download/infinity-qemu-test-v13.zip version-archive/packages/
echo "package: download/infinity-qemu-test-v13.zip ($(stat -c%s download/infinity-qemu-test-v13.zip) bytes)"
fi

# ---------------------------------------------------------------- commit
if want commit; then
step "[7/7] commit (+ optional vault push)"
git add -A patches/v13-memory-SAFE.efi patches/v13-memory-RT.efi \
          scripts/patch-v13.py scripts/build-v13.sh scripts/test-v13-linux.sh \
          scripts/patch-v13-bat.py scripts/audit-bat-parens.py \
          infinity-qemu-test/trigger-test-v13.ps1 infinity-qemu-test/README-V13-FA.md \
          infinity-qemu-test/phase-d.bat \
          download/infinity-qemu-test-v13.zip version-archive/packages/infinity-qemu-test-v13.zip \
          .gitignore 2>/dev/null || true
git commit -q -m "v13: safe observability — RAM-served INFDIAG/INFCNT reads (no orig SetVariable from hooks; v12 freshen BSOD fix), RAM-only write attribution" \
  || echo "(nothing new to commit)"
git log --oneline -1
if [ -n "${GITHUB_TOKEN:-}" ]; then
  echo "token present -> refreshing the GitHub vault (fulken/infinity-backup)"
  bash "$BASE/scripts/push-infinity-backup.sh" || echo "vault push failed (non-fatal)"
else
  echo "no token -> skipping GitHub vault push (local commit is the rollback copy)"
fi
fi

step "DONE"
echo "deliverable: download/infinity-qemu-test-v13.zip"
echo "user flow  : unzip -> phase-d.bat -> VM boots Windows -> trigger-test-v13.ps1 (elevated)"
echo "send back  : SUMMARY photo + serial-phase-d.log (+ QEMU window photo)"
