@echo off
rem ============================================================
rem INFINITY Phase D v21: boot installed Windows WITH the v21 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE ANCHOR STACK
rem + THE CONTAINING-WALK + THE EXPORT RESOLUTION). v20's stack is
rem unchanged; v21 adds op 10 (ReqOp_ResolveSymbol): symbols are
rem resolved from the VALIDATED image's own export table - every
rem parse read in-image bounds-checked, fail-closed on any corrupt
rem intermediate value. No per-build offset tables ever again. The
rem op-9 wire, the read gate and the K/L/J semantics are UNTOUCHED.
rem Test script: trigger-test-v29.ps1 (K/L/M steps + J regression).
rem
rem v29 SCRIPT (2026-09-27): THE M2R EXPECTATION FIX + THE FULL
rem INFCNT ARITHMETIC (script-only - the v21 driver STAYS, 131709
rem bytes, untouched). The v28 field run (2026-09-26 21:11) was
rem DRIVER-GREEN end to end: all four M resolutions + both M reads
rem returned perfect data - but the script printed [M2r] FAIL on
rem the CANONICAL NtBuildNumber dword 0xF0004A65 (build in the LOW
rem WORD 0x4A65 = 19045 = the KUSD J1 ground truth; QFE flag bits
rem above it). v28 masked 0x7FFFFFFF and compared against bare
rem 19045. v29 masks the BUILD field (0xFFFF) + accepts the
rem canonical dword (as a DECIMAL literal - no hex-cast trap).
rem Also: the v28 final-INFCNT line printed "expect G+8+ = 23" (an
rem empty format slot + the 4 M-side symbol-NAME writes missing) -
rem v29 counts every term: INFCNT 27 converged / 13 fail-closed.
rem
rem v28 SCRIPT (2026-09-26): STEP M - the F2 export-resolution
rem proof. The v27 field run was FULL GREEN: F1 PROVEN (converged
rem + MZ/PE-header/entry-code reads + both range negatives + J
rem 100% + INFCNT 17 exact). v28 adds M1 resolve
rem PsInitialSystemProcess (the F3 walk entry), M2 resolve
rem NtBuildNumber + read it (must equal the KUSD 19045 ground
rem truth), M3 resolve KeBugCheckEx + read 8 code bytes, M4 the
rem not-found negative (status 7). INFCNT 23 converged / 13
rem fail-closed. Stat-Name fixed to the driver enum (7=ErrNotFound).
rem
rem v9 baseline notes still true:
rem   - usb-d is attached READ-ONLY (cannot be corrupted)
rem   - transfer\ + refresh-files.bat = real-time file exchange
rem   - pre-flight gates keep usb-d pristine
rem
rem DRIVER SIZE GUARD (retargeted to v21-RT = 131709 bytes): with
rem the v17 driver (120678) J1..J5 WILL KILL THE VM (CR3 class);
rem with v18 (121253) there are no anchors at all; with v19 (125450)
rem the walk stops at the FIRST valid PE (the nested-PE trap); with
rem v20 (128010) everything runs EXCEPT the new M steps (no export
rem resolution - op 10 answers ErrUnsupported). The guard refuses
rem all four old generations.
rem
rem v24 SCRIPT basis (2026-09-26): K = ReqOp_Anchors (op 9) runs the
rem discovery ONCE and reports state/reason/pe_base/pe_size; L1..L3
rem read REAL kernel bytes through the validated range (MZ, PE
rem header, entry code); L4/L5 prove the gate stays CLOSED outside
rem the range. If anchors fail, everything fails CLOSED (L4/L5
rem still run and MUST be rejected). J1..J7 = the v23 regression.
rem
rem IMPORTANT: use the SAME acceleration mode number that your
rem Windows install finished with (same rule as phase-c).
rem
rem Requires: Windows already installed via phase-b.bat
rem Usage:   phase-d.bat [1 or 2 or 3]
rem ============================================================
setlocal
cd /d "%~dp0"

set QEMU=
for /f "delims=" %%p in ('where qemu-system-x86_64.exe 2^>nul') do if not defined QEMU set "QEMU=%%p"
if not defined QEMU if exist "%ProgramFiles%\qemu\qemu-system-x86_64.exe" set QEMU=%ProgramFiles%\qemu\qemu-system-x86_64.exe
if not defined QEMU if exist "%ProgramFiles(x86)%\qemu\qemu-system-x86_64.exe" set QEMU=%ProgramFiles(x86)%\qemu\qemu-system-x86_64.exe
if not defined QEMU (
  echo [ERROR] qemu-system-x86_64.exe not found.
  echo Install QEMU from: https://qemu.weilnetz.de/w64/
  pause
  exit /b 1
)

if not exist disk\win10.qcow2 (
  echo [ERROR] disk\win10.qcow2 not found.
  echo Run phase-b.bat first to install Windows into the VM.
  pause
  exit /b 1
)

rem ---- pre-flight 1: the trigger test script must be v29 ----
if not exist usb-d\trigger-test-v29.ps1 (
  echo [ERROR] usb-d\trigger-test-v29.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v29" usb-d\trigger-test-v29.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\trigger-test-v29.ps1 is NOT the v29 script.
  echo A stale v28 copy still runs and the DRIVER side is fully
  echo green - but it prints [M2r] FAIL on the healthy canonical
  echo 0xF0004A65 and its final INFCNT line says expect 23 where
  echo the true count is 27 - the verdict stops at F2 PARTIAL with
  echo the driver blameless. Replace it with the v29 script.
  echo Fix: extract the NEW v29 swap package over this folder.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v29.ps1 verified - pre-placed on the boot disk.

rem ---- pre-flight 1b: DRIVER SIZE GUARD (v21-RT = 131709) ----
set DRIVERSIZE=
for %%A in (usb-d\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="131709" (
  echo [ERROR] usb-d\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v21 RT driver ^(v21-RT = 131709 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v29 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v29 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v20 driver.
    ) else (
      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20+
        echo containing-walk converges on the true image.
      ) else (
        if "%DRIVERSIZE%"=="128010" (
          echo That size is the v20 RT driver ^(F1-proven, but no
          export resolution^): the K/L/J steps run green, the new M
          steps cannot ^(op 10 answers ErrUnsupported^). Replace
          with the v21 driver for the F2 proof.
        ) else (
          echo Unknown driver build. Only the v21 RT driver runs the
          echo v29 K/L/M steps.
        )
      )
    )
  )
  echo Fix: copy memory.efi from this package over usb-d\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
echo [Phase D] memory.efi verified - v21 RT build ^(131709 bytes^).

rem ---- pre-flight 2: usb-d must stay pristine ----
for %%E in (qcow2 vhd vhdx vmdk iso wim img raw zip rar 7z exe msi) do (
  if exist "usb-d\*.%%E" (
    echo [ERROR] usb-d contains *.%%E files - disk images, zips or
    echo programs do not belong on the boot disk. usb-d must contain
    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v29.ps1
    echo Current content of usb-d:
    dir /b usb-d
    echo Fix: delete the extra files from usb-d, then run phase-d again.
    echo To copy files into the VM use the transfer folder instead.
    pause
    exit /b 1
  )
)
for %%D in ("infinity-qemu-test" "disk" "vars" "firmware" "usb" "usb-c" "usb-check" "usb-d") do (
  if exist "usb-d\%%~D\" (
    echo [ERROR] found usb-d\%%~D\ - a folder was copied into usb-d.
    echo usb-d must contain ONLY the 4 shipped items:
    echo   EFI  memory.efi  startup.nsh  trigger-test-v29.ps1
    echo Fix: delete that folder from usb-d, then run phase-d again.
    echo To copy files into the VM use the transfer folder instead.
    pause
    exit /b 1
  )
)
echo [Phase D] usb-d clean - corruption-proof READ-ONLY boot disk.
echo [Phase D] Old trigger files ^(v17..v28^) may stay in the ROOT of
echo the stick - only usb-d is guarded. Harmless either way.

if not exist transfer mkdir transfer
if not exist transfer\README-FA.txt (
  echo Drop files for the VM into this folder, then double-click refresh-files.bat > transfer\README-FA.txt
  echo ^(the VM must be running via phase-d.bat from package v18+^) >> transfer\README-FA.txt
)

if not exist vars mkdir vars
if not exist vars\OVMF_VARS_4M.fd copy /y firmware\OVMF_VARS_4M.fd vars\OVMF_VARS_4M.fd >nul

set MODE=%~1
if "%MODE%"=="1" goto mode_ok
if "%MODE%"=="2" goto mode_ok
if "%MODE%"=="3" goto mode_ok
set MODE=
echo [Phase D] Acceleration: use the SAME mode number that your
echo [Phase D] Windows install finished with successfully.
echo   [1] WHPX fast - 2 cores
echo   [2] WHPX safe - 1 core
echo   [3] TCG - software emulation, slow boot
choice /c 123 /m "[Phase D] Choose 1, 2 or 3"
if errorlevel 3 (set MODE=3) else if errorlevel 2 (set MODE=2) else (set MODE=1)
:mode_ok

echo.
echo [Phase D] package v21 - Windows + memory.efi v21 RT boot test ^(F2 export resolution^). Mode %MODE%.
echo [Phase D] The banner must say: memory.efi v21 RT ^(kernel data path: direct reads + export resolution^).
echo [Phase D] Watch for these milestone lines in serial-phase-d.log:
echo [Phase D]   [INF][RT-EARLY] gRT hooks INSTALLED at load time
echo [Phase D]   [INF][EBS] ExitBootServices hook FIRED   ^(stage 2^)
echo [Phase D]   [INF][VA]  SetVirtualAddressMap ... FIRED ^(stage 3^)
echo [Phase D]   [INF][BLD] live windows build ^(ofs 0x260^)=19045
echo [Phase D]   [INF][HOOK] S OURVAR delete  ^(script canaries + cleanup^)
echo [Phase D]   [INF][RD] mapped va=...  +  mapped read ok=1  ^(THE LADDER^)
echo [Phase D] After the desktop loads do NOT close the VM:
echo [Phase D]   1. inside Windows open PowerShell as Administrator
echo [Phase D]   2. run the trigger test from the boot disk:
echo [Phase D]        D:\trigger-test-v29.ps1
echo [Phase D]      Its FIRST line must say: trigger test v29.
echo [Phase D]   3. STEP 0 of the script reads the Event Log and prints
echo [Phase D]      what killed the PREVIOUS run ^(BugCheck code if any^).
echo [Phase D]   4. copy files in/out via transfer\ + refresh-files.bat
echo [Phase D]   5. SHUT DOWN Windows from inside the VM, then the script
echo [Phase D]      transcript .txt from the Desktop can also be taken out
echo [Phase D]      with the transfer stick.
echo [Phase D] If QEMU closes by itself suddenly: that is the instant-death
echo [Phase D] class - KEEP serial-phase-d.log and photograph what you can.
echo.

if "%MODE%"=="3" goto run_tcg

rem ---------------- WHPX mode 1 or 2 ----------------
if "%MODE%"=="1" set SMP=2
if "%MODE%"=="2" set SMP=1
"%QEMU%" -machine q35 -m 4096 -smp %SMP% -cpu host -accel whpx ^
 -rtc base=localtime ^
 -drive if=pflash,format=raw,readonly=on,file=firmware\OVMF_CODE_4M.fd ^
 -drive if=pflash,format=raw,file=vars\OVMF_VARS_4M.fd ^
 -drive if=none,file=fat:usb-d,format=raw,id=bootdrv,readonly=on ^
 -device usb-storage,id=dstick,drive=bootdrv,bootindex=0 ^
 -drive if=none,file=disk\win10.qcow2,format=qcow2,id=windisk ^
 -device ide-hd,drive=windisk,bus=ide.0,bootindex=1 ^
 -nic none -usb -device usb-tablet ^
 -monitor telnet:127.0.0.1:5555,server,nowait ^
 -no-reboot -serial file:serial-phase-d.log
set RC=%errorlevel%
if "%RC%"=="0" goto done
echo.
echo [Phase D] WHPX could not start, exit code %RC% - retrying with TCG.
echo [Phase D] ^(If the error mentions the port or "Failed to bind":
echo [Phase D]  another VM is still running - close it first.^)
echo.

:run_tcg
"%QEMU%" -machine q35 -m 4096 -smp 2 -cpu max -accel tcg ^
 -rtc base=localtime ^
 -drive if=pflash,format=raw,readonly=on,file=firmware\OVMF_CODE_4M.fd ^
 -drive if=pflash,format=raw,file=vars\OVMF_VARS_4M.fd ^
 -drive if=none,file=fat:usb-d,format=raw,id=bootdrv,readonly=on ^
 -device usb-storage,id=dstick,drive=bootdrv,bootindex=0 ^
 -drive if=none,file=disk\win10.qcow2,format=qcow2,id=windisk ^
 -device ide-hd,drive=windisk,bus=ide.0,bootindex=1 ^
 -nic none -usb -device usb-tablet ^
 -monitor telnet:127.0.0.1:5555,server,nowait ^
 -no-reboot -serial file:serial-phase-d.log

:done
echo.
echo [Phase D] Done. Next steps:
echo   1. send serial-phase-d.log ^(contains [INF] + [RD] + canary lines^)
echo   2. send the trigger-test-v29 output .txt ^(Desktop, via transfer stick^)
echo   3. if the VM died: also send a photo of the last screen + the
echo      step-0 post-mortem printout of the NEXT run
echo   4. tell me which mode number you used
pause
