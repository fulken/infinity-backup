#!/usr/bin/env python3
"""
mon-test.py - QEMU HMP telnet monitor client for the vvfat-hotplug validation.

Speaks the EXACT byte protocol that the future refresh-files.ps1 will use
(raw TCP to the telnet monitor, send HMP lines, read until "(qemu)" prompt),
drives the hotplug/refresh cycle, and verifies guest->host write-back.

Sequence (driven by markers in the serial log):
  1. connect to 127.0.0.1:5555 (retry)
  2. wait for serial "PHASE1 COMPLETE"  (guest is in poll loop 1)
  3. drive_add  + device_add            (vvfat USB stick appears in guest)
  4. wait for serial "STICK1WRITE DONE" (guest saw it + wrote FROMGUEST.TXT)
  5. device_del + drive_del             (unplug; write-back should flush)
  6. check host transfer/FROMGUEST.TXT  (write-back verdict)
  7. create INFMARK2.TXT, drive_add + device_add again (refresh cycle 2)
  8. wait for serial "TYPE DONE"        (guest read our written file back)
  9. info block / info usb evidence, then quit
"""
import socket, time, os, sys

BASE = '/home/z/my-project/test-v6'
SERIAL = os.path.join(BASE, 'serial-ovf.log')
TRANSFER = os.path.join(BASE, 'transfer')
HOST, PORT = '127.0.0.1', 5555

DRIVE_ADD = ('drive_add 0 if=none,id=infstick0,'
             'file=fat:rw:512M:transfer,format=raw,cache=writeback')
DEVICE_ADD = 'device_add usb-storage,id=infstick,drive=infstick0'
DEVICE_DEL = 'device_del infstick'
DRIVE_DEL = 'drive_del infstick0'


def log(msg):
    print('[mon %8.1fs] %s' % (time.time() - T0, msg), flush=True)


def serial_has(marker, since_pos=0):
    try:
        with open(SERIAL, 'rb') as f:
            f.seek(since_pos)
            data = f.read()
        return (marker.encode() in data), since_pos + len(data)
    except FileNotFoundError:
        return False, since_pos


def wait_serial(marker, timeout):
    pos = 0
    end = time.time() + timeout
    while time.time() < end:
        found, pos = serial_has(marker, pos)
        if found:
            return True
        time.sleep(3)
    return False


def clean(raw):
    """strip telnet IAC sequences + ANSI escapes for readable logging"""
    out, i, n = bytearray(), 0, len(raw)
    while i < n:
        b = raw[i]
        if b == 0xFF and i + 2 < n:      # IAC WILL/WONT/DO/DONT + option byte
            i += 3
            continue
        out.append(b)
        i += 1
    text = out.decode('ascii', 'replace')
    for esc in ('\x1b[K', '\x1b[?7h', '\x1b[?25l', '\x1b[?25h', '\r'):
        text = text.replace(esc, '')
    return text


class Mon:
    def __init__(self):
        self.s = socket.create_connection((HOST, PORT), timeout=10)
        self.s.settimeout(2)
        self.buf = b''

    def read_until_prompt(self, timeout=15):
        end = time.time() + timeout
        while time.time() < end:
            try:
                d = self.s.recv(4096)
                if not d:
                    break
                self.buf += d
                if b'(qemu)' in self.buf[-400:]:
                    out, self.buf = self.buf, b''
                    return out
            except socket.timeout:
                continue
        out, self.buf = self.buf, b''
        return out

    def cmd(self, c, timeout=15):
        self.s.sendall(c.encode() + b'\n')
        return clean(self.read_until_prompt(timeout))


T0 = time.time()
os.makedirs(TRANSFER, exist_ok=True)

# --- marker files for stick 1 (host -> guest content) ---
with open(os.path.join(TRANSFER, 'INFMARK.TXT'), 'w') as f:
    f.write('transfer stick marker 1\n')
import shutil
shutil.copy('/home/z/my-project/download/trigger-test-v10.ps1',
            os.path.join(TRANSFER, 'trigger-test.ps1'))

# --- 1. connect ---
for attempt in range(20):
    try:
        m = Mon()
        break
    except OSError:
        time.sleep(2)
else:
    log('FATAL: cannot connect to monitor')
    sys.exit(1)
banner = m.read_until_prompt(5)
log('connected; banner %d bytes' % len(banner))

# --- 2. guest ready ---
if not wait_serial('PHASE1 POLLING', 200):
    log('FATAL: guest never reached PHASE1 COMPLETE')
    m.cmd('quit')
    sys.exit(2)
log('guest is polling for stick 1')

# --- 3. plug stick 1 ---
r = m.cmd(DRIVE_ADD)
log('drive_add -> ' + r.strip().replace('\n', ' | ')[:300])
r = m.cmd(DEVICE_ADD)
log('device_add -> ' + (r.strip() or '(no output = success)')[:300])
r = m.cmd('info block')
ok = 'infstick0' in r
log('info block: infstick0 present = %s' % ok)
r = m.cmd('info usb')
log('info usb -> ' + r.strip().replace('\n', ' | ')[:400])

# --- 4. guest sees it + writes ---
if not wait_serial('STICK1WRITE DONE', 200):
    log('ERROR: guest never saw stick 1 (EFI shell hotplug may not work; '
        'Windows-side PnP is the real target anyway)')
else:
    log('guest SAW stick 1 and wrote FROMGUEST.TXT')

# --- 5. unplug ---
time.sleep(5)
r = m.cmd(DEVICE_DEL, timeout=20)
log('device_del -> ' + (r.strip() or '(no output = success)')[:200])
time.sleep(4)
r = m.cmd(DRIVE_DEL, timeout=20)
log('drive_del -> ' + (r.strip() or '(no output = success)')[:200])
time.sleep(3)

# --- 6. write-back verdict ---
wb = os.path.join(TRANSFER, 'FROMGUEST.TXT')
if os.path.exists(wb) and os.path.getsize(wb) > 0:
    log('WRITE-BACK OK: %s (%d bytes) landed on host' %
        (wb, os.path.getsize(wb)))
    writeback_ok = True
else:
    log('WRITE-BACK NOT visible yet at device_del (will re-check after quit)')
    writeback_ok = False

# --- 7. refresh cycle 2 ---
with open(os.path.join(TRANSFER, 'INFMARK2.TXT'), 'w') as f:
    f.write('refresh 2 marker\n')
r = m.cmd(DRIVE_ADD)
log('refresh2 drive_add -> ' + r.strip().replace('\n', ' | ')[:300])
r = m.cmd(DEVICE_ADD)
log('refresh2 device_add -> ' + (r.strip() or '(no output = success)')[:300])
r = m.cmd('info usb')
log('refresh2 info usb -> ' + r.strip().replace('\n', ' | ')[:400])

# --- 8. guest reads our write back ---
if wait_serial('TYPE DONE', 150):
    log('REFRESH-2 OK: guest saw the new stick and read FROMGUEST.TXT back')
else:
    log('guest did not report TYPE DONE (check serial log manually)')

# --- 9. final evidence + exit ---
r = m.cmd('info block')
log('final info block: infstick0 present = %s' % ('infstick0' in r))
m.cmd('quit')
time.sleep(3)

if not writeback_ok and os.path.exists(wb) and os.path.getsize(wb) > 0:
    log('WRITE-BACK landed after quit instead (%d bytes)' % os.path.getsize(wb))
elif not writeback_ok:
    log('WRITE-BACK FAILED even after quit - guest->host via stick unreliable')

log('client finished')
