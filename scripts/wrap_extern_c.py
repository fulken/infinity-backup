#!/usr/bin/env python3
"""Wrap gnu-efi system includes in extern "C" guards.

gnu-efi 3.0.13 headers have no C++ linkage guards. Compiling main.c
as C++ therefore mangles every gnu-efi function reference (Print,
StrCmp, CopyMem, ...) so they no longer match the C symbols in
libefi.a -> 8 undefined symbols -> instant #GP crash on image load
(crt0 calls efi_main through a GOT slot that is never filled).

This script patches every file that includes <efi.h> directly.
"""
import re
import sys
from pathlib import Path

BASE = Path("/home/z/my-project/infinity-repo/UEFI")

# Files whose efi includes are NOT already wrapped by the v6 rewrites
# (main.c / RuntimeHook.h / CR3Capture.h / Diag.h carry their own wrap).
FILES = [
    "include/PhysicalMemory.h",
    "include/ProcessFinder.h",
    "include/ProcessMemory.h",
    "include/RequestHandler.h",
    "include/SharedMemoryPool.h",
    "include/WindowsOffsets.h",
]

GUARD = (
    '#ifdef __cplusplus\n'
    'extern "C" {\n'
    '#endif\n'
    '#include <efi.h>\n'
    '#include <efilib.h>\n'
    '#ifdef __cplusplus\n'
    '}\n'
    '#endif\n'
)

def main() -> int:
    for rel in FILES:
        p = BASE / rel
        src = p.read_text(encoding="utf-8")
        if 'extern "C" {\n#endif\n#include <efi.h>' in src:
            print(f"{rel}: already patched, skipping")
            continue
        # Match "<efi.h>" followed (possibly) by "<efilib.h>" lines.
        pat = re.compile(r"#include <efi\.h>\n(?:#include <efilib\.h>\n)?")
        m = pat.search(src)
        if not m:
            print(f"{rel}: NO MATCH, check manually!", file=sys.stderr)
            return 1
        src = src[: m.start()] + GUARD + src[m.end():]
        p.write_text(src, encoding="utf-8")
        print(f"{rel}: patched")
    return 0


if __name__ == "__main__":
    sys.exit(main())
