#!/usr/bin/env bash
# syntax-probe.sh - one boot, one serial log, all shell-syntax answers
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
O="$TDIR/ovf-d"

cat > "$O/startup.nsh" <<'NSH'
echo === SYNTAX PROBE BEGIN ===
echo P1 stall
stall 2000000
echo P1 OK
echo P2 for-in
for %c in 1 2 3
  echo P2 iter %c
endfor
echo P2 done
echo P4 ifexist
map -r
if exist FS0:\startup.nsh then
  echo P4 FS0 has startup.nsh
endif
echo P4 done
echo P5 echo-redirect
echo redirect-probe-xyz > FS0:\REDIR.TXT
if exist FS0:\REDIR.TXT then
  echo P5 redirect CREATED the file
  type FS0:\REDIR.TXT
  rm FS0:\REDIR.TXT
endif
echo P5 done
echo P6 for-run LAST
for %e run 1 3
  echo P6 iter %e
endfor
echo P6 done
echo === SYNTAX PROBE END ===
NSH
python3 -c "
p='$O/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-probe.fd"
rm -f "$TDIR/serial-probe.log"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-probe.fd" \
  -drive if=none,file=fat:rw:ovf-d,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -serial file:"serial-probe.log" >/dev/null 2>&1 &
QPID=$!
echo "probe QEMU pid $QPID"
for i in $(seq 1 24); do
  sleep 10
  if grep -aq 'SYNTAX PROBE END' serial-probe.log 2>/dev/null; then
    echo "probe finished at t=$((i*10))s"; break
  fi
  if ! kill -0 "$QPID" 2>/dev/null; then echo "QEMU died at t=$((i*10))s"; break; fi
done
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "=== PROBE SERIAL ==="
tr -d '\r' < serial-probe.log | grep -a -v '^$'
