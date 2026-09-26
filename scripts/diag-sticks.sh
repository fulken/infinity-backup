#!/usr/bin/env bash
# ============================================================================
# diag-sticks.sh - one boot, FOUR vvfat usb-storage sticks with different
# option combos, to isolate why a fat:rw:512M:... stick was invisible to
# OVMF at boot in the WB test while a plain fat: (RO) stick worked.
#   A: fat:rw:ta          (plain rw - no size, no cache)
#   B: fat:rw:512M:tb     (with the 512M size token)
#   C: fat:rw:tc + cache=writeback
#   D: fat:td             (read-only)
# The shell prints the mapping table; markers per stick tell us who is who.
# The monitor dumps info block for QEMU-side geometry of each.
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
O="$TDIR/ovf-d"
cd "$TDIR"
for v in a b c d; do
  rm -rf "t$v"; mkdir -p "t$v"
  printf "marker $v\n" > "t$v/MARK-$v.TXT"
done

cat > "$O/startup.nsh" <<'NSH'
echo === DIAG STICKS BEGIN ==
stall 5000000
echo == mapping round 1 ==
map
echo == probe round 1 ==
if exist FS1:\MARK-A.TXT then echo A-ON-FS1 endif
if exist FS1:\MARK-B.TXT then echo B-ON-FS1 endif
if exist FS1:\MARK-C.TXT then echo C-ON-FS1 endif
if exist FS1:\MARK-D.TXT then echo D-ON-FS1 endif
if exist FS2:\MARK-A.TXT then echo A-ON-FS2 endif
if exist FS2:\MARK-B.TXT then echo B-ON-FS2 endif
if exist FS2:\MARK-C.TXT then echo C-ON-FS2 endif
if exist FS2:\MARK-D.TXT then echo D-ON-FS2 endif
if exist FS3:\MARK-A.TXT then echo A-ON-FS3 endif
if exist FS3:\MARK-B.TXT then echo B-ON-FS3 endif
if exist FS3:\MARK-C.TXT then echo C-ON-FS3 endif
if exist FS3:\MARK-D.TXT then echo D-ON-FS3 endif
if exist FS4:\MARK-A.TXT then echo A-ON-FS4 endif
if exist FS4:\MARK-B.TXT then echo B-ON-FS4 endif
if exist FS4:\MARK-C.TXT then echo C-ON-FS4 endif
if exist FS4:\MARK-D.TXT then echo D-ON-FS4 endif
stall 10000000
echo == mapping round 2 (after 10s more) ==
map -r
if exist FS1:\MARK-A.TXT then echo R2-A-ON-FS1 endif
if exist FS1:\MARK-B.TXT then echo R2-B-ON-FS1 endif
if exist FS1:\MARK-C.TXT then echo R2-C-ON-FS1 endif
if exist FS1:\MARK-D.TXT then echo R2-D-ON-FS1 endif
if exist FS2:\MARK-A.TXT then echo R2-A-ON-FS2 endif
if exist FS2:\MARK-B.TXT then echo R2-B-ON-FS2 endif
if exist FS2:\MARK-C.TXT then echo R2-C-ON-FS2 endif
if exist FS2:\MARK-D.TXT then echo R2-D-ON-FS2 endif
if exist FS3:\MARK-A.TXT then echo R2-A-ON-FS3 endif
if exist FS3:\MARK-B.TXT then echo R2-B-ON-FS3 endif
if exist FS3:\MARK-C.TXT then echo R2-C-ON-FS3 endif
if exist FS3:\MARK-D.TXT then echo R2-D-ON-FS3 endif
if exist FS4:\MARK-A.TXT then echo R2-A-ON-FS4 endif
if exist FS4:\MARK-B.TXT then echo R2-B-ON-FS4 endif
if exist FS4:\MARK-C.TXT then echo R2-C-ON-FS4 endif
if exist FS4:\MARK-D.TXT then echo R2-D-ON-FS4 endif
echo === DIAG STICKS END ==
NSH
python3 -c "
p='$O/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-diag.fd"
rm -f "$TDIR/serial-diag.log" "$TDIR/mon-diag.log"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-diag.fd" \
  -drive if=none,file=fat:rw:ovf-d,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -drive if=none,file=fat:rw:ta,format=raw,id=stka \
  -device usb-storage,id=deva,drive=stka \
  -drive if=none,file=fat:rw:512M:tb,format=raw,id=stkb \
  -device usb-storage,id=devb,drive=stkb \
  -drive if=none,file=fat:rw:tc,format=raw,id=stkc,cache=writeback \
  -device usb-storage,id=devc,drive=stkc \
  -drive if=none,file=fat:td,format=raw,id=stkd,readonly=on \
  -device usb-storage,id=devd,drive=stkd \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor telnet:127.0.0.1:5555,server,nowait \
  -serial file:"serial-diag.log" >/dev/null 2>"qemu-diag.err" &
QPID=$!
echo "diag QEMU pid $QPID"

python3 - <<'PYEOF'
import socket, time
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
# wait for the GUEST script to finish before touching QEMU
import os
end = time.time() + 240
seen_end = False
pos = 0
while time.time() < end:
    try:
        with open('/home/z/my-project/test-v6/serial-diag.log', 'rb') as f:
            f.seek(pos); d = f.read(); pos += len(d)
        if b'DIAG STICKS END' in d:
            seen_end = True
            break
    except FileNotFoundError:
        pass
    time.sleep(3)
print('guest script finished:', seen_end)
open('/home/z/my-project/test-v6/mon-diag.log', 'w').write(
    '=== info block ===\n' + cmd('info block') +
    '\n=== info usb ===\n' + cmd('info usb'))
cmd('quit')
PYEOF
sleep 2
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo "--- qemu stderr ---"; head -3 qemu-diag.err
echo "--- monitor info block (sticks) ---"
sed 's/\x1b\[[0-9;]*[A-Za-z]//g' mon-diag.log | tr -d '\r' | grep -a -E "infstick|stk|usb-storage|info" | head -12
echo "--- monitor info usb ---"
sed 's/\x1b\[[0-9;]*[A-Za-z]//g' mon-diag.log | tr -d '\r' | sed -n '/info usb/,$p' | head -10
echo "--- guest view: mapping + markers ---"
tr -d '\r' < serial-diag.log | sed 's/\x1b\[[0-9;]*[A-Za-z]//g' | sed -n '/DIAG STICKS BEGIN/,$p' | head -45
