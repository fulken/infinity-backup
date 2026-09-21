#!/usr/bin/env bash
# ============================================================================
# smoke-v8-package.sh — boot the ACTUAL shipped usb-d/ ritual files (v8 RT)
# and verify the load-time chain (banner -> RT-EARLY -> stage 1) with no
# Windows disk attached (bootmgfw simply not found -> shell, as designed).
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
mkdir -p "$TDIR/vars"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-smoke8.fd"
rm -f "$TDIR/serial-smoke8.log"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-smoke8.fd" \
  -drive if=none,file=fat:rw:"$PKG/usb-d",format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -serial file:"serial-smoke8.log" >/dev/null 2>&1 &
QPID=$!
echo "QEMU pid $QPID — waiting for the load chain..."
sleep 75
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null

echo "--- [INF] lines from the SHIPPED package files ---"
grep -a -o '\[INF\]\[[A-Z-]*\][^[]*' "serial-smoke8.log" | head -40
echo
echo "--- banner check ---"
grep -a -o "Build: v8[^[]*" "serial-smoke8.log" | head -2
echo
echo "--- INFDIAG in NVRAM ---"
python3 "$BASE/scripts/check_diag.py" "$TDIR/vars/vars-smoke8.fd" | head -10
