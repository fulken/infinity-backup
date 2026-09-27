# ============================================================
# INFINITY bridge trigger test v21  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v17 driver stick (memory.efi v17 RT - "bridge +
# kernel data path (phase E)"). The DRIVER IS NOT CHANGED by v21;
# only this test script evolves (v18 -> v19 -> v20 -> v21).
#
# CRASH HISTORY (already root-caused - do not repeat):
#   v19: step I ReqOp_Attach (op=7, pid=0) KILLED the VM. The attach
#        handler walks the process list looking for emulator EXE
#        names; none exist in this VM -> fatal. v20+ SKIPS attach.
#   v20: first READ request (op=1, pid=0xFFFFFFFF, KUSD kernel alias
#        FFFFF78000000260, len=4) got FURTHER: serial shows
#        "[INF][RD] kern va=0xFFFFF78000000260" - the request was
#        received and parsed CORRECTLY (address exact), the kernel
#        read STARTED - then the VM died, no response ever written.
#        The crash is INSIDE the driver's cross-context read. The
#        only script-controllable inputs left: pid / addr / len.
#        (Proof plain reads CAN work in hook context: the driver's
#        own [BLD] probe read KUSD 0x260 fine in the SAME boot -
#        "live windows build=19045".)
#
# v21 STRATEGY - THE PID SAFETY LADDER (J1..J9):
#   Nine READ requests, ordered SAFEST-FIRST. Each prints a big
#   marker and pauses 1.5 s BEFORE it is sent - if the VM dies, the
#   last marker on screen + the last serial [RD] line name the
#   killer variant exactly. Every variant asks for known bytes:
#     KUSD+0x260 = 65 4A 00 00 (19045 LE), via the USER alias
#     0x7FFE0260 where possible (same physical page as the kernel
#     alias, mapped in EVERY process, no kernel-mode tricks needed)
#     J1  pid=$PID (this PowerShell)  addr=USER alias    - the
#         driver's DESIGNED job: read a live target process
#     J2  pid=$PID                    addr=KERNEL alias
#     J3  pid=4 (System process)      addr=USER alias
#     J4  pid=0                       addr=USER alias
#     J5  pid=0xFFFFFFFF              addr=USER alias  (v20 pid, safe addr)
#     J6  pid=0xFFFFFFFF              addr=KERNEL alias (exact v20 repeat)
#     J7  pid=$PID  KUSD+0x308 x4 (v15/v16 field truth: 0)
#     J8  pid=$PID  KUSD+0x260 x8 (chunk test; dword[0] must equal J1)
#     J9  pid=$PID  NON-CANONICAL VA  (expect ErrAccess(4), no crash)
#
# Step map:
#   A,B  INFDIAG reads          -> hook_calls must MOVE (read path)
#   C    INFPROBE write+read    -> raw NVRAM write path
#   D    INFTRIGGER write       -> trigger flag 0x20 + INFCNT
#   E    InfinityReq PING       -> the request transport
#   E2   InfinityResp read      -> FULL BRIDGE check (PONG)
#   F    final INFDIAG + read-backs
#   G    INFCNT read            -> live RAM write counter
#   H    InfinityData round trip-> payload transport
#   I    (SKIPPED - attach proven fatal in v19, see above)
#   J1..J9 the pid safety ladder
#   N    final INFCNT -> expect G+1 (H's data write is the only
#        counting write after G; requests are consumed in RAM and
#        deletes never count - proven by v17/v20 runs)
#
# ============================================================
# INFINITY bridge trigger test v22  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v18 DRIVER (memory.efi v18 RT - "bridge + direct
# KUSD reads"). usb-d\memory.efi must be the v18 RT build
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
# KEEP FILMING THE SCREEN. If the VM dies mid-ladder, the video plus
# serial-phase-d.log ARE the record (the .txt transcript dies with
# the VM). The last [Jn] marker on screen names the killer variant.
# ============================================================
# INFINITY bridge trigger test v23  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v23 = v22 + THE USER-ALIAS HEX FIX. Script-only; the driver is
# UNCHANGED (memory.efi v18 RT, 121253 bytes). In the v22 ladder
# the USER-alias rungs carried a mis-assembled hex string
# (0x00007FFE00000260 - the intended 0x7FFE0260 shifted up 32
# bits - instead of 0x000000007FFE0260) - the v18 gate
# correctly rejected them as out-of-window (J1/J3/J5 became
# accidental extra negatives; the 2026-09-22 run still PROVED the
# kernel alias: J2 -> 19045 = PHASE E COMPLETE). v23 sends the
# REAL user-alias addresses, so the last unproven cell runs:
#     J1/J5/J7  0x000000007FFE0260  (KUSD+0x260, user window)
#     J3        0x000000007FFE0308  (KUSD+0x308, user window)
# Expected with the v18 driver:
#     J1 Success + 19045   <- user-alias read via request
#     J2 Success + 19045   (re-confirm the kernel alias)
#     J3 Success + 0
#     J4 Success + 0       (re-confirm)
#     J5 Success + dword[0] = 19045
#     J6 ErrAccess(4)  non-canonical, gate reject, NO crash
#     J7 ErrAccess(4)  real pid without attach = pre-read reject
#                      (with the VALID address this now isolates
#                      the pid check; NO [RD] on serial = the pid
#                      check fires BEFORE the window gate)
#     N  INFCNT = G+8 (unchanged)
# The self-test now ALSO round-trips the user-alias hex string,
# so this class of slip can never again reach the driver.
# ============================================================
# ============================================================
# ============================================================
# ============================================================
# ============================================================
# ============================================================
# INFINITY bridge trigger test v30  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v22 DRIVER (memory.efi v22 RT - "anchors + exports
# + process walk (F3)", 134330 bytes). v30 runs the FULL K/L/M/J
# regression against v22 (re-proving F1+F2 on the new binary) and
# then the NEW step W: the F3 EPROCESS walk (op=11). With the v21
# driver (131709 B) everything except W still works - W refuses
# cleanly (op 11 -> ErrUnsupported) and the F3 verdict says so.
#
# WHAT F3 IS: the first reads of kernel data OUTSIDE the validated
# ntoskrnl image. The driver resolves PsInitialSystemProcess via
# the F2 export machinery (in-image gate - no new trust root) and
# walks ActiveProcessLinks from there with: double-link LIST_ENTRY
# consistency (Blink(cur)==prev AND Blink(next)==cur before every
# advance), canonical-VA + no-wrap gates, a +-4 GB pool-cluster
# window, 64-entry / 256-page hard budgets, and LIVE name-slot
# discovery ("System\0" probe - offsets derived, never trusted).
# The v19 attach death class (hardcoded name hunting) is
# structurally impossible here. Every refusal is a clean status -
# the VM stays alive (the M4 discipline).
#
# STEP W LADDER (all canaried; the serial [PW] lines cross-check):
#   W1  op-11 outN=32  -> payload.status=0(Ok), count>=1,
#       sys == M1's resolved VA (the built-in F2<->F3 cross-check),
#       entries[0] = System (pid 4, eproc == sys), names echoed
#       (flags bit0, "System\0" at entries[0].name)
#   W2  live cross-check: the walked pids exist in Get-Process,
#       count within tolerance of the live process count
#   W3  the script's own $PID among the walked entries (NOTE if
#       beyond the 32-entry stored window - honest reporting)
#   W4  negatives: outN=0 and outN=33 -> ErrInvalid(5), no crash
#   W5  pid-irrelevance: op-11 with a REAL pid answers the same
#       (kernel-list data has no pid gate - unlike op-1 reads)
#
# INFCNT v30: v29 formula + $wSent (every op-11 request +1; W
# writes no InfinityData - outN travels in the request header).
#
# ============================================================
# INFINITY bridge trigger test v29  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v29 = v28 + THE M2R EXPECTATION FIX (script-only - the v21
# driver STAYS: memory.efi v21 RT, 131709 bytes, untouched).
# WHY: the v28 field run (2026-09-26 21:11) was DRIVER-GREEN:
# all four M resolutions and both M reads returned perfect
# data - but the script printed "[M2r] FAIL: value mismatch"
# on the CANONICAL Win10 19045 dword. The read returned
# 0xF0004A65 - exactly right for NtBuildNumber: the BUILD is
# the LOW WORD (0x4A65 = 19045 = the KUSD J1 ground truth) and
# the high bits carry the QFE flag nibble. v28 masked
# 0x7FFFFFFF (leaving 0x70004A65) and compared against bare
# 19045 - a healthy system can never pass that. v29 masks the
# BUILD field correctly (0xFFFF) AND accepts the full canonical
# dword. Also fixed, same run: the final-INFCNT expectation
# line printed "expect G+8+ = 23" - the {4} slot pointed at an
# EMPTY argument, and the arithmetic forgot the 4 M-side
# symbol-NAME InfinityData writes (each Send-Resolve writes the
# name, THEN sends the op-10 request - both bump INFCNT; the
# field counted 27 = G2+H1+J7+KL7+name4+req6). v29 counts
# every term. Stale era texts refreshed (the ladder table still
# said driver 128010/v20; the pre-A canary still pointed at the
# script-v21 death spot). K/L/M/J request logic byte-identical.
# ============================================================
# INFINITY bridge trigger test v28  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v28 = the v21 DRIVER (memory.efi v21 RT - "anchors + exports",
# 131709 bytes) + STEP M: F2 export resolution. The v27 field run
# (2026-09-26 19:36) was FULL GREEN - F1 PROVEN: the containing-
# walk converged on the true ntoskrnl [0xFFFFF80719800000, +0x1046000),
# MZ + PE header + entry code came back through the gate, L4/L5
# rejected both range negatives, J1..J7 100%, INFCNT 17 exact.
# F2 answers the next question: WHERE is everything else? The
# image's own EXPORT TABLE resolves symbols by name at runtime -
# no per-build offset tables, no pattern scans, no hardcoded VAs.
# The driver parses the export table with every read bounds-checked
# inside the VALIDATED image (host-proven 50/50, zero out-of-map),
# then M2 cross-validates export data against the KUSD ground
# truth (NtBuildNumber == 19045 == J1) and M3 reads real code via
# a resolved symbol. M4 is the not-found negative. The op-9 wire,
# the read gate and the K/L/J semantics are UNTOUCHED.
# Stat-Name fixed to the driver's real SlotStatus enum (7 =
# ErrNotFound becomes reachable in M4).
# ============================================================
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
# INFINITY bridge trigger test v26  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v26 = v25 + THE V20 DRIVER (memory.efi v20 RT, 128010 bytes -
# "anchors + containing walk"). Script logic byte-identical to v25;
# only the K-step expectations moved. WHY: the v25 field run
# (2026-09-26) proved the whole stack EXCEPT convergence: the three
# walks agreed - on a NESTED PE (0xFFFFF8046BD60000) that does not
# contain the anchors, and the V4 containment backstop correctly
# FAIL-CLOSED (reason=6, zero crashes - the architecture worked).
# v20's containing-walk accepts a candidate ONLY if the image
# CONTAINS the anchor; the nested PE is skipped + counted and the
# walks converge on the TRUE ntoskrnl base. With v20 the EXPECTED
# result is: K state=1 reason=0 + the real pe_base/pe_size, then
# L1 MZ / L2 PE header / L3 entry bytes / L4+L5 clean negatives.
# Fail-closed (any reason) remains a valid, documented outcome - the
# new [AN] 'walk vN skipped/lastskip' serial lines name exactly what
# was refused.
# ============================================================
# INFINITY bridge trigger test v25  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v25 = v24 + THE SELFTEST FIXTURE FIX. Script-only; the driver
# is UNCHANGED (memory.efi v19 RT, 125450 bytes). The v24 field
# run (2026-09-26 04:07) aborted AT the selftest gate - by design:
# its canonical-kernel-base fixture was hand-assembled wrong
# (bytes 00 00 10 80 FF FF FF FF encode 0xFFFFFFFF80100000, not
# the intended 0xFFFF800010000000 = decimal 18446603336489631744),
# so the U64 round-trip check failed and the script REFUSED to
# touch the driver: serial showed ZERO [RD] lines, INFCNT unmoved,
# no crash - the cleanest possible failure, exactly what the gate
# is for. v25 DERIVES the fixture bytes from the decimal literal
# itself, so bytes and expectation can never disagree again - the
# slip class is eliminated, not patched. Everything else (K anchor
# discovery + L validated reads + J regression) is byte-identical
# to v24. The F1 ladder still awaits its field run.
# ============================================================
# INFINITY bridge trigger test v24  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# v24 = v23 + THE F1 PROOF STEPS. REQUIRES the v19 driver stick
# (memory.efi v19 RT - "anchors + validated image reads", 125450
# bytes). The v19 driver = the field-proven v18 + KernelAnchor.h:
# SIDT + anchor stack + 4 converging validators, FAIL-CLOSED.
#
# NEW STEPS (before the J-ladder, which is kept IDENTICAL as a
# full v23 regression):
#   K   ReqOp_Anchors (op=9): the driver runs the discovery once -
#       SIDT -> IDT #PF/#BP handler VAs -> IA32_LSTAR MSR -> three
#       independent 64KB-step walk-backs to the image base (32MB
#       bound, 'MZ' probes, full PE validation at every candidate)
#       - all three walks must AGREE, the PE header must be fully
#       valid, and all three anchor VAs must lie INSIDE the image
#       (containment). ANY failure = FAIL-CLOSED: the gate stays
#       KUSD-only for the whole boot and L1..L3 are skipped.
#   L1  read @pe_base len=4       -> expect 4D 5A 00 00 ('MZ')
#   L2a read @pe_base+0x3C len=4  -> e_lfanew (0x40..0x1000)
#   L2b read @pe_base+lfanew len=0x58 -> expect 'PE  ' + machine
#       0x8664 + entry RVA + SizeOfImage == the payload's pe_size
#       (the transport double-validates the driver's range!)
#   L3  read @pe_base+entryRVA len=8 -> real kernel entry bytes
#   L4  read @pe_base-0x1000      -> NEGATIVE: ErrAccess(4) below
#   L5  read @pe_base+pe_size     -> NEGATIVE: ErrAccess(4) above
# If K fails closed, L4/L5 still run at a fixed kernel VA and
# MUST be rejected - proof the gate never opens without anchors.
#
# EXPECTED with the v19 driver on a healthy boot:
#   K  Success + state=1 reason=0 + real pe_base/pe_size/idt_base
#   L1 Success + 4D 5A;  L2 Success + PE sig + size match;  L3 8 bytes
#   L4/L5 ErrAccess(4), no crash   J1..J7 exactly as v23 (regression)
#   N  INFCNT = G+8+7 = G+15 when converged (K,L1,L2a,L2b,L3,L4,L5)
#      or G+8+3 when fail-closed (K,L4,L5)
# ============================================================

$ErrorActionPreference = 'Continue'

$src = @'
using System;
using System.Runtime.InteropServices;

public static class EfiVarBridge {
    // ---- privilege enabling (struct fix from v7)
    [StructLayout(LayoutKind.Sequential)]
    public struct LUID { public uint LowPart; public int HighPart; }

    [StructLayout(LayoutKind.Sequential)]
    public struct LUID_AND_ATTRIBUTES {
        public LUID Luid;
        public uint Attributes;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct TOKEN_PRIVILEGES {
        public uint PrivilegeCount;
        public LUID_AND_ATTRIBUTES Privileges;
    }

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentProcess();

    [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    static extern bool LookupPrivilegeValue(string lpSystemName, string lpName, out LUID lpLuid);

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool AdjustTokenPrivileges(IntPtr TokenHandle, bool DisableAllPrivileges,
        ref TOKEN_PRIVILEGES NewState, uint BufferLength, IntPtr PreviousState, IntPtr ReturnLength);

    // ---- firmware variable APIs (v7 correct parameter order)
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern uint GetFirmwareEnvironmentVariableW(
        string lpName, string lpGuid, byte[] pBuffer, uint nSize);

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool SetFirmwareEnvironmentVariableExW(
        string lpName, string lpGuid, byte[] pValue, uint nSize, uint dwAttributes);

    public static bool EnablePriv(string name) {
        IntPtr token;
        if (!OpenProcessToken(GetCurrentProcess(), 0x28, out token))
            return false;
        LUID luid;
        if (!LookupPrivilegeValue(null, name, out luid))
            return false;
        TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES();
        tp.PrivilegeCount = 1;
        tp.Privileges.Luid = luid;
        tp.Privileges.Attributes = 2;   // SE_PRIVILEGE_ENABLED
        return AdjustTokenPrivileges(token, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
    }
}
'@

if (-not ("EfiVarBridge" -as [type])) {
    try { Add-Type -TypeDefinition $src -Language CSharp }
    catch {
        Write-Host '[ABORT] Add-Type failed (unexpected). Send the output .txt / a photo of this window.'
        Write-Host $_.Exception.Message
        exit 1
    }
}

# ---- constants ------------------------------------------------------
$guid  = '{A1B2C3D4-E5F6-4789-9ABC-DEF012345678}'
$attrs = 0x7    # EFI_VARIABLE_NON_VOLATILE | BOOTSERVICE | RUNTIME

# ---- helpers --------------------------------------------------------
function HexLe4([string]$hex) {
    # 'DEADBEEF' -> bytes EF BE AD DE (little endian), from hex STRING
    # (PowerShell hex-literal sign trap = the v10 bug, never again).
    $h = $hex.PadLeft(8, '0')
    $b = New-Object byte[] 4
    for ($i = 0; $i -lt 4; $i++) {
        $b[$i] = [Convert]::ToByte($h.Substring(6 - 2 * $i, 2), 16)
    }
    return $b
}

function U32([byte[]]$b, [int]$o) {
    # v19+ accumulator form: every intermediate stays [uint32].
    # (The v18 form kept the LEFT operand type on -shl - a [byte]!
    #  - so every dword was truncated to its low byte. That made the
    #  v18 PONG decode lie; the bridge itself was never broken.)
    $v = [uint32]0
    for ($i = 3; $i -ge 0; $i--) { $v = ($v -shl 8) -bor [uint32]$b[$o+$i] }
    return $v
}
function U64([byte[]]$b, [int]$o) {
    # accumulator form, explicit [uint64] casts - no operand-type traps
    $v = [uint64]0
    for ($i = 7; $i -ge 0; $i--) { $v = ($v -shl 8) -bor [uint64]$b[$o+$i] }
    return $v
}
function HexStr([byte[]]$b, [int]$n) {
    return (($b[0..($n-1)]) | ForEach-Object { $_.ToString('X2') }) -join ' '
}
function Dump-Dwords([byte[]]$b, [int]$n) {
    # every 4-byte-aligned dword, labeled by offset - lets the
    # kernel-read data location be found no matter the layout
    $parts = @()
    for ($o = 0; ($o + 4) -le $n; $o += 4) {
        $parts += ('@{0}={1}' -f $o, (U32 $b $o))
    }
    return $parts -join '  '
}
function Stat-Name([int]$s) {
    # 1 and 4 are field-confirmed (PONG status=1; step M expects 4).
    # The others follow the project convention - the NUMBER is authoritative.
    switch ($s) {
        0 { 'None' }
        1 { 'Success' }
        2 { 'ErrGeneric' }
        3 { 'ErrTimeout' }
        4 { 'ErrAccess' }
        5 { 'ErrInvalid' }
        6 { 'ErrNoBridge' }
        7 { 'ErrNotFound' }
        8 { 'ErrUnsupported' }
        default { "code-$s" }
    }
}
function Find-From([byte[]]$hay, [byte[]]$needle, [int]$start = 0) {
    # returns first offset >= start where needle matches, else -1
    if ($null -eq $hay) { return -1 }
    for ($i = $start; ($i + $needle.Length) -le $hay.Length; $i++) {
        $m = $true
        for ($j = 0; $j -lt $needle.Length; $j++) {
            if ($hay[$i + $j] -ne $needle[$j]) { $m = $false; break }
        }
        if ($m) { return $i }
    }
    return -1
}

function Read-EfiVar([string]$name, [byte[]]$buf) {
    $n = [EfiVarBridge]::GetFirmwareEnvironmentVariableW($name, $guid, $buf, [uint32]$buf.Length)
    $script:LastErr = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    return [int]$n
}

function Read-Infdiag([string]$Label) {
    $buf = New-Object byte[] 64
    $n = Read-EfiVar 'INFDIAG' $buf
    if ($n -le 0) {
        Write-Host "[$Label] INFDIAG read FAILED Win32=$LastErr"
        switch ($LastErr) {
            1314 { Write-Host "[$Label]   -> not elevated (run PowerShell as Administrator)" }
            2    { Write-Host "[$Label]   -> variable not found (RT driver not loaded this boot?)" }
            203  { Write-Host "[$Label]   -> variable not found (RT driver not loaded this boot?)" }
            87   { Write-Host "[$Label]   -> invalid parameter" }
        }
        return $null
    }
    Write-Host "[$Label] raw: $(HexStr $buf $n)"
    if ($n -ge 32 -and $buf[0] -eq 0x44 -and $buf[1] -eq 0x46 -and $buf[2] -eq 0x4E -and $buf[3] -eq 0x49) {
        $stage  = U32 $buf 4
        $flags  = U32 $buf 8
        $build  = U32 $buf 12
        $cr3    = U64 $buf 16
        $calls  = U32 $buf 24
        $lastst = U32 $buf 28
        $flagTxt = @()
        if ($flags -band 0x1)  { $flagTxt += 'loaded' }
        if ($flags -band 0x2)  { $flagTxt += 'EBS' }
        if ($flags -band 0x4)  { $flagTxt += 'virt' }
        if ($flags -band 0x8)  { $flagTxt += 'early-hooks' }
        if ($flags -band 0x20) { $flagTxt += 'TRIGGER-SEEN' }
        Write-Host ("[{0}] STAGE={1} flags=0x{2:X}({3}) win_build={4} os_cr3=0x{5:X} hook_calls={6} last_status=0x{7:X}" -f `
            $Label, $stage, $flags, ($flagTxt -join ','), $build, $cr3, $calls, $lastst)
        return [pscustomobject]@{ stage = $stage; flags = $flags; build = $build; calls = $calls; lastst = $lastst }
    }
    Write-Host "[$Label] magic mismatch - unexpected data"
    return $null
}

function Write-Var([string]$name, [byte[]]$data) {
    $ok = [EfiVarBridge]::SetFirmwareEnvironmentVariableExW($name, $guid, $data, [uint32]$data.Length, [uint32]$attrs)
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if ($ok) { Write-Host "[OK] $name write accepted (Win32=0)" }
    else {
        Write-Host "[FAIL] $name write Win32=$err"
        switch ($err) {
            1314 { Write-Host '   -> not elevated' }
            87   { Write-Host '   -> invalid parameter (name/GUID/attrs)' }
            5    { Write-Host '   -> access denied' }
            203  { Write-Host '   -> not found' }
        }
    }
    return $ok
}

function Try-Del([string]$name) {
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
}

function Read-VarBack([string]$name) {
    # returns the trimmed byte array or $null; prints one line
    $buf = New-Object byte[] 64
    $n = Read-EfiVar $name $buf
    if ($n -gt 0) {
        Write-Host "[OK] $name read-back: $n bytes: $(HexStr $buf $n)"
        return ,$buf[0..($n-1)]
    }
    Write-Host "[--] $name read-back: ABSENT (Win32=$LastErr)"
    return $null
}

# ---- the v17-bug-free request builders ------------------------------
# THE v17 BUG: the helper below used a parameter literally named
# $pid. $PID is a read-only automatic PowerShell variable, so every
# call threw "Cannot overwrite variable pid..." and NO request was
# ever sent. All parameters here are deliberately named rseq / rop /
# rpid / rlen / raddr - none of them is an automatic variable.

function New-Req([object]$rseq, [object]$rop, [object]$rpid, [object]$rlen, [object]$raddr, [byte[]]$rdata) {
    # builds the 48-byte InfinityReq packet:
    #   [0..3]   sequence  u32
    #   [4..7]   op        u32
    #   [8..11]  pid       u32   (0 = any process, 0xFFFFFFFF = kernel target)
    #   [12..15] length    u32
    #   [16..23] address   u64   (hex STRING avoids every literal trap)
    #   [24..47] payload   24 bytes
    $req = New-Object byte[] 48
    [BitConverter]::GetBytes([uint32]$rseq).CopyTo($req, 0)
    [BitConverter]::GetBytes([uint32]$rop).CopyTo($req, 4)

    if ($null -eq $rpid)        { $p32 = [uint32]0 }
    elseif ($rpid -is [string]) { $p32 = [Convert]::ToUInt32($rpid, 16) }
    else                        { $p32 = [uint32]$rpid }
    [BitConverter]::GetBytes($p32).CopyTo($req, 8)

    if ($null -eq $rlen)        { $l32 = [uint32]0 }
    elseif ($rlen -is [string]) { $l32 = [Convert]::ToUInt32($rlen, 16) }
    else                        { $l32 = [uint32]$rlen }
    [BitConverter]::GetBytes($l32).CopyTo($req, 12)

    if ($null -eq $raddr)        { $a64 = [uint64]0 }
    elseif ($raddr -is [string]) { $a64 = [Convert]::ToUInt64($raddr, 16) }
    else                         { $a64 = [uint64]$raddr }
    [BitConverter]::GetBytes($a64).CopyTo($req, 16)

    if ($null -ne $rdata) {
        $cnt = [Math]::Min(24, $rdata.Length)
        for ($i = 0; $i -lt $cnt; $i++) { $req[24 + $i] = $rdata[$i] }
    }

    # belt and braces: the header must round-trip through the bytes
    # (plain -ne comparisons only - [int] casts would overflow on 0xFFFFFFFF,
    #  the same class of PS 5.1 trap as the v10 sign bug)
    if ((U32 $req 0) -ne [uint32]$rseq -or (U32 $req 4) -ne [uint32]$rop -or
        (U32 $req 8) -ne $p32 -or (U32 $req 12) -ne $l32 -or (U64 $req 16) -ne $a64) {
        throw 'request byte build failed (header mismatch)'
    }
    return ,$req
}

function Send-Req([byte[]]$ReqBytes) {
    # writes the request, polls for the matching response,
    # dumps EVERYTHING (resp raw + header + all dwords + InfinityData)
    $want = U32 $ReqBytes 0
    $null = Write-Var 'InfinityReq' $ReqBytes

    $resp = $null
    $seen = $null
    for ($try = 1; $try -le 12; $try++) {
        Start-Sleep -Milliseconds 100
        $rb = New-Object byte[] 64
        $rn = Read-EfiVar 'InfinityResp' $rb
        if ($rn -ge 32) {
            $seen = New-Object byte[] $rn
            [Array]::Copy($rb, $seen, $rn)
            if ((U32 $seen 0) -eq $want) { $resp = $seen; break }
        }
    }

    $status = -1
    $seqOk  = $false
    if ($null -ne $resp) {
        Write-Host "[OK] InfinityResp $($resp.Length) bytes: $(HexStr $resp $resp.Length)"
        $rseq  = U32 $resp 0
        $rstat = U32 $resp 4
        $rxfer = U32 $resp 8
        $raddr = U64 $resp 16
        $status = $rstat
        $seqOk  = ($rseq -eq $want)
        Write-Host ("     header: sequence=0x{0:X}  status={1}({2})  bytes_transferred={3}  out_address=0x{4:X}" -f `
            $rseq, $rstat, (Stat-Name $rstat), $rxfer, $raddr)
        Write-Host ('     resp dwords: ' + (Dump-Dwords $resp $resp.Length))
    } elseif ($null -ne $seen) {
        # a response exists but its sequence does not match - do NOT
        # use it as the answer; dump it so nothing hides
        Write-Host "[--] InfinityResp: only a STALE response (seq=0x$((U32 $seen 0).ToString('X')), wanted 0x$($want.ToString('X'))) - NOT used"
        Write-Host "[--] stale raw: $(HexStr $seen $seen.Length)"
        Write-Host ('     stale dwords: ' + (Dump-Dwords $seen $seen.Length))
    } else {
        Write-Host "[--] InfinityResp ABSENT after 12 tries (Win32=$LastErr)"
    }

    # the read data may also land in the InfinityData buffer - dump it too
    $dataBytes = $null
    # v27: size the buffer to the DRIVER CAP (4096). v26 used 64 bytes;
    # L2b's 88-byte PE header came back Win32=122 (ERROR_INSUFFICIENT_
    # BUFFER) and the checks never saw the bytes the driver HAD delivered
    # (serial [RD] ok=1). No valid payload can exceed 4096 - dead class.
    $db = New-Object byte[] 4096
    $dn = Read-EfiVar 'InfinityData' $db
    if ($dn -gt 0) {
        Write-Host "[DT] InfinityData $dn bytes: $(HexStr $db $dn)"
        Write-Host ('     data dwords: ' + (Dump-Dwords $db $dn))
        $dataBytes = New-Object byte[] $dn
        [Array]::Copy($db, $dataBytes, $dn)
    } else {
        Write-Host "[DT] InfinityData absent (Win32=$LastErr)"
        if ($LastErr -eq 122) { Write-Host '[DT]   -> 122 = the payload exceeded the 4096-byte buffer (impossible per the driver cap) - send everything' }
    }

    Try-Del 'InfinityResp'
    Try-Del 'InfinityData'   # v21: fresh out-buffer for the next request
    return [pscustomobject]@{ Resp = $resp; SeqOk = $seqOk; Status = $status; Data = $dataBytes }
}

# ============================================================
# [0] find a writable spot + start the transcript
#      (the boot stick is READ-ONLY by design, so the output
#       lands on a writable drive - Desktop)
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$cands = @()
try { $cands += (Get-Location).ProviderPath } catch { }
try { $cands += [Environment]::GetFolderPath('Desktop') } catch { }
$cands += 'C:\Users\Administrator\Desktop'
$spot = $null
foreach ($c in $cands) {
    if (-not $c) { continue }
    try {
        $t = Join-Path $c ('.wr-' + [Guid]::NewGuid().ToString('N') + '.tmp')
        [IO.File]::WriteAllText($t, 'x')
        [IO.File]::Delete($t)
        $spot = $c
        break
    } catch { }
}
$transPath = $null
if ($spot) {
    $transPath = Join-Path $spot ("trigger-test-v30-output-$stamp.txt")
    try { Start-Transcript -Path $transPath | Out-Null }
    catch { $transPath = $null }
}
if ($transPath) {
    Write-Host '[LOG] writable spot found - auto-saving all output to:'
    Write-Host "[LOG] $transPath"
    Write-Host '[LOG] (the folder beside the script is READ-ONLY - the boot'
    Write-Host '[LOG]  stick is read-only by design - so the transcript lands'
    Write-Host '[LOG]  on a writable drive instead. Get it out of the VM with'
    Write-Host '[LOG]  the transfer stick + refresh-files.bat - see the end.)'
} else {
    Write-Host '[LOG] no writable spot found - photograph this window instead.'
}

Write-Host ''
Write-Host '==== INFINITY trigger test v30 (v22 driver: F3 THE EPROCESS WALK - process data OUTSIDE the image; full K/L/M/J regression re-proves F1+F2 on v22) ===='
Write-Host ("[ENV] PowerShell $($PSVersionTable.PSVersion)  Windows build $([Environment]::OSVersion.Version.ToString())")

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
Write-Host '      -> a BUGCHECK line at an OLD run time names THAT era killer;'
Write-Host '         41-only = instant death with no chance to log (the long-dead v19/v20 class).'

# ---- self-test: the parsers must be perfect BEFORE touching the driver
#      (v18's U32 truncated every dword to its low byte - caught only by
#       field runs. v19 added this gate; v21's FFFFFFFF check STILL
#       tripped the hex-literal trap: 0xFFFFFFFF parses as Int32 -1 and
#       [uint32]-1 throws (silently skipped that check - cosmetic).
#       v22: DECIMAL literals for max-value compares; uint32-vs-uint32
#       only, never an [u32] cast of a negative int)
$stFail = $false
function ST-Check([bool]$ok, [string]$what) {
    if (-not $ok) { $script:stFail = $true; Write-Host "[SELFTEST] FAILED: $what" }
}
$stb = New-Object byte[] 4
$stb[0] = 0x37; $stb[1] = 0x13; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]0x1337) 'U32 37 13 00 00 must be 0x1337'
$stb[0] = 0x65; $stb[1] = 0x4A; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]19045) 'U32 65 4A 00 00 must be 19045'
$stb[0] = 0xFF; $stb[1] = 0xFF; $stb[2] = 0xFF; $stb[3] = 0xFF
ST-Check ((U32 $stb 0) -eq [uint32]4294967295) 'U32 FF FF FF FF must be 4294967295'
$st8 = New-Object byte[] 8
$st8[0] = 0x00; $st8[1] = 0x10; $st8[2] = 0xC0; $st8[3] = 0x7F
$st8[4] = 0x00; $st8[5] = 0x00; $st8[6] = 0x00; $st8[7] = 0x00
ST-Check ((U64 $st8 0) -eq [uint64]0x7FC01000) 'U64 00 10 C0 7F 00 00 00 00 must be 0x7FC01000'
$stLe = HexLe4 'DEADBEEF'
ST-Check ($stLe.Length -eq 4 -and $stLe[0] -eq 0xEF -and $stLe[1] -eq 0xBE -and $stLe[2] -eq 0xAD -and $stLe[3] -eq 0xDE) 'HexLe4 DEADBEEF must be EF BE AD DE'
$stReq = $null
try { $stReq = New-Req 0x1337 1 'FFFFFFFF' 4 'FFFFF78000000260' $null }
catch { $stReq = $null }
$stOk = ($null -ne $stReq -and $stReq.Length -eq 48 -and
    $stReq[0] -eq 0x37 -and $stReq[1] -eq 0x13 -and $stReq[2] -eq 0x00 -and $stReq[3] -eq 0x00 -and
    $stReq[4] -eq 0x01 -and $stReq[5] -eq 0x00 -and $stReq[6] -eq 0x00 -and $stReq[7] -eq 0x00 -and
    $stReq[8] -eq 0xFF -and $stReq[9] -eq 0xFF -and $stReq[10] -eq 0xFF -and $stReq[11] -eq 0xFF -and
    $stReq[12] -eq 0x04 -and $stReq[13] -eq 0x00 -and $stReq[14] -eq 0x00 -and $stReq[15] -eq 0x00 -and
    $stReq[16] -eq 0x60 -and $stReq[17] -eq 0x02 -and $stReq[18] -eq 0x00 -and $stReq[19] -eq 0x00 -and
    $stReq[20] -eq 0x80 -and $stReq[21] -eq 0xF7 -and $stReq[22] -eq 0xFF -and $stReq[23] -eq 0xFF)
ST-Check $stOk 'New-Req header bytes (seq/op/pid/len/addr) must round-trip'
$stReq2 = $null
try { $stReq2 = New-Req 0x1338 1 'FFFFFFFF' 4 '000000007FFE0260' $null }
catch { $stReq2 = $null }
$stOk2 = ($null -ne $stReq2 -and $stReq2.Length -eq 48 -and
    $stReq2[16] -eq 0x60 -and $stReq2[17] -eq 0x02 -and $stReq2[18] -eq 0xFE -and $stReq2[19] -eq 0x7F -and
    $stReq2[20] -eq 0x00 -and $stReq2[21] -eq 0x00 -and $stReq2[22] -eq 0x00 -and $stReq2[23] -eq 0x00)
ST-Check $stOk2 'New-Req user alias 000000007FFE0260 -> bytes 60 02 FE 7F 00 00 00 00 (the v22 slip, never again)'
$stb[0] = 0x4D; $stb[1] = 0x5A; $stb[2] = 0x00; $stb[3] = 0x00
ST-Check ((U32 $stb 0) -eq [uint32]0x00005A4D) 'U32 4D 5A 00 00 must be 0x5A4D (the MZ dword - the L1 expectation)'
$stb[0] = 0x50; $stb[1] = 0x45
ST-Check ((U32 $stb 0) -eq [uint32]0x00004550) 'U32 50 45 00 00 must be 0x4550 (the PE dword - the L2 expectation)'
$stU64 = New-Object byte[] 8
# v25 FIX (the v24 field abort, 2026-09-26 04:07): these bytes were
# hand-assembled WRONG (00 00 10 80 FF FF FF FF encodes
# 0xFFFFFFFF80100000, not 0xFFFF800010000000) so the gate refused
# to start - CORRECTLY; nothing was touched. The class fix is not
# "better hand-assembly": the fixture is now DERIVED from the
# decimal literal itself, so bytes and expectation can never
# disagree again.
$stBase = [uint64]18446603336489631744   # = 0xFFFF800010000000
for ($i = 0; $i -lt 8; $i++) { $stU64[$i] = [byte](($stBase -shr (8 * $i)) -band 0xFF) }
ST-Check ((U64 $stU64 0) -eq $stBase) 'U64 must round-trip the canonical kernel base 0xFFFF800010000000 (fixture DERIVED from the decimal literal - no hand-assembled bytes)'
ST-Check (([uint64]18446603336489631744 + [uint64]0x400000) -gt [uint64]18446603336489631744) 'uint64 range math (validated-range end must not wrap)'
if ($stFail) {
    Write-Host '[SELFTEST][ABORT] parser self-test failed - the driver was NOT touched. Send the output .txt / a photo.'
    if ($transPath) { try { Stop-Transcript | Out-Null } catch { } }
    exit 1
}
Write-Host '[SELFTEST] U32/U64/HexLe4/New-Req all passed - parsers verified before touching the driver'

# [1] privilege
$rc = [EfiVarBridge]::EnablePriv('SeSystemEnvironmentPrivilege')
if (-not $rc) {
    Write-Host '[ABORT] SeSystemEnvironmentPrivilege failed - run PowerShell as Administrator.'
    exit 1
}
Write-Host '[OK] SeSystemEnvironmentPrivilege enabled (rc=0)'

# [2] cleanup stale probe variables from earlier runs (best-effort)
Try-Del 'INFPROBE'
Try-Del 'INFTRIGGER'
Try-Del 'InfinityReq'
Try-Del 'InfinityResp'
Try-Del 'InfinityData'
Start-Sleep -Milliseconds 200
Write-Host '[CLR] stale probe variables cleaned (best effort)'
Canary 'pre-A (baseline INFDIAG reads next - the script-v21 death spot, class-killed long ago)'

# [3] baseline reads: A then B (no writes in between)
Write-Host ''
Write-Host '--- step A/B: baseline INFDIAG double read (read path via hook?) ---'
Write-Host '       v15+: reads are answered LIVE from RAM by the hook (the'
Write-Host '       bridge is field-proven since v15), so B must be A+1 or'
Write-Host '       more if the read path works.'
$A = Read-Infdiag 'A'
Start-Sleep -Milliseconds 250
$B = Read-Infdiag 'B'
if ($null -eq $A -or $null -eq $B) {
    Write-Host '[ABORT] INFDIAG unreadable - is the RT driver (usb-d) the one that booted?'
    exit 1
}

# [4] neutral write probe: INFPROBE (not a driver name - pure raw NVRAM write)
Write-Host ''
Write-Host '--- step C: INFPROBE write (neutral name; raw NVRAM write path) ---'
$payload = New-Object byte[] 1
$payload[0] = 0x42
$null = Write-Var 'INFPROBE' $payload
Start-Sleep -Milliseconds 250
$C = Read-Infdiag 'C'
$probeBack = Read-VarBack 'INFPROBE'

# [5] driver trigger variable (first INFCNT increment)
Write-Host ''
Write-Host '--- step D: INFTRIGGER write (trigger flag 0x20 + INFCNT +1) ---'
$payload[0] = 0x42
$null = Write-Var 'INFTRIGGER' $payload
Start-Sleep -Milliseconds 250
$D = Read-Infdiag 'D'

# [6] the real PING
Write-Host ''
Canary 'pre-E (the PING request transport next)'
Write-Host '--- step E: InfinityReq PING (48 bytes, op=0xDEADBEEF) ---'
$req = New-Object byte[] 48
[BitConverter]::GetBytes([uint32]0x1337).CopyTo($req, 0)   # sequence (small literal: safe)
$opBytes = HexLe4 'DEADBEEF'
$opBytes.CopyTo($req, 4)                                    # op = PING
if ($req[0] -ne 0x37 -or $req[1] -ne 0x13 -or $req[4] -ne 0xEF -or $req[5] -ne 0xBE -or $req[6] -ne 0xAD -or $req[7] -ne 0xDE) {
    Write-Host '[ABORT] packet bytes wrong - refusing to send a broken ping. Send the output .txt.'
    exit 1
}
Write-Host "       req bytes[0..7]: $(HexStr $req 8)  (37 13 00 00 EF BE AD DE expected)"
$null = Write-Var 'InfinityReq' $req
Start-Sleep -Milliseconds 400
$E = Read-Infdiag 'E'   # also gives the driver a foreign call to process the ping

Write-Host ''
Write-Host '--- step E2: reading InfinityResp (FULL BRIDGE check) ---'
$rbuf = New-Object byte[] 64
$rn = Read-EfiVar 'InfinityResp' $rbuf
$respAnswered = $false
$respTxt = 'ABSENT'
if ($rn -ge 32) {
    Write-Host "[OK] InfinityResp $rn bytes: $(HexStr $rbuf $rn)"
    $rseq  = U32 $rbuf 0
    $rstat = U32 $rbuf 4
    $rxfer = U32 $rbuf 8
    $raddr = U64 $rbuf 16
    Write-Host ("     sequence=0x{0:X}  status={1}({2})  bytes_transferred={3}  out_address=0x{4:X}" -f `
        $rseq, $rstat, (Stat-Name $rstat), $rxfer, $raddr)
    if ($rseq -eq 0x1337 -and $rstat -eq 1) {
        $respAnswered = $true
        $respTxt = 'ANSWERED seq=0x1337 status=1(Success) - PONG PERFECT'
    } else {
        $respTxt = "WRONG-CONTENT seq=0x$($rseq.ToString('X')) status=$rstat"
    }
} else {
    Write-Host "[--] InfinityResp ABSENT (Win32=$LastErr; 203 = not found)"
}
Try-Del 'InfinityResp'   # clear the PONG so steps I..M cannot read it as stale

# [7] final state + read-backs
Write-Host ''
Write-Host '--- step F: final INFDIAG + InfinityReq read-back ---'
$F = Read-Infdiag 'F'
$reqBack = Read-VarBack 'InfinityReq'
$reqAbsent = ($null -eq $reqBack)

# [8] INFCNT - the bypass-safe write-path proof
Write-Host ''
Write-Host '--- step G: INFCNT read (live RAM count: 0 = writes bypassed, 2 = both reached) ---'
$cntBack = Read-VarBack 'INFCNT'
$cntVal = -1
if ($null -ne $cntBack -and $cntBack.Length -ge 4) { $cntVal = U32 $cntBack 0 }

# [9] step H: InfinityData write+read round trip (the payload transport)
Write-Host ''
Write-Host '--- step H: InfinityData write+read round trip (the payload transport) ---'
$hd = New-Object byte[] 32
[BitConverter]::GetBytes([uint32]0x1447).CopyTo($hd, 0)    # step H sequence
$v = 0x27
for ($i = 4; $i -lt 32; $i++) { $hd[$i] = [byte]$v; $v += 7 }
if ($hd[4] -ne 0x27 -or $hd[31] -ne 0xE4) {
    Write-Host '[ABORT] H pattern bytes wrong - refusing to send. Send the output .txt.'
    exit 1
}
$null = Write-Var 'InfinityData' $hd
Start-Sleep -Milliseconds 300
$hBack = Read-VarBack 'InfinityData'
$hExact = $false
if ($null -ne $hBack -and $hBack.Length -eq 32) {
    $hExact = $true
    for ($i = 0; $i -lt 32; $i++) { if ($hBack[$i] -ne $hd[$i]) { $hExact = $false; break } }
}
if ($hExact) { Write-Host '     32-byte pattern echoed back byte-exact: YES - payload transport WORKS' }
else         { Write-Host '     32-byte pattern echoed back byte-exact: NO - see raw above' }

# [10] step I: ReqOp_Attach -- SKIPPED. v19 PROVED op=7 kills this VM
#      (it walks the process list hunting emulator EXE names that do
#      not exist here). Kernel reads do not need it. Never re-enable.
Write-Host ''
Write-Host '--- step I: ReqOp_Attach -- SKIPPED (v19 crashed the VM here; op=7 walks the ---'
Write-Host '    process list for emulator EXEs that do not exist in this VM -'
Write-Host '    disassembly-proven fatal, and NOT needed for kernel reads)'
$attachTxt = 'SKIPPED (v19-proven fatal in this VM)'

# ---- InfinityData hygiene: H's echo must not pollute the ladder dumps
Try-Del 'InfinityData'
Start-Sleep -Milliseconds 150

# ============================================================
# [11a] F1 STEP K: ReqOp_Anchors (op=9) - the anchor discovery
#       (SIDT + IDT + LSTAR + walk-backs + validators, fail-closed)
# ============================================================
Write-Host ''
Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v22 containing-walk) ---'
Write-Host '      status=1(Success) => CONVERGED (EXPECTED with v20/v21): the containing-walk skips'
Write-Host '            nested PEs and the TRUE image range unlocks (L1..L3).
      status=4(ErrAccess) => FAIL-CLOSED (valid, documented): gate stays KUSD-only
      (L1..L3 skip; L4/L5 still run). Serial [AN] skip lines name the refusal.'
Canary 'pre-K'
$K = $null
try { $K = Send-Req (New-Req 0x1701 9 '00000000' 32 '0000000000000000' $null) }
catch { Write-Host "[!] step K threw: $($_.Exception.Message)" }
$anState = -1; $anReason = -1
$peBase = [uint64]0; $peSize = [uint64]0; $anIdt = [uint64]0
if ($null -ne $K -and $null -ne $K.Data -and $K.Data.Length -ge 32) {
    $anState  = U32 $K.Data 0
    $anReason = U32 $K.Data 4
    $peBase   = U64 $K.Data 8
    $peSize   = U64 $K.Data 16
    $anIdt    = U64 $K.Data 24
}
$anSent = 1
$anOk = ($anState -eq 1)
if ($anState -ge 0) {
    Write-Host ("     [K] payload: state={0} reason={1} pe_base=0x{2:X} pe_size=0x{3:X} idt_base=0x{4:X}" -f $anState, $anReason, $peBase, $peSize, $anIdt)
} else {
    Write-Host '     [K] NO PAYLOAD (no response / no data) - treat as fail-closed'
}
if ($anOk) {
    Write-Host ("     [K] >>> ANCHORS CONVERGED - validated range [0x{0:X}, 0x{1:X}) UNLOCKED <<<" -f $peBase, ($peBase + $peSize))
} else {
    Write-Host '     [K] FAIL-CLOSED (reason above) - L1..L3 SKIPPED, L4/L5 run at a fixed VA'
}

# ---- L1: the validated image must start with 'MZ' ----
Write-Host ''
Write-Host '--- step L1: read @pe_base len=4 - the MZ signature ---'
$mzOk = $false; $L1 = $null
if ($anOk) {
    Canary 'pre-L1'
    try { $L1 = Send-Req (New-Req 0x1702 1 'FFFFFFFF' 4 ('{0:X16}' -f $peBase) $null) }
    catch { Write-Host "[!] L1 threw: $($_.Exception.Message)" }
    if ($null -ne $L1 -and $null -ne $L1.Resp -and $L1.Status -eq 1 -and $null -ne $L1.Data -and $L1.Data.Length -ge 2) {
        $mzOk = ($L1.Data[0] -eq 0x4D -and $L1.Data[1] -eq 0x5A)
    }
    $anSent++
    if ($mzOk) { Write-Host '     [L1] PASS: 4D 5A = MZ - the validated image header came back through the gate' }
    else       { Write-Host '     [L1] FAIL: no MZ (see raw above + serial [AN]/[RD])' }
} else { Write-Host '     [L1] SKIPPED (anchors not converged)' }

# ---- L2a: e_lfanew ----
Write-Host ''
Write-Host '--- step L2a: read @pe_base+0x3C len=4 - e_lfanew ---'
$lfanew = -1; $L2a = $null
if ($anOk) {
    Canary 'pre-L2a'
    try { $L2a = Send-Req (New-Req 0x1703 1 'FFFFFFFF' 4 ('{0:X16}' -f ($peBase + [uint64]0x3C)) $null) }
    catch { Write-Host "[!] L2a threw: $($_.Exception.Message)" }
    if ($null -ne $L2a -and $L2a.Status -eq 1 -and $null -ne $L2a.Data -and $L2a.Data.Length -ge 4) {
        $lfanew = U32 $L2a.Data 0
    }
    $anSent++
    if ($lfanew -ge 0x40 -and $lfanew -le 0x1000) { Write-Host ("     [L2a] PASS: e_lfanew=0x{0:X} (in range)" -f $lfanew) }
    else { Write-Host ("     [L2a] FAIL: e_lfanew={0} (expect 0x40..0x1000)" -f $lfanew) }
} else { Write-Host '     [L2a] SKIPPED (anchors not converged)' }

# ---- L2b: the PE header block (0x58 bytes: sig, machine, entry, size) ----
Write-Host ''
Write-Host '--- step L2b: read @pe_base+e_lfanew len=0x58 - the PE header block ---'
$peOk = $false; $sizeMatch = $false; $epRva = -1; $L2b = $null
if ($anOk -and $lfanew -ge 0x40) {
    Canary 'pre-L2b'
    try { $L2b = Send-Req (New-Req 0x1704 1 'FFFFFFFF' 0x58 ('{0:X16}' -f ($peBase + [uint64]$lfanew)) $null) }
    catch { Write-Host "[!] L2b threw: $($_.Exception.Message)" }
    if ($null -ne $L2b -and $L2b.Status -eq 1 -and $null -ne $L2b.Data -and $L2b.Data.Length -ge 0x58) {
        $sigOk  = ($L2b.Data[0] -eq 0x50 -and $L2b.Data[1] -eq 0x45 -and $L2b.Data[2] -eq 0x00 -and $L2b.Data[3] -eq 0x00)
        $machOk = ((U32 $L2b.Data 4) -band [uint32]0xFFFF) -eq [uint32]0x8664
        $epRva    = U32 $L2b.Data 0x28
        $sizeImg  = U32 $L2b.Data 0x50
        $sizeMatch = ([uint64]$sizeImg -eq $peSize)
        $epOkR     = ($epRva -gt 0 -and [uint64]$epRva -lt $peSize)
        $peOk = ($sigOk -and $machOk -and $epOkR)
        Write-Host ("     [L2b] sig PE\0\0={0}  machine AMD64={1}  entry RVA=0x{2:X}  SizeOfImage=0x{3:X}" -f $sigOk, $machOk, $epRva, $sizeImg)
        if ($sizeMatch) { Write-Host '     [L2b] PASS + SizeOfImage == the anchor payload pe_size (transport double-validates the range)' }
        else            { Write-Host '     [L2b] FAIL: header SizeOfImage != payload pe_size - send everything' }
    }
    $anSent++
} else { Write-Host '     [L2b] SKIPPED (anchors not converged / no e_lfanew)' }

# ---- L3: real kernel entry code bytes ----
Write-Host ''
Write-Host '--- step L3: read @pe_base+entryRVA len=8 - real kernel code bytes ---'
$epOk = $false; $L3 = $null
if ($anOk -and $epRva -gt 0) {
    Canary 'pre-L3'
    try { $L3 = Send-Req (New-Req 0x1705 1 'FFFFFFFF' 8 ('{0:X16}' -f ($peBase + [uint64]$epRva)) $null) }
    catch { Write-Host "[!] L3 threw: $($_.Exception.Message)" }
    if ($null -ne $L3 -and $L3.Status -eq 1 -and $null -ne $L3.Data -and $L3.Data.Length -ge 8) {
        $nonzero = $false
        foreach ($b in $L3.Data[0..7]) { if ($b -ne 0) { $nonzero = $true; break } }
        $epOk = $nonzero
        $hx = ($L3.Data[0..7] | ForEach-Object { $_.ToString('X2') }) -join ' '
        if ($epOk) { Write-Host "     [L3] PASS: 8 entry-point bytes back: $hx" }
        else       { Write-Host '     [L3] FAIL: all-zero bytes (implausible for an entry point)' }
    }
    $anSent++
} else { Write-Host '     [L3] SKIPPED (no validated entry RVA)' }

# ---- L4/L5: the gate must stay CLOSED outside the validated range ----
Write-Host ''
Write-Host '--- steps L4/L5: gate negatives (below and above the validated range) ---'
$l4AddrStr = 'FFFFF80002000000'; $l4Txt = 'fixed kernel VA (fail-closed mode)'
if ($anOk) {
    $l4AddrStr = '{0:X16}' -f ($peBase - [uint64]0x1000)
    $l4Txt = 'pe_base-0x1000 (below the range)'
}
Canary 'pre-L4'
$L4 = $null
try { $L4 = Send-Req (New-Req 0x1706 1 'FFFFFFFF' 4 $l4AddrStr $null) }
catch { Write-Host "[!] L4 threw: $($_.Exception.Message)" }
$anSent++
$l4Ok = ($null -ne $L4 -and $L4.Status -eq 4)
if ($l4Ok) { Write-Host "     [L4] PASS: $l4Txt rejected ErrAccess(4) - gate closed below" }
else       { Write-Host "     [L4] FAIL: status=$($L4.Status) (expect 4) - see serial" }
$l5AddrStr = 'FFFFF80004000000'; $l5Txt = 'fixed kernel VA (fail-closed mode)'
if ($anOk) {
    $l5AddrStr = '{0:X16}' -f ($peBase + $peSize)
    $l5Txt = 'pe_base+pe_size (above the range)'
}
Canary 'pre-L5'
$L5 = $null
try { $L5 = Send-Req (New-Req 0x1707 1 'FFFFFFFF' 4 $l5AddrStr $null) }
catch { Write-Host "[!] L5 threw: $($_.Exception.Message)" }
$anSent++
$l5Ok = ($null -ne $L5 -and $L5.Status -eq 4)
if ($l5Ok) { Write-Host "     [L5] PASS: $l5Txt rejected ErrAccess(4) - gate closed above" }
else       { Write-Host "     [L5] FAIL: status=$($L5.Status) (expect 4) - see serial" }
$lNegTxt = if ($l4Ok -and $l5Ok) { 'OK - both outside-range reads rejected ErrAccess(4), no crash' } else { 'FAILED - a read outside the range was NOT rejected (see L4/L5 + serial)' }

# ============================================================
# [11] THE DIRECT-READ LADDER - J1..J7 (v18 driver semantics)
#      pid=0xFFFFFFFF = KERNEL target = the v18 DIRECT volatile read
#      gated to the two KUSER_SHARED_DATA windows (can never fault).
#      Known-answer bytes everywhere:
#        KUSD+0x260 -> 65 4A 00 00 (19045 LE) - both aliases, same page
#        KUSD+0x308 -> 00 00 00 00 (v15/v16 field truth)
#      WARNING: with a v17 driver on the stick, J1..J5 die (the v20
#      CR3-switch killer). phase-d.bat checks memory.efi size 128010 (v20-RT).
# ============================================================
$expBuild = New-Object byte[] 4
$expBuild[0] = 0x65; $expBuild[1] = 0x4A; $expBuild[2] = 0x00; $expBuild[3] = 0x00   # 19045 = 0x4A65 LE
$myPid = [uint32]$PID
$ladder = @(
    @{ n = 'J1'; seq = 0x1601; rpid = 'FFFFFFFF'; len = 4; addr = '000000007FFE0260'; atxt = 'USER alias 0x7FFE0260';       why = 'THE DATA PATH PROOF: v18 direct read, user window - the same page [BLD] reads' }
    @{ n = 'J2'; seq = 0x1602; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000260'; atxt = 'KERNEL alias 0xFFFFF78000000260'; why = 'kernel-space VA via requests - first kernel-alias data ever (v20 died here; v18 reads it directly)' }
    @{ n = 'J3'; seq = 0x1603; rpid = 'FFFFFFFF'; len = 4; addr = '000000007FFE0308'; atxt = 'USER alias 0x7FFE0308';       why = 'second KUSD field, known value 0 (v15/v16 field truth)' }
    @{ n = 'J4'; seq = 0x1604; rpid = 'FFFFFFFF'; len = 4; addr = 'FFFFF78000000308'; atxt = 'KERNEL alias 0xFFFFF78000000308'; why = 'second field via the kernel alias - cross-check of J3' }
    @{ n = 'J5'; seq = 0x1605; rpid = 'FFFFFFFF'; len = 8; addr = '000000007FFE0260'; atxt = 'USER alias 0x7FFE0260';       why = 'x8 chunk test (dword[0] must equal J1; stays inside the window)' }
    @{ n = 'J6'; seq = 0x1606; rpid = 'FFFFFFFF'; len = 4; addr = '0000800000000000'; atxt = 'NON-CANONICAL VA';           why = 'negative: the gate must reject BEFORE any access - expect ErrAccess(4), no crash' }
    @{ n = 'J7'; seq = 0x1607; rpid = $myPid;     len = 4; addr = '000000007FFE0260'; atxt = 'USER alias 0x7FFE0260';       why = 'per-pid read WITHOUT attach, VALID window address: expect clean ErrAccess(4) pre-read, NO [RD] on serial - isolates the pid check; honest negative' }
)

Write-Host ''
Write-Host 'LADDER DECISION TABLE (for reading the video if the VM dies):'
Write-Host ' dies at J1     -> the driver is NOT v18+ (a v17 would walk+CR3-switch = instant death).'
Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v22-only; v21 refuses op-11 = ErrUnsupported, never a crash).' +
                     '  Check size: v22-RT = 134330.'
Write-Host '                  Check usb-d\memory.efi size: v22-RT = 134330 bytes (v21-RT = 131709 runs F1+F2 but not W).'
Write-Host ' dies at J2..J5 -> a window read is fatal DESPITE the direct path - the serial'
Write-Host '                  [RD] mapped va / mapped read ok pair tells exactly how far it got'
Write-Host ' dies at J6/J7  -> unexpected (gate-rejected / no-attach paths) - send everything'
Write-Host ' J1 answers ErrAccess(4) -> the gate rejected a VALID KUSD address: driver not v18+.'
Write-Host '                  Do NOT rerun until memory.efi is replaced (size 131709).'
Write-Host ' survives all 7 -> full matrix ran; verdict printed at the end'
Start-Sleep -Milliseconds 800

$jVal     = -1
$jWhere   = 'NOWHERE'
$dataOff  = -1
$bufKind  = ''
$ladderLog = @()
$negTxt   = 'never reached'

foreach ($v in $ladder) {
    Write-Host ''
    Write-Host ("--- step $($v.n): kernel READ  pid=$($v.rpid)  len=$($v.len)  addr=$($v.atxt) ---")
    Write-Host "      why: $($v.why)"
    Canary ("pre-" + $v.n)
    Write-Host ("[{0}] >>> SENDING op=1(READ) seq=0x{1:X} pid={2} len={3} addr=0x{4}" -f $v.n, $v.seq, $v.rpid, $v.len, $v.addr)
    Write-Host ("[{0}]     if the VM dies NOW, the killer is: pid={1} + addr={2} + len={3}" -f $v.n, $v.rpid, $v.atxt, $v.len)
    Start-Sleep -Milliseconds 1500
    $R = $null
    try { $R = Send-Req (New-Req $v.seq 1 $v.rpid $v.len $v.addr $null) }
    catch { Write-Host "[!] step $($v.n) threw: $($_.Exception.Message)" }

    $vTxt = 'NO RESPONSE (see marker above + serial [RD])'
    if ($null -ne $R -and $null -ne $R.Resp) {
        $vTxt = "ANSWERED status=$($R.Status)($(Stat-Name $R.Status)) seq_ok=$($R.SeqOk)"
    }
    # known-bytes search: 65 4A 00 00 in the response (offset >= 8),
    # then in the InfinityData out-buffer
    $foundWhere = ''
    if ($null -ne $R -and $null -ne $R.Resp) {
        $o = Find-From $R.Resp $expBuild 8
        if ($o -ge 8) {
            $foundWhere = "InfinityResp offset $o"
            if ($dataOff -lt 0) { $dataOff = $o; $bufKind = 'resp' }
        }
    }
    if ($foundWhere -eq '' -and $null -ne $R -and $null -ne $R.Data) {
        $o = Find-From $R.Data $expBuild 0
        if ($o -ge 0) {
            $foundWhere = "InfinityData offset $o"
            if ($dataOff -lt 0) { $dataOff = $o; $bufKind = 'data' }
        }
    }
    if ($foundWhere -ne '') {
        $vTxt += " + 19045 FOUND at $foundWhere"
        if ($jVal -lt 0) {
            $jVal = 19045
            $jWhere = "$($v.n) $foundWhere"
            Write-Host "      *** KERNEL DATA PATH ANSWER: 19045 (0x4A65) came back at $foundWhere ***"
        }
    }
    # J3/J4 cross-check (expected 0) and J5 chunk check, at the learned offset
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
    }
    if ($v.n -eq 'J6' -or $v.n -eq 'J7') {
        if ($null -ne $R -and $null -ne $R.Resp) {
            if ($R.Status -eq 4) { $negTxt = "OK - $($v.n) status=4(ErrAccess) as designed; script still alive = no crash" }
            else { $negTxt = "UNEXPECTED $($v.n) status=$($R.Status)($(Stat-Name $R.Status)) - see serial" }
        } else {
            $negTxt = "NO RESPONSE on $($v.n) (but script alive - see serial [RD])"
        }
    }
    Write-Host ("      [{0}] result: {1}" -f $v.n, $vTxt)
    $ladderLog += ("    [{0}] pid={1,-10} addr={2,-22} -> {3}" -f $v.n, $v.rpid, $v.atxt, $vTxt)
}

Canary 'post-ladder (all J-steps done)'
$kernOk = ($jVal -eq 19045)
if ($kernOk) { $jTxt = "PROVEN - 19045 via $jWhere" }
else         { $jTxt = 'NOT PROVEN - see the ladder results above + serial [RD] lines' }

# ============================================================
# [14a] F2 STEP M: ReqOp_ResolveSymbol (op=10) - export resolution
#       (v21 driver: the VALIDATED image's own export table, every
#       parse read in-image bounds-checked; the symbol NAME travels
#       via InfinityData, the answer is a 64-byte payload:
#       +0 found, +4 name_index, +8 resolved_va, +16 pe_base echo,
#       +24 pe_size echo, +32 kpcr_base, +40 idt_base echo,
#       +48 name_len, +52 rcode, +56 flags bit0 = kpcr-idt match)
# ============================================================
Write-Host ''
Write-Host '--- step M: ReqOp_ResolveSymbol (op=10) - F2 export resolution (v21 driver) ---'
$m1Ok = $false; $m2Ok = $false; $m2ReadOk = $false
$mNameWrites = 0   # v29: every Send-Resolve ALSO writes the symbol name to InfinityData (+1 INFCNT each)
$m3Ok = $false; $m3ReadOk = $false; $m4Ok = $false
$mKpcr = [uint64]0; $mKpcrMatch = 0; $mVa = [uint64]0; $nbVa = [uint64]0
function Send-Resolve([object]$rseq, [string]$symName) {
    # writes the symbol name to InfinityData, then sends the op-10
    # request with data_size = name length; returns the Send-Req result
    $nb = [System.Text.Encoding]::ASCII.GetBytes($symName)
    $null = Write-Var 'InfinityData' $nb
    $script:mNameWrites = $script:mNameWrites + 1   # v29: the NAME write bumps INFCNT too
    return (Send-Req (New-Req $rseq 10 'FFFFFFFF' $nb.Length '0000000000000000' $null))
}
if ($anOk) {
    # ---- M1: PsInitialSystemProcess (the F3 walk entry) ----
    Write-Host ''
    Write-Host '--- step M1: resolve PsInitialSystemProcess (the F3 EPROCESS-walk entry) ---'
    Canary 'pre-M1'
    $M1 = $null
    try { $M1 = Send-Resolve 0x1801 'PsInitialSystemProcess' } catch { Write-Host "[!] M1 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M1 -and $M1.Status -eq 1 -and $null -ne $M1.Data -and $M1.Data.Length -ge 64) {
        $mFound  = U32 $M1.Data 0
        $mIdx    = U32 $M1.Data 4
        $mVa     = U64 $M1.Data 8
        $mPb     = U64 $M1.Data 16
        $mPs     = U64 $M1.Data 24
        $mKpcr   = U64 $M1.Data 32
        $mIdt    = U64 $M1.Data 40
        $mFlags  = U32 $M1.Data 56
        $mKpcrMatch = ($mFlags -band 1)
        Write-Host ("     [M1] payload: found={0} idx={1} va=0x{2:X} pe_base=0x{3:X} pe_size=0x{4:X}" -f $mFound, $mIdx, $mVa, $mPb, $mPs)
        Write-Host ("     [M1] kpcr_base=0x{0:X} (IA32_GS_BASE)  idt echo=0x{1:X}  V5 kpcr-idt match={2}" -f $mKpcr, $mIdt, $mKpcrMatch)
        $m1Ok = ($mFound -eq 1) -and ($mVa -ge $peBase) -and ($mVa -lt ($peBase + $peSize)) -and ($mPb -eq $peBase) -and ($mPs -eq $peSize)
        if ($m1Ok) { Write-Host ("     [M1] PASS: resolved IN-IMAGE at 0x{0:X} (echoes exact) - the F3 walk entry is located" -f $mVa) }
        else       { Write-Host '     [M1] FAIL: not found / out of the validated range / echo mismatch (see raw above)' }
    } else { Write-Host '     [M1] FAIL: no Success response or short payload (see raw above + serial [XS])' }

    # ---- M2: NtBuildNumber + read it back (== 19045 ground truth) ----
    Write-Host ''
    Write-Host '--- step M2: resolve NtBuildNumber, then read it (must equal the KUSD 19045) ---'
    Canary 'pre-M2'
    $M2 = $null
    try { $M2 = Send-Resolve 0x1802 'NtBuildNumber' } catch { Write-Host "[!] M2 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M2 -and $M2.Status -eq 1 -and $null -ne $M2.Data -and $M2.Data.Length -ge 64) {
        $nbFound = U32 $M2.Data 0
        $nbVa    = U64 $M2.Data 8
        $m2Ok = ($nbFound -eq 1) -and ($nbVa -ge $peBase) -and ($nbVa -lt ($peBase + $peSize))
        if ($m2Ok) { Write-Host ("     [M2] PASS: NtBuildNumber resolved in-image at 0x{0:X}" -f $nbVa) }
        else       { Write-Host '     [M2] FAIL: resolve failed (see raw above + serial [XS])' }
    } else { Write-Host '     [M2] FAIL: no Success response or short payload' }
    if ($m2Ok) {
        Canary 'pre-M2r'
        $M2r = $null
        try { $M2r = Send-Req (New-Req 0x1803 1 'FFFFFFFF' 4 ('{0:X16}' -f $nbVa) $null) } catch { Write-Host "[!] M2r threw: $($_.Exception.Message)" }
        $anSent++
        if ($null -ne $M2r -and $M2r.Status -eq 1 -and $null -ne $M2r.Data -and $M2r.Data.Length -ge 4) {
            $nbVal = U32 $M2r.Data 0
            # v29: NtBuildNumber packs the BUILD in the LOW WORD (19045
            # = 0x4A65); the bits above carry the QFE/lab flags - the
            # canonical 19045 dword is 0xF0004A65. (v28 masked 0x7FFFFFFF
            # and compared against bare 19045 - the v28 field "FAIL" on a
            # perfect read.) The canonical compare uses the DECIMAL literal
            # 4026550885 - a [uint32]0xF0004A65 cast would re-trigger the
            # v21 line-444 hex-cast trap class (hex >= 0x80000000 parses
            # as NEGATIVE Int32 and the cast THROWS).
            $nbBuild = [uint32]($nbVal -band 0xFFFF)
            $nbCanon = ($nbVal -eq 4026550885)
            Write-Host ("     [M2r] raw dword = 0x{0:X} ({0})  build(low word) = {1}  canonical = {2}" -f $nbVal, $nbBuild, $nbCanon)
            $m2ReadOk = ($nbBuild -eq 19045) -or $nbCanon
            if ($m2ReadOk) { Write-Host '     [M2r] PASS: NtBuildNumber build field == 19045 == the KUSD J1 ground truth (double-proven; the bits above the low word are the QFE marker)' }
            else           { Write-Host '     [M2r] FAIL: build field != 19045 - see raw above + serial [RD] (a healthy 19045 system answers 0xF0004A65)' }
        } else { Write-Host '     [M2r] FAIL: read at the resolved VA failed (see raw above + serial [RD])' }
    }

    # ---- M3: KeBugCheckEx + read 8 code bytes ----
    Write-Host ''
    Write-Host '--- step M3: resolve KeBugCheckEx, then read 8 bytes (real code via exports) ---'
    Canary 'pre-M3'
    $M3 = $null
    try { $M3 = Send-Resolve 0x1804 'KeBugCheckEx' } catch { Write-Host "[!] M3 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M3 -and $M3.Status -eq 1 -and $null -ne $M3.Data -and $M3.Data.Length -ge 64) {
        $kbFound = U32 $M3.Data 0
        $kbVa    = U64 $M3.Data 8
        $m3Ok = ($kbFound -eq 1) -and ($kbVa -ge $peBase) -and ($kbVa -lt ($peBase + $peSize))
        if ($m3Ok) { Write-Host ("     [M3] PASS: KeBugCheckEx resolved in-image at 0x{0:X}" -f $kbVa) }
        else       { Write-Host '     [M3] FAIL: resolve failed (see raw above + serial [XS])' }
    } else { Write-Host '     [M3] FAIL: no Success response or short payload' }
    if ($m3Ok) {
        Canary 'pre-M3r'
        $M3r = $null
        try { $M3r = Send-Req (New-Req 0x1805 1 'FFFFFFFF' 8 ('{0:X16}' -f $kbVa) $null) } catch { Write-Host "[!] M3r threw: $($_.Exception.Message)" }
        $anSent++
        if ($null -ne $M3r -and $M3r.Status -eq 1 -and $null -ne $M3r.Data -and $M3r.Data.Length -ge 8) {
            $codeTxt = (HexStr $M3r.Data 8)
            $nonZero = $false
            for ($i = 0; $i -lt 8; $i++) { if ($M3r.Data[$i] -ne 0) { $nonZero = $true; break } }
            Write-Host ("     [M3r] code bytes: {0}" -f $codeTxt)
            $m3ReadOk = $nonZero
            if ($m3ReadOk) { Write-Host '     [M3r] PASS: non-zero kernel code bytes read via an export-resolved symbol' }
            else           { Write-Host '     [M3r] FAIL: all-zero bytes at the resolved VA - see serial [RD]' }
        } else { Write-Host '     [M3r] FAIL: read at the resolved VA failed (see raw above + serial [RD])' }
    }

    # ---- M4: the not-found negative ----
    Write-Host ''
    Write-Host '--- step M4: resolve NoSuchSymbolV28 (the honest negative: ErrNotFound) ---'
    Canary 'pre-M4'
    $M4 = $null
    try { $M4 = Send-Resolve 0x1806 'NoSuchSymbolV28' } catch { Write-Host "[!] M4 threw: $($_.Exception.Message)" }
    $anSent++
    if ($null -ne $M4 -and $null -ne $M4.Resp) {
        if ($M4.Status -eq 7) {
            $m4Ok = $true
            Write-Host '     [M4] PASS: status=7(ErrNotFound) as designed - the parser refuses cleanly, VM alive'
        } else {
            Write-Host ("     [M4] FAIL: expected 7(ErrNotFound), got {0}({1}) - see raw above + serial [XS]" -f $M4.Status, (Stat-Name $M4.Status))
        }
    } else { Write-Host '     [M4] FAIL: no response at all (see raw above + serial [XS])' }
} else {
    Write-Host '     [M] SKIPPED (anchors not converged - the resolve refuses without the validated range)'
}

# ============================================================
# [14.5] step W: ReqOp_ProcessWalk (op=11) - THE F3 EPROCESS WALK
# (v22 driver only; with v21 the op refuses ErrUnsupported cleanly)
# ============================================================
$wSent     = 0
$w1Ok      = $false
$wNamesOk  = $false
$w2Ok      = $false
$w3Txt     = 'NOT RUN'
$w4Ok      = $false
$w5Ok      = $false
$wCount    = -1
$wStored   = -1
$wPayloadTxt = 'no payload'

if ($anOk) {
    Write-Host ''
    Write-Host '--- step W: ReqOp_ProcessWalk (op=11, pid ignored, outN=32) - THE F3 WALK ---'
    Write-Host '      resp status=1(Success) + payload.status=0(Ok) => the walk ran'
    Write-Host '      payload.status: 0 Ok / 1 bad-args / 2 no-entry / 3 bad-S1 / 4 not-System /'
    Write-Host '                     5 broken-link / 6 window-refused / 7 budget (refuse = VM alive)'

    # ---- W1: the walk itself ----
    Canary 'pre-W1'
    $W1 = $null
    try { $W1 = Send-Req (New-Req 0x1901 11 'FFFFFFFF' 32 '0000000000000000' $null) } catch { Write-Host "[!] W1 threw: $($_.Exception.Message)" }
    $wSent++
    if ($null -ne $W1 -and $null -ne $W1.Resp -and $W1.Status -eq 1 -and $null -ne $W1.Data -and $W1.Data.Length -ge 1056) {
        $wSt     = U32 $W1.Data 1024
        $wCount  = U32 $W1.Data 1028
        $wSys    = U64 $W1.Data 1032
        $wOfs    = U32 $W1.Data 1040
        $wClosed = U32 $W1.Data 1044
        $wPages  = U32 $W1.Data 1048
        $wStored = U32 $W1.Data 1052
        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} sys=0x{6:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys)
        Write-Host ("     [W1] payload: {0}" -f $wPayloadTxt)
        if ($wSt -ne 0) {
            Write-Host ("     [W1] WALK REFUSED (payload status={0}) - the VM is alive; serial [PW] names the refusal" -f $wSt)
        } else {
            # the F2<->F3 cross-check: sys MUST equal M1's resolved VA
            $sysEcho = ($wSys -eq $mVa)
            $e0pid = U32 $W1.Data 0
            $e0eproc = U64 $W1.Data 8
            $e0flags = U32 $W1.Data 4
            $e0name = [System.Text.Encoding]::ASCII.GetString($W1.Data, 16, 8)
            Write-Host ("     [W1] entries[0]: pid={0} eproc=0x{1:X} flags={2} name='{3}'" -f $e0pid, $e0eproc, $e0flags, $e0name)
            $w1Ok = ($wCount -ge 1) -and $sysEcho -and ($e0pid -eq 4) -and ($e0eproc -eq $mVa)
            if ($w1Ok) {
                Write-Host '     [W1] PASS: System entry self-echo at the M1-resolved VA (F2<->F3 cross-check) - list head proven'
            } else {
                Write-Host '     [W1] FAIL: sys!=M1-va or entries[0] is not System@S1 (see above + serial [PW])'
            }
            # names
            $wNamesOk = ($wOfs -ne 0) -and ($e0flags -band 1) -and ($e0name.StartsWith('System'))
            if ($wNamesOk) { Write-Host ("     [W1] PASS: name slot discovered live at +0x{0:X} - names echoed (derive, never trust)" -f $wOfs) }
            else           { Write-Host '     [W1] NOTE: names not echoed (name_ofs=0 or flags bit0=0) - the walk itself is still valid' }

            # ---- W2: the live Get-Process cross-check ----
            Write-Host ''
            Write-Host '--- step W2: live cross-check (Get-Process) ---'
            try {
                $liveProcs = @(Get-Process -ErrorAction Stop)
                $liveIds = @{}
                foreach ($p in $liveProcs) { $liveIds[[int]$p.Id] = $true }
                $checked = 0; $missing = 0
                $lim = $wStored; if ($lim -gt 12) { $lim = 12 }
                for ($i = 0; $i -lt $lim; $i++) {
                    $ep = U32 $W1.Data ($i * 32)
                    if ($ep -ne 0) {
                        $checked++
                        if (-not $liveIds.ContainsKey([int]$ep) -and $ep -ne 4) { $missing++; Write-Host ("     [W2] pid {0} not in the live list (protected/exit race?)" -f $ep) }
                    }
                }
                $cntDelta = [Math]::Abs([int]$wCount - $liveProcs.Count)
                Write-Host ("     [W2] walked={0} live={1} delta={2} checked={3} missing={4}" -f $wCount, $liveProcs.Count, $cntDelta, $checked, $missing)
                $w2Ok = ($missing -eq 0) -and ($cntDelta -le 3)
                if ($w2Ok) { Write-Host '     [W2] PASS: the walked list matches the live process list' }
                else       { Write-Host '     [W2] FAIL: too many mismatches - send the .txt + serial [PW]' }
            } catch { Write-Host "     [W2] SKIPPED (Get-Process failed: $($_.Exception.Message))" }

            # ---- W3: the script's own $PID among the walked entries ----
            Write-Host ''
            Write-Host '--- step W3: is THIS PowerShell (pid $myPid) in the walked list? ---'
            $foundAt = -1
            $lim3 = $wStored
            for ($i = 0; $i -lt $lim3; $i++) {
                if ((U32 $W1.Data ($i * 32)) -eq [uint32]$myPid) { $foundAt = $i; break }
            }
            if ($foundAt -ge 0) {
                $nm3 = [System.Text.Encoding]::ASCII.GetString($W1.Data, ($foundAt * 32) + 16, 8)
                Write-Host ("     [W3] FOUND at entry {0}: name='{1}' - the walk sees the requester itself" -f $foundAt, $nm3)
                $w3Txt = "FOUND at entry $foundAt ('$nm3')"
            } elseif ($wStored -lt $wCount) {
                Write-Host ("     [W3] NOTE: not within the first {0} stored entries (list has {1}; late-started processes sit at the tail) - not a failure" -f $wStored, $wCount)
                $w3Txt = "beyond the stored window (stored=$wStored count=$wCount)"
            } else {
                Write-Host '     [W3] FAIL: the whole list was stored but this pid is absent'
                $w3Txt = 'ABSENT from a fully-stored list'
            }
        }
    } elseif ($null -ne $W1 -and $null -ne $W1.Resp) {
        Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v22 build (134330 B)? With v21 op 11 is ErrUnsupported(8)" -f $W1.Status, (Stat-Name $W1.Status))
    } else {
        Write-Host '     [W1] FAIL: no response at all (see raw above + serial [PW])'
    }

    # ---- W4: the honest negatives (outN gate) ----
    Write-Host ''
    Write-Host '--- step W4: negatives - outN=0 and outN=33 must both refuse ErrInvalid(5), VM alive ---'
    Canary 'pre-W4'
    $W4a = $null
    try { $W4a = Send-Req (New-Req 0x1902 11 'FFFFFFFF' 0 '0000000000000000' $null) } catch { Write-Host "[!] W4a threw: $($_.Exception.Message)" }
    $wSent++
    $W4b = $null
    try { $W4b = Send-Req (New-Req 0x1903 11 'FFFFFFFF' 33 '0000000000000000' $null) } catch { Write-Host "[!] W4b threw: $($_.Exception.Message)" }
    $wSent++
    $w4aOk = ($null -ne $W4a -and $null -ne $W4a.Resp -and $W4a.Status -eq 5)
    $w4bOk = ($null -ne $W4b -and $null -ne $W4b.Resp -and $W4b.Status -eq 5)
    if ($w4aOk) { Write-Host '     [W4a] PASS: outN=0 -> ErrInvalid(5) clean' } else { Write-Host '     [W4a] FAIL: expected ErrInvalid(5) - see raw above' }
    if ($w4bOk) { Write-Host '     [W4b] PASS: outN=33 -> ErrInvalid(5) clean' } else { Write-Host '     [W4b] FAIL: expected ErrInvalid(5) - see raw above' }
    $w4Ok = $w4aOk -and $w4bOk

    # ---- W5: pid-irrelevance (no pid gate on kernel-list data) ----
    Write-Host ''
    Write-Host '--- step W5: op-11 with a REAL pid must answer the same (kernel-list reads have no pid gate) ---'
    Canary 'pre-W5'
    $W5 = $null
    try { $W5 = Send-Req (New-Req 0x1904 11 $myPid 32 '0000000000000000' $null) } catch { Write-Host "[!] W5 threw: $($_.Exception.Message)" }
    $wSent++
    $w5Ok = ($null -ne $W5 -and $null -ne $W5.Resp -and $W5.Status -eq 1)
    if ($w5Ok) { Write-Host '     [W5] PASS: real pid answered Success - the walk is kernel data, not per-process (contrast: op-1 J7 ErrAccess)' }
    else       { Write-Host '     [W5] FAIL: expected Success with a real pid - see raw above' }
} else {
    Write-Host ''
    Write-Host '--- step W: SKIPPED (anchors not converged - the walk refuses without the validated range) ---'
}

# [15] step N: final INFCNT (expect G+1 - only InfinityData persists)
Write-Host ''
Write-Host '--- step N: final INFCNT read (live RAM count; expect G+8+name-writes+requests: H +1, J1..J7 +7, K/L + M requests + M name-writes + W walk requests) ---'
$nBack = Read-VarBack 'INFCNT'
$cntFinal = -1
if ($null -ne $nBack -and $nBack.Length -ge 4) { $cntFinal = U32 $nBack 0 }

# ============================================================
# summary (null-safe: -1 means that read failed)
function NCalls($x) { if ($null -ne $x) { return [int]$x.calls } else { return -1 } }
$cA = NCalls $A; $cB = NCalls $B; $cC = NCalls $C
$cD = NCalls $D; $cE = NCalls $E; $cF = NCalls $F
$fStage = -1; $fFlags = 0; $fBuild = -1
if ($null -ne $F) { $fStage = $F.stage; $fFlags = $F.flags; $fBuild = $F.build }
$winBuildOs = [Environment]::OSVersion.Version.Build

$readOk   = (($cB - $cA) -ge 1)
$writeOk  = ($cntVal -ge 2) -or ((($fFlags -band 0x20) -ne 0) -and ($cntVal -ge 1))
$trigSet  = ($fFlags -band 0x20) -ne 0
$probeFound = ($null -ne $probeBack)

Write-Host ''
Write-Host '==== SUMMARY (auto-saved to the output .txt) ===='
Write-Host ("hook_calls  A={0} B={1} C={2} D={3} E={4} F={5}" -f $cA, $cB, $cC, $cD, $cE, $cF)
Write-Host ("stage F={0}  flags F=0x{1:X}  trigger_seen(0x20)={2}" -f $fStage, $fFlags, $(if ($trigSet) {'SET'} else {'NOT-SET'}))
Write-Host ("win_build  driver-live={0}  script-side={1}   (equal = build detection works)" -f $fBuild, $winBuildOs)
Write-Host ("INFCNT live RAM count (our-var writes that reached the hook) = {0}   (0 = bypassed, 2 = both)" -f $cntVal)
Write-Host ("[1] GetVariable path via hook : {0}" -f $(if ($readOk) {'PROVEN (hook_calls moves between reads)'} else {'BYPASSED (counts frozen - kernel reads NVRAM directly)'}))
Write-Host ("[2] SetVariable path via hook : {0}" -f $(if ($writeOk) {"PROVEN (INFCNT=$cntVal, flag 0x20)"} else {'BYPASSED (writes land in NVRAM but never touch the hook)'}))
Write-Host ("[3] INFPROBE landed in NVRAM  : {0}" -f $(if ($probeFound) {'YES (raw firmware write path works)'} else {'NO (write returned OK but variable absent!)'}))
Write-Host ("[4] InfinityReq consumed (RAM) : {0}" -f $(if ($respAnswered) {'YES (PONG proves it)'} else {'UNPROVEN (no PONG this run)'}))
if ($reqAbsent -and $respAnswered) { Write-Host '    NVRAM read-back: absent - ABSENT is EXPECTED (v13+ consumes it in RAM)' }
Write-Host ("[5] InfinityResp PING         : {0}" -f $respTxt)
Write-Host ("[6] InfinityData buffer round trip : {0}" -f $(if ($hExact) {'BYTE-EXACT (payload transport works)'} else {'FAILED - see step H raw bytes'}))
Write-Host ("[7] Attach step (I)                : {0}" -f $attachTxt)
Write-Host '     ladder detail (each line = one variant, in send order):'
foreach ($ln in $ladderLog) { Write-Host $ln }
Write-Host ("[8] Kernel read via ladder (J1..J7) : {0}" -f $jTxt)
Write-Host ("[9] Negatives (J6 gate, J7 no-attach) : {0}" -f $negTxt)
if ($anOk) {
    Write-Host ("[10] F1 anchors (K) : CONVERGED - pe_base=0x{0:X} pe_size=0x{1:X} idt_base=0x{2:X}" -f $peBase, $peSize, $anIdt)
    Write-Host ("[11] Validated-image reads (L1..L3) : MZ={0} PE-sig+machine={1} size-match={2} entry-bytes={3}" -f $mzOk, $peOk, $sizeMatch, $epOk)
} else {
    Write-Host ("[10] F1 anchors (K) : FAIL-CLOSED (state={0} reason={1}) - the gate stayed KUSD-only" -f $anState, $anReason)
    Write-Host '     [11] Validated-image reads (L1..L3) : SKIPPED (fail-closed)'
}
Write-Host ("[12] Range negatives (L4 below, L5 above) : {0}" -f $lNegTxt)
$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites) and the W walk requests (+wSent); requests are consumed in RAM and deletes never count)'
$mTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
         elseif ($m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok) { 'PROVEN - resolve + cross-validated reads + negative' }
         else { 'PARTIAL/FAILED - see the M-step lines above + serial [XS]/[KPCR]' }
Write-Host ("[13] F2 export resolution (M1..M4) : {0}" -f $mTxt)
$wTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
        elseif ($w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok) { "PROVEN - {0} processes walked, System self-echo + live-list cross-check green" -f $wCount }
        elseif ($wCount -ge 1) { 'PARTIAL - the walk ran but a cross-check failed (see the W-step lines + serial [PW])' }
        else { "REFUSED ($wPayloadTxt) - serial [PW] names the reason" }
Write-Host ("[14] F3 process walk (W1..W5)    : {0}" -f $wTxt)
if ($wCount -ge 1) { Write-Host ("     walked count={0} stored={1} closed(capped)={2}  self-pid: {3}" -f $wCount, $wStored, $(if ($wClosed) {'circle'} else {'64-cap'}), $w3Txt) }

Write-Host ''
Write-Host 'VERDICT:'
$bridgeOk = $respAnswered -and $hExact
if ($kernOk) {
    Write-Host '>>> KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE <<<'
    Write-Host "Windows -> InfinityReq -> our hook -> direct KUSD read -> InfinityResp ($jWhere)."
    if ($negTxt -notlike 'OK*') {
        Write-Host 'NOTE: J9 did not return a clean ErrAccess(4) - check [9] + serial.'
    }
} elseif ($bridgeOk) {
    Write-Host '>>> FULL BRIDGE PROVEN - and the VM SURVIVED all 7 ladder variants,'
    Write-Host '>>> but none returned the expected dword. <<<'
    Write-Host 'That combination is NEW information - send the output .txt +'
    Write-Host 'serial-phase-d.log (every [RD] line matters).'
} else {
    Write-Host '>>> BRIDGE REGRESSION (PING or payload transport failed). <<<'
    Write-Host 'Send output .txt + serial-phase-d.log.'
}
Write-Host ''
$f1Ok = $anOk -and $mzOk -and $peOk -and $sizeMatch -and $epOk -and ($lNegTxt -like 'OK*')
if ($f1Ok) {
    Write-Host '>>> F1 PROVEN: ANCHORS CONVERGED + VALIDATED-IMAGE READS VIA REQUESTS <<<'
    Write-Host ("SIDT -> IDT/LSTAR -> walk-backs -> 4 validators -> gate opened [0x{0:X}, 0x{1:X}) ->" -f $peBase, ($peBase + $peSize))
    Write-Host 'real kernel bytes came back (MZ, PE header, entry code) and the gate'
    Write-Host 'stayed CLOSED one page below and one byte above. Fail-closed works.'
} elseif ($anOk) {
    Write-Host '>>> F1 PARTIAL: anchors converged but a validated read or negative failed. <<<'
    Write-Host 'Send output .txt + serial-phase-d.log (every [AN]/[RD] line matters).'
} else {
    Write-Host '>>> F1 FAIL-CLOSED (the gate never opened). The ladder regression below still counts. <<<'
    Write-Host 'Serial [AN] lines name the exact reason - send them + the output .txt.'
}
$f2Ok = $anOk -and $m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok
if ($f2Ok) {
    Write-Host ''
    Write-Host '>>> F2 PROVEN: EXPORT-RESOLVED SYMBOLS + VALIDATED READS VIA REQUESTS <<<'
    Write-Host 'The image answers its own layout: export table -> PsInitialSystemProcess,'
    Write-Host 'NtBuildNumber (== the KUSD ground truth), KeBugCheckEx code bytes - all'
    Write-Host 'through the validated gate. No per-build offset tables ever again.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F2 PARTIAL: anchors converged but an M-step failed - see above. <<<'
    Write-Host 'Serial [XS]/[KPCR]/[RD] lines matter - send them + the output .txt.'
}
$f3Ok = $anOk -and $w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok
if ($f3Ok) {
    Write-Host ''
    Write-Host '>>> F3 PROVEN: THE EPROCESS WALK - PROCESS DATA OUTSIDE THE IMAGE <<<'
    Write-Host ('From the F2-resolved PsInitialSystemProcess: ActiveProcessLinks walked with' )
    Write-Host 'double-link consistency + canonical/cluster gates + hard budgets.'
    Write-Host ("{0} processes counted, System self-echo at the M1 VA, live-list cross-check green," -f $wCount)
    Write-Host 'names discovered live. The first arbitrary-kernel-VA reads are proven -'
    Write-Host 'fail-closed held the whole way (W4 negatives clean, VM alive).'
    Write-Host 'Next: F4 (PTE/page-table base for arbitrary-VA validation), then Infinity.exe.'
} elseif ($anOk -and $wCount -ge 1) {
    Write-Host ''
    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F3 NOT PROVEN THIS RUN (the walk refused or was skipped). <<<'
    Write-Host 'Refusals are clean by design - the payload status + serial [PW] name it.'
}
Write-Host '==== END v30 ===='

if ($transPath) {
    $saved = $false
    try {
        $fi = Get-Item -LiteralPath $transPath -ErrorAction Stop
        if ($fi.Length -gt 1024) { $saved = $true }
    } catch { }
    if ($saved) { Write-Host "[LOG] output saved and VERIFIED: $transPath" }
    else        { Write-Host "[LOG] output file problem: $transPath (photograph this window too)" }
    Write-Host '[LOG] HOW TO GET THE .TXT OUT of the VM (no photos needed):'
    Write-Host '[LOG]   1. on YOUR machine: put any file for the VM into the'
    Write-Host '[LOG]      transfer folder and double-click refresh-files.bat'
    Write-Host '[LOG]      - a USB stick appears inside Windows'
    Write-Host '[LOG]   2. inside Windows: copy the .txt onto that stick'
    Write-Host '[LOG]   3. on YOUR machine: run refresh-files.bat again - the'
    Write-Host '[LOG]      file lands in the transfer folder. Send that file.'
    try { Stop-Transcript | Out-Null } catch { }
}
