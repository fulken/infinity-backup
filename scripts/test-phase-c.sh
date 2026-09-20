#!/usr/bin/env bash
# Validate the NEW phase-C startup.nsh mechanics in the sandbox bench:
#   1) loop-scan FS0..FS7 to find+load memory.efi (user's phase-b failed on hardcoded FS0)
#   2) loop-scan to find the OS bootloader and launch it from the script
# Device layout mirrors the user's phase-b run: FAT disk (bootindex=0) + CD (bootindex=1)
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
FW=$BASE/infinity-qemu-test/firmware
TC=$BASE/test-c

export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

# 1) Build the test FAT ritual
rm -rf "$TC"
mkdir -p "$TC/usb/EFI/BOOT"
cp "$BASE/test-a/usb/EFI/BOOT/bootx64.efi" "$TC/usb/EFI/BOOT/bootx64.efi"
cp "$BASE/test-a/usb/memory.efi"           "$TC/usb/memory.efi"

cat > "$TC/usb/startup.nsh" <<'EOF'
echo === INFINITY phase C TEST: scan filesystems ===
for %a in (FS0: FS1: FS2: FS3: FS4: FS5: FS6: FS7:) do
  if exist %a\memory.efi then
    echo Driver found on %a
    load %a\memory.efi
  endif
endfor
echo === driver stage done, looking for OS bootloader ===
for %a in (FS0: FS1: FS2: FS3: FS4: FS5: FS6: FS7:) do
  if exist %a\EFI\BOOT\BOOTX64.EFI then
    if not exist %a\memory.efi then
      echo OS bootloader on %a, launching
      %a\EFI\BOOT\BOOTX64.EFI
    endif
  endif
endfor
echo === END: no bootloader found ===
EOF
# .nsh must be CRLF
sed -i 's/\r\?$/\r/' "$TC/usb/startup.nsh"

cp "$FW/OVMF_VARS_4M.fd" "$TC/vars.fd"

# 2) Run the VM (FAT first like user's machine, CD second)
timeout -s TERM 300 "$QEMU" \
  -L "$BASE/qemu-bios" \
  -machine q35 -m 2048 -accel tcg -cpu max -smp 2 \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$FW/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="$TC/vars.fd" \
  -drive if=none,file=fat:rw:$TC/usb,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bootindex=0 \
  -drive if=none,file=$BASE/alpine.iso,format=raw,media=cdrom,id=testcd \
  -device ide-cd,drive=testcd,bus=ide.1,bootindex=1 \
  -net none -display none \
  -serial file:$TC/serial.log

echo "=== qemu exit code: $? ==="
echo "=== serial log (cat -v) ==="
cat -v "$TC/serial.log"
