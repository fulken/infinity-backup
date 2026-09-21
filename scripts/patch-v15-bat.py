#!/usr/bin/env python3
"""
patch-v15-bat.py — turn the PROVEN v13 phase-d.bat (pristine template)
into the v15 phase-d.bat.

Pure version-bump derivation (same chain as v14; the v12.2 paren-free
guard lesson is preserved). v15 references everywhere, the script size
is recomputed from trigger-test-v15.ps1, and the stale-copy warning
now names v10..v14.
"""
import os, sys

SRC = "/home/z/my-project/patches/phase-d-v13.bat"            # pristine template
DST = "/home/z/my-project/infinity-qemu-test/phase-d.bat"        # v15 output
SCRIPT = "/home/z/my-project/infinity-qemu-test/trigger-test-v15.ps1"

def main():
    if not os.path.exists(SCRIPT):
        sys.exit("FATAL: trigger-test-v15.ps1 not found")
    scr_size = os.path.getsize(SCRIPT)

    with open(SRC, encoding="utf-8", errors="replace", newline="") as f:
        t = f.read()

    def sub(old, new, count=1):
        nonlocal t
        n = t.count(old)
        if n != count:
            sys.exit(f"FATAL: anchor found {n}x (expected {count}): {old[:70]!r}")
        t = t.replace(old, new)

    # banner expectation strings (rem header + 'must say' echo)
    sub("memory.efi v13 RT (safe observability build)",
        "memory.efi v15 RT (hex-safe serial + kusd probe)", count=2)

    sub("rem INFINITY Phase D v13: boot installed Windows WITH the v13 RT build",
        "rem INFINITY Phase D v15: boot installed Windows WITH the v15 RT build")
    sub("rem Test script: trigger-test-v13.ps1 (4-signal attribution).",
        "rem Test script: trigger-test-v15.ps1 (hex-safe attribution + kusd probe).")
    sub("rem ---- pre-flight 1: the trigger test script must be v13 ----",
        "rem ---- pre-flight 1: the trigger test script must be v15 ----")
    sub("usb-d\\trigger-test-v13.ps1", "usb-d\\trigger-test-v15.ps1", count=5)
    sub('findstr /I /C:"trigger test v13"', 'findstr /I /C:"trigger test v15"')
    # (after the filename swap above, the ERROR line now reads v15/v13)
    sub("echo [ERROR] usb-d\\trigger-test-v15.ps1 is NOT the v13 script.",
        "echo [ERROR] usb-d\\trigger-test-v15.ps1 is NOT the v15 script.")
    sub("  echo A stale old copy - v10 v11 or v12 - cannot read the v13",
        "  echo A stale old copy - v10 to v14 - cannot read the v15")
    sub("  echo live RAM signals and its verdict would be wrong.",
        "  echo live signals and its verdict would be wrong.")
    sub("  echo Fix: extract the NEW v13 package zip over this folder, so that",
        "  echo Fix: extract the NEW v15 package zip over this folder, so that")
    sub(" - v13 is 16303 bytes.", f" - v15 is {scr_size} bytes.")
    sub("echo [Phase D] trigger-test-v13.ps1 verified", "echo [Phase D] trigger-test-v15.ps1 verified")
    sub("startup.nsh  trigger-test-v13.ps1", "startup.nsh  trigger-test-v15.ps1", count=2)
    sub("echo (the VM must be running via phase-d.bat from package v13+)",
        "echo (the VM must be running via phase-d.bat from package v15+)")
    sub("echo [Phase D] package v13 - Windows + memory.efi v13 RT boot test. Mode %MODE%.",
        "echo [Phase D] package v15 - Windows + memory.efi v15 RT boot test. Mode %MODE%.")
    sub("echo [Phase D]        D:\\trigger-test-v13.ps1", "echo [Phase D]        D:\\trigger-test-v15.ps1")
    sub("echo [Phase D]      Its FIRST output line must say: trigger test v13.",
        "echo [Phase D]      Its FIRST output line must say: trigger test v15.")
    sub("echo   3. send the output of trigger-test-v13.ps1 if you ran it",
        "echo   3. send the output of trigger-test-v15.ps1 if you ran it")

    if "v13" in t.replace("- v10 to v14 -", ""):
        leftovers = [l for l in t.splitlines() if "v13" in l and "v10 to v14" not in l]
        sys.exit(f"FATAL: leftover v13 references: {leftovers}")

    with open(DST, "w", encoding="utf-8", newline="") as f:
        f.write(t)
    print(f"patched OK -> {DST} ({len(t)} bytes; v15 script = {scr_size} bytes)")

if __name__ == "__main__":
    main()
