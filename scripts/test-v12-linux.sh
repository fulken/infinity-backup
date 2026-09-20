#!/usr/bin/env bash
# ============================================================================
# test-v12-linux.sh — sandbox validation of the v12 driver
# (adapted from test-v7-linux.sh; v12 = observability build:
#  cumulative HookEnter counter, no HookEnter persist, INFDIAG read
#  freshen post-VM, our-namespace write attribution + INFCNT)
#
# v12 expectations:
#   A (RT):  "[INF][RT-EARLY] memory.efi v12 RT" marker, gRT hooks
#            installed at load, BOOT-CTX hook traces (#1..#8 sampled,
#            #64/#128 from the cumulative counter), EBS fired
#            (stage 2), VA event -> "(v12 early) - keeping slots",
#            stage 3 write, all ConvertPointers st=0, va_done armed.
#            Linux then hits the known NX #PF on the first RT service
#            call (documented since v6 — Windows is the real target);
#            a page fault AFTER the full green chain is a PASS.
#   B (SAFE): full green boot to Alpine busybox, driver loads
#            (stage 1 write), NO gRT hook lines at all.
#
# Usage: bash test-v12-linux.sh A|B   (A = RT build, B = SAFE build)
# Exit status: 0 = PASS, 1 = FAIL (grep verdicts at the end)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
TDIR=$BASE/test-v12

NAME="${1:?usage: test-v12-linux.sh A|B}"
BUDGET="${2:-420}"

mkdir -p "$TDIR/vars"

# ---------- extract kernel + initramfs from the ISO (once) ----------
VMLINUX="$TDIR/vmlinuz"
INITRD="$TDIR/initrd.img"
if [ ! -f "$VMLINUX" ] || [ ! -f "$INITRD" ]; then
  echo "-- extracting /BOOT/VMLINUZ_VIRT and INITRAMFS_VIRT from alpine.iso --"
  python3 "$BASE/scripts/iso_extract.py" "$BASE/alpine.iso" \
      '/BOOT/VMLINUZ_VIRT.;1' "$VMLINUX" '/BOOT/INITRAMFS_VIRT.;1' "$INITRD"
fi
ls -la "$VMLINUX" "$INITRD"

# ---------- build the linux-boot ritual FAT ----------
RIT="$TDIR/usb-l$NAME"
rm -rf "$RIT"; mkdir -p "$RIT/EFI/BOOT"
cp "$TDIR/vmlinuz"                          "$RIT/vmlinuz"
cp "$TDIR/initrd.img"                       "$RIT/initrd.img"
case "$NAME" in
  A) cp "$BASE/patches/v12-memory-RT.efi"   "$RIT/memory.efi" ;;
  B) cp "$BASE/patches/v12-memory-SAFE.efi" "$RIT/memory.efi" ;;
  *) echo "bad name $NAME"; exit 2 ;;
esac
cp "$BASE/upload/extracted-v9-full/usb-c/EFI/BOOT/bootx64.efi" "$RIT/EFI/BOOT/bootx64.efi"

cat > "$RIT/startup.nsh" <<'NSH'
echo === INFINITY v12 linux rig: load driver then boot kernel directly ===
if exist FS0:\memory.efi then
  load FS0:\memory.efi
endif
if exist FS1:\memory.efi then
  load FS1:\memory.efi
endif
if exist FS2:\memory.efi then
  load FS2:\memory.efi
endif
if exist FS3:\memory.efi then
  load FS3:\memory.efi
endif
if exist FS4:\memory.efi then
  load FS4:\memory.efi
endif
echo === driver stage done, booting kernel ===
if exist FS0:\vmlinuz then
  FS0:\vmlinuz console=ttyS0,115200 panic=-1 efi=debug initrd=\initrd.img
endif
if exist FS1:\vmlinuz then
  FS1:\vmlinuz console=ttyS0,115200 panic=-1 efi=debug initrd=\initrd.img
endif
if exist FS2:\vmlinuz then
  FS2:\vmlinuz console=ttyS0,115200 panic=-1 efi=debug initrd=\initrd.img
endif
if exist FS3:\vmlinuz then
  FS3:\vmlinuz console=ttyS0,115200 panic=-1 efi=debug initrd=\initrd.img
endif
if exist FS4:\vmlinuz then
  FS4:\vmlinuz console=ttyS0,115200 panic=-1 efi=debug initrd=\initrd.img
endif
echo === ERROR: kernel not found ===
NSH
python3 -c "
p='$RIT/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

# ---------- run ----------
cp "$BASE/upload/extracted-v9-full/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-l$NAME.fd"
rm -f "$TDIR/serial-l$NAME.log" "$TDIR/mon-l$NAME.sock"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$BASE/upload/extracted-v9-full/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-l$NAME.fd" \
  -drive if=none,file=fat:rw:$RIT,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor unix:"mon-l$NAME.sock",server,nowait \
  -serial file:"serial-l$NAME.log" >/dev/null 2>&1 &
QPID=$!
echo "QEMU started (pid $QPID), budget ${BUDGET}s (early exit on kernel panic)"

t=0
while [ "$t" -lt "$BUDGET" ]; do
  sleep 20; t=$((t+20))
  if ! kill -0 "$QPID" 2>/dev/null; then
    echo "[t=${t}s] QEMU exited on its own (panic->reboot->-no-reboot)"; break
  fi
  sz=$(wc -c < "serial-l$NAME.log" 2>/dev/null || echo 0)
  kern=$(grep -a -c 'Linux version' "serial-l$NAME.log" 2>/dev/null || echo 0)
  echo "[t=${t}s] alive, size=${sz}B linux_booted=${kern}"
done
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "run finished."
echo
echo "--- INFDIAG from vars pflash ---"
python3 "$BASE/scripts/check_diag.py" "$TDIR/vars/vars-l$NAME.fd" 2>&1 | head -8
echo
echo "--- [INF] trace lines (full) ---"
grep -a -o '\[INF\]\[[A-Z-]*\][^[]*' "$TDIR/serial-l$NAME.log" | head -110
echo
echo "--- kernel evidence ---"
grep -a -o "Linux version [0-9][^\[]*\|Kernel panic[^\[]*\|Welcome to Alpine[^\[]*\|NX-protected[^\[]*\|EFI: [^\[]*" "$TDIR/serial-l$NAME.log" | head -14

# ================= verdict =================
LOG="$TDIR/serial-l$NAME.log"
has() { grep -a -q -- "$1" "$LOG"; }
cnt() { grep -a -c -- "$1" "$LOG" 2>/dev/null || true; }

echo
echo "================ VERDICT ($NAME) ================"
PASS=1
if [ "$NAME" = A ]; then
  for pat in \
    '\[INF\]\[RT-EARLY\] memory.efi v12 RT' \
    'gRT hooks INSTALLED at load time' \
    '\[INF\]\[HOOK\] . BOOT-CTX call#' \
    '\[INF\]\[DIAG\] write stage=2' \
    '\[INF\]\[VA\] SetVirtualAddressMap event FIRED' \
    'hooks already installed at load (v12 early)' \
    '\[INF\]\[DIAG\] write stage=3' \
    '\[INF\]\[VA\] virtual mode armed'
  do
    if has "$pat"; then echo "  PASS  $pat"; else echo "  FAIL  $pat"; PASS=0; fi
  done
  # conversion failures must be zero
  cvt_bad=$(grep -a -o '\[INF\]\[CVT\][^(]*st=0x[0-9A-F]*' "$LOG" | grep -vc 'st=0x00000000' || true)
  if [ "${cvt_bad:-0}" -eq 0 ]; then echo "  PASS  all ConvertPointer st=0"; else echo "  FAIL  $cvt_bad ConvertPointer failures"; PASS=0; fi
  # kernel: either Alpine reached (great) or the known NX panic after the chain
  if has 'Linux version'; then
    echo "  PASS  Linux kernel booted (EFI stub)"
  else
    echo "  FAIL  Linux kernel never started"; PASS=0
  fi
  if has 'Welcome to Alpine'; then
    echo "  NOTE  Alpine userspace reached (NX did not bite this run)"
  elif has 'Kernel panic' || has 'page fault' || has 'BUG:'; then
    echo "  PASS  expected post-chain NX/kernel stop (documented Linux limitation)"
  fi
else
  # B (SAFE) — driver's contract only: stage-1 write, kernel boots, NO hooks.
  # "Welcome to Alpine" is NOT required: the archived v7 SAFE run
  # (test-v7/artifacts/serial-lB.log) hit the same initramfs boot-media
  # mount quirk (vvfat under TCG) and dropped to the recovery shell —
  # kernel-space behavior is identical and that is all the driver touches.
  for pat in \
    '\[INF\]\[DIAG\] write stage=1' \
    'Linux version' \
    'Run /init as init process'
  do
    if has "$pat"; then echo "  PASS  $pat"; else echo "  FAIL  $pat"; PASS=0; fi
  done
  if has 'Welcome to Alpine'; then
    echo "  NOTE  Alpine userspace reached (media mount worked this run)"
  elif has 'emergency recovery shell'; then
    echo "  NOTE  initramfs boot-media mount quirk (same as archived v7 SAFE run) - not driver-related"
  fi
  if has '\[INF\]\[RT-EARLY\]'; then
    echo "  FAIL  SAFE build must not install gRT hooks"; PASS=0
  else
    echo "  PASS  no gRT hook lines (SAFE)"
  fi
fi
echo "================ $NAME: $([ $PASS -eq 1 ] && echo PASS || echo FAIL) ================"
[ $PASS -eq 1 ]
