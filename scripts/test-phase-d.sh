#!/usr/bin/env bash
# ============================================================================
# test-phase-d.sh — validate rebuilt memory.efi (safe) + memory-rt.efi (RT)
#
# Tests:
#   1. shell-safe : boot ritual FAT -> startup.nsh loads SAFE memory.efi
#                   expect: banner + "Success" in serial, INFDIAG stage=1
#   2. shell-rt   : same with memory-rt.efi
#                   expect: identical (RT code only runs at SVAM/EBS)
#   3. linux-safe : load SAFE driver, fall through to Alpine Linux
#                   expect: Linux boots, INFDIAG stage=2 + cr3!=0 + flags bit0
#   4. linux-rt   : load RT driver, fall through to Alpine linux
#                   expect: THE parked question — does Linux survive with
#                   hooks installed at the VA event now that Diag never
#                   touches the stale gRT? (hang => documented, not a blocker)
#
# Usage: bash test-phase-d.sh [1|2|3|4|all]
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
FW=$BASE/infinity-qemu-test/firmware
BUILD=$BASE/Infinity/UEFI/build
OUT=$BASE/test-d

export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

which_test="${1:-all}"

run_vm() {  # $1=tag $2=efi-path $3=linux(yes|no) $4=timeout
    local tag="$1" efi="$2" with_linux="$3" tmo="$4"
    local dir="$OUT/$tag"
    rm -rf "$dir"; mkdir -p "$dir/usb/EFI/BOOT"

    cp "$BASE/test-a/usb/EFI/BOOT/bootx64.efi" "$dir/usb/EFI/BOOT/bootx64.efi"
    cp "$efi" "$dir/usb/memory.efi"

    cat > "$dir/usb/startup.nsh" <<'EOF'
echo === INFINITY test: load driver ===
if exist FS0:\memory.efi then
  load FS0:\memory.efi
endif
if exist FS1:\memory.efi then
  load FS1:\memory.efi
endif
if exist FS2:\memory.efi then
  load FS2:\memory.efi
endif
if exist FS3:\memory.efi then
  load FS3:\memory.efi
endif
if exist FS4:\memory.efi then
  load FS4:\memory.efi
endif
echo === driver stage done ===
EOF
    # Linux tests append an explicit launch of the CD's own bootloader.
    # NOTE: FS0 is skipped in the launch scan — FS0 is the ritual FAT
    # itself (its \EFI\BOOT\BOOTX64.EFI is the BootKit shell; launching
    # it again would loop forever).
    if [ "$with_linux" = "yes" ]; then
        cat >> "$dir/usb/startup.nsh" <<'EOF'
echo === launching Linux bootloader from DVD ===
if exist FS1:\EFI\BOOT\BOOTX64.EFI then
  FS1:\EFI\BOOT\BOOTX64.EFI
endif
if exist FS2:\EFI\BOOT\BOOTX64.EFI then
  FS2:\EFI\BOOT\BOOTX64.EFI
endif
if exist FS3:\EFI\BOOT\BOOTX64.EFI then
  FS3:\EFI\BOOT\BOOTX64.EFI
endif
echo === END: no Linux bootloader found ===
EOF
    else
        echo "echo === shell test: staying at prompt ===" >> "$dir/usb/startup.nsh"
    fi
    sed -i 's/\r\?$/\r/' "$dir/usb/startup.nsh"

    cp "$FW/OVMF_VARS_4M.fd" "$dir/vars.fd"

    local cd_args=()
    if [ "$with_linux" = "yes" ]; then
        cd_args=(-drive if=none,file=$BASE/alpine.iso,format=raw,media=cdrom,id=testcd
                 -device ide-cd,drive=testcd,bus=ide.2,bootindex=1)
    fi

    timeout -s TERM "$tmo" "$QEMU" \
      -L "$BASE/qemu-bios" \
      -machine q35 -m 1024 -accel tcg -cpu max -smp 2 \
      -rtc base=localtime \
      -drive if=pflash,format=raw,readonly=on,file="$FW/OVMF_CODE_4M.fd" \
      -drive if=pflash,format=raw,file="$dir/vars.fd" \
      -drive if=none,file=fat:rw:$dir/usb,format=raw,id=bootdrv \
      -device ide-hd,drive=bootdrv,bus=ide.1,bootindex=0 \
      "${cd_args[@]}" \
      -net none -display none \
      -serial file:"$dir/serial.log"
    echo "[$tag] qemu exit: $?"
}

decode() {  # $1=tag
    echo "--- [$1] INFDIAG decode ---"
    python3 "$BASE/scripts/check_diag.py" "$OUT/$1/vars.fd" 2>&1
}

summary() {  # $1=tag  — grep the interesting bits out of serial
    echo "--- [$1] serial highlights ---"
    grep -aE "INFINITY|Bridge|SUCCESS|Success|load|memory.efi|Welcome to Alpine|login:" \
      "$OUT/$1/serial.log" | head -12
}

mkdir -p "$OUT"

case "$which_test" in
  1|all) run_vm shell-safe  "$BUILD/build/memory.efi"    no  120
         summary shell-safe;  decode shell-safe ;;
  2|all) run_vm shell-rt    $BUILD/build/memory-rt.efi           no  120
         summary shell-rt;    decode shell-rt ;;
  3|all) run_vm linux-safe  "$BUILD/build/memory.efi"    yes 300
         summary linux-safe;  decode linux-safe ;;
  4|all) run_vm linux-rt    $BUILD/build/memory-rt.efi           yes 300
         summary linux-rt;    decode linux-rt ;;
  *) echo "unknown test $which_test"; exit 2 ;;
esac
