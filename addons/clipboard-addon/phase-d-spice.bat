@echo off
rem ============================================================
rem INFINITY Phase D SPICE - the SAME test VM as phase-d.bat,
rem plus a CLIPBOARD channel: copy/paste text between your PC
rem and the Windows VM in both directions.
rem
rem This changes NOTHING about the tested machine chain:
rem   - same OVMF firmware files + same vars file
rem   - same read-only boot stick usb-d + same memory.efi
rem   - same Windows disk, same serial log, same monitor port
rem The ONLY hardware addition is one virtio-serial controller
rem - the pipe the guest clipboard agent uses. The UEFI variable
rem hooks are not touched by it in any way.
rem
rem This file does NOT check the trigger-test script version on
rem purpose: it works next to ANY package version you currently
rem have extracted. The original phase-d.bat stays untouched and
rem remains the reference for pristine evidence runs.
rem
rem ONE-TIME SETUP:
rem   1. inside the VM: install spice-guest-tools-latest.exe
rem      then restart Windows inside the VM once
rem   2. on YOUR PC: install virt-viewer - Windows installer
rem      from https://virt-manager.org/download
rem   3. while the VM runs: double-click spice-connect.bat
rem
rem Usage: phase-d-spice.bat [1 or 2 or 3]  - same modes as phase-d
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
  echo Copy phase-d-spice.bat into your existing phase-d test
  echo folder - the one that contains disk + firmware + usb-d.
  pause
  exit /b 1
)

if not exist firmware\OVMF_CODE_4M.fd (
  echo [ERROR] firmware\OVMF_CODE_4M.fd not found.
  echo Copy phase-d-spice.bat into your existing phase-d test
  echo folder - the one that contains disk + firmware + usb-d.
  pause
  exit /b 1
)

rem ---- pre-flight: does this QEMU build support SPICE at all ----
"%QEMU%" -chardev help >"%TEMP%\inf_chardev_probe.txt" 2>&1
findstr /I /C:"spicevmc" "%TEMP%\inf_chardev_probe.txt" >nul 2>&1
if errorlevel 1 (
  echo [ERROR] this QEMU build has no SPICE support compiled in,
  echo so clipboard mode cannot work with it. The normal test
  echo still runs fine - use phase-d.bat for that.
  echo If you want clipboard support: install the QEMU setup from
  echo https://qemu.weilnetz.de/w64/ - that build includes SPICE.
  pause
  exit /b 1
)
echo [Phase D-SPICE] QEMU SPICE support verified.

rem ---- pre-flight: usb-d must stay pristine - same rule as phase-d ----
for %%E in (qcow2 vhd vhdx vmdk iso wim img raw zip rar 7z exe msi) do (
  if exist "usb-d\*.%%E" (
    echo [ERROR] usb-d contains *.%%E files - the boot disk must
    echo contain ONLY its shipped boot items. Delete the extras,
    echo then run this file again.
    pause
    exit /b 1
  )
)
for %%D in ("infinity-qemu-test" "disk" "vars" "firmware" "usb" "usb-c" "usb-check" "usb-d") do (
  if exist "usb-d\%%~D\" (
    echo [ERROR] found usb-d\%%~D\ - a folder was copied into
    echo the boot disk. Delete it, then run this file again.
    pause
    exit /b 1
  )
)
echo [Phase D-SPICE] usb-d clean - read-only boot disk ready.

if not exist transfer mkdir transfer
if not exist transfer\README-FA.txt (
  echo Drop files for the VM into this folder, then double-click refresh-files.bat > transfer\README-FA.txt
  echo The VM must be running via phase-d.bat or phase-d-spice.bat from package v9+ >> transfer\README-FA.txt
)

if not exist vars mkdir vars
if not exist vars\OVMF_VARS_4M.fd copy /y firmware\OVMF_VARS_4M.fd vars\OVMF_VARS_4M.fd >nul

set MODE=%~1
if "%MODE%"=="1" goto mode_ok
if "%MODE%"=="2" goto mode_ok
if "%MODE%"=="3" goto mode_ok
set MODE=
echo [Phase D-SPICE] Acceleration: use the SAME mode number that your
echo [Phase D-SPICE] Windows install finished with successfully.
echo   [1] WHPX fast - 2 cores
echo   [2] WHPX safe - 1 core
echo   [3] TCG - software emulation, slow boot
choice /c 123 /m "[Phase D-SPICE] Choose 1, 2 or 3"
if errorlevel 3 (set MODE=3) else if errorlevel 2 (set MODE=2) else (set MODE=1)
:mode_ok

echo.
echo [Phase D-SPICE] mode %MODE% - same VM as phase-d, plus clipboard.
echo [Phase D-SPICE] The normal QEMU window opens as always - photos
echo [Phase D-SPICE] are still possible from it. WHILE the VM runs,
echo [Phase D-SPICE] double-click spice-connect.bat to open a second
echo [Phase D-SPICE] view with copy/paste support - see README-SPICE-FA.md
echo [Phase D-SPICE] for the one-time setup steps.
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
 -device virtio-serial-pci ^
 -chardev spicevmc,id=vdagent,name=vdagent ^
 -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 ^
 -spice addr=127.0.0.1,port=5930,disable-ticketing=on ^
 -monitor telnet:127.0.0.1:5555,server,nowait ^
 -no-reboot -serial file:serial-phase-d.log
set RC=%errorlevel%
if "%RC%"=="0" goto done
echo.
echo [Phase D-SPICE] WHPX could not start, exit code %RC% - retrying with TCG.
echo [Phase D-SPICE] If the error mentions port 5930 or 5555: another VM
echo [Phase D-SPICE] or an old spice-connect window is still open - close
echo [Phase D-SPICE] it first, then run this file again.
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
 -device virtio-serial-pci ^
 -chardev spicevmc,id=vdagent,name=vdagent ^
 -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 ^
 -spice addr=127.0.0.1,port=5930,disable-ticketing=on ^
 -monitor telnet:127.0.0.1:5555,server,nowait ^
 -no-reboot -serial file:serial-phase-d.log

:done
echo.
echo [Phase D-SPICE] Done. serial-phase-d.log was written as always.
echo Next steps are identical to phase-d.bat - phase-b-check.bat etc.
echo NOTE: to copy files into/out of a RUNNING VM you can also use
echo transfer\ + refresh-files.bat - no restart needed.
pause
