#!/usr/bin/env bash
# ============================================================================
# validate-v5.sh — validate the v5 package before shipping:
#   [A] CRLF check on every .bat and .nsh in the package
#   [B] boot the EXACT shipped usb-rt ritual -> expect RT banner + Success
#       + INFDIAG stage 1 (fresh vars)
#   [C] boot the EXACT shipped usb-check ritual against vars that already
#       contain a v5 INFDIAG (stage 2 from the linux-safe test) -> expect
#       the GUID-based dmpstore to display it
# ============================================================================
set -u
BASE=/home/z/my-project
QR=$BASE/qemu-root
QEMU=$QR/usr/bin/qemu-system-x86_64
PKG=$BASE/infinity-qemu-test
export LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu

fail=0

echo "=== [A] CRLF check ==="
for f in "$PKG"/*.bat "$PKG"/usb*/startup.nsh; do
    bad=$(grep -c -v $'\r$' "$f" || true)
    if [ "$bad" -gt 0 ]; then
        echo "  RED: $f has $bad non-CRLF lines"
        fail=1
    else
        echo "  ok : $(basename "$f")"
    fi
done

run_qemu() {  # $1=tag $2=vars-src $3=fatdir $4=timeout
    local tag="$1" varssrc="$2" fatdir="$3" tmo="$4"
    local dir="$BASE/test-v5/$tag"
    rm -rf "$dir"; mkdir -p "$dir"
    cp "$PKG/firmware/OVMF_CODE_4M.fd" "$dir/code.fd"
    cp "$varssrc" "$dir/vars.fd"
    timeout "$tmo" "$QEMU" -L "$BASE/qemu-bios" \
      -machine q35 -m 1024 -accel tcg \
      -drive if=pflash,format=raw,readonly=on,file="$dir/code.fd" \
      -drive if=pflash,format=raw,file="$dir/vars.fd" \
      -drive if=none,file=fat:rw:$fatdir,format=raw,id=bootdrv \
      -device ide-hd,drive=bootdrv,bootindex=0 \
      -nic none -no-reboot -display none -serial file:"$dir/serial.log"
}

echo "=== [B] boot shipped usb-rt (fresh vars) ==="
run_qemu rt-boot "$PKG/firmware/OVMF_VARS_4M.fd" "$PKG/usb-rt" 90
if grep -aq "runtime hooks ENABLED" "$BASE/test-v5/rt-boot/serial.log" && \
   grep -aq "Success" "$BASE/test-v5/rt-boot/serial.log"; then
    echo "  ok : RT banner + load Success present"
else
    echo "  RED: RT ritual boot missing banner/Success"
    fail=1
fi
python3 "$BASE/scripts/check_diag.py" "$BASE/test-v5/rt-boot/vars.fd" | tail -2

echo "=== [C] boot shipped usb-check against stage-2 vars ==="
# vars from test-d/linux-safe contain a REAL v5 INFDIAG (stage 2 + cr3)
run_qemu chk-boot "$BASE/test-d/linux-safe/vars.fd" "$PKG/usb-check" 90
if grep -aq "44 46 4E 49" "$BASE/test-v5/chk-boot/serial.log"; then
    echo "  ok : INFDIAG bytes displayed by the check ritual"
else
    echo "  RED: check ritual did not display INFDIAG"
    fail=1
fi

echo "=== [D] binary sanity (sizes + banners) ==="
s_safe=$(stat -c%s "$PKG/usb-c/memory.efi")
s_rt=$(stat -c%s "$PKG/usb-rt/memory.efi")
s_v4=$(stat -c%s "$PKG/firmware/memory-v4.efi")
echo "  safe=$s_safe rt=$s_rt v4-rollback=$s_v4"
[ "$s_rt" -gt "$s_safe" ] || { echo "  RED: rt must be bigger"; fail=1; }
strings -el "$PKG/usb-c/memory.efi" | grep -q "no runtime hooks" && echo "  ok : safe banner" || { echo "  RED"; fail=1; }
strings -el "$PKG/usb-rt/memory.efi" | grep -q "ENABLED" && echo "  ok : rt banner" || { echo "  RED"; fail=1; }

echo
if [ "$fail" -eq 0 ]; then
    echo "================ V5 VALIDATION: ALL GREEN ================"
else
    echo "================ V5 VALIDATION: RED — FIX BEFORE SHIP ==="
fi
exit $fail
