#!/usr/bin/env python3
"""
patch-v17-bat.py — turn the PROVEN v16 phase-d.bat into the v17 edition.

Pure version-bump derivation (same chain as v14/v15/v16; the v12.2
paren-free-guard lesson is preserved: every NEW echo line added here is
paren-free, keeping the field-proven shapes). v17 references everywhere,
the script size is recomputed from trigger-test-v17.ps1, the stale-copy
warning now names v10..v16, and three v17-specific changes:

  1. the auto-save instruction block is REWRITTEN (the v16 text said
     "next to the script" — the boot stick is READ-ONLY by design, that
     is exactly the v16 field defect; v17 says the file lands on the
     first WRITABLE drive and the script prints the path)
  2. the [INF][RD] kern va / kern read ok milestone lines (the new
     data-path serial traces)
  3. the send-back line now names the v17 output file
"""
import os
import sys

SRC = "/home/z/my-project/infinity-qemu-test/phase-d.bat"     # v16 edition (proven)
DST = SRC
SCRIPT = "/home/z/my-project/infinity-qemu-test/trigger-test-v17.ps1"


def main():
    if not os.path.exists(SCRIPT):
        sys.exit("FATAL: trigger-test-v17.ps1 not found")
    scr_size = os.path.getsize(SCRIPT)

    with open(SRC, encoding="utf-8", errors="replace", newline="") as f:
        t = f.read()

    if "Phase D v17" in t and "trigger-test-v17.ps1" in t:
        print(f"already v17: {DST} (idempotent skip)")
        return

    def sub(old, new, count=1):
        nonlocal t
        n = t.count(old)
        if n != count:
            sys.exit(f"FATAL: anchor found {n}x (expected {count}): {old[:70]!r}")
        t = t.replace(old, new)

    # ---- header / driver / script lines -----------------------------------
    sub("rem INFINITY Phase D v16: boot installed Windows WITH the v16 RT build",
        "rem INFINITY Phase D v17: boot installed Windows WITH the v17 RT build")
    sub("rem Driver: memory.efi v16 RT (full bridge proven, clean serial labels).",
        "rem Driver: memory.efi v17 RT (kernel data path: current-CR3 reads).")
    sub("rem Test script: trigger-test-v16.ps1 (dword fix + status decode + auto-tee).",
        "rem Test script: trigger-test-v17.ps1 (the data-path proof: steps H..N).")

    # ---- pre-flight 1 ------------------------------------------------------
    sub("rem ---- pre-flight 1: the trigger test script must be v16 ----",
        "rem ---- pre-flight 1: the trigger test script must be v17 ----")
    sub("usb-d\\trigger-test-v16.ps1", "usb-d\\trigger-test-v17.ps1", count=5)
    sub('findstr /I /C:"trigger test v16"', 'findstr /I /C:"trigger test v17"')
    sub("echo [ERROR] usb-d\\trigger-test-v17.ps1 is NOT the v16 script.",
        "echo [ERROR] usb-d\\trigger-test-v17.ps1 is NOT the v17 script.")
    sub("  echo A stale old copy - v10 to v15 - cannot read the v16",
        "  echo A stale old copy - v10 to v16 - cannot read the v17")
    sub(" - v16 is 19894 bytes.", f" - v17 is {scr_size} bytes.")
    sub("echo [Phase D] trigger-test-v16.ps1 verified", "echo [Phase D] trigger-test-v17.ps1 verified")
    sub("startup.nsh  trigger-test-v16.ps1", "startup.nsh  trigger-test-v17.ps1", count=2)
    sub("echo (the VM must be running via phase-d.bat from package v16+)",
        "echo (the VM must be running via phase-d.bat from package v17+)")

    # ---- banner expectation + mode line ------------------------------------
    sub("echo [Phase D] package v16 - Windows + memory.efi v16 RT boot test. Mode %MODE%.",
        "echo [Phase D] package v17 - Windows + memory.efi v17 RT boot test. Mode %MODE%.")
    sub("echo [Phase D] The banner must say: memory.efi v16 RT (full bridge proven, clean serial labels).",
        "echo [Phase D] The banner must say: memory.efi v17 RT (kernel data path: current-CR3 reads).")

    # ---- run instructions ---------------------------------------------------
    sub("echo [Phase D]        D:\\trigger-test-v16.ps1",
        "echo [Phase D]        D:\\trigger-test-v17.ps1")
    sub("echo [Phase D]      Its FIRST output line must say: trigger test v16.",
        "echo [Phase D]      Its FIRST output line must say: trigger test v17.")

    # (1) the auto-save block REWRITE (v16 field defect: the boot stick is
    #     read-only, "next to the script" can never work). NOTE: CRLF file —
    #     multi-line anchors need \r\n. All new lines are paren-free.
    sub("echo [Phase D]      v16 auto-saves ALL output to a trigger-test-v16-\r\n"
        "echo [Phase D]      output-DATE.txt next to the script - send that\r\n"
        "echo [Phase D]      file, no photos needed.\r\n",
        "echo [Phase D]      v17 auto-saves ALL output to a trigger-test-v17-\r\n"
        "echo [Phase D]      output-DATE.txt on the first WRITABLE drive - the\r\n"
        "echo [Phase D]      boot stick D: is read-only by design, so the file\r\n"
        "echo [Phase D]      lands elsewhere and the script prints the path.\r\n"
        "echo [Phase D]      Send that file, no photos needed.\r\n")

    # (2) the [RD] data-path milestone lines, right after the [BLD] probe line
    sub("echo [Phase D]   [INF][BLD] kusd raw 0x260=0x...  - desktop build probe\r\n"
        "echo [Phase D] After the desktop loads do NOT close the VM:",
        "echo [Phase D]   [INF][BLD] kusd raw 0x260=0x...  - desktop build probe\r\n"
        "echo [Phase D]   [INF][RD] kern va=0x... kern read ok - data path reads\r\n"
        "echo [Phase D] After the desktop loads do NOT close the VM:")

    # ---- done steps ----------------------------------------------------------
    sub("echo   3. send the trigger-test-v16-output .txt file if you ran it",
        "echo   3. send the trigger-test-v17-output .txt file if you ran it")

    with open(DST, "w", encoding="utf-8", newline="") as f:
        f.write(t)
    print(f"written: {DST} (script size line: v17 is {scr_size} bytes)")


if __name__ == "__main__":
    main()
