#!/usr/bin/env python3
"""Patch phase-d.bat + check_diag.py for v7 (CRLF-safe edits)."""
import io, re, sys

BASE = "/home/z/my-project"

def patch(path, pairs):
    with io.open(path, "r", encoding="utf-8", newline="") as f:
        data = f.read()
    for old, new in pairs:
        # normalize: match either \n or \r\n variants by working on the
        # file as-is; our patterns use \n so also try \r\n form.
        o2 = old.replace("\n", "\r\n")
        n2 = new.replace("\n", "\r\n")
        if old in data:
            data = data.replace(old, n2 if old not in data else new, 1)
        elif o2 in data:
            data = data.replace(o2, n2, 1)
        else:
            print(f"[FAIL] pattern not found in {path}:\n{old[:120]}...")
            sys.exit(1)
    with io.open(path, "w", encoding="utf-8", newline="") as f:
        f.write(data)
    print(f"[OK] patched {path}")

# ---------------- phase-d.bat ----------------
bat = f"{BASE}/infinity-qemu-test/phase-d.bat"
patch(bat, [
    (
"""rem INFINITY Phase D v6: boot installed Windows WITH the RT build
rem (runtime hooks ENABLED). This is the deep test.
rem
rem v6 changes vs v5:
rem   - memory.efi v6 RT has full serial-port diagnostics. Every
rem     milestone now prints a line starting with [INF] into
rem     serial-phase-d.log. Nothing can silently fail anymore.
rem   - After the desktop loads, ALSO run trigger-test.ps1 inside
rem     Windows (see README-FA.md) - it forces Windows to call our
rem     hooked UEFI services and proves the full chain.
""",
"""rem INFINITY Phase D v7: boot installed Windows WITH the RT build
rem (EARLY gRT hooks). This is the deep test.
rem
rem v7 changes vs v6:
rem   - ROOT-CAUSE FIX: the v6 run proved Windows does NOT call the
rem     firmware's post-SetVirtualAddressMap gRT table (winload takes
rem     its own snapshot earlier). v7 installs the hooks IMMEDIATELY
rem     at driver load, so bootmgr/winload snapshot OUR pointers.
rem   - Serial diagnostics extended: [INF][RT-EARLY] at load,
rem     [INF][HOOK] x BOOT-CTX traces during boot, and OS-runtime
rem     hook calls now bump INFDIAG to stage 4.
rem   - trigger-test.ps1 v7: correct SetFirmwareEnvironmentVariableExW
rem     marshaling + real InfinityReq/InfinityResp PING protocol.
rem   - After the desktop loads, run trigger-test.ps1 inside Windows
rem     (see README-FA.md) - it proves the full chain.
""",
    ),
    (
"""echo [Phase D] Windows + memory.efi v6 RT boot test. Mode %MODE% selected.
echo [Phase D] The banner must say: Build: v6 RT - runtime hooks ENABLED.
echo [Phase D] Watch for these milestone lines in serial-phase-d.log:
echo [Phase D]   [INF][EBS] ExitBootServices hook FIRED   (stage 2)
echo [Phase D]   [INF][VA]  SetVirtualAddressMap ... FIRED (stage 3)
echo [Phase D]   [INF][HOOK] G/S/T call#1                 (stage 4)
""",
"""echo [Phase D] Windows + memory.efi v7 RT boot test. Mode %MODE% selected.
echo [Phase D] The banner must say: Build: v7 RT - EARLY gRT hooks.
echo [Phase D] Watch for these milestone lines in serial-phase-d.log:
echo [Phase D]   [INF][RT-EARLY] gRT hooks INSTALLED at load time
echo [Phase D]   [INF][EBS] ExitBootServices hook FIRED   (stage 2)
echo [Phase D]   [INF][VA]  SetVirtualAddressMap ... FIRED (stage 3)
echo [Phase D]   [INF][HOOK] G/S call#1 FIRST             (stage 4)
""",
    ),
])

# ---------------- check_diag.py ----------------
diag = f"{BASE}/scripts/check_diag.py"
patch(diag, [
    (
'    UINT32 flags       # bit0 loaded, bit1 EBS fired, bit2 virtual mode',
'    UINT32 flags       # bit0 loaded, bit1 EBS fired, bit2 virtual mode,\n'
'                       # bit3 EARLY gRT hooks (v7, installed at load)',
    ),
    (
'FLAGS = {0x1: "loaded", 0x2: "EBS_fired", 0x4: "virtual_mode"}',
'FLAGS = {0x1: "loaded", 0x2: "EBS_fired", 0x4: "virtual_mode",\n'
'         0x8: "EARLY_hooks(v7)"}',
    ),
])

print("ALL PATCHES OK")
