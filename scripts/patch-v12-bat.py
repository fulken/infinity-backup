#!/usr/bin/env python3
"""
patch-v12-bat.py — turn the v9 template phase-d.bat into the v12 phase-d.bat.

The v12 package replaced usb-d\\trigger-test.ps1 (v10) with
usb-d\\trigger-test-v12.ps1, and the memory.efi v8 RT binary with the
v12 RT build. phase-d.bat's pre-flight guard and instruction texts still
referenced the old script — the guard aborted the run immediately
(user hit exactly this on a fresh v12 extract).

Anchored replacements (each must occur exactly once unless noted):
  R0  title line            (Phase D v9 -> v12)
  R1  header comment        (v8.1/v10 note -> v12 note)
  R2  pre-flight 1 block    (check trigger-test-v12.ps1 / "trigger test v12")
  R3  pre-flight 2 msgs     (4-item list, 2x)
  R4  package banner line   (v9/v8 -> v12/v12)
  R5  "banner must say"     (v8 RT phase D3 -> v12 observability)
  R6  on-desktop script ref (D:\\trigger-test.ps1 + "say: trigger test v10")
  R7  next-steps line       (send output of trigger-test-v12.ps1)
  R8  transfer README hint  (package v9+ -> package v12+)
"""
import sys

SRC = "/home/z/my-project/upload/extracted-v9-full/phase-d.bat"
DST = "/home/z/my-project/infinity-qemu-test/phase-d.bat"

def sub_once(text, old, new, count=1):
    n = text.count(old)
    if n != count:
        sys.exit(f"FATAL: anchor found {n}x (expected {count}): {old[:60]!r}")
    return text.replace(old, new)

def main():
    with open(SRC, encoding="utf-8", errors="replace", newline="") as f:
        t = f.read()

    # R0 — title line
    t = sub_once(t,
        "rem INFINITY Phase D v9: boot installed Windows WITH the RT build\r\n",
        "rem INFINITY Phase D v12: boot installed Windows WITH the v12 RT build\r\n")

    # R1 — header comment
    t = sub_once(t,
        "rem Driver and trigger-test.ps1 are unchanged from v8.1 (v8 RT\r\n"
        "rem build + trigger test v10).\r\n",
        "rem Driver: memory.efi v12 RT (observability build).\r\n"
        "rem Test script: trigger-test-v12.ps1 (4-signal attribution).\r\n")

    # R2 — pre-flight 1: the whole guard block
    t = sub_once(t,
        'rem ---- pre-flight 1: the trigger test script must be v10 ----\r\n'
        'if not exist usb-d\\trigger-test.ps1 (\r\n'
        '  echo [ERROR] usb-d\\trigger-test.ps1 not found.\r\n'
        '  echo The package ships it pre-placed in usb-d. Re-extract the\r\n'
        '  echo full package zip over this folder - do not copy scripts by hand.\r\n'
        '  pause\r\n'
        '  exit /b 1\r\n'
        ')\r\n'
        'findstr /I /C:"trigger test v10" usb-d\\trigger-test.ps1 >nul 2>&1\r\n'
        'if errorlevel 1 (\r\n'
        '  echo [ERROR] usb-d\\trigger-test.ps1 is NOT the v10 script.\r\n'
        '  echo A stale old copy would fail with the privilege error again.\r\n'
        '  echo Fix: extract the NEW package zip over this folder, so that\r\n'
        '  echo usb-d\\trigger-test.ps1 is replaced - v10 is 14290 bytes.\r\n'
        '  pause\r\n'
        '  exit /b 1\r\n'
        ')\r\n'
        'echo [Phase D] trigger-test.ps1 v10 verified - pre-placed on the boot disk.\r\n',
        'rem ---- pre-flight 1: the trigger test script must be v12 ----\r\n'
        'if not exist usb-d\\trigger-test-v12.ps1 (\r\n'
        '  echo [ERROR] usb-d\\trigger-test-v12.ps1 not found.\r\n'
        '  echo The package ships it pre-placed in usb-d. Re-extract the\r\n'
        '  echo full package zip over this folder - do not copy scripts by hand.\r\n'
        '  pause\r\n'
        '  exit /b 1\r\n'
        ')\r\n'
        'findstr /I /C:"trigger test v12" usb-d\\trigger-test-v12.ps1 >nul 2>&1\r\n'
        'if errorlevel 1 (\r\n'
        '  echo [ERROR] usb-d\\trigger-test-v12.ps1 is NOT the v12 script.\r\n'
        '  echo A stale old copy (v10/v11) cannot read the v12 signals\r\n'
        '  echo (INFCNT, live INFDIAG) and its verdict would be wrong.\r\n'
        '  echo Fix: extract the NEW v12 package zip over this folder, so that\r\n'
        '  echo usb-d\\trigger-test-v12.ps1 is replaced - v12 is 16499 bytes.\r\n'
        '  pause\r\n'
        '  exit /b 1\r\n'
        ')\r\n'
        'echo [Phase D] trigger-test-v12.ps1 verified - pre-placed on the boot disk.\r\n')

    # R3 — the two "only 4 shipped items" lists
    t = sub_once(t,
        "startup.nsh  trigger-test.ps1",
        "startup.nsh  trigger-test-v12.ps1", count=2)

    # R4 — package banner
    t = sub_once(t,
        "echo [Phase D] package v9 - Windows + memory.efi v8 RT boot test. Mode %MODE%.\r\n",
        "echo [Phase D] package v12 - Windows + memory.efi v12 RT boot test. Mode %MODE%.\r\n")

    # R5 — serial banner expectation
    t = sub_once(t,
        "echo [Phase D] The banner must say: Build: v8 RT - EARLY gRT hooks (phase D3).\r\n",
        "echo [Phase D] The banner must say: memory.efi v12 RT (observability build).\r\n")

    # R6 — on-desktop instructions
    t = sub_once(t,
        "echo [Phase D]        D:\\trigger-test.ps1\r\n"
        "echo [Phase D]      Its FIRST output line must say: trigger test v10.\r\n",
        "echo [Phase D]        D:\\trigger-test-v12.ps1\r\n"
        "echo [Phase D]      Its FIRST output line must say: trigger test v12.\r\n")

    # R7 — closing next-steps line
    t = sub_once(t,
        "echo   3. send the output of trigger-test.ps1 if you ran it\r\n",
        "echo   3. send the output of trigger-test-v12.ps1 if you ran it\r\n")

    # R8 — transfer README hint
    t = sub_once(t,
        "echo (the VM must be running via phase-d.bat from package v9+) >> transfer\\README-FA.txt\r\n",
        "echo (the VM must be running via phase-d.bat from package v12+) >> transfer\\README-FA.txt\r\n")

    with open(DST, "w", encoding="utf-8", newline="") as f:
        f.write(t)
    print(f"patched OK -> {DST} ({len(t)} bytes)")

if __name__ == "__main__":
    main()
