#!/usr/bin/env bash
# ============================================================================
# test-v6.sh — sandbox validation of the v6 driver builds
#
# Usage: bash test-v6.sh A|B|all     (A = RT build, B = SAFE build)
#
# Alpine boots to an interactive boot menu on the serial console, so we
# drive it with QEMU monitor "sendkey ret" once the menu is up.
#
# Trace sequence expected in the serial log (LINUX order — note it is
# the REVERSE of Windows: the EFI stub calls ExitBootServices FIRST,
# the kernel calls SetVirtualAddressMap LATER from efi_enter_virtual_mode):
#   MAIN efi_main v6 ... -> DIAG stage=1
#   EBS  ExitBootServices hook FIRED -> cr3 -> build(0 on Linux) -> DIAG stage=2
#   VA   SetVirtualAddressMap event FIRED -> (RT) hook installs -> CVT lines
#        -> DIAG stage=3
#   HOOK (RT) kernel calls a hooked service -> stage=4 (or the known
#        Linux early-boot hang — the traces now show WHICH service hung it)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test

WHICH="${1:-all}"

TDIR=$BASE/test-v6
if [ ! -d "$TDIR/usb-d" ] || [ ! -d "$TDIR/usb-s" ]; then
  rm -rf "$TDIR"; mkdir -p "$TDIR/vars"
  mkdir -p "$TDIR/usb-d/EFI/BOOT" "$TDIR/usb-s/EFI/BOOT"
  cp "$BASE/v6-memory-RT.efi"           "$TDIR/usb-d/memory.efi"
  cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"  "$TDIR/usb-d/EFI/BOOT/bootx64.efi"
  cp "$PKG/usb-c/startup.nsh"           "$TDIR/usb-d/startup.nsh"
  cp "$BASE/v6-memory-SAFE.efi"         "$TDIR/usb-s/memory.efi"
  cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"  "$TDIR/usb-s/EFI/BOOT/bootx64.efi"
  cp "$PKG/usb-c/startup.nsh"           "$TDIR/usb-s/startup.nsh"
  # Sandbox-only: no Windows here — exit the shell so BDS boots the CD.
  printf 'exit\r\n' >> "$TDIR/usb-d/startup.nsh"
  printf 'exit\r\n' >> "$TDIR/usb-s/startup.nsh"
fi

sendkey () { # sendkey <sock> <key> [times]
  local sock="$1" key="$2" n="${3:-1}"
  python3 - "$sock" "$key" "$n" <<'PYEOF'
import socket, sys, time
sock, key, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
try:
    s = socket.socket(socket.AF_UNIX); s.connect(sock); s.settimeout(1.0)
    time.sleep(0.3)
    try: s.recv(65536)
    except Exception: pass
    for _ in range(n):
        s.sendall(("sendkey %s\n" % key).encode()); time.sleep(0.4)
        try: s.recv(65536)
        except Exception: pass
    s.close()
    print("sendkey OK: %s x%d" % (key, n))
except Exception as e:
    print("sendkey FAILED:", e)
PYEOF
}

run_test () {
  local name="$1" ritual="$2" tmo="$3"
  echo "=============================================================="
  echo "=== TEST $name : $([ "$name" = A ] && echo 'RT build + Alpine' || echo 'SAFE build + Alpine')"
  echo "=============================================================="
  cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-$name.fd"
  rm -f "$TDIR/serial-$name.log" "$TDIR/mon-$name.sock"
  ( cd "$TDIR" && "$QEMU" -L "$BASE/qemu-bios" \
      -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
      -rtc base=localtime \
      -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
      -drive if=pflash,format=raw,file="vars/vars-$name.fd" \
      -drive if=none,file=fat:rw:$ritual,format=raw,id=bootdrv \
      -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
      -drive if=none,file="$BASE/alpine.iso",format=raw,media=cdrom,id=linuxiso \
      -device ide-cd,drive=linuxiso,bus=ide.0,bootindex=1 \
      -nic none -usb -device usb-tablet \
      -no-reboot -display none \
      -monitor unix:"mon-$name.sock",server,nowait \
      -serial file:"serial-$name.log" & echo $! > "$TDIR/qemu-$name.pid" )
  sleep 60
  echo "-- pressing Enter on the Alpine menu --"
  sendkey "$TDIR/mon-$name.sock" ret 2
  # keep running until the per-test budget is over
  local waited=60
  while [ "$waited" -lt "$tmo" ]; do sleep 10; waited=$((waited+10)); done
  kill "$(cat "$TDIR/qemu-$name.pid")" 2>/dev/null
  sleep 1
  echo "qemu stopped (budget ${tmo}s)"
  echo
  echo "--- INFDIAG from vars pflash ---"
  python3 "$BASE/scripts/check_diag.py" "$TDIR/vars/vars-$name.fd" 2>&1 | head -8
  echo
  echo "--- [INF] trace lines (the v6 diagnostics) ---"
  grep -a -o '\[INF\]\[[A-Z]*\][^[]*' "$TDIR/serial-$name.log" | head -75
  echo
  echo "--- OS boot evidence ---"
  grep -a -o "memory.efi' loaded[^\[]*\|Welcome to Alpine[^\[]*\|login:[^\[]*\|Linux version [0-9][^\[]*" "$TDIR/serial-$name.log" | head -6
  echo
}

case "$WHICH" in
  A) run_test A "$TDIR/usb-d" 180 ;;
  B) run_test B "$TDIR/usb-s" 180 ;;
  *) run_test A "$TDIR/usb-d" 180; run_test B "$TDIR/usb-s" 180 ;;
esac

echo "=============================================================="
echo "V6 SANDBOX TEST [$WHICH] DONE — logs in $TDIR"
echo "=============================================================="
