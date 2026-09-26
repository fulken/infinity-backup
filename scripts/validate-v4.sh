#!/usr/bin/env bash
# Validate v4 check flow: new startup.nsh must find INFDIAG via -guid
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
PKG=$BASE/infinity-qemu-test
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

TDIR=$BASE/test-v4; rm -rf "$TDIR"; mkdir -p "$TDIR"
cp "$PKG/firmware/OVMF_CODE_4M.fd" "$TDIR/"
# vars WITH a real INFDIAG (stage 1) from the previous full Linux boots
cp "$BASE/test-c-final/vars.fd" "$TDIR/OVMF_VARS_4M.fd"

cd "$TDIR"
timeout 60 "$QEMU" -L "$BASE/qemu-bios" -machine q35 -m 1024 -accel tcg \
 -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE_4M.fd \
 -drive if=pflash,format=raw,file=OVMF_VARS_4M.fd \
 -drive if=none,file=fat:rw:$PKG/usb-check,format=raw,id=chkdrv \
 -device ide-hd,drive=chkdrv,bootindex=0 \
 -nic none -no-reboot -display none -serial file:serial-check.log

echo "qemu exit: $?"
echo "=== dmpstore section of serial log ==="
grep -a -o "dmpstore[^\[]*\|Variable [^\[]*\|00000000:[^\[]*\|00000010:[^\[]*\|No matching[^\[]*\|=== end ===" serial-check.log | head -12
echo "=== verdict ==="
if grep -aq "44 46 4E 49" serial-check.log && grep -aq "01 00 00 00" serial-check.log; then
  echo "GREEN: INFDIAG found with correct GUID + stage 1 visible"
else
  echo "RED: variable data not shown - check output above"
fi
