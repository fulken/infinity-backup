#!/usr/bin/env bash
# ============================================================================
# test-ovf-hotplug.sh — two-part validation for package v9
#
# PART A (overflow repro): rebuild the user's exact accident — the whole
#   infinity-qemu-test folder (including disk\win10.qcow2, 6 GB) copied into
#   the vvfat source dir — and prove which files QEMU's virtual FAT corrupts
#   (user evidence: v10 trigger-test.ps1 truncated at byte 11433 = line 263).
#
# PART B (real-time transfer): with the VM running, hotplug a SECOND vvfat as
#   a USB stick via the HMP telnet monitor (drive_add/device_add), watch the
#   EFI shell see it live (map -r polling), write a file from the guest, then
#   device_del and check whether the guest file lands in the host folder.
#   This is exactly what refresh-files.ps1 will do on the user's machine.
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu
PKG=$BASE/infinity-qemu-test
TDIR=$BASE/test-v6
mkdir -p "$TDIR/vars"

# ---------------- build the overflow vvfat source dir ----------------
O="$TDIR/ovf-d"
rm -rf "$O"
# EXACT mimic of the user's usb-d at the bad boot: clean top level (fresh
# v8.1 extract) + the whole test folder copied in, MINUS win10.qcow2 (QEMU
# refuses >2GB files in a vvfat dir - proven in run 1 - so the user's copy
# necessarily skipped it, likely an in-use/skip error during the drag-copy).
mkdir -p "$O/EFI/BOOT" "$O/infinity-qemu-test/disk" "$O/infinity-qemu-test/vars" \
         "$O/infinity-qemu-test/usb-d/EFI/BOOT" "$O/infinity-qemu-test/firmware" \
         "$O/infinity-qemu-test/usb/EFI/BOOT" "$O/infinity-qemu-test/usb-c/EFI/BOOT" \
         "$O/infinity-qemu-test/usb-check/EFI/BOOT"
cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"            "$O/EFI/BOOT/bootx64.efi"
cp "$PKG/usb-d/memory.efi"                      "$O/memory.efi"
cp "$PKG/usb-d/startup.nsh"                     "$O/startup.nsh.orig"   # keep, unused
cp "$BASE/download/trigger-test-v10.ps1"        "$O/trigger-test.ps1"
# --- the user's folder copy (qcow2 skipped: >2GB = QEMU refuses to start) ---
cp "$PKG/firmware/OVMF_VARS_4M.fd"              "$O/infinity-qemu-test/vars/OVMF_VARS_4M.fd"
cp "$PKG/firmware/OVMF_CODE_4M.fd"              "$O/infinity-qemu-test/firmware/OVMF_CODE_4M.fd"
cp "$BASE/download/trigger-test-v10.ps1"        "$O/infinity-qemu-test/trigger-test.ps1"
cp "$BASE/download/trigger-test-v10.ps1"        "$O/infinity-qemu-test/usb-d/trigger-test.ps1"
cp "$PKG/phase-d.bat"                           "$O/infinity-qemu-test/phase-d.bat"
cp "$PKG/usb/EFI/BOOT/bootx64.efi"              "$O/infinity-qemu-test/usb/EFI/BOOT/bootx64.efi"
cp "$PKG/usb/memory.efi"                        "$O/infinity-qemu-test/usb/memory.efi"
cp "$PKG/usb-c/EFI/BOOT/bootx64.efi"            "$O/infinity-qemu-test/usb-c/EFI/BOOT/bootx64.efi"
cp "$PKG/usb-check/EFI/BOOT/bootx64.efi"        "$O/infinity-qemu-test/usb-check/EFI/BOOT/bootx64.efi"

# compute host-side sha256 of the v10 copies for reference
sha256sum "$O/trigger-test.ps1" "$O/infinity-qemu-test/trigger-test.ps1" \
          "$O/infinity-qemu-test/usb-d/trigger-test.ps1" | sed 's|.*/ovf-d/||'
echo "--- overflow dir content (host view) ---"
du -sh --apparent-size "$O"; find "$O" -type f -printf '%10s  %P\n' | sort -k2

# ---------------- the probe startup.nsh ----------------
cat > "$O/startup.nsh" <<'NSH'
echo === overflow+hotplug probe begin ===
echo == root listing ==
ls FS0:\
echo == sizes of key files (14290 = intact) ==
ls FS0:\trigger-test.ps1
ls FS0:\memory.efi
ls FS0:\infinity-qemu-test\usb-d\trigger-test.ps1
ls FS0:\infinity-qemu-test\trigger-test.ps1
echo == comp top-level vs nested ==
comp FS0:\trigger-test.ps1 FS0:\infinity-qemu-test\usb-d\trigger-test.ps1
comp FS0:\trigger-test.ps1 FS0:\infinity-qemu-test\trigger-test.ps1
echo == comp done (no differences = identical) ==
echo === PHASE1 POLLING ==
for %b in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
  stall 2000000
  map -r
  if exist FS0:\INFMARK.TXT then
    echo STICK1 ONLINE on FS0 poll %b
    ls FS0:\trigger-test.ps1
    echo guestwrite-probe-12345 > FS0:\FROMGUEST.TXT
    echo STICK1WRITE DONE
    rm FS0:\INFMARK.TXT
  endif
  if exist FS1:\INFMARK.TXT then
    echo STICK1 ONLINE on FS1 poll %b
    ls FS1:\trigger-test.ps1
    echo guestwrite-probe-12345 > FS1:\FROMGUEST.TXT
    echo STICK1WRITE DONE
    rm FS1:\INFMARK.TXT
  endif
  if exist FS2:\INFMARK.TXT then
    echo STICK1 ONLINE on FS2 poll %b
    ls FS2:\trigger-test.ps1
    echo guestwrite-probe-12345 > FS2:\FROMGUEST.TXT
    echo STICK1WRITE DONE
    rm FS2:\INFMARK.TXT
  endif
endfor
echo === PHASE1 POLL ENDED ==
echo === PHASE2 POLLING ==
for %c in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
  stall 2000000
  map -r
  if exist FS0:\INFMARK2.TXT then
    echo STICK2 ONLINE on FS0 poll %c
    type FS0:\FROMGUEST.TXT
    echo TYPE DONE
    rm FS0:\INFMARK2.TXT
  endif
  if exist FS1:\INFMARK2.TXT then
    echo STICK2 ONLINE on FS1 poll %c
    type FS1:\FROMGUEST.TXT
    echo TYPE DONE
    rm FS1:\INFMARK2.TXT
  endif
  if exist FS2:\INFMARK2.TXT then
    echo STICK2 ONLINE on FS2 poll %c
    type FS2:\FROMGUEST.TXT
    echo TYPE DONE
    rm FS2:\INFMARK2.TXT
  endif
endfor
echo === PHASE2 POLL ENDED - ALL PROBES COMPLETE ==
NSH
python3 -c "
p='$O/startup.nsh'; d=open(p,'rb').read().replace(b'\r\n',b'\n').replace(b'\n',b'\r\n'); open(p,'wb').write(d)"

# ---------------- transfer dir (stick content) ----------------
rm -rf "$TDIR/transfer"; mkdir -p "$TDIR/transfer"

# ---------------- launch QEMU (mirrors phase-d.bat exactly) ----------------
cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/vars-ovf.fd"
rm -f "$TDIR/serial-ovf.log" "$TDIR/qemu-ovf.err" "$TDIR/qemu-ovf.out"
cd "$TDIR"
setsid nohup "$QEMU" -L "$BASE/qemu-bios" \
  -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$PKG/firmware/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="vars/vars-ovf.fd" \
  -drive if=none,file=fat:rw:ovf-d,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -nic none -usb -device usb-tablet \
  -no-reboot -display none \
  -monitor telnet:127.0.0.1:5555,server,nowait \
  -serial file:"serial-ovf.log" >qemu-ovf.out 2>qemu-ovf.err &
QPID=$!
echo "QEMU pid $QPID"

# ---------------- drive the monitor client ----------------
python3 "$BASE/scripts/mon-test.py" 2>&1 | tee "$TDIR/mon-out.log"
RC=${PIPESTATUS[0]}
echo "mon-test.py exit $RC"

# ---------------- teardown + analysis ----------------
kill "$QPID" 2>/dev/null; sleep 1; kill -9 "$QPID" 2>/dev/null
echo
echo "================ QEMU stderr (vvfat warnings?) ================"
head -20 "$TDIR/qemu-ovf.err"
echo
echo "================ SERIAL LOG (guest view) ================"
cat "$TDIR/serial-ovf.log" | tr -d '\r' | grep -a -v '^$' | head -120
echo
echo "================ host transfer/ dir after the run ================"
ls -la "$TDIR/transfer"
echo
echo "================ VERDICT INPUTS ================"
echo "top-level trigger-test.ps1 size inside guest (want: see serial ls) vs 14290"
grep -a "trigger-test.ps1" "$TDIR/serial-ovf.log" | tr -d '\r' | head -10
