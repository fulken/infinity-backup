#!/usr/bin/env bash
# ============================================================================
# test-v6-long.sh — long-budget sandbox run of ONE v6 build against Alpine
# Usage: bash test-v6-long.sh A|B [budget_seconds]
#
# QEMU is fully detached (setsid + /dev/null) so the calling shell never
# blocks on it; we poll the serial log, send Enter on the GRUB menu at
# t=90s (belt and braces), and stop at the budget.
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6

NAME="$1"; BUDGET="${2:-420}"
RITUAL="$TDIR/usb-$([ "$NAME" = A ] && echo d || echo s)"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-$NAME.fd"
rm -f "$TDIR/serial-$NAME.log" "$TDIR/mon-$NAME.sock" "$TDIR/qemu-$NAME.pid"

cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-$NAME.fd" \
  -drive if=none,file=fat:rw:$RITUAL,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -drive if=none,file="$BASE/alpine.iso",format=raw,media=cdrom,id=linuxiso \
  -device ide-cd,drive=linuxiso,bus=ide.0,bootindex=1 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor unix:"mon-$NAME.sock",server,nowait \
  -serial file:"serial-$NAME.log" >/dev/null 2>&1 &
echo $! > "$TDIR/qemu-$NAME.pid"
echo "QEMU started (pid $(cat "$TDIR/qemu-$NAME.pid")), budget ${BUDGET}s"

sendkey () {
  python3 - "$1" <<'PYEOF'
import socket, sys, time
sock = sys.argv[1]
try:
    s = socket.socket(socket.AF_UNIX); s.connect(sock); s.settimeout(1.0)
    time.sleep(0.3)
    try: s.recv(65536)
    except Exception: pass
    s.sendall(b"sendkey ret\n"); time.sleep(0.4)
    try: s.recv(65536)
    except Exception: pass
    s.close(); print("  sendkey ret -> OK")
except Exception as e:
    print("  sendkey FAILED:", e)
PYEOF
}

t=0
while [ "$t" -lt "$BUDGET" ]; do
  sleep 30; t=$((t+30))
  sz=$(wc -c < "$TDIR/serial-$NAME.log" 2>/dev/null || echo 0)
  inf=$(grep -a -c '\[INF\]' "$TDIR/serial-$NAME.log" 2>/dev/null || echo 0)
  kern=$(grep -a -c 'Linux version' "$TDIR/serial-$NAME.log" 2>/dev/null || echo 0)
  echo "[t=${t}s] size=${sz}B inf_lines=${inf} linux_booted=${kern}"
  if [ "$t" = "90" ]; then
    echo "-- sending Enter to GRUB menu --"
    sendkey "$TDIR/mon-$NAME.sock"
  fi
done

PID=$(cat "$TDIR/qemu-$NAME.pid" 2>/dev/null || echo 1)
kill "$PID" 2>/dev/null; sleep 2; kill -9 "$PID" 2>/dev/null
echo "QEMU stopped."
echo
echo "--- INFDIAG from vars pflash ---"
python3 "$BASE/scripts/check_diag.py" "$TDIR/vars/vars-$NAME.fd" 2>&1 | head -8
echo
echo "--- [INF] trace lines ---"
grep -a -o '\[INF\]\[[A-Z]*\][^[]*' "$TDIR/serial-$NAME.log" | head -75
echo
echo "--- OS boot evidence ---"
grep -a -o "memory.efi' loaded[^\[]*\|Welcome to Alpine[^\[]*\|login:[^\[]*\|Linux version [0-9][^\[]*" "$TDIR/serial-$NAME.log" | head -6
