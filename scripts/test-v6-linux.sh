#!/usr/bin/env bash
# ============================================================================
# test-v6-linux.sh — direct EFI-stub Linux boot with the v6 driver
#
# Instead of fighting GRUB's interactive menu, boot Alpine's EFI-stub
# kernel DIRECTLY from the EFI shell:
#   startup.nsh: load memory.efi ; FSx:\vmlinuz console=ttyS0 panic=-1
#               initrd=\initrd.img
# The EFI stub calls ExitBootServices (EBS trace), the kernel calls
# SetVirtualAddressMap (VA trace), then early-kernel RT service calls
# hit our gRT hooks (HOOK traces). The boot eventually dies on the
# missing ISO root (modloop/apks) — we don't care, all milestones fire
# long before that. panic=-1 + -no-reboot = clean early QEMU exit.
#
# Usage: bash test-v6-linux.sh A|B   (A = RT build, B = SAFE build)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6

NAME="${1:?usage: test-v6-linux.sh A|B}"
BUDGET="${2:-420}"

# ---------- extract kernel + initramfs from the ISO (once) ----------
VMLINUX="$TDIR/vmlinuz"
INITRD="$TDIR/initrd.img"
if [ ! -f "$VMLINUX" ] || [ ! -f "$INITRD" ]; then
  echo "-- extracting /BOOT/VMLINUZ_VIRT and INITRAMFS_VIRT from alpine.iso --"
  python3 - "$BASE/alpine.iso" "$VMLINUX" "$INITRD" <<'PYEOF'
import sys, pycdlib
iso = pycdlib.PyCdlib(); iso.open(sys.argv[1])
for src, dst in [('/BOOT/VMLINUZ_VIRT.;1', sys.argv[2]),
                 ('/BOOT/INITRAMFS_VIRT.;1', sys.argv[3])]:
    f = iso.open_file_from_iso(iso_path=src)
    with open(dst, 'wb') as out:
        while True:
            chunk = f.read(1 << 20)
            if not chunk: break
            out.write(chunk)
    print('extracted', src, '->', dst)
PYEOF
fi
ls -la "$VMLINUX" "$INITRD"

# ---------- build the linux-boot ritual FAT ----------
RIT="$TDIR/usb-l$NAME"
rm -rf "$RIT"; mkdir -p "$RIT/EFI/BOOT"
cp "$TDIR/vmlinuz"                          "$RIT/vmlinuz"
cp "$TDIR/initrd.img"                       "$RIT/initrd.img"
cp "$BASE/v6-memory-$([ "$NAME" = A ] && echo RT || echo SAFE).efi" "$RIT/memory.efi"
cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"       "$RIT/EFI/BOOT/bootx64.efi"

cat > "$RIT/startup.nsh" <<'NSH'
echo === INFINITY v6 linux rig: load driver then boot kernel directly ===
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
unix2dos "$RIT/startup.nsh" 2>/dev/null || python3 -c "
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
grep -a -o '\[INF\]\[[A-Z]*\][^[]*' "serial-l$NAME.log" | head -90
echo
echo "--- kernel evidence ---"
grep -a -o "Linux version [0-9][^\[]*\|Kernel panic[^\[]*\|Welcome to Alpine[^\[]*\|EFI: [^\[]*" "serial-l$NAME.log" | head -12
