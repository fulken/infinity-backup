@echo off
rem ============================================================
rem INFINITY spice-connect - open a second view of the RUNNING
rem VM with copy/paste support, using remote-viewer.
rem
rem Run phase-d-spice.bat FIRST, wait until the QEMU window is
rem up, THEN double-click this file.
rem One-time requirement: virt-viewer for Windows installed -
rem https://virt-manager.org/download  ->  Windows installer
rem ============================================================
setlocal

set PF86=%ProgramFiles(x86)%

set RV=
for /f "delims=" %%p in ('where remote-viewer 2^>nul') do if not defined RV set "RV=%%p"
if not defined RV for /d %%D in ("%ProgramFiles%\VirtViewer*") do if exist "%%D\bin\remote-viewer.exe" set "RV=%%D\bin\remote-viewer.exe"
if not defined RV for /d %%D in ("%PF86%\VirtViewer*") do if exist "%%D\bin\remote-viewer.exe" set "RV=%%D\bin\remote-viewer.exe"
if not defined RV for /d %%D in ("%LOCALAPPDATA%\Programs\VirtViewer*") do if exist "%%D\bin\remote-viewer.exe" set "RV=%%D\bin\remote-viewer.exe"

if not defined RV (
  echo [ERROR] remote-viewer not found on your PC.
  echo Install virt-viewer for Windows first - the MSI from:
  echo   https://virt-manager.org/download
  echo then run this file again.
  pause
  exit /b 1
)

echo [SPICE] opening remote-viewer - the VM console opens in a new
echo [SPICE] window. The clipboard is synced BOTH ways while it
echo [SPICE] stays open. The normal QEMU window is unaffected.
start "" "%RV%" spice://127.0.0.1:5930
