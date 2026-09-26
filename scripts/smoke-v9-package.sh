#!/usr/bin/env bash
# ============================================================================
# smoke-v9-package.sh - validate the SHIPPED v9 package configuration:
#   - boot from the real package usb-d/ attached EXACTLY like phase-d.bat
#     v9 does: fat: (read-only) + usb-storage bootindex=0
#   - plus a dummy Windows disk on IDE bus=ide.0 bootindex=1
#   - the v8 RT driver ritual must complete (banner + RT-EARLY + stage 1 +
#     INFDIAG in NVRAM) and reach "Windows not found" (designed outcome
#     with an empty disk)
#   - the monitor port + the EXACT refresh-files.ps1 command strings must
#     hotplug/unplug the transfer stick (QEMU-side verification)
#   - the package usb-d folder must be BYTE-IDENTICAL before/after (RO proof)
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
IMG=$BASE/qemu-utils-root/usr/bin/qemu-img
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu:$BASE/qemu-utils-root/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
mkdir -p "$TDIR/vars"
cd "$TDIR"

# hash the shipped usb-d before (RO proof)
BEFORE=$(find "$PKG/usb-d" -type f -exec sha256sum {} + | sort | sha256sum)

# dummy "Windows" disk (empty qcow2 - ritual must fail to find bootmgfw)
rm -f dummy-win.qcow2
"$IMG" create -f qcow2 dummy-win.qcow2 2G >/dev/null

# transfer stick content (what refresh would deliver)
rm -rf transfer; mkdir -p transfer
cp "$BASE/download/trigger-test-v10.ps1" transfer/trigger-test.ps1
printf 'smoke marker\n' > transfer/SMOKE.TXT

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-smoke9.fd"
rm -f serial-smoke9.log

setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-smoke9.fd" \
  -drive if=none,file=fat:"$PKG/usb-d",format=raw,id=bootdrv,readonly=on \
  -device usb-storage,id=dstick,drive=bootdrv,bootindex=0 \
  -drive if=none,file=dummy-win.qcow2,format=qcow2,id=windisk \
  -device ide-hd,drive=windisk,bus=ide.0,bootindex=1 \
  -nic none -usb -device usb-tablet \
  -monitor telnet:127.0.0.1:5555,server,nowait \
  -no-reboot -display none \
  -serial file:"serial-smoke9.log" >/dev/null 2>&1 &
QPID=$!
echo "smoke9 QEMU pid $QPID"

python3 - <<'PYEOF'
import socket, time
T0 = time.time()
def log(m): print('[smoke %6.1fs] %s' % (time.time()-T0, m), flush=True)
SER = '/home/z/my-project/test-v6/serial-smoke9.log'
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
def rp(t=12):
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
def cmd(c, t=15):
    s.sendall(c.encode() + b'\n')
    return rp(t).decode('ascii', 'replace')
rp(4)

ok_ritual = wait_serial('Windows not found', 300)
log('boot ritual finished (Windows not found = designed outcome): %s' % ok_ritual)

# ---- EXACT refresh-files.ps1 commands ----
r1 = cmd('device_del infstick'); time.sleep(2)
r2 = cmd('drive_del infstick0'); time.sleep(1)
r3 = cmd('drive_add 0 if=none,id=infstick0,file=fat:rw:transfer,format=raw')
r4 = cmd('device_add usb-storage,id=infstick,drive=infstick0')
r5 = cmd('info block')
r6 = cmd('info usb')
import re
def clean(x): return re.sub(r'\x1b\[[0-9;]*[A-Za-z]', '', x).replace('\r', '')
c5, c6 = clean(r5), clean(r6)
log('drive_add accepted: %s' % ('infstick0' in c5))
log('device attached:   %s' % ('infstick' in c6))
log('info usb: ' + ' | '.join(l.strip() for l in c6.split('\n') if 'Device' in l))
time.sleep(2)
r7 = cmd('device_del infstick'); time.sleep(3)
r8 = cmd('drive_del infstick0')
r9 = cmd('info block')
c9 = clean(r9)
log('unplug clean (infstick0 gone): %s' % ('infstick0' not in c9))
cmd('quit')
PYEOF
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null

AFTER=$(find "$PKG/usb-d" -type f -exec sha256sum {} + | sort | sha256sum)
echo
echo "================ SMOKE 9 VERDICT ================"
echo "usb-d folder before: $BEFORE"
echo "usb-d folder after:  $AFTER"
[ "$BEFORE" = "$AFTER" ] && echo "USB-D BYTE-IDENTICAL (read-only proof): PASS" || echo "USB-D CHANGED: FAIL"
echo
echo "--- banner + [INF] chain from the SHIPPED package files ---"
grep -a -o '\[INF\]\[[A-Z-]*\][^[]*' serial-smoke9.log | head -25
echo
echo "--- banner ---"
grep -a -o "Build: v8[^[]*" serial-smoke9.log | head -2
echo
echo "--- INFDIAG in NVRAM ---"
python3 "$BASE/scripts/check_diag.py" "$TDIR/vars/vars-smoke9.fd" | head -10
