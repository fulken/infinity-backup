#!/usr/bin/env python3
"""Derive trigger-test-v15.ps1 from trigger-test-v14.ps1 (anchored edits)."""
import sys
from pathlib import Path

SRC = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v14.ps1")
DST = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v15.ps1")

def edit(text, tag, old, new, count=1):
    n = text.count(old)
    if n != count:
        print(f"FATAL: anchor {tag}: found {n} (need {count})")
        sys.exit(1)
    return text.replace(old, new)

t = SRC.read_text(encoding="utf-8-sig") if SRC.read_bytes()[:3] == b"\xef\xbb\xbf" else SRC.read_text()

# ---- S1: header block -------------------------------------------------
t = edit(t, "S1-header", """# ============================================================
# INFINITY trigger test v14  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v14 driver (infinity-qemu-test-v14 package).
# Running it against v9/v12/v13 drivers gives WRONG verdicts -
# check that phase-d.bat printed "package v14" and the boot log
# says "memory.efi v14 RT".
#
# What v14 changed (the v13 verdict was an artifact):
#   - The v13 run came back "both paths bypassed" - but the vars
#     files proved all three script writes LANDED in NVRAM while
#     the hook traced nothing. Root cause (found by disassembly):
#     gnu-efi's CompareGuid returns 0 when GUIDs are EQUAL. Two
#     call sites used EDK2-style '== TRUE / != TRUE' - so the RAM
#     serve never fired (stale 251 reads) and our own variables
#     were never classified as ours (no traces, no counts). v14
#     fixes both comparisons - the verdict is REAL now.
#   - win_build is captured LIVE at desktop time: the driver reads
#     NtBuildNumber directly from KUSER_SHARED_DATA inside the
#     hook (at EBS time the CPU still runs on the FIRMWARE page
#     tables, which is why win_build was 0 since v6). The SUMMARY
#     now shows driver-side build next to the script-side build.
#   - Our-namespace writes are handled in RAM AND chained to the
#     original SetVariable (dual write) - the landing checks keep
#     working. This chain path is proven safe by the v13 run.
#""", """# ============================================================
# INFINITY trigger test v15  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v15 driver (infinity-qemu-test-v15 package).
# Running it against v9..v14 drivers gives WRONG verdicts or a
# BSOD - check that phase-d.bat printed "package v15" and the boot
# log says "memory.efi v15 RT".
#
# What v15 changed (the v14 BSOD, root-caused by disassembly):
#   - v14 CRASHED (KMODE_EXCEPTION) on step A - the first INFDIAG
#     read. The serial log truncated mid-hex-print. Root cause:
#     SerialTrace's hex formatter used 'static const char* k = ...'
#     - the compiler materialized it as a POINTER SLOT holding the
#     load-time (physical) address, never converted at the VA
#     event. The FIRST hex print from the Windows kernel context
#     dereferenced that stale address -> page fault. (The v12 BSOD
#     had the SAME signature - both logs truncate mid '=0x'.)
#     v15 turns the table into an ARRAY - rip-relative, safe in
#     every address space.
#   - The v14 KUSD read returned an implausible build: +0x308 is
#     NOT NtBuildNumber on live Win10 19045 x64 (the base repo's
#     constant was wrong). v15 probes BOTH candidate offsets
#     (0x260, 0x308), traces the RAW values on serial, and takes
#     the first plausible one. SUMMARY shows driver vs script
#     build side by side.
#   - Everything else from v14 is UNCHANGED (GUID fixes, RAM
#     serve, dual-write chain, PING step E).
#""")

# ---- S3: banner --------------------------------------------------------
t = edit(t, "S3-banner", "Write-Host '==== INFINITY trigger test v14 (guid fix + live build) ===='",
         "Write-Host '==== INFINITY trigger test v15 (hex-safe serial + kusd probe) ===='")

# ---- S4: step A/B note -------------------------------------------------
t = edit(t, "S4-abnote", """Write-Host '       v14: reads are answered LIVE from RAM by the hook (the'
Write-Host '       v13 GUID bug is fixed), so B must be A+1 or more if the'
Write-Host '       read path works.'""",
         """Write-Host '       v15: reads are answered LIVE from RAM by the hook and the'
Write-Host '       hex printer is VA-safe now, so B must be A+1 or more if the'
Write-Host '       read path works.'""")

# ---- S7: verdict branches (v15 direction -> v16) -----------------------
t = edit(t, "S7-directions", "Write-Host 'v15 direction: shared-memory pool transport for Infinity.exe'",
         "Write-Host 'v16 direction: shared-memory pool transport for Infinity.exe'",
         count=2)
t = edit(t, "S7-direction-b", "Write-Host 'v15 direction: serve responses through a REAL NVRAM variable the'",
         "Write-Host 'v16 direction: serve responses through a REAL NVRAM variable the'")

# ---- S8: frozen NOTE + END ---------------------------------------------
t = edit(t, "S8-frozen-note", """    Write-Host 'NOTE: hook_calls frozen across ALL steps. With the v14 GUID fix'
    Write-Host 'this now means the read path truly bypasses the hook. First rule'
    Write-Host 'out a stale driver: phase-d.bat must have said "package v14" and'
    Write-Host 'the serial log must show "memory.efi v14 RT".'""",
         """    Write-Host 'NOTE: hook_calls frozen across ALL steps. With the v15 fixes'
    Write-Host 'this now means the read path truly bypasses the hook. First rule'
    Write-Host 'out a stale driver: phase-d.bat must have said "package v15" and'
    Write-Host 'the serial log must show "memory.efi v15 RT".'""")

t = edit(t, "S8-end", "Write-Host '==== END v14 ===='",
         "Write-Host '==== END v15 ===='")

# ---- S9: build note gains the raw-probe hint ---------------------------
t = edit(t, "S9-build-note", """    Write-Host 'NOTE: driver-side win_build still 0 - the live KUSD capture did'
    Write-Host 'not run yet (no INFDIAG read reached the hook). Send the photo +'
    Write-Host 'serial-phase-d.log so we can see the [BLD] serial lines.'""",
         """    Write-Host 'NOTE: driver-side win_build still 0 - the KUSD probe found no'
    Write-Host 'plausible value at either candidate offset. Send the photo +'
    Write-Host 'serial-phase-d.log so we can read the [BLD] kusd raw 0x260/0x308'
    Write-Host 'lines and pin the real offset.'""")

# final sanity
for probe in ("trigger test v15", "END v15", "v16 direction", "hex-safe serial + kusd probe"):
    if probe not in t:
        print(f"FATAL: post-check — '{probe}' missing")
        sys.exit(1)
leftovers = [l for l in t.splitlines()
             if "v14" in l and "v14 CRASHED" not in l and "v14 KUSD" not in l
             and "v15 changes" not in l and "against v9..v14" not in l]
if leftovers:
    print("NOTE: remaining v14 mentions (intentional history references):")
    for l in leftovers[:8]:
        print("   ", l.strip()[:100])

DST.write_text(t, encoding="utf-8")
print(f"OK: {DST} written ({len(t.encode('utf-8'))} bytes, {len(t.splitlines())} lines)")
