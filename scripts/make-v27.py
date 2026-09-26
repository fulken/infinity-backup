#!/usr/bin/env python3
"""make-v27.py - build trigger-test-v27.ps1 from the v26 script.

v27 = v26 + THE L2B READ-BACK FIX (script-only; the v20 driver
STAYS - memory.efi v20 RT, 128010 bytes, untouched).

The v26 field run (2026-09-26 08:16) CONVERGED - K state=1 reason=0,
the containing-walk skipped the v25 nested PE (all three walks
lastskip=0xFFFFF8046BD60000) and unlocked the TRUE ntoskrnl range
[0xFFFFF8046BC00000, 0xFFFFF8046CC46000). L1 (MZ) + L2a (e_lfanew)
came back green. But L2b's 88-byte PE header block never reached the
checks: Send-Req read InfinityData back through a 64-BYTE buffer;
88 > 64 -> GetFirmwareEnvironmentVariableW failed Win32=122
(ERROR_INSUFFICIENT_BUFFER) -> "[DT] InfinityData absent" although
the driver HAD delivered all 88 bytes (serial [RD]
mapped va=0xFFFFF8046BC00118 ok=1). L3 cascade-skipped, INFCNT
landed at 16 (exactly G+1+7+6 - L3 was the only missing request),
and the run printed "F1 PARTIAL" with the driver blameless.

Script-side changes (K/L/J request logic byte-identical):
  1. v27 header block above the v26 header block
  2. transcript filename v26 -> v27
  3. banner line: K CONVERGED in the field + the L2b fix named
  4. END marker v26 -> v27
  5. THE FIX: Send-Req's InfinityData read-back buffer 64 -> 4096
     (the driver's hard read cap - no valid payload can exceed it;
     the Win32=122 class is dead)
  6. [DT] absent branch: a 122-specific hint line (documents the
     class for eternity)
  7. decision-table staleness fix: the "if the VM dies" guidance
     still named v19-RT 125450 / v18 121253 - retargeted to the
     v20 field kit (v20-RT 128010)
"""
import re, hashlib

SRC = '/home/z/my-project/infinity-qemu-test/trigger-test-v26.ps1'
DST = '/home/z/my-project/infinity-qemu-test/trigger-test-v27.ps1'

src = open(SRC, 'rb').read().decode('utf-8')  # keep the PE\0\0 NULs as-is

def must_count(pat, n, flags=0):
    got = len(re.findall(pat, src, flags))
    assert got == n, f'pattern {pat!r}: expected {n} hits, got {got}'

# ---- pre-edit sanity: the v26 shapes we rely on are present ----
must_count(r'trigger-test-v26-output-\$stamp', 1)
must_count(r"==== INFINITY trigger test v26 \(v20 driver: containing-walk", 1)
must_count(r"==== END v26 ====", 1)
must_count(re.escape("    $db = New-Object byte[] 64\n    $dn = Read-EfiVar 'InfinityData' $db"), 1)
must_count(re.escape('Write-Host \' dies at J1     -> the driver is NOT v18 (a v17 would walk+CR3-switch = v20 death).\''), 1)
must_count(re.escape('Write-Host \'                  Check usb-d\\memory.efi size: v19-RT = 125450 bytes.\''), 1)
must_count(re.escape('Write-Host \'                  Do NOT rerun until memory.efi is replaced (size 121253).\''), 1)
# the OTHER 64-byte buffers stay 64 (INFDIAG 32B struct, InfinityResp
# 32B struct, Read-VarBack 1-4B vars) - only the DATA path grows
must_count(r'\$db = New-Object byte\[\] 64', 1)

# ---- 1. v27 header block, inserted above the v26 header block ----
V27HDR = '''# ============================================================
# INFINITY bridge trigger test v27  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v27 = v26 + THE L2B READ-BACK FIX (script-only - the v20 driver
# STAYS: memory.efi v20 RT, 128010 bytes, untouched). WHY: the v26
# field run (2026-09-26 08:16) CONVERGED - K state=1 reason=0, the
# containing-walk skipped the v25 nested PE (all three walks
# lastskip=0xFFFFF8046BD60000) and unlocked the TRUE ntoskrnl
# range. L1 (MZ) and L2a (e_lfanew) came back green through the
# gate - but L2b's 88-byte PE header block never reached the
# checks: the script read InfinityData back through a 64-BYTE
# buffer; 88 > 64 -> Win32=122 (ERROR_INSUFFICIENT_BUFFER) ->
# "[DT] absent" although the driver HAD delivered all 88 bytes
# (serial [RD] mapped va=0xFFFFF8046BC00118 ok=1). L3 cascade-
# skipped and the run printed "F1 PARTIAL" with the driver
# blameless. v27 sizes the read-back buffer to the DRIVER CAP
# (4096 bytes - no valid payload can exceed it), so the 122 class
# is dead. Expected v27 = the v26 expectation, now reachable:
# K CONVERGED, L1 MZ, L2a e_lfanew, L2b PE sig + machine +
# SizeOfImage match, L3 entry bytes, L4/L5 ErrAccess, J1..J7
# regression, INFCNT 17 converged -> "F1 PROVEN".
# ============================================================
# INFINITY bridge trigger test v26  (run INSIDE the Windows VM,'''

anchor = '# INFINITY bridge trigger test v26  (run INSIDE the Windows VM,'
assert src.count(anchor) == 1
src = src.replace(anchor, V27HDR, 1)

# ---- 2/3/4. the three runtime version strings ----
src = src.replace('trigger-test-v26-output-$stamp', 'trigger-test-v27-output-$stamp')
src = src.replace(
    "Write-Host '==== INFINITY trigger test v26 (v20 driver: containing-walk - K expected CONVERGED; L validated reads + J regression) ===='",
    "Write-Host '==== INFINITY trigger test v27 (v20 driver: K CONVERGED in the field; L validated reads - the L2b 88-byte read-back fixed + J regression) ===='")
src = src.replace("Write-Host '==== END v26 ===='", "Write-Host '==== END v27 ===='")

# ---- 5. THE FIX: the InfinityData read-back buffer -> the driver cap ----
src = src.replace(
    "    # the read data may also land in the InfinityData buffer - dump it too\n"
    "    $dataBytes = $null\n"
    "    $db = New-Object byte[] 64\n",
    "    # the read data may also land in the InfinityData buffer - dump it too\n"
    "    $dataBytes = $null\n"
    "    # v27: size the buffer to the DRIVER CAP (4096). v26 used 64 bytes;\n"
    "    # L2b's 88-byte PE header came back Win32=122 (ERROR_INSUFFICIENT_\n"
    "    # BUFFER) and the checks never saw the bytes the driver HAD delivered\n"
    "    # (serial [RD] ok=1). No valid payload can exceed 4096 - dead class.\n"
    "    $db = New-Object byte[] 4096\n")

# ---- 6. the [DT] absent branch: document the 122 class forever ----
src = src.replace(
    "    } else {\n"
    "        Write-Host \"[DT] InfinityData absent (Win32=$LastErr)\"\n"
    "    }\n",
    "    } else {\n"
    "        Write-Host \"[DT] InfinityData absent (Win32=$LastErr)\"\n"
    "        if ($LastErr -eq 122) { Write-Host '[DT]   -> 122 = the payload exceeded the 4096-byte buffer (impossible per the driver cap) - send everything' }\n"
    "    }\n")

# ---- 7. decision-table staleness fix (only read if the VM dies) ----
src = src.replace(
    "Write-Host ' dies at J1     -> the driver is NOT v18 (a v17 would walk+CR3-switch = v20 death).'",
    "Write-Host ' dies at J1     -> the driver is NOT v18+ (a v17 would walk+CR3-switch = instant death).'")
src = src.replace(
    "Write-Host '                  Check usb-d\\memory.efi size: v19-RT = 125450 bytes.'",
    "Write-Host '                  Check usb-d\\memory.efi size: v20-RT = 128010 bytes.'")
src = src.replace(
    "Write-Host ' J1 answers ErrAccess(4) -> the gate rejected a VALID KUSD address: driver not v18.'",
    "Write-Host ' J1 answers ErrAccess(4) -> the gate rejected a VALID KUSD address: driver not v18+.'")
src = src.replace(
    "Write-Host '                  Do NOT rerun until memory.efi is replaced (size 121253).'",
    "Write-Host '                  Do NOT rerun until memory.efi is replaced (size 128010).'")

# ---- 8. stale in-file doc comment: the bat's guard moved to v20 ----
src = src.replace(
    "#      CR3-switch killer). phase-d.bat checks memory.efi size 125450 (v19-RT).",
    "#      CR3-switch killer). phase-d.bat checks memory.efi size 128010 (v20-RT).")

# ---- post-edit verification ----
assert 'trigger-test-v27-output-' in src
assert "trigger test v27 (v20 driver" in src
assert '==== END v27 ====' in src
assert '$db = New-Object byte[] 4096' in src
assert 'the L2b 88-byte read-back fixed' in src
assert 'Win32=122' in src and 'ERROR_INSUFFICIENT' in src
assert 'v20-RT = 128010 bytes' in src
assert 'size 128010' in src
assert 'phase-d.bat checks memory.efi size 128010 (v20-RT)' in src
# no stale v26 runtime strings (the historical header block may keep v26 words)
assert 'trigger-test-v26-output-$stamp' not in src
assert '==== END v26 ====' not in src
assert "trigger test v26 (v20 driver" not in src
# the OTHER 64-byte buffers stay untouched (INFDIAG / Resp x2 / VarBack)
assert len(re.findall(r'New-Object byte\[\] 64', src)) == 4, \
    'expected exactly 4 remaining 64-byte buffers (INFDIAG x1, Resp x2, VarBack x1)'
# exactly ONE data-path buffer, and it is 4096
assert len(re.findall(r'\$db = New-Object byte\[\] 4096', src)) == 1
# the fix comment names the class
assert 'dead class' in src

data = src.encode('utf-8')
open(DST, 'wb').write(data)
h = hashlib.sha256(data).hexdigest()
print(f'written: {DST}')
print(f'bytes  : {len(data)}')
print(f'sha256 : {h}')
print('ALL SHAPE CHECKS PASS')
