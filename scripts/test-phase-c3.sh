#!/usr/bin/env bash
# Phase-C test v3: EXACT production shape.
#   FAT#1 (ritual: shell+startup.nsh+memory.efi)  bus=ide.1 bootindex=0  <- boots
#   FAT#2 (fake Windows ESP: EFI/Microsoft/Boot/bootmgfw.efi = gnu-efi t.efi)
#                                                  bus=ide.0 bootindex=1
#   Alpine CD                                      bus=ide.2 bootindex=2
# Validates: loop-scan load of memory.efi + loop-scan find+launch of
#            \EFI\Microsoft\Boot\bootmgfw.efi  (the real phase-C mechanism)
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
FW=$BASE/infinity-qemu-test/firmware
TC=$BASE/test-c

export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

# 1) ritual FAT
rm -rf "$TC"
mkdir -p "$TC/usb/EFI/BOOT" "$TC/fake-esp/EFI/Microsoft/Boot"
cp "$BASE/test-a/usb/EFI/BOOT/bootx64.efi" "$TC/usb/EFI/BOOT/bootx64.efi"
cp "$BASE/test-a/usb/memory.efi"           "$TC/usb/memory.efi"

# 2) fake Windows ESP: bootmgfw.efi = gnu-efi sample app
cp "$BASE/gnuefi-local/usr/lib/gnuefi/apps/t.efi" "$TC/fake-esp/EFI/Microsoft/Boot/bootmgfw.efi"

cat > "$TC/usb/startup.nsh" <<'EOF'
echo === INFINITY phase C: load driver then boot Windows ===
if exist FS0:\memory.efi then
  echo Loading driver from FS0
  load FS0:\memory.efi
endif
if exist FS1:\memory.efi then
  echo Loading driver from FS1
  load FS1:\memory.efi
endif
if exist FS2:\memory.efi then
  echo Loading driver from FS2
  load FS2:\memory.efi
endif
if exist FS3:\memory.efi then
  echo Loading driver from FS3
  load FS3:\memory.efi
endif
if exist FS4:\memory.efi then
  echo Loading driver from FS4
  load FS4:\memory.efi
endif
echo === driver stage done ===
if exist FS0:\EFI\Microsoft\Boot\bootmgfw.efi then
  echo Booting Windows from FS0
  FS0:\EFI\Microsoft\Boot\bootmgfw.efi
  echo FS0 bootloader returned
endif
if exist FS1:\EFI\Microsoft\Boot\bootmgfw.efi then
  echo Booting Windows from FS1
  FS1:\EFI\Microsoft\Boot\bootmgfw.efi
  echo FS1 bootloader returned
endif
if exist FS2:\EFI\Microsoft\Boot\bootmgfw.efi then
  echo Booting Windows from FS2
  FS2:\EFI\Microsoft\Boot\bootmgfw.efi
  echo FS2 bootloader returned
endif
if exist FS3:\EFI\Microsoft\Boot\bootmgfw.efi then
  echo Booting Windows from FS3
  FS3:\EFI\Microsoft\Boot\bootmgfw.efi
  echo FS3 bootloader returned
endif
if exist FS4:\EFI\Microsoft\Boot\bootmgfw.efi then
  echo Booting Windows from FS4
  FS4:\EFI\Microsoft\Boot\bootmgfw.efi
  echo FS4 bootloader returned
endif
echo === END: no Windows bootloader found ===
EOF
sed -i 's/\r\?$/\r/' "$TC/usb/startup.nsh"

cp "$FW/OVMF_VARS_4M.fd" "$TC/vars.fd"

# 3) run
timeout -s TERM 240 "$QEMU" \
  -L "$BASE/qemu-bios" \
  -machine q35 -m 2048 -accel tcg -cpu max -smp 2 \
  -rtc base=localtime \
  -drive if=pflash,format=raw,readonly=on,file="$FW/OVMF_CODE_4M.fd" \
  -drive if=pflash,format=raw,file="$TC/vars.fd" \
  -drive if=none,file=fat:rw:$TC/usb,format=raw,id=bootdrv \
  -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
  -drive if=none,file=fat:rw:$TC/fake-esp,format=raw,id=fakeesp \
  -device ide-hd,drive=fakeesp,bus=ide.0,bootindex=1 \
  -drive if=none,file=$BASE/alpine.iso,format=raw,media=cdrom,id=testcd \
  -device ide-cd,drive=testcd,bus=ide.2,bootindex=2 \
  -net none -display none \
  -serial file:$TC/serial.log

echo "=== qemu exit code: $? ==="
