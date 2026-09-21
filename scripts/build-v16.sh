#!/bin/bash
# ============================================================================
# build-v16.sh — the complete v16 pipeline (script-truth fixes + cosmetics):
#
#   repo (a8e41b3) -> +v7 diff -> v7 source -> patch-v13.py -> v13 source
#   -> patch-v14.py -> v14 source -> patch-v15.py -> v15 source
#   -> patch-v16.py -> v16 source
#   -> build SAFE + RT -> binary checks (+ disassembly VA-safety check)
#   -> sandbox validation (Alpine) -> package infinity-qemu-test-v16.zip
#   -> commit -> vault push (token auto-read from .secrets/)
#
# v16 = the v15 bridge (field-proven COMPLETE) + script-side truth fixes
# (dword parsing, SlotStatus decode, [4] relabel, auto-tee in the PS
# script) + driver COSMETICS only (banners incl. the stale v7 screen
# banner, the "0x=0x" double prefix, the EBS-time build line, the stale
# WindowsOffsets header comment). ZERO logic changes in the driver.
#
# Usage:
#   bash scripts/build-v16.sh                                  # if infinity-repo/ exists
#   bash scripts/build-v16.sh --skip-sandbox                   # build+package only
#   bash scripts/build-v16.sh --only repo|tree|build|check|sandbox|package|commit
#
# The sandbox QEMU run: A ~1 min, B up to 8 min.
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v16-tree
PKGDIR=$BASE/build/pkg-v16
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
  if [ -z "${GITHUB_TOKEN:-}" ] && [ ! -f "$BASE/.secrets/github-token" ]; then
    echo "FATAL: no clone and no token (env or .secrets/github-token)."
    echo "The driver source lives ONLY in the private repo"
    echo "fulken/Infinity (branch uefi-full-migration, commit $PIN)."
    exit 1
  fi
  export GITHUB_TOKEN="${GITHUB_TOKEN:-$(head -1 "$BASE/.secrets/github-token" 2>/dev/null | tr -d '[:space:]')}"
  bash "$BASE/scripts/fetch-infinity-repo.sh"
  git -C "$REPO" rev-parse --verify -q "$PIN^{commit}" >/dev/null || {
    echo "FATAL: pinned commit $PIN not found in the cloned branch"; exit 1; }
fi
fi

# ---------------------------------------------------------------- tree
if want tree; then
step "[2/7] v7 tree + v13 + v14 + v15 + v16 patches"
git -C "$REPO" worktree remove --force "$WORK" 2>/dev/null || true
rm -rf "$WORK"
git -C "$REPO" worktree add --detach "$WORK" "$PIN"
echo "tree at $(git -C "$WORK" rev-parse --short HEAD)"
git -C "$WORK" apply "$V7DIFF"
echo "v7 diff applied (tree is now the exact v7 source)"
python3 "$BASE/scripts/patch-v13.py" "$WORK"
echo "v13 patch applied (tree is now the exact v13 source)"
python3 "$BASE/scripts/patch-v14.py" "$WORK"
echo "v14 patch applied (tree is now the exact v14 source)"
python3 "$BASE/scripts/patch-v15.py" "$WORK"
echo "v15 patch applied (tree is now the exact v15 source)"
python3 "$BASE/scripts/patch-v16.py" "$WORK"
echo "v16 patch applied (tree is now the exact v16 source)"
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
cp "$OUT" $BASE/patches/v16-memory-SAFE.efi
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -8
cp "$OUT" $BASE/patches/v16-memory-RT.efi
cd "$BASE"
ls -la patches/v16-memory-*.efi
fi

# ---------------------------------------------------------------- check
if want check; then
step "[4/7] binary checks"
# NOTE: with `set -o pipefail`, `strings | grep -q` is a SIGPIPE RACE
# (grep -q exits on first match -> strings dies with 141 -> pipeline
# "fails" even though the string exists). Collect strings ONCE per
# file and grep the variable - no pipe, no race.
for v in SAFE RT; do
  f=$BASE/patches/v16-memory-$v.efi
  STR8=$(strings -a "$f")
  STR16=$(strings -a -e l "$f")
  echo "--- $v ($(stat -c%s "$f") bytes, sha256 $(sha256sum "$f" | cut -c1-16)...) ---"
  if [ "$v" = RT ]; then
    for s in "memory.efi v16 RT" "full bridge proven, clean serial labels" "INFDIAG live" "INFCNT live" "OURVAR" "kusd raw 0x260" "kusd raw 0x308" "v16 early" "EBS-time; 0 is normal" "efi_main v16 boot"; do
      if grep -qF -- "$s" <<<"$STR8"; then echo "  PASS  string: $s"
      else echo "  FAIL  string missing: $s"; exit 1; fi
    done
    # v16 cosmetic proof: the double-prefix KV labels must be GONE
    if grep -qF -- "kusd raw 0x260=0x" <<<"$STR8"; then
      echo "  FAIL  the v15 double-prefix label 'kusd raw 0x260=0x' is still present"; exit 1
    else echo "  PASS  no double-prefix KV labels (0x=0x fix landed)"; fi
    # UEFI variable names are UTF-16LE (CHAR16) — plain strings(1) can't see them
    for s in "INFTRIGGER" "INFCNT" "INFDIAG" "InfinityReq"; do
      if grep -qF -- "$s" <<<"$STR16"; then echo "  PASS  u16 name: $s"
      else echo "  FAIL  u16 name missing: $s"; exit 1; fi
    done
  else
    if grep -qF -- "INFCNT" <<<"$STR8"; then
      echo "  FAIL  SAFE build must not contain INFCNT (hook code)"; exit 1
    else echo "  PASS  SAFE build clean of hook strings"; fi
    # NOTE: kBuildLine (main.c) is DEAD code eliminated by the compiler
    # since the v7 era - the LIVE screen banner is the wide string in
    # PrintBanner, visible only via strings -e l (UTF-16LE).
    if grep -qF -- "Build: v16 SAFE" <<<"$STR16"; then
      echo "  PASS  u16 screen banner: Build: v16 SAFE"
    else echo "  FAIL  u16 screen banner missing: Build: v16 SAFE"; exit 1; fi
    for s in "efi_main v16 boot" "variant: SAFE"; do
      if grep -qF -- "$s" <<<"$STR8"; then echo "  PASS  string: $s"
      else echo "  FAIL  string missing: $s"; exit 1; fi
    done
  fi
done

# the LIVE RT screen banner (wide string) proves the C3 cosmetic landed
RT16=$(strings -a -e l $BASE/patches/v16-memory-RT.efi)
if grep -qF -- "Build: v16 RT - full bridge proven" <<<"$RT16"; then
  echo "  PASS  RT u16 screen banner: Build: v16 RT - full bridge proven (phase D COMPLETE)"
else
  echo "  FAIL  RT u16 screen banner missing (the stale v7 screen banner fix)"; exit 1
fi

# ---- THE critical VA-safety check (the v12/v14 BSOD class) ----
echo "--- disassembly VA-safety check (the v12/v14 BSOD class) ---"
RTF=$BASE/patches/v16-memory-RT.efi
BAD=$(objdump -d -M intel "$RTF" 2>/dev/null | grep -cE "mov +r[a-z0-9]+,QWORD PTR \[rip\+[^]]*# [^ ]*(Hex64EmE1k|Hex32EjE1k)" || true)
if [ "$BAD" -ne 0 ]; then
  echo "  FAIL  stale hex-table POINTER loads still present ($BAD sites) — the table must be an array (lea, not mov)"
  exit 1
fi
echo "  PASS  no QWORD pointer-slot loads for the hex tables remain"
# positive evidence: the nibble loops now LEA the table directly
# (constant-data QWORD loads near the k symbol — e.g. the INFDIAG
# magic 0x494E4644 — are fine; only POINTER loads were the bug.)
N=$(objdump -d -M intel "$RTF" 2>/dev/null | grep -E "lea +r[a-z0-9]+,\[rip" | grep -cE "Hex64EmE1k|Hex32EjE1k" || true)
if [ "$N" -lt 2 ]; then
  echo "  FAIL  expected at least 2 rip-relative LEA hex-table sites (Hex64+Hex32), found $N"
  exit 1
fi
echo "  PASS  $N rip-relative LEA hex-table sites (VA-safe)"
echo "binary checks passed"
fi

# ---------------------------------------------------------------- sandbox
if want sandbox && [ "$SKIP_SANDBOX" -eq 0 ]; then
step "[5/7] sandbox validation (Alpine EFI-stub boots)"
A_OK=0; B_OK=0
bash "$BASE/scripts/test-v16-linux.sh" A 300 && A_OK=1 || true
bash "$BASE/scripts/test-v16-linux.sh" B 300 && B_OK=1 || true
echo
echo "sandbox: RT=$([ $A_OK -eq 1 ] && echo PASS || echo FAIL)  SAFE=$([ $B_OK -eq 1 ] && echo PASS || echo FAIL)"
if [ $A_OK -ne 1 ] || [ $B_OK -ne 1 ]; then
  echo "FATAL: sandbox validation failed — NOT packaging. Inspect test-v16/serial-l{A,B}.log"
  exit 1
fi
else
  step "[5/7] sandbox validation SKIPPED (--skip-sandbox)"
fi

# ---------------------------------------------------------------- package
if want package; then
step "[6/7] package infinity-qemu-test-v16"
rm -rf "$BASE/build/pkg-v16"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip template leftovers we do not want in v16
rm -f "$PKGDIR/trigger-test.ps1" "$PKGDIR/usb-d/trigger-test.ps1" "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md"
# new binaries
cp "$BASE/patches/v16-memory-SAFE.efi" "$PKGDIR/usb/memory.efi"
cp "$BASE/patches/v16-memory-SAFE.efi" "$PKGDIR/usb-c/memory.efi"
cp "$BASE/patches/v16-memory-RT.efi"   "$PKGDIR/usb-d/memory.efi"
# v16 script + docs everywhere the user might look
for d in "." "usb-d" "transfer"; do
  cp "$BASE/infinity-qemu-test/trigger-test-v16.ps1" "$PKGDIR/$d/trigger-test-v16.ps1"
done
cp "$BASE/infinity-qemu-test/README-V16-FA.md" "$PKGDIR/README-V16-FA.md"
# phase-d.bat: v16 edition — built by scripts/patch-v16-bat.py (bumps the proven v13 bat)
python3 "$BASE/scripts/patch-v16-bat.py"
cp "$BASE/infinity-qemu-test/phase-d.bat" "$PKGDIR/phase-d.bat"
# refresh-files hint line
sed -i 's/package v9+/package v16+/g' "$PKGDIR/refresh-files.bat"
# guard simulation: the phase-d pre-flight must pass against this exact package
if ! grep -q "trigger test v16" "$PKGDIR/usb-d/trigger-test-v16.ps1"; then
  echo "FATAL: guard simulation: usb-d script lacks the 'trigger test v16' marker"; exit 1
fi
echo "  guard simulation PASS (usb-d trigger-test-v16.ps1 carries the marker)"
# VERSION.txt
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi"    | awk '{print toupper($1)}')
SHA_RT=$(sha256sum   "$PKGDIR/usb-d/memory.efi"  | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum  "$PKGDIR/trigger-test-v16.ps1" | awk '{print toupper($1)}')
SZ_SAFE=$(stat -c%s  "$PKGDIR/usb/memory.efi"); SZ_RT=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE - v16
================================
Date: $(date -u +%Y-%m-%d)

WHAT v16 IS (the full bridge, proven; script truth + cosmetics):
  The v15 run COMPLETED the full bridge end-to-end: desktop
  SetVariable(InfinityReq PING) -> hook -> inline process ->
  RAM-served InfinityResp PONG, zero crashes, live build 19045
  read from KUSD+0x260. The v15 report's "WRONG-CONTENT
  status=1" verdict was a script BUG (confirmed at source
  level): status=1 IS SlotStatus_Success. v16 fixes the script
  side and polishes the driver's cosmetic output:
    1. trigger-test-v16.ps1: full-dword parsing (v15 displayed
       byte-truncated values: 19045 -> "101"), SlotStatus name
       decoding, step [4] relabel (InfinityReq is RAM-consumed
       by design - ABSENT read-back is EXPECTED), and auto-tee:
       all output is saved to trigger-test-v16-output-DATE.txt
       next to the script - send that file, no photos needed.
    2. Driver COSMETICS only (zero logic changes): the screen
       banner said "v7 RT" since phase D2 - now v16; the serial
       "[BLD] kusd raw 0x260=0x=0x..." double prefix is fixed;
       the EBS-time "windows build=0" line is relabelled (0 at
       EBS is normal - the desktop-time probe is authoritative).
    3. Everything else from v15 is unchanged: hex-safe serial
       tables, KUSD dual-offset probe, GUID fixes, RAM-served
       INFDIAG/INFCNT, dual-write chain, PING step E.
  Run trigger-test-v16.ps1 (elevated) after phase-d.bat boots.

KEY FILE HASHES (SHA256):
  memory.efi v16 SAFE ($SZ_SAFE bytes): usb\\memory.efi + usb-c\\memory.efi
    $SHA_SAFE
  memory.efi v16 RT ($SZ_RT bytes): usb-d\\memory.efi
    $SHA_RT
  trigger-test-v16.ps1
    $SHA_SCR

DRIVER SOURCE LINEAGE (reproducible):
  fulken/Infinity @ $PIN (branch uefi-full-migration)
  + patches/v7-on-a8e41b3.diff   (v7 source)
  + scripts/patch-v13.py         (v8 counter policy + v13 safe observability)
  + scripts/patch-v14.py         (GUID semantics fix + live KUSD build + dual-write chain)
  + scripts/patch-v15.py         (hex-safe serial tables + KUSD dual-offset probe)
  + scripts/patch-v16.py         (cosmetics: banners, clean serial labels, EBS note)

WHAT DID NOT CHANGE:
  - firmware/ (OVMF), phase-a/b/c/b-check scripts, refresh-files flow
  - boot chain: phase-d.bat (banner text says v16 now)
EOF
# zip (flat structure, same as v9)
cd "$PKGDIR"
rm -f "$BASE/download/infinity-qemu-test-v16.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v16.zip" . -x '.git/*'
cd "$BASE"
cp download/infinity-qemu-test-v16.zip version-archive/packages/
echo "package: download/infinity-qemu-test-v16.zip ($(stat -c%s download/infinity-qemu-test-v16.zip) bytes)"
fi

# ---------------------------------------------------------------- commit
if want commit; then
step "[7/7] commit (+ vault push via stored token)"
git add -A patches/v16-memory-SAFE.efi patches/v16-memory-RT.efi \
          scripts/patch-v16.py scripts/build-v16.sh scripts/test-v16-linux.sh \
          scripts/patch-v16-bat.py scripts/make-v16-script.py \
          infinity-qemu-test/trigger-test-v16.ps1 infinity-qemu-test/trigger-test-v15.ps1 \
          infinity-qemu-test/README-V16-FA.md infinity-qemu-test/README-V15-FA.md \
          infinity-qemu-test/phase-d.bat \
          download/infinity-qemu-test-v16.zip version-archive/packages/infinity-qemu-test-v16.zip \
          .gitignore 2>/dev/null || true
git commit -q -m "v16: bridge COMPLETE (v15 status=1 = SlotStatus_Success, source-proven); script truth fixes (full-dword parsing, SlotStatus decode, [4] RAM-consume relabel, auto-tee transcript) + driver cosmetics only (v7 screen banner -> v16, 0x=0x KV label fix, EBS-time build note, stale 0x308 comment)" \
  || echo "(nothing new to commit)"
git log --oneline -1
if [ -n "${GITHUB_TOKEN:-}" ] || [ -f "$BASE/.secrets/github-token" ]; then
  echo "token available -> refreshing the GitHub vault (fulken/infinity-backup)"
  bash "$BASE/scripts/push-infinity-backup.sh" || echo "vault push failed (non-fatal)"
else
  echo "no token -> skipping GitHub vault push (local commit is the rollback copy)"
fi
fi

echo
echo "DONE: build-v16 pipeline complete"
