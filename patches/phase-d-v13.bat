@echo off
rem ============================================================
rem INFINITY Phase D v13: boot installed Windows WITH the v13 RT build
rem (EARLY gRT hooks + hardened virtual path). Deep test.
rem
rem v9 changes vs v8:
rem   - THE BIG ONE: the boot disk (usb-d) is now attached as a
rem     READ-ONLY USB stick instead of a writable IDE disk. The
rem     2026-09-20 corruption (trigger-test.ps1 truncated to
rem     11433 of 14290 bytes = parse error at line 263) happened
rem     because Windows writes to the virtual FAT and QEMU's
rem     experimental fat:rw write path corrupted the FAT chain
rem     during the session. A read-only stick CANNOT be corrupted
rem     and Windows can never pollute the usb-d folder again.
rem   - REAL-TIME FILE TRANSFER: QEMU now opens a control port
rem     (monitor) on 127.0.0.1:5555. While the VM runs, put any
rem     file into the "transfer" folder and double-click
rem     refresh-files.bat - seconds later a USB stick with your
rem     files appears inside Windows. NO VM restart, ever again.
rem     (Works both ways: files you copy onto that stick inside
rem     the VM land in the transfer folder when you refresh.)
rem   - Pre-flight gates now also refuse to start if usb-d has
rem     disk images / archives in it or the test folder copied
rem     into it (the exact accident of 2026-09-20).
rem
rem Driver: memory.efi v13 RT (safe observability build).
rem Test script: trigger-test-v13.ps1 (4-signal attribution).
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

rem ---- pre-flight 1: the trigger test script must be v13 ----
if not exist usb-d\trigger-test-v13.ps1 (
  echo [ERROR] usb-d\trigger-test-v13.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v13" usb-d\trigger-test-v13.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\trigger-test-v13.ps1 is NOT the v13 script.
  echo A stale old copy - v10 v11 or v12 - cannot read the v13
  echo live RAM signals and its verdict would be wrong.
  echo Fix: extract the NEW v13 package zip over this folder, so that
  echo usb-d\trigger-test-v13.ps1 is replaced - v13 is 16303 bytes.
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v13.ps1 verified - pre-placed on the boot disk.

rem ---- pre-flight 2: usb-d must stay pristine ----
rem usb-d becomes the READ-ONLY boot disk. It must contain ONLY
rem the 4 shipped boot items. The gates below stop the exact
rem accident of 2026-09-20 (the test folder copied into usb-d)
rem with a clear message instead of a broken test run.
for %%E in (qcow2 vhd vhdx vmdk iso wim img raw zip rar 7z exe msi) do (
  if exist "usb-d\*.%%E" (
    echo [ERROR] usb-d contains *.%%E files - disk images, zips or
    echo programs do not belong on the boot disk. usb-d must contain
    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v13.ps1
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
    echo This is the exact accident of 2026-09-20: it corrupted the
    echo test script. usb-d must contain ONLY the 4 shipped items:
    echo   EFI  memory.efi  startup.nsh  trigger-test-v13.ps1
    echo Fix: delete that folder from usb-d, then run phase-d again.
    echo To copy files into the VM use the transfer folder instead.
    pause
    exit /b 1
  )
)
echo [Phase D] usb-d clean - corruption-proof READ-ONLY boot disk.
echo [Phase D] Note: if QEMU itself ever says "Directory does not fit
echo in FAT16" or "larger than 2GB" at startup, usb-d has grown too
echo big - remove the extra content (shipped files only, a few MB).

if not exist transfer mkdir transfer
if not exist transfer\README-FA.txt (
  echo Drop files for the VM into this folder, then double-click refresh-files.bat > transfer\README-FA.txt
  echo (the VM must be running via phase-d.bat from package v13+) >> transfer\README-FA.txt
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
echo [Phase D] package v13 - Windows + memory.efi v13 RT boot test. Mode %MODE%.
echo [Phase D] The banner must say: memory.efi v13 RT (safe observability build).
echo [Phase D] NEW: the boot disk (usb-d) is now a READ-ONLY USB stick -
echo [Phase D] Windows can no longer corrupt it (that is what broke the
echo [Phase D] test script last time). It shows up as a Removable drive,
echo [Phase D] usually D: - if Windows gave it another letter, use that.
echo [Phase D] Watch for these milestone lines in serial-phase-d.log:
echo [Phase D]   [INF][RT-EARLY] gRT hooks INSTALLED at load time
echo [Phase D]   [INF][HOOK] G/S call#N BOOT-CTX  (shell/bootmgr chained OK)
echo [Phase D]   [INF][EBS] ExitBootServices hook FIRED   (stage 2)
echo [Phase D]   [INF][VA]  SetVirtualAddressMap ... FIRED (stage 3)
echo [Phase D]   [INF][HOOK] G/S/T call#N VIRT FIRST  (stage 4!)
echo [Phase D] After the desktop loads do NOT close the VM:
echo [Phase D]   1. inside Windows open PowerShell as Administrator
echo [Phase D]   2. run the trigger test from the boot disk:
echo [Phase D]        D:\trigger-test-v13.ps1
echo [Phase D]      Its FIRST output line must say: trigger test v13.
echo [Phase D]   3. WANT TO COPY ANY NEW FILE INTO THE VM? Put it into
echo [Phase D]      the transfer\ folder on YOUR machine and run
echo [Phase D]      refresh-files.bat - a USB stick with the files
echo [Phase D]      appears inside Windows seconds later. No restart.
echo [Phase D]      Copy files OUT of the VM the same way: put them on
echo [Phase D]      that stick inside Windows, run refresh-files.bat
echo [Phase D]      again - they land in transfer\ on your machine.
echo [Phase D]   4. SHUT DOWN Windows from inside the VM (this saves
echo [Phase D]      the final INFDIAG via the ResetSystem hook)
echo [Phase D]   5. then run phase-b-check.bat
echo [Phase D] If Windows hangs, resets or BSODs, that IS a valuable
echo [Phase D] result - keep the serial log and send it.
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
echo   1. run phase-b-check.bat and send a photo of the INFDIAG line
echo   2. send serial-phase-d.log (contains the [INF] diagnostic lines)
echo   3. send the output of trigger-test-v13.ps1 if you ran it
echo   4. tell me which mode number you used
echo   NOTE: to copy files into/out of a RUNNING VM use
echo   transfer\ + refresh-files.bat (no restart needed).
pause
