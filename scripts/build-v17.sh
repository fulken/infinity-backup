#!/bin/bash
# ============================================================================
# build-v17.sh — the complete v17 pipeline (the data-path proof):
#
#   repo (a8e41b3) -> +v7 diff -> v7 source -> patch-v13.py -> v13 source
#   -> patch-v14.py -> v14 source -> patch-v15.py -> v15 source
#   -> patch-v16.py -> v16 source -> patch-v17.py -> v17 source
#   -> build SAFE + RT -> binary checks (+ disassembly VA-safety check)
#   -> sandbox validation (Alpine) -> package infinity-qemu-test-v17.zip
#   -> commit -> vault push (token auto-read from .secrets/)
#
# v17 = the v16 bridge (field-proven COMPLETE 2026-09-21) + ONE surgical
# functional addition: the KERNEL-TARGET read for the variable transport
# (pid=0xFFFFFFFF -> ReadKernelVA walks the CALLER's CR3; all data reads
# via ReadPhysical - no dereference path for bad VAs, so the negative
# test returns ErrAccess instead of crashing). Everything else is version
# cosmetics. The v16 field defect (auto-tee on the READ-ONLY boot stick)
# is fixed script-side (writability probe -> Desktop -> TEMP fallback).
#
# Usage:
#   bash scripts/build-v17.sh                                  # if infinity-repo/ exists
#   bash scripts/build-v17.sh --skip-sandbox                   # build+package only
#   bash scripts/build-v17.sh --only repo|tree|build|check|sandbox|package|commit
#
# The sandbox QEMU run: A ~1 min, B up to 8 min.
# ============================================================================
set -euo pipefail
BASE=/home/z/my-project
REPO=$BASE/infinity-repo
WORK=$BASE/build-v17-tree
PKGDIR=$BASE/build/pkg-v17
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
step "[2/7] v7 tree + v13 + v14 + v15 + v16 + v17 patches"
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
python3 "$BASE/scripts/patch-v17.py" "$WORK"
echo "v17 patch applied (tree is now the exact v17 source)"
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
cp "$OUT" $BASE/patches/v17-memory-SAFE.efi
echo "--- RT ---"
make clean >/dev/null 2>&1 || true
make $EFI_ARGS RT=1 2>&1 | tail -8
cp "$OUT" $BASE/patches/v17-memory-RT.efi
cd "$BASE"
ls -la patches/v17-memory-*.efi
fi

# ---------------------------------------------------------------- check
if want check; then
step "[4/7] binary checks"
# NOTE: with `set -o pipefail`, `strings | grep -q` is a SIGPIPE RACE
# (grep -q exits on first match -> strings dies with 141 -> pipeline
# "fails" even though the string exists). Collect strings ONCE per
# file into variables, greps use -qF herestrings.
for v in SAFE RT; do
  f=$BASE/patches/v17-memory-$v.efi
  STR8=$(strings -a "$f")
  STR16=$(strings -a -e l "$f")
  echo "--- $v ---"
  if [ "$v" = RT ]; then
    for s in "memory.efi v17 RT" "kernel data path: current-CR3 reads" "kern va" "kern read ok" "INFDIAG live" "INFCNT live" "OURVAR" "kusd raw 0x260" "v17 early" "efi_main v17 boot"; do
      if grep -qF -- "$s" <<<"$STR8"; then echo "  PASS  string: $s"
      else echo "  FAIL  string missing: $s"; exit 1; fi
    done
    # v17 must NOT regress the v16 clean labels
    if grep -qF -- "kusd raw 0x260=0x=" <<<"$STR8"; then
      echo "  FAIL  stale double-prefix KV label present"; exit 1
    else echo "  PASS  no double-prefix KV label"; fi
    # UEFI variable names are UTF-16LE (CHAR16) — plain strings(1) can't see them
    for s in "InfinityReq" "InfinityResp" "InfinityData"; do
      if grep -qF -- "$s" <<<"$STR16"; then echo "  PASS  u16 name: $s"
      else echo "  FAIL  u16 name missing: $s"; exit 1; fi
    done
  else
    for s in "efi_main v17 boot" "variant: SAFE"; do
      if grep -qF -- "$s" <<<"$STR8"; then echo "  PASS  string: $s"
      else echo "  FAIL  string missing: $s"; exit 1; fi
    done
    for s in "RT-EARLY" "HOOK" "kern va" "INFDIAG live"; do
      if grep -qF -- "$s" <<<"$STR8"; then echo "  FAIL  SAFE build must not contain hook string: $s"; exit 1
      else echo "  PASS  SAFE clean of: $s"; fi
    done
    # PrintBanner, visible only via strings -e l (UTF-16LE).
    if grep -qF -- "Build: v17 SAFE" <<<"$STR16"; then
      echo "  PASS  u16 screen banner: Build: v17 SAFE"
    else echo "  FAIL  u16 screen banner missing: Build: v17 SAFE"; exit 1; fi
  fi
done
RT16=$(strings -a -e l $BASE/patches/v17-memory-RT.efi)
if grep -qF -- "Build: v17 RT - bridge + kernel data path" <<<"$RT16"; then
  echo "  PASS  RT u16 screen banner: Build: v17 RT - bridge + kernel data path (phase E)"
else
  echo "  FAIL  RT u16 screen banner missing"; exit 1
fi

# ---- THE critical VA-safety check (the v12/v14 BSOD class) ----
echo "--- disassembly VA-safety check (the v12/v14 BSOD class) ---"
RTF=$BASE/patches/v17-memory-RT.efi
BAD=$(objdump -d -M intel "$RTF" 2>/dev/null | grep -cE "mov +r[a-z0-9]+,QWORD PTR \[rip\+[^]]*# [^ ]*(Hex64EmE1k|Hex32EjE1k)" || true)
if [ "$BAD" -ne 0 ]; then
  echo "  FAIL  stale hex-table POINTER loads still present ($BAD sites) — the table must be an array (lea, not mov)"
  exit 1
fi
echo "  PASS  no QWORD pointer-slot loads for the hex tables remain"
N=$(objdump -d -M intel "$RTF" 2>/dev/null | grep -E "lea +r[a-z0-9]+,\[rip" | grep -cE "Hex64EmE1k|Hex32EjE1k" || true)
if [ "$N" -lt 2 ]; then
  echo "  FAIL  expected at least 2 rip-relative LEA hex-table sites (Hex64+Hex32), found $N"
  exit 1
fi
echo "  PASS  $N rip-relative LEA hex-table sites (VA-safe)"

# ---- v17-specific: no new .data.rel.ro pointer slots vs v16 ----
echo "--- .data.rel.ro pointer-slot count vs v16 (the F3 literals must be LEAs, not slots) ---"
cnt_slots() { objdump -s -j .data.rel.ro "$1" 2>/dev/null | grep -c '^ ' || true; }
S16=$(cnt_slots "$BASE/patches/v16-memory-RT.efi")
S17=$(cnt_slots "$BASE/patches/v17-memory-RT.efi")
echo "  v16 .data.rel.ro lines: $S16   v17 .data.rel.ro lines: $S17"
if [ "$S17" -gt "$S16" ]; then
  echo "  FAIL  v17 grew .data.rel.ro by $((S17-S16)) lines - new pointer slots are the v12/v14 BSOD class"
  exit 1
fi
echo "  PASS  .data.rel.ro did not grow (no new pointer slots)"
echo "binary checks passed"
fi

# ---------------------------------------------------------------- sandbox
if want sandbox && [ "$SKIP_SANDBOX" -eq 0 ]; then
step "[5/7] sandbox validation (Alpine EFI-stub boots)"
A_OK=0; B_OK=0
bash "$BASE/scripts/test-v17-linux.sh" A 300 && A_OK=1 || true
bash "$BASE/scripts/test-v17-linux.sh" B 300 && B_OK=1 || true
echo
echo "sandbox: RT=$([ $A_OK -eq 1 ] && echo PASS || echo FAIL)  SAFE=$([ $B_OK -eq 1 ] && echo PASS || echo FAIL)"
if [ $A_OK -ne 1 ] || [ $B_OK -ne 1 ]; then
  echo "FATAL: sandbox validation failed — NOT packaging. Inspect test-v17/serial-l{A,B}.log"
  exit 1
fi
else
  step "[5/7] sandbox validation SKIPPED (--skip-sandbox)"
fi

# ---------------------------------------------------------------- package
if want package; then
step "[6/7] package infinity-qemu-test-v17"
rm -rf "$BASE/build/pkg-v17"; mkdir -p "$BASE/build"
cp -a "$TEMPLATE" "$PKGDIR"
# strip template leftovers we do not want in v17
rm -f "$PKGDIR/trigger-test.ps1" "$PKGDIR/usb-d/trigger-test.ps1" "$PKGDIR/VERSION.txt" "$PKGDIR/README-FA.md" "$PKGDIR/trigger-test-v16.ps1" "$PKGDIR/usb-d/trigger-test-v16.ps1"
# new binaries
cp "$BASE/patches/v17-memory-SAFE.efi" "$PKGDIR/usb/memory.efi"
cp "$BASE/patches/v17-memory-SAFE.efi" "$PKGDIR/usb-c/memory.efi"
cp "$BASE/patches/v17-memory-RT.efi"   "$PKGDIR/usb-d/memory.efi"
# v17 script + docs everywhere the user might look
for d in "." "usb-d" "transfer"; do
  cp "$BASE/infinity-qemu-test/trigger-test-v17.ps1" "$PKGDIR/$d/trigger-test-v17.ps1"
done
cp "$BASE/infinity-qemu-test/README-V17-FA.md" "$PKGDIR/README-V17-FA.md"
# phase-d.bat: v17 edition — built by scripts/patch-v17-bat.py (bumps the proven v16 bat)
python3 "$BASE/scripts/patch-v17-bat.py"
cp "$BASE/infinity-qemu-test/phase-d.bat" "$PKGDIR/phase-d.bat"
# refresh-files hint line
sed -i 's/package v9+/package v17+/g' "$PKGDIR/refresh-files.bat"
# guard simulation: the phase-d pre-flight must pass against this exact package
if ! grep -q "trigger test v17" "$PKGDIR/usb-d/trigger-test-v17.ps1"; then
  echo "FATAL: guard simulation: usb-d script lacks the 'trigger test v17' marker"; exit 1
fi
echo "  guard simulation PASS (usb-d trigger-test-v17.ps1 carries the marker)"
# VERSION.txt
SHA_SAFE=$(sha256sum "$PKGDIR/usb/memory.efi"    | awk '{print toupper($1)}')
SHA_RT=$(sha256sum   "$PKGDIR/usb-d/memory.efi"  | awk '{print toupper($1)}')
SHA_SCR=$(sha256sum  "$PKGDIR/trigger-test-v17.ps1" | awk '{print toupper($1)}')
SZ_SAFE=$(stat -c%s  "$PKGDIR/usb/memory.efi"); SZ_RT=$(stat -c%s "$PKGDIR/usb-d/memory.efi")
cat > "$PKGDIR/VERSION.txt" <<EOF
INFINITY QEMU TEST PACKAGE - v17
================================
Date: $(date -u +%Y-%m-%d)

WHAT v17 IS (the data-path proof on top of the COMPLETE bridge):
  The v16 field run (2026-09-21) printed the script's own verdict:
  ">>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<" (PONG PERFECT,
  win_build 19045=19045, INFCNT=2, TRIGGER-SEEN set, stage 4).
  v17 proves the last unproven piece - the DATA path that the
  real client (Infinity.exe) uses for process memory:
    1. Driver: ONE surgical addition. A ReqOp_Read with
       pid=0xFFFFFFFF (KERNEL_TARGET_PID) is answered from the
       CALLER's address space: ReadKernelVA walks the current
       CR3 (inside the gRT hook = the calling Windows thread's
       page tables, which map KUSER_SHARED_DATA). All data
       reads go through ReadPhysical (UEFI identity map): a
       bad/unmapped/non-canonical VA fails the page walk BEFORE
       any dereference - no #PF/#GP path exists. Writes keep
       the target-process-only rule. The real client flow
       (attach -> read) is byte-identical to v16.
    2. Script: trigger-test-v17.ps1 adds steps H..N - the
       InfinityData buffer round trip (byte-exact), ReqOp_Attach
       decode, kernel reads of KUSD +0x260 (expect 19045) and
       +0x308 (expect 0), an 8-byte chunk read consistency
       check, a NEGATIVE read (non-canonical VA -> ErrAccess,
       no crash), and the final INFCNT=8 accounting.
    3. v16 field defect fixed: the boot stick (D:) is READ-ONLY
       by design, so "save the transcript beside the script"
       could never work - v17 probes writability and falls back
       Desktop -> TEMP, verifies the file at the end, and prints
       copy-out instructions (transfer stick + refresh-files).
  Run trigger-test-v17.ps1 (elevated) after phase-d.bat boots.

KEY FILE HASHES (SHA256):
  memory.efi v17 SAFE ($SZ_SAFE bytes): usb\\memory.efi + usb-c\\memory.efi
    $SHA_SAFE
  memory.efi v17 RT ($SZ_RT bytes): usb-d\\memory.efi
    $SHA_RT
  trigger-test-v17.ps1
    $SHA_SCR

DRIVER SOURCE LINEAGE (reproducible):
  fulken/Infinity @ $PIN (branch uefi-full-migration)
  + patches/v7-on-a8e41b3.diff   (v7 source)
  + scripts/patch-v13.py         (v8 counter policy + v13 safe observability)
  + scripts/patch-v14.py         (GUID semantics fix + live KUSD build + dual-write chain)
  + scripts/patch-v15.py         (hex-safe serial tables + KUSD dual-offset probe)
  + scripts/patch-v16.py         (cosmetics: banners, clean serial labels, EBS note)
  + scripts/patch-v17.py         (kernel-target read: KERNEL_TARGET_PID + ReadKernelVA + handler branch)

WHAT DID NOT CHANGE:
  - firmware/ (OVMF), phase-a/b/c/b-check scripts, refresh-files flow
  - boot chain: phase-d.bat (guard now says v17)
EOF
# zip (flat structure, same as v9)
cd "$PKGDIR"
rm -f "$BASE/download/infinity-qemu-test-v17.zip"
zip -r -q "$BASE/download/infinity-qemu-test-v17.zip" . -x '.git/*'
cd "$BASE"
cp download/infinity-qemu-test-v17.zip version-archive/packages/
echo "package: download/infinity-qemu-test-v17.zip ($(stat -c%s download/infinity-qemu-test-v17.zip) bytes)"
fi

# ---------------------------------------------------------------- commit
if want commit; then
step "[7/7] commit (+ vault push via stored token)"
git add -A patches/v17-memory-SAFE.efi patches/v17-memory-RT.efi \
          scripts/patch-v17.py scripts/build-v17.sh scripts/test-v17-linux.sh \
          scripts/patch-v17-bat.py scripts/make-v17-script.py \
          infinity-qemu-test/trigger-test-v17.ps1 \
          infinity-qemu-test/README-V17-FA.md infinity-qemu-test/phase-d.bat \
          download/infinity-qemu-test-v17.zip version-archive/packages/infinity-qemu-test-v17.zip \
          version-archive/reports/ANALYSIS-V16.md \
          version-archive/reports/infinity-qemu-test-v16-Report.zip \
          .gitignore 2>/dev/null || true
git commit -q -m "v17: data-path proof build (kernel-target reads via current CR3, KERNEL_TARGET_PID, ReadKernelVA; negative-VA-safe); v16 field report archived - FULL BRIDGE PROVEN verdict confirmed (PONG PERFECT, win 19045=19045, INFCNT=2, stage 4); auto-tee read-only-boot-stick fix" \
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
echo "DONE: build-v17 pipeline complete"
