#!/usr/bin/env bash
# ============================================================================
# test-wb2.sh - write-back timing test.
# Boot FROM a fat:rw vvfat usb stick (the only case where the OVMF shell
# can see+write a USB stick - it does not enumerate non-boot sticks).
# startup.nsh (which lives ON the stick) writes FROMGUEST.TXT to itself,
# prints a marker, and stalls. The monitor then device_del+drive_del the
# stick and we check whether FROMGUEST.TXT lands in the host folder:
#   - at device_del  -> write-back flushes on unplug (best case)
#   - after quit     -> write-back at QEMU exit only
#   - never          -> guest->host via stick unreliable (document it)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
cd "$TDIR"

rm -rf wbstick; mkdir -p wbstick/EFI/BOOT
cp "$PKG/usb-c/EFI/BOOT/bootx64.efi" wbstick/EFI/BOOT/bootx64.efi
printf 'wb marker\n' > wbstick/WBMARK.TXT

cat > wbstick/startup.nsh <<'NSH'
echo === WB2 BEGIN ==
echo wb-guest-wrote-this-98765 > FS0:\FROMGUEST.TXT
if exist FS0:\FROMGUEST.TXT then
  echo GUEST WRITE VISIBLE
  type FS0:\FROMGUEST.TXT
endif
echo === WBWRITE DONE ==
stall 30000000
echo === WB2 SCRIPT END ==
NSH
python3 -c "
p='$TDIR/wbstick/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-wb2.fd"
rm -f serial-wb2.log
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-wb2.fd" \
  -drive if=none,file=fat:rw:wbstick,format=raw,id=bootdrv \
  -device usb-storage,id=stickdev,drive=bootdrv,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor telnet:127.0.0.1:5555,server,nowait \
  -serial file:"serial-wb2.log" >/dev/null 2>&1 &
QPID=$!
echo "WB2: QEMU pid $QPID"

python3 - <<'PYEOF'
import socket, time, os
T0 = time.time()
def log(m): print('[wb2 %6.1fs] %s' % (time.time()-T0, m), flush=True)
SER = '/home/z/my-project/test-v6/serial-wb2.log'
HOSTDIR = '/home/z/my-project/test-v6/wbstick'
def wait_serial(marker, timeout):
    pos = 0; end = time.time() + timeout
    while time.time() < end:
        try:
            with open(SER, 'rb') as f:
                f.seek(pos); d = f.read(); pos += len(d)
            if marker.encode() in d: return True
        except FileNotFoundError: pass
        time.sleep(3)
    return False
for _ in range(20):
    try:
        s = socket.create_connection(('127.0.0.1', 5555), timeout=5); break
    except OSError: time.sleep(2)
else:
    raise SystemExit('no monitor')
s.settimeout(2); buf = b''
def rp(t=10):
    global buf
    end = time.time() + t
    while time.time() < end:
        try:
            d = s.recv(4096)
            if not d: break
            buf += d
            if b'(qemu)' in buf[-300:]: break
        except socket.timeout: pass
    out, buf = buf, b''
    return out
def cmd(c, t=12):
    s.sendall(c.encode() + b'\n')
    return rp(t).decode('ascii', 'replace')
rp(4)

if not wait_serial('WBWRITE DONE', 240):
    log('guest never wrote the file - ABORT')
    cmd('quit'); raise SystemExit(1)
log('guest wrote FROMGUEST.TXT on the stick (visible in-guest)')

cmd('device_del stickdev'); time.sleep(5)
log('device_del done')
cmd('drive_del bootdrv'); time.sleep(4)
log('drive_del done')

wb = os.path.join(HOSTDIR, 'FROMGUEST.TXT')
if os.path.exists(wb) and os.path.getsize(wb) > 0:
    log('WRITE-BACK AT DEVICE_DEL: YES (%d bytes) - refresh = bidirectional!' % os.path.getsize(wb))
else:
    log('not visible after device_del - checking after quit...')
    cmd('quit'); time.sleep(4)
    if os.path.exists(wb) and os.path.getsize(wb) > 0:
        log('WRITE-BACK AT QEMU EXIT: YES (%d bytes) - files arrive when the VM stops' % os.path.getsize(wb))
    elif os.path.exists(wb):
        log('file appeared but 0 bytes')
    else:
        log('WRITE-BACK FAILED COMPLETELY - guest->host via stick unreliable')
PYEOF
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "--- WB2 serial ---"
tr -d '\r' < serial-wb2.log | sed 's/\x1b\[[0-9;]*[A-Za-z]//g' | grep -a -E "WB2|GUEST|FROMGUEST|wb-guest" | head -8
echo "--- wbstick dir after test ---"
ls -la wbstick/
