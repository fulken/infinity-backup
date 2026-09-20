#!/usr/bin/env bash
# Validate v3 package: CRLF conversion + batch syntax lint + QEMU live test
set -u
BASE=/home/z/my-project
PKG=$BASE/infinity-qemu-test
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

echo "=== [1] CRLF conversion for .bat files ==="
for f in "$PKG"/phase-b.bat "$PKG"/phase-c.bat; do
  # normalize to LF first, then to CRLF
  sed -i 's/\r$//' "$f"
  sed -i 's/$/\r/' "$f"
  # verify: every line must end with CR
  bad=$(grep -c $'[^\r]$' "$f" || true)
  echo "  $(basename $f): lines=$(wc -l < "$f"), non-CRLF-lines=$bad"
done

echo
echo "=== [2] Batch syntax lint ==="
for f in "$PKG"/phase-b.bat "$PKG"/phase-c.bat; do
  echo "  -- $(basename $f)"
  # raw pipe (not escaped with ^) outside quotes
  pipes=$(grep -nP '(?<!\^)\|' "$f" | grep -v '\^|' | wc -l)
  echo "     raw-pipe lines: $pipes"
  # check label/paren balance roughly: count open/close parens in echo lines (must be quoted or safe)
  ob=$(grep -o '(' "$f" | wc -l); cb=$(grep -o ')' "$f" | wc -l)
  echo "     parens: open=$ob close=$cb (must match)"
  # continuation lines: every line ending with ^ must not have trailing junk
  badcont=$(grep -nP '\^\s+\S' "$f" | head -5 | wc -l)
  echo "     suspicious continuation lines: $badcont"
done

echo
echo "=== [3] Live QEMU test: phase-b TCG line (verbatim) ==="
TDIR=$BASE/test-v3; rm -rf "$TDIR"; mkdir -p "$TDIR/vars" "$TDIR/disk"
cp "$PKG/firmware/OVMF_CODE_4M.fd" "$TDIR/"
cp "$PKG/firmware/OVMF_VARS_4M.fd" "$TDIR/vars/OVMF_VARS_4M.fd"
$BASE/qemu-utils-root/usr/bin/qemu-img create -f qcow2 "$TDIR/disk/win10.qcow2" 64G >/dev/null

cd "$TDIR"
timeout 60 "$QEMU" -L "$BASE/qemu-bios" -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
 -rtc base=localtime \
 -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE_4M.fd \
 -drive if=pflash,format=raw,file=vars/OVMF_VARS_4M.fd \
 -drive if=none,file=disk/win10.qcow2,format=qcow2,id=windisk \
 -device ide-hd,drive=windisk,bus=ide.0,bootindex=0 \
 -drive if=none,file="$BASE/alpine.iso",format=raw,media=cdrom,id=winiso \
 -device ide-cd,drive=winiso,bus=ide.1,bootindex=1 \
 -nic none -usb -device usb-tablet \
 -display none -serial file:serial-phase-b.log
echo "  qemu exit: $? (124=timeout reached = good, machine ran)"
echo "  --- serial log (BdsDxe boot lines) ---"
grep -a -o 'BdsDxe: [^\[]*' serial-phase-b.log | head -8
echo "  --- drive enumeration ---"
grep -a -c 'Sata' serial-phase-b.log || echo "  no Sata lines!"

echo
echo "=== [4] Live QEMU test: phase-c TCG line (verbatim) ==="
rm -f serial-phase-c.log
timeout 60 "$QEMU" -L "$BASE/qemu-bios" -machine q35 -m 1024 -smp 2 -cpu max -accel tcg \
 -rtc base=localtime \
 -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE_4M.fd \
 -drive if=pflash,format=raw,file=vars/OVMF_VARS_4M.fd \
 -drive if=none,file=fat:rw:$PKG/usb-c,format=raw,id=bootdrv \
 -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
 -drive if=none,file=disk/win10.qcow2,format=qcow2,id=windisk \
 -device ide-hd,drive=windisk,bus=ide.0,bootindex=1 \
 -nic none -usb -device usb-tablet \
 -no-reboot -display none -serial file:serial-phase-c.log
echo "  qemu exit: $?"
echo "  --- phase-c serial: driver load attempt ---"
grep -a -o 'INFINITY[^\[]*\|load FS[0-9][^\[]*\|Booting Windows[^\[]*\|memory.efi[^\[]*' serial-phase-c.log | head -10
echo "  --- banner found? ---"
grep -a -c 'INFINITY UEFI BRIDGE LOADED' serial-phase-c.log || echo "  banner NOT in serial (it prints to VGA only) - check startup.nsh echo lines"
grep -a -o 'echo === [^\[]*\|=== INFINITY[^\[]*' serial-phase-c.log | head -6

echo
echo "=== [5] WHPX-line device wiring check (accel/cpu swapped for sandbox) ==="
timeout 25 "$QEMU" -L "$BASE/qemu-bios" -machine q35 -m 1024 -smp 1 -cpu max -accel tcg \
 -rtc base=localtime \
 -drive if=pflash,format=raw,readonly=on,file=OVMF_CODE_4M.fd \
 -drive if=pflash,format=raw,file=vars/OVMF_VARS_4M.fd \
 -drive if=none,file=disk/win10.qcow2,format=qcow2,id=windisk \
 -device ide-hd,drive=windisk,bus=ide.0,bootindex=0 \
 -drive if=none,file="$BASE/alpine.iso",format=raw,media=cdrom,id=winiso \
 -device ide-cd,drive=winiso,bus=ide.1,bootindex=1 \
 -nic none -usb -device usb-tablet \
 -display none -serial file:serial-smp1.log
echo "  smp1 variant exit: $? (124 = parsed and ran fine)"

echo
echo "ALL VALIDATION DONE"
