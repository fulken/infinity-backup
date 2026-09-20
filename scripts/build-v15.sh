#!/bin/bash
# ============================================================================
# build-v15.sh — the complete v15 pipeline (hex-safe serial + KUSD probe):
#
#   repo (a8e41b3) -> +v7 diff -> v7 source -> patch-v13.py -> v13 source
#   -> patch-v14.py -> v14 source -> patch-v15.py -> v15 source
#   -> build SAFE + RT -> binary checks (+ disassembly VA-safety check)
#   -> sandbox validation (Alpine) -> package infinity-qemu-test-v15.zip
#   -> commit -> vault push (token auto-read from .secrets/)
#
# Usage:
#   bash scripts/build-v15.sh                                  # if infinity-repo/ exists
#   bash scripts/build-v15.sh --skip-sandbox                   # build+package only
#   bash scripts/build-v15.sh --only repo|tree|build|check|sandbox|package|commit
#
# The sandbox QEMU run: A ~1 min, B up to 8 min.
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v15-tree
PKGDIR=$BASE/build/pkg-v15
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
step "[2/7] v7 tree + v13 + v14 + v15 patches"
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
cp "$OUT" $BASE/patches/v15-memory-SAFE.efi
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -8
cp "$OUT" $BASE/patches/v15-memory-RT.efi
cd "$BASE"
ls -la patches/v15-memory-*.efi
fi

# ---------------------------------------------------------------- check
if want check; then
step "[4/7] binary checks"
for v in SAFE RT; do
  f=$BASE/patches/v15-memory-$v.efi
  echo "--- $v ($(stat -c%s "$f") bytes, sha256 $(sha256sum "$f" | cut -c1-16)...) ---"
  if [ "$v" = RT ]; then
    for s in "memory.efi v15 RT" "hex-safe serial + kusd probe" "INFDIAG live" "INFCNT live" "OURVAR" "kusd raw 0x260" "kusd raw 0x308" "v15 early"; do
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

# ---- THE v15 CRITICAL CHECK: hex tables must be rip-relative (VA-safe) ----
echo "--- disassembly VA-safety check (the v12/v14 BSOD class) ---"
RTF=$BASE/patches/v15-memory-RT.efi
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
bash "$BASE/scripts/test-v15-linux.sh" A 300 && A_OK=1 || true
bash "$BASE/scripts/test-v15-linux.sh" B 300 && B_OK=1 || true
echo
echo "sandbox: RT=$([ $A_OK -eq 1 ] && echo PASS || echo FAIL)  SAFE=$([ $B_OK -eq 1 ] && echo PASS || echo FAIL)"
if [ $A_OK -ne 1 ] || [ $B_OK -ne 1 ]; then
  echo "FATAL: sandbox validation failed — NOT packaging. Inspect test-v15/serial-l{A,B}.log"
  exit 1
fi
else
  step "[5/7] sandbox validation SKIPPED (--skip-sandbox)"
fi

# ---------------------------------------------------------------- package
if want package; then
step "[6/7] package infinity-qemu-test-v15"
rm -rf "$BASE/build/pkg-v15"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip template leftovers we do not want in v15
rm -f "$PKGDIR/trigger-test.ps1" "$PKGDIR/usb-d/trigger-test.ps1" "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md"
# new binaries
cp "$BASE/patches/v15-memory-SAFE.efi" "$PKGDIR/usb/memory.efi"
cp "$BASE/patches/v15-memory-SAFE.efi" "$PKGDIR/usb-c/memory.efi"
cp "$BASE/patches/v15-memory-RT.efi"   "$PKGDIR/usb-d/memory.efi"
# v15 script + docs everywhere the user might look
for d in "." "usb-d" "transfer"; do
  cp "$BASE/infinity-qemu-test/trigger-test-v15.ps1" "$PKGDIR/$d/trigger-test-v15.ps1"
done
cp "$BASE/infinity-qemu-test/README-V15-FA.md" "$PKGDIR/README-V15-FA.md"
# phase-d.bat: v15 edition — built by scripts/patch-v15-bat.py (bumps the proven v13 bat)
python3 "$BASE/scripts/patch-v15-bat.py"
cp "$BASE/infinity-qemu-test/phase-d.bat" "$PKGDIR/phase-d.bat"
# refresh-files hint line
sed -i 's/package v9+/package v15+/g' "$PKGDIR/refresh-files.bat"
# guard simulation: the phase-d pre-flight must pass against this exact package
if ! grep -q "trigger test v15" "$PKGDIR/usb-d/trigger-test-v15.ps1"; then
  echo "FATAL: guard simulation: usb-d script lacks the 'trigger test v15' marker"; exit 1
fi
echo "  guard simulation PASS (usb-d trigger-test-v15.ps1 carries the marker)"
# VERSION.txt
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi"    | awk '{print toupper($1)}')
SHA_RT=$(sha256sum   "$PKGDIR/usb-d/memory.efi"  | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum  "$PKGDIR/trigger-test-v15.ps1" | awk '{print toupper($1)}')
SZ_SAFE=$(stat -c%s  "$PKGDIR/usb/memory.efi"); SZ_RT=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE - v15
================================
Date: $(date -u +%Y-%m-%d)

WHAT v15 IS (hex-safe serial + KUSD probe — the v14 BSOD fix):
  v14 CRASHED (KMODE_EXCEPTION) on the script's step A. Root cause
  (disassembly-proven): SerialTrace's hex formatter used a
  'static const char*' table — the compiler materialized it as a
  POINTER SLOT holding the load-time physical address, never
  converted at SetVirtualAddressMap. The first hex print from the
  Windows kernel context dereferenced the stale address and page-
  faulted. The v12 BSOD had the SAME signature (both logs truncate
  mid '=0x').
    1. Hex tables are ARRAYS now (rip-relative, safe in every
       address space) — verified by a disassembly check in the
       build pipeline.
    2. The v14 KUSD read returned an implausible build (+0x308 is
       NOT NtBuildNumber on live Win10 19045 x64). v15 probes BOTH
       candidate offsets (0x260, 0x308), traces the RAW values on
       serial ([BLD] kusd raw ...), takes the first plausible one.
    3. Everything else from v14 is unchanged: GUID fixes, RAM-
       served INFDIAG/INFCNT, dual-write chain, PING step E.
  Run trigger-test-v15.ps1 (elevated) after phase-d.bat boots.

KEY FILE HASHES (SHA256):
  memory.efi v15 SAFE ($SZ_SAFE bytes): usb\\memory.efi + usb-c\\memory.efi
    $SHA_SAFE
  memory.efi v15 RT ($SZ_RT bytes): usb-d\\memory.efi
    $SHA_RT
  trigger-test-v15.ps1
    $SHA_SCR

DRIVER SOURCE LINEAGE (reproducible):
  fulken/Infinity @ $PIN (branch uefi-full-migration)
  + patches/v7-on-a8e41b3.diff   (v7 source)
  + scripts/patch-v13.py         (v8 counter policy + v13 safe observability)
  + scripts/patch-v14.py         (GUID semantics fix + live KUSD build + dual-write chain)
  + scripts/patch-v15.py         (hex-safe serial tables + KUSD dual-offset probe)

WHAT DID NOT CHANGE:
  - firmware/ (OVMF), phase-a/b/c/b-check scripts, refresh-files flow
  - boot chain: phase-d.bat (only the banner text says v15 now)
EOF
# zip (flat structure, same as v9)
cd "$PKGDIR"
rm -f "$BASE/download/infinity-qemu-test-v15.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v15.zip" . -x '.git/*'
cd "$BASE"
cp download/infinity-qemu-test-v15.zip version-archive/packages/
echo "package: download/infinity-qemu-test-v15.zip ($(stat -c%s download/infinity-qemu-test-v15.zip) bytes)"
fi

# ---------------------------------------------------------------- commit
if want commit; then
step "[7/7] commit (+ vault push via stored token)"
git add -A patches/v15-memory-SAFE.efi patches/v15-memory-RT.efi \
          scripts/patch-v15.py scripts/build-v15.sh scripts/test-v15-linux.sh \
          scripts/patch-v15-bat.py scripts/make-v15-script.py \
          infinity-qemu-test/trigger-test-v15.ps1 infinity-qemu-test/README-V15-FA.md \
          infinity-qemu-test/phase-d.bat \
          download/infinity-qemu-test-v15.zip version-archive/packages/infinity-qemu-test-v15.zip \
          .gitignore 2>/dev/null || true
git commit -q -m "v15: hex-table pointer slot was the v12+v14 BSOD root cause (stale load-time address, first hex print from Windows context = #PF) - arrays now; KUSD build dual-offset probe (0x260+0x308) with raw forensics" \
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
echo "DONE: build-v15 pipeline complete"
