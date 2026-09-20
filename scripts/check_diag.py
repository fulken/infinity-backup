#!/usr/bin/env python3
"""Parse INFDIAG variable from an OVMF VARS pflash image.

Usage: python3 check_diag.py <vars-file>

The UEFI variable store layout (authenticated-variable header in
OVMF) places the UTF-16 variable name followed by its data. We
locate the name, then the INFD magic right after it, and decode
the 32-byte InfinityDiag struct (v6):

    UINT32 magic       = 0x494E4644
    UINT32 stage       # 1 loaded, 2 EBS fired, 3 hooks installed, 4 hook called
    UINT32 flags       # bit0 loaded, bit1 EBS fired, bit2 virtual mode,
                       # bit3 EARLY gRT hooks (v7, installed at load)
    UINT32 win_build
    UINT64 os_cr3
    UINT32 hook_calls
    UINT32 last_status # EFI_STATUS of the last INFDIAG write
"""
import struct
import sys

MAGIC_LE = b"\x44\x46\x4E\x49"  # 0x494E4644 little-endian = "DFNI"
NAME_U16 = "INFDIAG".encode("utf-16-le")

STAGES = {
    1: "driver loaded OK (pool + handler + EBS hook installed)",
    2: "ExitBootServices FIRED (os_cr3 + win_build captured)",
    3: "RT build: gRT hooks installed at SetVirtualAddressMap",
    4: "RT build: WINDOWS CALLED a hooked service (FULL CHAIN ALIVE)",
}

FLAGS = {0x1: "loaded", 0x2: "EBS_fired", 0x4: "virtual_mode",
         0x8: "EARLY_hooks(v7)"}


def main(path: str) -> int:
    data = open(path, "rb").read()
    pos = 0
    found = False
    while True:
        i = data.find(NAME_U16, pos)
        if i < 0:
            break
        pos = i + 2
        # variable data follows the name (name has a NUL terminator
        # that is included in NameSize), so scan a small window
        window = data[i + len(NAME_U16): i + len(NAME_U16) + 64]
        m = window.find(MAGIC_LE)
        if m >= 0 and m <= 16:
            base = i + len(NAME_U16) + m
            magic, stage, flags, build = struct.unpack_from("<IIII", data, base)
            cr3, calls, lastst = struct.unpack_from("<QII", data, base + 16)
            flagnames = [n for bit, n in FLAGS.items() if flags & bit]
            print(f"INFDIAG FOUND at offset {base:#x}")
            print(f"  magic          = {magic:#010x}")
            print(f"  stage          = {stage}  -> {STAGES.get(stage, 'UNKNOWN')}")
            print(f"  flags          = {flags:#x}  ({', '.join(flagnames) or 'none'})")
            print(f"  win_build      = {build}")
            print(f"  os_cr3         = {cr3:#x}")
            print(f"  hook_calls     = {calls}")
            print(f"  last_status    = {lastst:#010x}  (0x0 = last INFDIAG write succeeded)")
            found = True
    if not found:
        print("INFDIAG NOT FOUND in variable store.")
        print("=> memory.efi never reached its EfiMain diagnostic write.")
        return 1
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
