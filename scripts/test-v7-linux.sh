#!/usr/bin/env bash
# ============================================================================
# test-v7-linux.sh — direct EFI-stub Linux boot with the v7 driver
# (adapted from test-v6-linux.sh; v7 = EARLY gRT hook install at load)
#
# v7 expectations:
#   A (RT):  RT-EARLY traces at load, BOOT-CTX hook traces (shell/kernel-
#            stub variable calls pass through), EBS fired (stage 2),
#            VA event -> "hooks already installed at load (v7 early) -
#            keeping slots", conversions clean, va_done armed. Linux then
#            calls the first RT service -> NX #PF (known Linux limitation,
#            documented in v6; Windows is the real target).
#   B (SAFE): identical to v6 SAFE — full green boot to Alpine busybox.
#
# Usage: bash test-v7-linux.sh A|B   (A = RT build, B = SAFE build)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v7

NAME="${1:?usage: test-v7-linux.sh A|B}"
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
cp "$BASE/patches/v7-memory-$([ "$NAME" = A ] && echo RT || echo SAFE).efi" "$RIT/memory.efi"
cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"       "$RIT/EFI/BOOT/bootx64.efi"

cat > "$RIT/startup.nsh" <<'NSH'
echo === INFINITY v7 linux rig: load driver then boot kernel directly ===
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
cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-l$NAME.fd"
rm -f "$TDIR/serial-l$NAME.log" "$TDIR/mon-l$NAME.sock"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
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
grep -a -o '\[INF\]\[[A-Z-]*\][^[]*' "serial-l$NAME.log" | head -110
echo
echo "--- kernel evidence ---"
grep -a -o "Linux version [0-9][^\[]*\|Kernel panic[^\[]*\|Welcome to Alpine[^\[]*\|NX-protected[^\[]*\|EFI: [^\[]*" "serial-l$NAME.log" | head -14
