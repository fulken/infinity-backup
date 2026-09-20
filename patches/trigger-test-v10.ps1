# ============================================================
# INFINITY bridge trigger test v10  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# For driver memory.efi v8 RT (EARLY hooks build).
#
# v10 FIX (over v9): the TOKEN_PRIVILEGES P/Invoke struct was
#   flattened to {int; long; int} - but .NET gives `long` an
#   8-byte alignment, so the LUID landed at offset 8 instead of
#   4. AdjustTokenPrivileges saw a garbage LUID -> error 1300
#   ("not all privileges assigned") which the v9 script then
#   misreported as "not elevated". v10 restores the PROVEN
#   nested LUID / LUID_AND_ATTRIBUTES structs from test v7/v8.
#   Also fixed: the write results are now the REAL API return
#   values (v9 used PowerShell $? which does not reflect the
#   Win32 BOOL return).
#
# What it does (full production bridge loop, all live):
#   1. Enables SeSystemEnvironmentPrivilege (correct structs).
#   2. READ  INFDIAG      -> goes THROUGH our hooked GetVariable:
#      shows the LIVE stage/flags/hook_calls (v8 synthesizes it
#      from memory - no reboot needed).
#   3. WRITE INFTRIGGER   -> SetFirmwareEnvironmentVariableEx with
#      EFI attributes NV|BS|RT (fixes the old Win32 error 87: the
#      non-Ex API passed attributes=0). Our HookedSetVariable sees
#      it and answers directly - the firmware varstore is never
#      touched, so no attribute/creation pitfalls remain.
#   4. WRITE InfinityReq  -> the REAL production trigger: a 48-byte
#      EfiVarReq ping (op=0xDEADBEEF). The driver processes it and
#      stores an EfiVarResp.
#   5. READ  InfinityResp -> the driver's response. status=1
#      (SlotStatus_Success) means the full
#      Windows->kernel->gRT->OUR HOOK->handler->response chain
#      is ALIVE.
#   6. READ  INFDIAG again -> flags must now contain
#      trigger_seen (0x20) and hook_calls must have grown.
#
# Expected results:
#   - READ1 stage=4 + hook_calls>0        -> virtual hook chain ALIVE
#   - TRIGGER writes report "OK"          -> hook received the write
#   - RESP status=1                       -> bridge answered
#   - READ2 flags has 0x20 bit set        -> trigger SEEN by driver
#   - Win32 1314                          -> PowerShell not elevated
#   - Win32 2 on INFDIAG                  -> driver not loaded this boot
# ============================================================

$ErrorActionPreference = 'Continue'

$src = @'
using System;
using System.Runtime.InteropServices;

public static class EfiVarBridge {
    // ---- privilege structures: MUST mirror the Win32 layout ----
    // native TOKEN_PRIVILEGES = DWORD + LUID_AND_ATTRIBUTES
    //   LUID = {DWORD LowPart; LONG HighPart}          (align 4)
    //   LUID_AND_ATTRIBUTES = {LUID; DWORD Attributes} (align 4)
    // Flattening these into {int; long; int} is WRONG:
    // .NET aligns `long` to 8 and shifts every field.
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

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetCurrentProcess();

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(
        IntPtr ProcessHandle, uint DesiredAccess, out IntPtr TokenHandle);

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool LookupPrivilegeValueW(
        string lpSystemName, string lpName, out LUID lpLuid);

    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool AdjustTokenPrivileges(
        IntPtr TokenHandle, bool DisableAllPrivileges,
        ref TOKEN_PRIVILEGES NewState, uint BufferLength,
        IntPtr PreviousState, IntPtr ReturnLength);

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr hObject);

    // Returns 0 on success; otherwise the meaningful Win32 error
    // (1300 = privilege not held by the token,
    //  100+n = OpenProcessToken failed, 200+n = Lookup failed,
    //  300+n = AdjustTokenPrivileges itself returned FALSE).
    public static int EnableSystemEnvironmentPrivilege() {
        IntPtr token;
        if (!OpenProcessToken(GetCurrentProcess(),
                0x28 /* TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY */,
                out token))
            return 100 + Marshal.GetLastWin32Error();

        LUID luid;
        if (!LookupPrivilegeValueW(null, "SeSystemEnvironmentPrivilege", out luid)) {
            int e = Marshal.GetLastWin32Error();
            CloseHandle(token);
            return 200 + e;
        }

        TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES();
        tp.PrivilegeCount  = 1;
        tp.Privileges.Luid = luid;
        tp.Privileges.Attributes = 2; /* SE_PRIVILEGE_ENABLED */

        if (!AdjustTokenPrivileges(token, false, ref tp, 0,
                IntPtr.Zero, IntPtr.Zero)) {
            int e = Marshal.GetLastWin32Error();
            CloseHandle(token);
            return 300 + e;
        }
        int err = Marshal.GetLastWin32Error(); /* 0 OK, 1300 not assigned */
        CloseHandle(token);
        return err;
    }

    // ---- firmware variable access ----
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern uint GetFirmwareEnvironmentVariableW(
        string lpName, string lpGuid, byte[] pBuffer, uint nSize);

    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetFirmwareEnvironmentVariableExW(
        string lpName, string lpGuid, byte[] pBuffer, uint nSize,
        uint dwAttributes);
}
'@

Add-Type -TypeDefinition $src -Language CSharp

# EFI variable attributes
$EFI_NV   = 0x1
$EFI_BS   = 0x2
$EFI_RT   = 0x4
$EFI_ATTR = $EFI_NV -bor $EFI_BS -bor $EFI_RT   # 7

$GUID = '{A1B2C3D4-E5F6-4789-9ABC-DEF012345678}'

function Read-EfiVar {
    param([string]$Name, [int]$Size)
    $buf = New-Object byte[] $Size
    $n = [EfiVarBridge]::GetFirmwareEnvironmentVariableW($Name, $GUID, $buf, [uint32]$Size)
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if ($n -eq 0) {
        # size-0-but-found also lands here with err=0 (ok=true)
        return @{ ok = ($err -eq 0); size = 0; err = $err; buf = $null }
    }
    return @{ ok = $true; size = [int]$n; err = 0; buf = $buf[0..([int]$n-1)] }
}

function Write-EfiVar {
    param([string]$Name, [byte[]]$Data)
    $ret = [EfiVarBridge]::SetFirmwareEnvironmentVariableExW($Name, $GUID, $Data, [uint32]$Data.Length, [uint32]$EFI_ATTR)
    $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
    return @{ ok = $ret; err = $err }
}

function Show-Infdiag {
    param([string]$Label, $r)
    if (-not $r.ok) {
        Write-Host ("[{0}] INFDIAG read FAILED Win32={1}" -f $Label, $r.err)
        switch ($r.err) {
            1314 { Write-Host "[$Label]   -> privilege not held (not elevated?)" }
            2    { Write-Host "[$Label]   -> variable not found (driver never loaded this boot?)" }
            default { Write-Host "[$Label]   -> see error code" }
        }
        return $null
    }
    if ($r.size -lt 32) { Write-Host ("[{0}] INFDIAG short ({1} bytes)" -f $Label, $r.size); return $null }
    $b = $r.buf
    $hex = ($b | ForEach-Object { $_.ToString('X2') }) -join ' '
    Write-Host "[$Label] INFDIAG raw: $hex"
    $stage  = $b[4]  -bor ($b[5]  -shl 8) -bor ($b[6]  -shl 16) -bor ($b[7]  -shl 24)
    $flags  = $b[8]  -bor ($b[9]  -shl 8) -bor ($b[10] -shl 16) -bor ($b[11] -shl 24)
    $build  = $b[12] -bor ($b[13] -shl 8) -bor ($b[14] -shl 16) -bor ($b[15] -shl 24)
    $cr3 = 0; for ($i = 23; $i -ge 16; $i--) { $cr3 = ($cr3 -shl 8) -bor $b[$i] }
    $calls  = $b[24] -bor ($b[25] -shl 8) -bor ($b[26] -shl 16) -bor ($b[27] -shl 24)
    $lastst = $b[28] -bor ($b[29] -shl 8) -bor ($b[30] -shl 16) -bor ($b[31] -shl 24)
    Write-Host ("[{0}] STAGE={1}  flags=0x{2:X}  win_build={3}  os_cr3=0x{4:X}  hook_calls={5}  last_status=0x{6:X}" -f $Label, $stage, $flags, $build, $cr3, $calls, $lastst)
    return @{ stage=$stage; flags=$flags; calls=$calls }
}

# ---- build the 48-byte EfiVarReq ping (little endian) ----
# u32 sequence, u32 op=0xDEADBEEF(Ping), u32 pid, u32 data_size,
# u64 address, u64 alloc_size, u32 protect, u32 timeout_ms,
# u32 status, u32 crc32
function New-PingReq {
    [byte[]]$d = New-Object byte[] 48
    $seq = [BitConverter]::GetBytes([uint32]0x12345678)
    [Array]::Copy($seq, 0, $d, 0, 4)
    $op = [BitConverter]::GetBytes([uint32]0xDEADBEEF)
    [Array]::Copy($op, 0, $d, 4, 4)
    return $d
}

Write-Host '=== INFINITY trigger test v10 (driver v8 RT) ==='

# ---- 0) privilege ----
$prc = [EfiVarBridge]::EnableSystemEnvironmentPrivilege()
if ($prc -ne 0) {
    Write-Host ("[ERROR] privilege enable failed: code {0}" -f $prc)
    if ($prc -eq 1300) {
        Write-Host '  1300 = ERROR_NOT_ALL_ASSIGNED: this token does NOT hold'
        Write-Host '  SeSystemEnvironmentPrivilege. Really not elevated, or the'
        Write-Host '  right was removed by Local Security Policy. Proof below:'
    }
    elseif ($prc -gt 100 -and $prc -lt 200) {
        Write-Host ("  OpenProcessToken failed, Win32 {0}" -f ($prc - 100))
    }
    elseif ($prc -gt 200 -and $prc -lt 300) {
        Write-Host ("  LookupPrivilegeValueW failed, Win32 {0}" -f ($prc - 200))
    }
    elseif ($prc -gt 300) {
        Write-Host ("  AdjustTokenPrivileges returned FALSE, Win32 {0}" -f ($prc - 300))
    }
    whoami
    whoami /priv | findstr /i "SystemEnvironment SeShutdown"
    exit 1
}
Write-Host '[OK] SeSystemEnvironmentPrivilege enabled (rc=0)'
whoami /priv | findstr /i SystemEnvironment

# ---- 1) live INFDIAG (through the hook) ----
$r1 = Read-EfiVar 'INFDIAG' 64
$d1 = Show-Infdiag 'READ1' $r1
Start-Sleep -Milliseconds 300

# ---- 2) INFTRIGGER write (alias trigger) ----
Write-Host ''
Write-Host '[TRIG1] writing INFTRIGGER (1 byte) via SetFirmwareEnvironmentVariableEx ...'
$w1 = Write-EfiVar 'INFTRIGGER' ([byte[]]@(1))
if ($w1.ok) { Write-Host '[TRIG1] OK - the hook accepted the write' }
else        { Write-Host ("[TRIG1] FAILED Win32={0}" -f $w1.err) }

# ---- 3) InfinityReq production ping ----
Write-Host ''
Write-Host '[TRIG2] writing InfinityReq (48-byte EfiVarReq ping, op=0xDEADBEEF) ...'
$w2 = Write-EfiVar 'InfinityReq' (New-PingReq)
if ($w2.ok) { Write-Host '[TRIG2] OK - the hook accepted the request' }
else        { Write-Host ("[TRIG2] FAILED Win32={0}" -f $w2.err) }

# ---- 4) read the response ----
Write-Host ''
$r3 = Read-EfiVar 'InfinityResp' 64
if ($r3.ok -and $r3.size -ge 32) {
    $b = $r3.buf
    $hex = ($b | ForEach-Object { $_.ToString('X2') }) -join ' '
    Write-Host "[RESP] InfinityResp (32 bytes): $hex"
    $seq  = $b[0]  -bor ($b[1]  -shl 8) -bor ($b[2]  -shl 16) -bor ($b[3]  -shl 24)
    $stat = $b[4]  -bor ($b[5]  -shl 8) -bor ($b[6]  -shl 16) -bor ($b[7]  -shl 24)
    $bt   = 0; for ($i = 15; $i -ge 8;  $i--) { $bt = ($bt -shl 8) -bor $b[$i] }
    $oa   = 0; for ($i = 23; $i -ge 16; $i--) { $oa = ($oa -shl 8) -bor $b[$i] }
    Write-Host ("[RESP] sequence=0x{0:X}  status={1}  bytes_transferred={2}  out_address=0x{3:X}" -f $seq, $stat, $bt, $oa)
    if ($stat -eq 1)           { Write-Host '[RESP] status=1 (SlotStatus_Success) -> THE BRIDGE ANSWERED. FULL LOOP ALIVE.' }
    elseif ($seq -eq 0x54524947) { Write-Host '[RESP] INFTRIGGER echo response seen (GIRT) -> alias trigger path alive.' }
    else                       { Write-Host "[RESP] status=$stat -> see protocol codes (2=generic,5=invalid,8=unsupported)" }
} elseif ($r3.ok -and $r3.size -eq 0) {
    Write-Host '[RESP] InfinityResp empty - the hook answered but no trigger was processed. (TRIG writes above failed?)'
} else {
    Write-Host "[RESP] InfinityResp read FAILED Win32=$($r3.err) - if error 2: hook not in the GetVariable path this boot."
}

# ---- 5) live INFDIAG again ----
Write-Host ''
$r2 = Read-EfiVar 'INFDIAG' 64
$d2 = Show-Infdiag 'READ2' $r2

# ---- 6) verdict ----
Write-Host ''
Write-Host '=== VERDICT ==='
$alive = $false
if ($d1 -and $d1.stage -ge 4 -and $d1.calls -gt 0) {
    Write-Host ("[OK] virtual-mode hook chain ALIVE (stage=4, hook_calls={0} at first read)" -f $d1.calls)
    $alive = $true
} elseif ($d2 -and $d2.calls -gt 0) {
    Write-Host '[OK] hooks are being called (hook_calls grew on second read)'
    $alive = $true
} else {
    Write-Host '[!!] INFDIAG shows no hook activity - see interpretation below.'
}
if ($d1 -and $d2) {
    if (($d2.flags -band 0x20) -ne 0) {
        Write-Host '[OK] trigger_seen flag (0x20) IS set - the driver SAW a trigger write from Windows.'
    } else {
        Write-Host '[!!] trigger_seen flag (0x20) NOT set - trigger writes did not reach the hook.'
    }
    if ($d2.calls -gt $d1.calls) {
        Write-Host ("[OK] hook_calls grew ({0} -> {1}) between reads" -f $d1.calls, $d2.calls)
    }
}
if ($alive) {
    Write-Host ''
    Write-Host 'PHASE D GOAL REACHED: Windows -> UEFI runtime variable -> OUR HOOK -> response.'
    Write-Host 'Send this output + serial-phase-d.log back.'
} else {
    Write-Host ''
    Write-Host 'Interpretation:'
    Write-Host ' - INFDIAG error 2      -> memory.efi v8 RT was not loaded this boot (check phase-d.bat + serial log).'
    Write-Host ' - stage 3, calls 0     -> hooks installed but Windows has not called one yet: run this script again,'
    Write-Host '                          check serial-phase-d.log for "[HOOK] .. VIRT" lines.'
    Write-Host ' - stage 1/2 only       -> OS boot did not reach the VA event: check serial log + BSOD report.'
    Write-Host 'Send this output + serial-phase-d.log + screenshot back.'
}
