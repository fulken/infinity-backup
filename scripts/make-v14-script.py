#!/usr/bin/env python3
"""Derive trigger-test-v14.ps1 from trigger-test-v13.ps1 (anchored edits)."""
import sys
from pathlib import Path

SRC = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v13.ps1")
DST = Path("/home/z/my-project/infinity-qemu-test/trigger-test-v14.ps1")

def edit(text, tag, old, new, count=1):
    n = text.count(old)
    if n != count:
        print(f"FATAL: anchor {tag}: found {n} (need {count})")
        sys.exit(1)
    return text.replace(old, new)

t = SRC.read_text(encoding="utf-8-sig") if SRC.read_bytes()[:3] == b"\xef\xbb\xbf" else SRC.read_text()

# ---- S1: header block -------------------------------------------------
t = edit(t, "S1-header", """# ============================================================
# INFINITY trigger test v13  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v13 driver (infinity-qemu-test-v13 package).
# Running it against v9/v12 drivers gives wrong or crashing
# results - check that phase-d.bat printed "package v13" and
# the boot log says "memory.efi v13 RT".
#
# What v13 changed (the BSOD fix + live signals):
#   - v12 proved the desktop READ path reaches our hook, but its
#     "freshen" (an NVRAM write from inside the GetVariable
#     dispatch) crashed the kernel (KMODE_EXCEPTION). v13 hooks
#     NEVER write NVRAM at runtime - no crash class at all.
#   - INFDIAG reads are ANSWERED FROM LIVE RAM by the hook: every
#     read returns the CURRENT counter/stage/flags. If reads go
#     through the hook, hook_calls MOVES between reads.
#   - INFCNT reads are answered from RAM too: the LIVE count of
#     our-namespace writes that reached the hook (0 = writes
#     bypass the hook, 2 = INFTRIGGER + InfinityReq both arrived).
#   - hook_calls counts ALL hook traffic from driver load.
#""", """# ============================================================
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
#""")

# ---- S2: parser object gains build ------------------------------------
t = edit(t, "S2-obj", "        return [pscustomobject]@{ stage = $stage; flags = $flags; calls = $calls; lastst = $lastst }",
         "        return [pscustomobject]@{ stage = $stage; flags = $flags; build = $build; calls = $calls; lastst = $lastst }")

# ---- S3: banner --------------------------------------------------------
t = edit(t, "S3-banner", "Write-Host '==== INFINITY trigger test v13 (safe live signals) ===='",
         "Write-Host '==== INFINITY trigger test v14 (guid fix + live build) ===='")

# ---- S4: step A/B note -------------------------------------------------
t = edit(t, "S4-abnote", """Write-Host '       v13: reads are answered LIVE from RAM by the hook, so'
Write-Host '       B must be A+1 or more if the read path works.'""",
         """Write-Host '       v14: reads are answered LIVE from RAM by the hook (the'
Write-Host '       v13 GUID bug is fixed), so B must be A+1 or more if the'
Write-Host '       read path works.'""")

# ---- S5: attribution order fix + build line ----------------------------
t = edit(t, "S5-order", """$readOk   = (($cB - $cA) -ge 1)          # read-only gap of >= 1
$writeOk  = ($cntVal -ge 1) -or ($trigSet)
$trigSet  = ($fFlags -band 0x20) -ne 0
$frozen   = ($cA -ge 0 -and $cA -eq $cB -and $cB -eq $cC -and $cC -eq $cF)
$probeFound = ($null -ne $probeBack)""",
         """$readOk   = (($cB - $cA) -ge 1)          # read-only gap of >= 1
$trigSet  = ($fFlags -band 0x20) -ne 0     # (set BEFORE use - v13 ordering bug)
$writeOk  = ($cntVal -ge 1) -or ($trigSet)
$frozen   = ($cA -ge 0 -and $cA -eq $cB -and $cB -eq $cC -and $cC -eq $cF)
$probeFound = ($null -ne $probeBack)
$drvBuild = -1
if ($null -ne $A) { $drvBuild = [int]$A.build }
$osBuild  = [Environment]::OSVersion.Version.Build""")

# ---- S6: summary lines --------------------------------------------------
t = edit(t, "S6-summary", """Write-Host ("INFCNT live RAM count (our-var writes that reached the hook) = {0}   (0 = bypassed, 2 = both)" -f $cntVal)""",
         """Write-Host ("win_build  driver-live={0}  script-side={1}   (equal = build detection works)" -f $drvBuild, $osBuild)
Write-Host ("INFCNT live RAM count (our-var writes that reached the hook) = {0}   (0 = bypassed, 2 = both)" -f $cntVal)""")

# ---- S7: verdict branches ----------------------------------------------
t = edit(t, "S7-verdict", """} elseif ($readOk -and -not $writeOk) {
    Write-Host 'Reads reach the hook, writes BYPASS it (kernel writes NVRAM directly).'
    Write-Host 'This matches the v12 field evidence. v14 direction: serve requests'
    Write-Host 'from the GetVariable path / shared-memory pool transport.'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
} elseif ($writeOk -and -not $readOk) {
    Write-Host 'Writes reach the hook (INFCNT moved), reads BYPASS it (counts frozen).'
    Write-Host 'v14 direction: serve responses through a REAL NVRAM variable the'
    Write-Host 'desktop can read without our hook.'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
} else {
    Write-Host 'BOTH paths bypass our hooks (counts frozen AND INFCNT absent):'
    Write-Host 'desktop Windows variable transport is dead for our namespace.'
    Write-Host 'v14 direction: shared-memory pool transport for Infinity.exe'
    Write-Host '(the original ProjectMemory/SharedMemoryPool architecture).'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
}""",
         """} elseif ($readOk -and -not $writeOk) {
    Write-Host 'Reads reach the hook, writes BYPASS it (kernel writes NVRAM directly).'
    Write-Host 'v15 direction: shared-memory pool transport for Infinity.exe'
    Write-Host '(InfinityMem already in NVRAM + the 4MB pool).'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
} elseif ($writeOk -and -not $readOk) {
    Write-Host 'Writes reach the hook (INFCNT moved), reads BYPASS it (counts frozen).'
    Write-Host 'v15 direction: serve responses through a REAL NVRAM variable the'
    Write-Host 'desktop can read without our hook.'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
} else {
    Write-Host 'BOTH paths bypass our hooks (counts frozen AND INFCNT absent):'
    Write-Host 'desktop Windows variable transport is dead for our namespace.'
    Write-Host 'v15 direction: shared-memory pool transport for Infinity.exe'
    Write-Host '(the original ProjectMemory/SharedMemoryPool architecture).'
    Write-Host 'Send photo of SUMMARY + serial-phase-d.log.'
}""")

# ---- S8: frozen NOTE -----------------------------------------------------
t = edit(t, "S8-note", """if ($frozen) {
    Write-Host ''
    Write-Host 'NOTE: hook_calls frozen across ALL steps. With the v13 driver this'
    Write-Host 'means the read path truly bypasses the hook - confirm the boot'
    Write-Host 'used the v13 driver: phase-d.bat said "package v13".'
}
Write-Host '==== END v13 ===='""",
         """if ($frozen) {
    Write-Host ''
    Write-Host 'NOTE: hook_calls frozen across ALL steps. With the v14 GUID fix'
    Write-Host 'this now means the read path truly bypasses the hook. First rule'
    Write-Host 'out a stale driver: phase-d.bat must have said "package v14" and'
    Write-Host 'the serial log must show "memory.efi v14 RT".'
}
if ($drvBuild -le 0) {
    Write-Host ''
    Write-Host 'NOTE: driver-side win_build still 0 - the live KUSD capture did'
    Write-Host 'not run yet (no INFDIAG read reached the hook). Send the photo +'
    Write-Host 'serial-phase-d.log so we can see the [BLD] serial lines.'
}
Write-Host '==== END v14 ===='""")

# final sanity
for probe in ("trigger test v14", "win_build  driver-live", "END v14", "v14 GUID fix"):
    if probe not in t:
        print(f"FATAL: post-check — '{probe}' missing")
        sys.exit(1)
if "v13" in t.replace("v13 ordering bug", "").replace("GUID bug", ""):
    import re
    leftovers = [l for l in t.splitlines() if "v13" in l and "ordering bug" not in l]
    print("NOTE: remaining v13 mentions (intentional history references):")
    for l in leftovers[:8]:
        print("   ", l.strip()[:100])

DST.write_text(t, encoding="utf-8")
print(f"OK: {DST} written ({len(t.encode('utf-8'))} bytes, {len(t.splitlines())} lines)")
