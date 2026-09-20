#!/usr/bin/env python3
"""
patch-v14-bat.py — turn the PROVEN v13 phase-d.bat into the v14 phase-d.bat.

Pure version-bump derivation (the v13 bat already carries the v12.2
paren-free guard lesson). Every v13 reference becomes v14, the script
size is recomputed from trigger-test-v14.ps1, and the stale-copy warning
now also names v13.
"""
import os, sys

SRC = "/home/z/my-project/patches/phase-d-v13.bat"            # pristine v13 edition
DST = "/home/z/my-project/infinity-qemu-test/phase-d.bat"        # v14 output
SCRIPT = "/home/z/my-project/infinity-qemu-test/trigger-test-v14.ps1"

def main():
    if not os.path.exists(SCRIPT):
        sys.exit("FATAL: trigger-test-v14.ps1 not found")
    scr_size = os.path.getsize(SCRIPT)

    with open(SRC, encoding="utf-8", errors="replace", newline="") as f:
        t = f.read()

    def sub(old, new, count=1):
        nonlocal t
        n = t.count(old)
        if n != count:
            sys.exit(f"FATAL: anchor found {n}x (expected {count}): {old[:70]!r}")
        t = t.replace(old, new)

    # banner expectation string (must match the actual serial banner;
    # occurs twice: header rem + 'must say' echo)
    sub("memory.efi v13 RT (safe observability build)",
        "memory.efi v14 RT guid fix + live build", count=2)

    sub("rem INFINITY Phase D v13: boot installed Windows WITH the v13 RT build",
        "rem INFINITY Phase D v14: boot installed Windows WITH the v14 RT build")
    sub("rem Test script: trigger-test-v13.ps1 (4-signal attribution).",
        "rem Test script: trigger-test-v14.ps1 (attribution + build check).")
    sub("rem ---- pre-flight 1: the trigger test script must be v13 ----",
        "rem ---- pre-flight 1: the trigger test script must be v14 ----")
    sub("usb-d\\trigger-test-v13.ps1", "usb-d\\trigger-test-v14.ps1", count=5)
    sub('findstr /I /C:"trigger test v13"', 'findstr /I /C:"trigger test v14"')
    sub("echo [ERROR] usb-d\\trigger-test-v14.ps1 is NOT the v13 script.",
        "echo [ERROR] usb-d\\trigger-test-v14.ps1 is NOT the v14 script.")
    sub("  echo A stale old copy - v10 v11 or v12 - cannot read the v13",
        "  echo A stale old copy - v10 v11 v12 or v13 - cannot read the")
    sub("  echo live RAM signals and its verdict would be wrong.",
        "  echo v14 live signals and its verdict would be wrong.")
    sub("  echo Fix: extract the NEW v13 package zip over this folder, so that",
        "  echo Fix: extract the NEW v14 package zip over this folder, so that")
    sub(" - v13 is 16303 bytes.", f" - v14 is {scr_size} bytes.")
    sub("echo [Phase D] trigger-test-v13.ps1 verified", "echo [Phase D] trigger-test-v14.ps1 verified")
    sub("startup.nsh  trigger-test-v13.ps1", "startup.nsh  trigger-test-v14.ps1", count=2)
    sub("echo (the VM must be running via phase-d.bat from package v13+)",
        "echo (the VM must be running via phase-d.bat from package v14+)")
    sub("echo [Phase D] package v13 - Windows + memory.efi v13 RT boot test. Mode %MODE%.",
        "echo [Phase D] package v14 - Windows + memory.efi v14 RT boot test. Mode %MODE%.")
    sub("echo [Phase D]        D:\\trigger-test-v13.ps1", "echo [Phase D]        D:\\trigger-test-v14.ps1")
    sub("echo [Phase D]      Its FIRST output line must say: trigger test v13.",
        "echo [Phase D]      Its FIRST output line must say: trigger test v14.")
    sub("echo   3. send the output of trigger-test-v13.ps1 if you ran it",
        "echo   3. send the output of trigger-test-v14.ps1 if you ran it")

    if "v13" in t.replace("- v10 v11 v12 or v13 -", ""):
        leftovers = [l for l in t.splitlines() if "v13" in l and "v10 v11 v12 or v13" not in l]
        sys.exit(f"FATAL: leftover v13 references: {leftovers}")

    with open(DST, "w", encoding="utf-8", newline="") as f:
        f.write(t)
    print(f"patched OK -> {DST} ({len(t)} bytes; v14 script = {scr_size} bytes)")

if __name__ == "__main__":
    main()
