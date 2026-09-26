#!/usr/bin/env bash
# ============================================================================
# test-wb-ro.sh - two focused boots:
#  TEST WB: write-back at device_del - boot with a vvfat USB stick present
#           FROM BOOT (OVMF cannot hotplug-enumerate, so attach at start),
#           shell writes a file on it, we device_del it via the monitor and
#           check whether the file lands in the host transfer/ folder.
#  TEST RO: read-only vvfat (fat:DIR, readonly=on) as usb-storage - does
#           QEMU accept it (ide-hd rejected it) and does OVMF boot+read it?
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
O="$TDIR/ovf-d"
TR="$TDIR/transfer"
mkdir -p "$TDIR/vars"

# ================= TEST WB =================
rm -rf "$TR"; mkdir -p "$TR"
printf 'marker for wb test\n' > "$TR/INFMARK.TXT"

cat > "$O/startup.nsh" <<'NSH'
echo === WB TEST BEGIN ==
stall 3000000
map -r
echo == looking for stick ==
if exist FS1:\INFMARK.TXT then
  echo STICK IS FS1
  echo wb-guest-wrote-this > FS1:\FROMGUEST.TXT
  type FS1:\FROMGUEST.TXT
  echo WBDONE
endif
if exist FS2:\INFMARK.TXT then
  echo STICK IS FS2
  echo wb-guest-wrote-this > FS2:\FROMGUEST.TXT
  type FS2:\FROMGUEST.TXT
  echo WBDONE
endif
echo === WB SCRIPT END ==
NSH
python3 -c "
p='$O/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-wb.fd"
rm -f "$TDIR/serial-wb.log" "$TDIR/mon-wb.log"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-wb.fd" \
  -drive if=none,file=fat:rw:ovf-d,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -drive if=none,file=fat:rw:512M:transfer,format=raw,id=infstick0,cache=writeback \
  -device usb-storage,id=infstick,drive=infstick0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor telnet:127.0.0.1:5555,server,nowait \
  -serial file:"serial-wb.log" >/dev/null 2>&1 &
QPID=$!
echo "WB: QEMU pid $QPID"

python3 - <<'PYEOF'
import socket, time, os
T0=time.time()
def log(m): print('[wb %6.1fs] %s' % (time.time()-T0, m), flush=True)
SER='/home/z/my-project/test-v6/serial-wb.log'
TR='/home/z/my-project/test-v6/transfer'
def wait_serial(marker, timeout):
    pos=0; end=time.time()+timeout
    while time.time()<end:
        try:
            with open(SER,'rb') as f:
                f.seek(pos); d=f.read()
            if marker.encode() in d: return True
            pos+=len(d)
        except FileNotFoundError: pass
        time.sleep(3)
    return False

for _ in range(20):
    try:
        s=socket.create_connection(('127.0.0.1',5555),timeout=5); break
    except OSError: time.sleep(2)
else:
    log('no monitor'); raise SystemExit(1)
s.settimeout(2); buf=b''
def rp(t=10):
    global buf
    end=time.time()+t
    while time.time()<end:
        try:
            d=s.recv(4096)
            if not d: break
            buf+=d
            if b'(qemu)' in buf[-300:]: break
        except socket.timeout: pass
    out=buf; buf=b''; return out
def cmd(c,t=12):
    s.sendall(c.encode()+b'\n'); return rp(t).decode('ascii','replace')
rp(4)
if wait_serial('WB SCRIPT END', 200):
    log('guest script finished (stick seen+written, see serial)')
else:
    log('guest script did not finish; continuing to unplug anyway')
cmd('device_del infstick'); time.sleep(4)
log('device_del done')
cmd('drive_del infstick0'); time.sleep(3)
log('drive_del done')
wb=os.path.join(TR,'FROMGUEST.TXT')
if os.path.exists(wb) and os.path.getsize(wb)>0:
    log('WRITE-BACK AT DEVICE_DEL: YES - %d bytes landed on host' % os.path.getsize(wb))
else:
    log('WRITE-BACK AT DEVICE_DEL: not yet visible')
cmd('info block')
cmd('quit'); time.sleep(3)
if os.path.exists(wb) and os.path.getsize(wb)>0:
    log('WRITE-BACK AFTER QUIT: YES - %d bytes' % os.path.getsize(wb))
elif os.path.exists(wb):
    log('file exists but 0 bytes after quit')
else:
    log('WRITE-BACK FAILED: file never appeared on host')
PYEOF
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "--- WB serial (tail) ---"
tr -d '\r' < "$TDIR/serial-wb.log" | grep -a -E "WB TEST|STICK|WBDONE|wb-guest|SCRIPT END" | head -10
echo "--- transfer dir after WB test ---"
ls -la "$TR"

# ================= TEST RO =================
echo
echo "================ TEST RO: read-only vvfat as usb-storage ================"
cat > "$O/startup.nsh" <<'NSH'
echo === RO TEST BEGIN ==
ls FS0:\
if exist FS0:\trigger-test.ps1 then
  echo RO READ OK trigger-test.ps1 visible
endif
comp FS0:\trigger-test.ps1 FS0:\infinity-qemu-test\usb-d\trigger-test.ps1
echo === RO SCRIPT END ==
NSH
python3 -c "
p='$O/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"
cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-ro.fd"
rm -f "$TDIR/serial-ro.log" "$TDIR/qemu-ro.err"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-ro.fd" \
  -drive if=none,file=fat:ovf-d,format=raw,id=bootdrv,readonly=on \
  -device usb-storage,drive=bootdrv,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -serial file:"serial-ro.log" >/dev/null 2>"qemu-ro.err" &
QPID=$!
echo "RO: QEMU pid $QPID (vvfat READ-ONLY + usb-storage)"
sleep 100
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "--- RO qemu stderr ---"; head -5 "$TDIR/qemu-ro.err"
echo "--- RO serial ---"
tr -d '\r' < "$TDIR/serial-ro.log" 2>/dev/null | grep -a -v '^$' | tail -25
