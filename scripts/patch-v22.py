#!/usr/bin/env python3
# ============================================================================
# patch-v22.py — trigger-test v21 -> v22 script transformation
#
# v22 pairs with the v18 DRIVER (direct KUSD-window reads). Changes:
#   1. [POSTMORTEM] step 0: Event Log BugCheck(1001)/Kernel-Power(41) query
#      FIRST - names the previous run's killer (bugcheck vs instant death).
#   2. Serial canaries: Try-Del INFTRIGGER (hook-entry logs "S OURVAR
#      delete") before step A, before step E, before EVERY ladder send and
#      after the ladder - the serial log now pinpoints the script position
#      even when the console output is lost.
#   3. Self-test fix: [uint32]0xFFFFFFFF -> [uint32]4294967295 (the v21
#      line-444 hex-literal trap: 0xFFFFFFFF parses as Int32 -1 and the
#      cast throws, silently skipping that check).
#   4. LADDER REWRITTEN J1..J7 for the v18 driver semantics:
#      pid=FFFFFFFF = direct window-gated read (the data-path proof);
#      per-pid reads without attach = clean ErrAccess (honest negative).
#   5. Summary/verdict/decision-table updates; INFCNT final = G+8.
#
# Usage: python3 scripts/patch-v22.py   (reads/patches infinity-qemu-test/)
# ============================================================================
import sys, pathlib

BASE = pathlib.Path("/home/z/my-project")
SRC = BASE / "infinity-qemu-test" / "trigger-test-v21.ps1"
DST = BASE / "infinity-qemu-test" / "trigger-test-v22.ps1"

def main():
    state = {'t': SRC.read_text(), 'n': 0}
    def rep(old, new, tag):
        t = state['t']
        if t.count(old) != 1:
            print(f"  FAIL {tag}: anchor found {t.count(old)}x"); sys.exit(1)
        state['t'] = t.replace(old, new, 1); state['n'] += 1
        print(f"  {tag} OK")

    # ------------------------------------------------------------------
    # 1) Header comment block (whole v21 header -> v22 header)
    # ------------------------------------------------------------------
    old_hdr_end = "# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal \"variable absent\").\n# stage=4 is EXPECTED (virtual mode armed - OS runtime calls count).\n#\n"
    new_hdr = """# ============================================================
# INFINITY bridge trigger test v22  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v18 DRIVER (memory.efi v18 RT - "bridge + direct
# KUSD reads"). usb-d\\memory.efi must be the v18 RT build
# (121253 bytes). With the v17 driver the J-ladder WILL KILL THE VM
# (v20 class) - the phase-d.bat guard checks the file size.
#
# CRASH HISTORY (root-caused 2026-09-22 from the v17 source):
#   v19: step I attach (op=7) and v20: step J kernel read BOTH died
#        inside ReadPhysical: it switches CR3 to the boot-time
#        firmware tables, which under Windows map NEITHER our hook
#        code (0xFFFFF800...) nor the OS IDT/stack -> fault storm.
#   v18 DRIVER FIX: pid=0xFFFFFFFF reads are now DIRECT volatile
#        reads in the hook's own context, gated to the two
#        KUSER_SHARED_DATA windows every address space maps
#        (user 0x7FFE0000-0x7FFEFFFF, kernel alias
#        0xFFFFF78000000000-0xFFFFF7800000FFFF). The read cannot
#        fault; anything outside the windows fails cleanly.
#   v21: the ladder never ran - the VM died at step A (first
#        INFDIAG read, BEFORE any request; a path proven in 4 prior
#        boots). Step 0 (post-mortem) now reads the Event Log so the
#        next run NAMES the previous killer (BugCheck 1001 = real
#        bugcheck code; Kernel-Power 41 only = instant death class).
#
# v22 STRATEGY:
#   step 0  PREVIOUS-BOOT POST-MORTEM (Event Log; no firmware contact)
#   canaries Try-Del INFTRIGGER before A / E / every Jn / after the
#           ladder: the serial log then shows the exact script
#           position even if the console dies with the VM.
#   J1..J7  the direct-read ladder (all known-answer):
#     J1  pid=FFFFFFFF  USER alias 0x7FFE0260 x4  -> 19045 = PROOF
#     J2  pid=FFFFFFFF  KERNEL alias              -> 19045
#     J3  pid=FFFFFFFF  0x7FFE0308 x4             -> 0
#     J4  pid=FFFFFFFF  kernel alias 0x308        -> 0
#     J5  pid=FFFFFFFF  0x7FFE0260 x8             -> dword[0]=19045
#     J6  pid=FFFFFFFF  NON-CANONICAL VA          -> ErrAccess(4)
#     J7  pid=$PID      USER alias                -> ErrAccess(4)
#         (per-pid reads need an attach; attach stays fatal in this
#          VM - v19. J7 documents the honest negative, no crash.)
#
# Step map:
#   0    previous-boot post-mortem (Event Log 1001/41)
#   A,B  INFDIAG reads          -> hook_calls must MOVE (read path)
#   C    INFPROBE write+read    -> raw NVRAM write path
#   D    INFTRIGGER write       -> trigger flag 0x20 + INFCNT
#   E    InfinityReq PING       -> the request transport
#   E2   InfinityResp read      -> FULL BRIDGE check (PONG)
#   F    final INFDIAG + read-backs
#   G    INFCNT read            -> live RAM write counter
#   H    InfinityData round trip-> payload transport
#   I    (SKIPPED - attach proven fatal in v19, see above)
#   J1..J7 the direct-read ladder (v18 driver)
#   N    final INFCNT -> expect G+8 (H +1 and J1..J7 +7 are the only
#        counting writes after G; requests are consumed in RAM and
#        deletes never count - proven by v17/v20 runs)
#
# Win32 203 = ERROR_ENVVAR_NOT_FOUND (normal "variable absent").
# stage=4 is EXPECTED (virtual mode armed - OS runtime calls count).
#
"""
    rep(old_hdr_end, new_hdr, "H1-header-block")

    # ------------------------------------------------------------------
    # 2) transcript filename
    # ------------------------------------------------------------------
    rep('"trigger-test-v21-output-$stamp.txt"', '"trigger-test-v22-output-$stamp.txt"', "H2-transcript-name")

    # ------------------------------------------------------------------
    # 3) banner
    # ------------------------------------------------------------------
    rep("Write-Host '==== INFINITY trigger test v21 (v20 crash root-caused - the pid safety ladder J1..J9) ===='",
        "Write-Host '==== INFINITY trigger test v22 (v18 driver: direct KUSD reads - the proof ladder J1..J7) ===='",
        "H3-banner")

    # ------------------------------------------------------------------
    # 4) [POSTMORTEM] step 0 right after [ENV]
    # ------------------------------------------------------------------
    old_env = 'Write-Host ("[ENV] PowerShell $($PSVersionTable.PSVersion)  Windows build $([Environment]::OSVersion.Version.ToString())")\n'
    new_env = old_env + """
# ---- step 0: PREVIOUS-BOOT POST-MORTEM (Event Log; pure Windows,
#      NO firmware contact - safe to run first whatever happened)
Write-Host ''
Write-Host '--- step 0: previous-boot post-mortem (Event Log) ---'
$postmortem = 'no events'
try {
    $ev = Get-WinEvent -FilterHashtable @{ LogName='System'; Id=1001; ProviderName='Microsoft-Windows-WER-SystemErrorReporting' } -MaxEvents 3 -ErrorAction Stop
    $postmortem = 'BugCheck events FOUND'
    foreach ($e in $ev) {
        $m = ($e.Message -replace "`r`n", ' ')
        if ($m.Length -gt 200) { $m = $m.Substring(0, 200) + '...' }
        Write-Host ("      BUGCHECK {0}: {1}" -f $e.TimeCreated, $m)
    }
} catch { Write-Host '      no BugCheck(1001) events (clean history or never logged)' }
try {
    $ev41 = Get-WinEvent -FilterHashtable @{ LogName='System'; Id=41; ProviderName='Microsoft-Windows-Kernel-Power' } -MaxEvents 3 -ErrorAction Stop
    foreach ($e in $ev41) {
        Write-Host ("      KERNEL-POWER 41 {0} (unexpected stop - the instant-death class leaves ONLY this)" -f $e.TimeCreated)
    }
} catch { Write-Host '      no Kernel-Power(41) events' }
Write-Host '      -> a BUGCHECK line at the v21 run time names the v21 step-A killer;'
Write-Host '         41-only = instant death with no chance to log (v19/v20 class).'
"""
    rep(old_env, new_env, "H4-postmortem")

    # ------------------------------------------------------------------
    # 5) self-test comment + the 0xFFFFFFFF literal fix
    # ------------------------------------------------------------------
    rep("""# ---- self-test: the parsers must be perfect BEFORE touching the driver
#      (v18's U32 truncated every dword to its low byte - caught only by
#       field runs. v19 added this gate; its own 0xFFFFFFFF check tripped
#       a cast trap ("Cannot convert -1 to UInt32") that v20/v21 avoid:
#       uint32-vs-uint32 compares only, never an [u32] cast of an int)""",
        """# ---- self-test: the parsers must be perfect BEFORE touching the driver
#      (v18's U32 truncated every dword to its low byte - caught only by
#       field runs. v19 added this gate; v21's FFFFFFFF check STILL
#       tripped the hex-literal trap: 0xFFFFFFFF parses as Int32 -1 and
#       [uint32]-1 throws (silently skipped that check - cosmetic).
#       v22: DECIMAL literals for max-value compares; uint32-vs-uint32
#       only, never an [u32] cast of a negative int)""",
        "H5-selftest-comment")
    rep("ST-Check ((U32 $stb 0) -eq [uint32]0xFFFFFFFF) 'U32 FF FF FF FF must be 0xFFFFFFFF'",
        "ST-Check ((U32 $stb 0) -eq [uint32]4294967295) 'U32 FF FF FF FF must be 4294967295'",
        "H6-literal-fix")

    # ------------------------------------------------------------------
    # 6) canary helper after Try-Del
    # ------------------------------------------------------------------
    rep("""function Try-Del([string]$name) {
    # best-effort delete (size 0 + same attributes = EFI delete)
    try { $null = [EfiVarBridge]::SetFirmwareEnvironmentVariableExW($name, $guid, $null, [uint32]0, [uint32]$attrs) } catch { }
}""",
        """function Try-Del([string]$name) {
    # best-effort delete (size 0 + same attributes = EFI delete)
    try { $null = [EfiVarBridge]::SetFirmwareEnvironmentVariableExW($name, $guid, $null, [uint32]0, [uint32]$attrs) } catch { }
}

function Canary([string]$tag) {
    # v22 serial canary: INFTRIGGER is an OURVAR name, so its delete is
    # logged at HOOK ENTRY ("S OURVAR delete") before anything happens -
    # inert (deletes never set flags/counts), but the serial log then
    # shows exactly where the script is. If the VM dies between a canary
    # and the next expected line, the window is closed tight.
    Write-Host ("[CANARY] {0}  (serial: 'S OURVAR delete' = we got this far)" -f $tag)
    Try-Del 'INFTRIGGER'
    Start-Sleep -Milliseconds 120
}""",
        "H7-canary-helper")

    # ------------------------------------------------------------------
    # 7) canary before step A
    # ------------------------------------------------------------------
    rep("""Start-Sleep -Milliseconds 200
Write-Host '[CLR] stale probe variables cleaned (best effort)'

# [3] baseline reads: A then B (no writes in between)""",
        """Start-Sleep -Milliseconds 200
Write-Host '[CLR] stale probe variables cleaned (best effort)'
Canary 'pre-A (baseline INFDIAG reads next - v21 died HERE)'

# [3] baseline reads: A then B (no writes in between)""",
        "H8-canary-pre-A")

    # ------------------------------------------------------------------
    # 8) canary before step E
    # ------------------------------------------------------------------
    rep("""Write-Host ''
Write-Host '--- step E: InfinityReq PING (48 bytes, op=0xDEADBEEF) ---'""",
        """Write-Host ''
Canary 'pre-E (the PING request transport next)'
Write-Host '--- step E: InfinityReq PING (48 bytes, op=0xDEADBEEF) ---'""",
        "H9-canary-pre-E")

    # ------------------------------------------------------------------
    # 9) ladder block: intro + table + decision table
    # ------------------------------------------------------------------
    rep("""# ============================================================
# [11] THE PID SAFETY LADDER - J1..J9
#      Nine READ requests (op=1), ordered SAFEST-FIRST. Each prints
#      its marker and pauses 1.5 s BEFORE sending, so if the VM dies
#      the video + serial log name the killer variant exactly.
#      Known-answer bytes everywhere:
#        KUSD+0x260 -> 65 4A 00 00 (19045 LE). The USER alias
#                      0x7FFE0260 and the KERNEL alias
#                      0xFFFFF78000000260 are the SAME physical
#                      page - but the user alias is mapped in EVERY
#                      process and needs no kernel-mode tricks.
#        KUSD+0x308 -> 00 00 00 00 (v15/v16 field truth)
#      $PID = this very PowerShell: a real, listed, alive target
#      process - exactly the read-a-target-process job the driver
#      was built for.
# ============================================================
$expBuild = New-Object byte[] 4
$expBuild[0] = 0x65; $expBuild[1] = 0x4A; $expBuild[2] = 0x00; $expBuild[3] = 0x00   # 19045 = 0x4A65 LE
$myPid = [uint32]$PID
$ladder = @(
    @{ n = 'J1'; seq = 0x1601; rpid = $myPid;     len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'the designed use case: read a live process (this PowerShell) - safest possible' }
    @{ n = 'J2'; seq = 0x1602; rpid = $myPid;     len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias';          why = 'same safe pid, kernel-space address' }
    @{ n = 'J3'; seq = 0x1603; rpid = 4;          len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'pid=4 (System process) - a different real, existing process' }
    @{ n = 'J4'; seq = 0x1604; rpid = 0;          len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'pid=0 semantics probe (Idle? current? attached?)' }
    @{ n = 'J5'; seq = 0x1605; rpid = 'FFFFFFFF'; len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = "v20's killer PID with a SAFE address - isolates pid vs addr" }
    @{ n = 'J6'; seq = 0x1606; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias';          why = 'EXACT v20 repeat (pid=FFFFFFFF + kernel alias) - reproduce/confirm' }
    @{ n = 'J7'; seq = 0x1607; rpid = $myPid;     len = 4; addr = '00007FFE00000308'; atxt = 'USER alias 0x7FFE0308';  why = 'second KUSD field (v15/v16 truth: 0)' }
    @{ n = 'J8'; seq = 0x1608; rpid = $myPid;     len = 8; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';  why = 'x8 chunk test (dword[0] must equal J1)' }
    @{ n = 'J9'; seq = 0x1609; rpid = $myPid;     len = 4; addr = '0000800000000000'; atxt = 'NON-CANONICAL VA';      why = 'negative test: expect ErrAccess(4), NO crash' }
)

Write-Host ''
Write-Host 'LADDER DECISION TABLE (for reading the video if the VM dies):'
Write-Host ' dies at J1     -> the per-pid read path itself is fatal (needs attach?) - Phase E rests on [BLD]'
Write-Host ' dies at J2     -> J1 PROVED the data path (user space); kernel-alias reads are the killer'
Write-Host ' dies at J3/J4  -> pid=4 / pid=0 resolution fatal; J1 already proved the path'
Write-Host ' dies at J5     -> pid=FFFFFFFF (os_cr3 / kernel mode) is the killer; J1 proved the path'
Write-Host ' dies at J6     -> v20 crash reproduced AFTER J1..J5 passed: the pid+addr COMBINATION kills'
Write-Host ' survives all 9 -> full matrix ran; verdict printed at the end'
Start-Sleep -Milliseconds 800""",
        """# ============================================================
# [11] THE DIRECT-READ LADDER - J1..J7 (v18 driver semantics)
#      pid=0xFFFFFFFF = KERNEL target = the v18 DIRECT volatile read
#      gated to the two KUSER_SHARED_DATA windows (can never fault).
#      Known-answer bytes everywhere:
#        KUSD+0x260 -> 65 4A 00 00 (19045 LE) - both aliases, same page
#        KUSD+0x308 -> 00 00 00 00 (v15/v16 field truth)
#      WARNING: with a v17 driver on the stick, J1..J5 die (the v20
#      CR3-switch killer). phase-d.bat checks memory.efi size 121253.
# ============================================================
$expBuild = New-Object byte[] 4
$expBuild[0] = 0x65; $expBuild[1] = 0x4A; $expBuild[2] = 0x00; $expBuild[3] = 0x00   # 19045 = 0x4A65 LE
$myPid = [uint32]$PID
$ladder = @(
    @{ n = 'J1'; seq = 0x1601; rpid = 'FFFFFFFF'; len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';       why = 'THE DATA PATH PROOF: v18 direct read, user window - the same page [BLD] reads' }
    @{ n = 'J2'; seq = 0x1602; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias 0xFFFFF78000000260'; why = 'kernel-space VA via requests - first kernel-alias data ever (v20 died here; v18 reads it directly)' }
    @{ n = 'J3'; seq = 0x1603; rpid = 'FFFFFFFF'; len = 4; addr = '00007FFE00000308'; atxt = 'USER alias 0x7FFE0308';       why = 'second KUSD field, known value 0 (v15/v16 field truth)' }
    @{ n = 'J4'; seq = 0x1604; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000308'; atxt = 'KERNEL alias 0xFFFFF78000000308'; why = 'second field via the kernel alias - cross-check of J3' }
    @{ n = 'J5'; seq = 0x1605; rpid = 'FFFFFFFF'; len = 8; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';       why = 'x8 chunk test (dword[0] must equal J1; stays inside the window)' }
    @{ n = 'J6'; seq = 0x1606; rpid = 'FFFFFFFF'; len = 4; addr = '0000800000000000'; atxt = 'NON-CANONICAL VA';           why = 'negative: the gate must reject BEFORE any access - expect ErrAccess(4), no crash' }
    @{ n = 'J7'; seq = 0x1607; rpid = $myPid;     len = 4; addr = '00007FFE00000260'; atxt = 'USER alias 0x7FFE0260';       why = 'per-pid read WITHOUT attach: expect clean ErrAccess(4) - per-pid reads still need a (currently fatal) attach; honest negative' }
)

Write-Host ''
Write-Host 'LADDER DECISION TABLE (for reading the video if the VM dies):'
Write-Host ' dies at J1     -> the driver is NOT v18 (a v17 would walk+CR3-switch = v20 death).'
Write-Host '                  Check usb-d\\memory.efi size: v18-RT = 121253 bytes.'
Write-Host ' dies at J2..J5 -> a window read is fatal DESPITE the direct path - the serial'
Write-Host '                  [RD] mapped va / mapped read ok pair tells exactly how far it got'
Write-Host ' dies at J6/J7  -> unexpected (gate-rejected / no-attach paths) - send everything'
Write-Host ' J1 answers ErrAccess(4) -> the gate rejected a VALID KUSD address: driver not v18.'
Write-Host '                  Do NOT rerun until memory.efi is replaced (size 121253).'
Write-Host ' survives all 7 -> full matrix ran; verdict printed at the end'
Start-Sleep -Milliseconds 800""",
        "H10-ladder-table")

    # ------------------------------------------------------------------
    # 10) in-loop canary before each send
    # ------------------------------------------------------------------
    rep("""    Write-Host ("[{0}] >>> SENDING op=1(READ) seq=0x{1:X} pid={2} len={3} addr=0x{4}" -f $v.n, $v.seq, $v.rpid, $v.len, $v.addr)""",
        """    Canary ("pre-" + $v.n)
    Write-Host ("[{0}] >>> SENDING op=1(READ) seq=0x{1:X} pid={2} len={3} addr=0x{4}" -f $v.n, $v.seq, $v.rpid, $v.len, $v.addr)""",
        "H11-loop-canary")

    # ------------------------------------------------------------------
    # 11) cross-check block J7/J8 -> J3/J4(expected 0) + J5(chunk)
    # ------------------------------------------------------------------
    rep("""    # J7 cross-check (expected 0) and J8 chunk check, at the learned offset
    if (($v.n -eq 'J7' -or $v.n -eq 'J8') -and $dataOff -ge 0 -and $null -ne $R) {
        $srcArr = $null
        if ($bufKind -eq 'resp' -and $null -ne $R.Resp) { $srcArr = $R.Resp }
        if ($bufKind -eq 'data' -and $null -ne $R.Data) { $srcArr = $R.Data }
        if ($null -ne $srcArr) {
            if ($v.n -eq 'J7' -and ($dataOff + 4) -le $srcArr.Length) {
                $kv = U32 $srcArr $dataOff
                $vTxt += " | J7 dword@$dataOff = $kv (expected 0)"
            }
            if ($v.n -eq 'J8' -and ($dataOff + 8) -le $srcArr.Length) {
                $d0 = U32 $srcArr $dataOff
                $d1 = U32 $srcArr ($dataOff + 4)
                $vTxt += " | J8 dword[0]=$d0 dword[1]=$d1 (dword[0] must be 19045)"
            }
        }
    }""",
        """    # J3/J4 cross-check (expected 0) and J5 chunk check, at the learned offset
    if (($v.n -eq 'J3' -or $v.n -eq 'J4' -or $v.n -eq 'J5') -and $dataOff -ge 0 -and $null -ne $R) {
        $srcArr = $null
        if ($bufKind -eq 'resp' -and $null -ne $R.Resp) { $srcArr = $R.Resp }
        if ($bufKind -eq 'data' -and $null -ne $R.Data) { $srcArr = $R.Data }
        if ($null -ne $srcArr) {
            if (($v.n -eq 'J3' -or $v.n -eq 'J4') -and ($dataOff + 4) -le $srcArr.Length) {
                $kv = U32 $srcArr $dataOff
                $vTxt += " | $($v.n) dword@$dataOff = $kv (expected 0)"
            }
            if ($v.n -eq 'J5' -and ($dataOff + 8) -le $srcArr.Length) {
                $d0 = U32 $srcArr $dataOff
                $d1 = U32 $srcArr ($dataOff + 4)
                $vTxt += " | J5 dword[0]=$d0 dword[1]=$d1 (dword[0] must be 19045)"
            }
        }
    }""",
        "H12-crosscheck")

    # ------------------------------------------------------------------
    # 12) negative block J9 -> J6/J7
    # ------------------------------------------------------------------
    rep("""    if ($v.n -eq 'J9') {
        if ($null -ne $R -and $null -ne $R.Resp) {
            if ($R.Status -eq 4) { $negTxt = 'OK - status=4(ErrAccess) as designed; script still alive = no crash' }
            else { $negTxt = "UNEXPECTED status=$($R.Status)($(Stat-Name $R.Status)) - see serial" }
        } else {
            $negTxt = 'NO RESPONSE (but script alive - see serial [RD])'
        }
    }""",
        """    if ($v.n -eq 'J6' -or $v.n -eq 'J7') {
        if ($null -ne $R -and $null -ne $R.Resp) {
            if ($R.Status -eq 4) { $negTxt = "OK - $($v.n) status=4(ErrAccess) as designed; script still alive = no crash" }
            else { $negTxt = "UNEXPECTED $($v.n) status=$($R.Status)($(Stat-Name $R.Status)) - see serial" }
        } else {
            $negTxt = "NO RESPONSE on $($v.n) (but script alive - see serial [RD])"
        }
    }""",
        "H13-negatives")

    # ------------------------------------------------------------------
    # 13) post-ladder canary + verdict wording
    # ------------------------------------------------------------------
    rep("""$kernOk = ($jVal -eq 19045)""",
        """Canary 'post-ladder (all J-steps done)'
$kernOk = ($jVal -eq 19045)""",
        "H14-postladder-canary")

    rep("""Write-Host '>>> KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE <<<'
    Write-Host "Windows -> InfinityReq -> our hook -> cross-context read -> InfinityResp ($jWhere)." """.rstrip(),
        """Write-Host '>>> KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE <<<'
    Write-Host "Windows -> InfinityReq -> our hook -> direct KUSD read -> InfinityResp ($jWhere)." """.rstrip(),
        "H15-verdict-wording")

    rep("""    Write-Host '>>> FULL BRIDGE PROVEN - and the VM SURVIVED all 9 ladder variants,'
    Write-Host '>>> but none returned the expected dword. <<<'""",
        """    Write-Host '>>> FULL BRIDGE PROVEN - and the VM SURVIVED all 7 ladder variants,'
    Write-Host '>>> but none returned the expected dword. <<<'""",
        "H16-verdict-9to7")

    # ------------------------------------------------------------------
    # 14) summary lines + step N expectation
    # ------------------------------------------------------------------
    rep("Write-Host '--- step N: final INFCNT read (live RAM count; expect G+1: only InfinityData persists) ---'",
        "Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8: H +1 and J1..J7 +7) ---'",
        "H17-stepN-header")
    rep("""Write-Host ("[8] Kernel read via ladder (J1..J9) : {0}" -f $jTxt)
Write-Host ("[9] Negative VA handling (J9)      : {0}" -f $negTxt)""",
        """Write-Host ("[8] Kernel read via ladder (J1..J7) : {0}" -f $jTxt)
Write-Host ("[9] Negatives (J6 gate, J7 no-attach) : {0}" -f $negTxt)""",
        "H18-summary-89")
    rep("""Write-Host ("    INFCNT final = {0}   (expect G+1 = {1}: H's InfinityData write is the only" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 1 } else { '?' }))
Write-Host '     counting write after G; requests are consumed in RAM and deletes never count)'""",
        """Write-Host ("    INFCNT final = {0}   (expect G+8 = {1}: H's InfinityData write (+1) and the" -f $cntFinal, $(if ($cntVal -ge 0) { $cntVal + 8 } else { '?' }))
Write-Host '     7 ladder InfinityReq writes (+7); requests are consumed in RAM and deletes never count)'""",
        "H19-stepN-math")

    rep("Write-Host '==== END v21 ===='", "Write-Host '==== END v22 ===='", "H20-end-marker")

    # ------------------------------------------------------------------
    # final sanity
    # ------------------------------------------------------------------
    checks = [
        ("trigger-test-v22-output", "transcript name v22"),
        ("[uint32]4294967295", "decimal literal fix present"),
        ("[uint32]0xFFFFFFFF" not in state['t'], "hex-literal trap removed"),
        ("Get-WinEvent", "post-mortem present"),
        ("function Canary", "canary helper present"),
        ('("pre-" + $v.n)' in state['t'] and "post-ladder" in state['t'] and "pre-A" in state['t'] and "pre-E" in state['t'], "canary call sites present"),
        ("J1..J7" in state['t'], "ladder renamed to J1..J7"),
        ("'J9'" not in state['t'], "no stale J9 references"),
        ("'J8'" not in state['t'], "no stale J8 references"),
        ("121253", "driver size documented"),
        ("mapped" in state['t'], "v18 trace references"),
        ("==== END v22 ====", "end marker"),
    ]
    ok = True
    for good, label in checks:
        res = good if isinstance(good, bool) else (good in state['t'])
        print(("  PASS  " if res else "  FAIL  ") + label)
        ok = ok and res
    if not ok:
        print("SANITY FAILURES - not writing v22"); sys.exit(1)

    t = state['t']
    DST.write_text(t)
    print(f"[patch-v22] {state['n']} anchored edits applied -> {DST}")
    print(f"[patch-v22] {len(t.splitlines())} lines, {len(t.encode())} bytes")

if __name__ == "__main__":
    main()
