@echo off
rem ============================================================
rem INFINITY Phase D v35: SCRIPT-ONLY - the v26 driver UNCHANGED.
rem The v34 field run (2026-09-28 04:50) = THE SECOND F4-ERA BSOD
rem (0x50 PAGE_FAULT_IN_NONPAGED_AREA, same as v33). The v34 run's
rem step 0 captured the v33 crash's FULL bugcheck args:
rem   0x50 (0xfffff807154e5078, 0, 0xfffff8071d08707c, 0)
rem and 0xfffff807154e5078 - 0xfffff807154e0000 = 0x5078 =
rem 0x1AD*0x30 + 8 EXACTLY (pfn 0x1AD = the v33 System DTB
rem 0x1AD000 >> 12; stride 0x30 = _MMPFN; +8 = .PteAddress).
rem THE FINGERPRINT NAMES THE REAL KILLER: op-12's chain B -
rem pdb + pfn*0x30 + 8 deref'd RAW with pdb = a GARBAGE kernel
rem pointer from a WRONG nt!MmPfnDatabase RVA (the 5 researched
rem candidates do not match this build; the weak canonical+
rem aligned check passes random pointers). NOT the v25 formulas
rem (with chain A's correct base the old addresses stay INSIDE
rem the mapped PTE space - wrong data maybe, a fault NEVER).
rem The v26 formula fix was real but irrelevant; "constants
rem intact" kept the poison and killed the VM a second time.
rem
rem v35 STRATEGY (fail-closed to the bone): op-12 IS RETIRED -
rem the script NEVER sends it (the crash op is simply not
rem called). Everything runs through the op-1 image gate
rem (L1-L5 field-proven since v20) + op-11 (the W walk):
rem   [R] RECON: the 7 candidate qwords (2x MmPteBase + 5x
rem       MmPfnDatabase) + the op-11 dtb echo - the actual
rem       values THIS build has there, through the proven gate.
rem   [D] THE .data DUMP: the whole .data section, 1024B chunks
rem       (self-verified vs MZ/e_lfanew, resumable, manifest +
rem       sha256) - the ground truth for the offline constant
rem       verification that gates the v36 walk kit.
rem   Plus: step 0 prints the FULL bugcheck args (the v34
rem   crash's own args will show the same +0x30-stride+8
rem   fingerprint) + W2 exit-race tolerance (the v34 pid-656).
rem
rem DRIVER: v26-RT = 140582 bytes, sha256 c8f79b95... - THE
rem SAME BINARY AS v34 (8-times field-proven op-1/op-11 paths;
rem its op-12 is never called by v35). v25-RT = 141154 (the
rem FIRST BSOD binary) - refused by hash as before.
rem Test script: trigger-test-v35.ps1.
rem ============================================================
rem INFINITY Phase D v26 (historical): v25 + THE FORMULA FIX. The v33 field
rem run (2026-09-28 01:16) was the FIRST F4-ERA BSOD: F1/F2/F3
rem green a 7th time, the cap-aware W2 PROVEN, the op-11 dtb
rem echo PROVEN (0x1AD000) - then P1 hit BSOD 0x50
rem PAGE_FAULT_IN_NONPAGED_AREA inside op-12 (the engine died on
rem its FIRST PTE-space read, never returned; [PT]=0 on serial).
rem Root cause (walk-level, engine-side): v25 addressed the upper
rem page-table levels at PTE_BASE + shifted-vpn*8 - LOW-USER PTE
rem slots; the self-ref read walked PML4E[0] of the CALLER process
rem (absent in the trigger script context) and faulted.
rem
rem v26 computes the TRUE level bases (ground-truthed against the
rem published classic s=0x1ED constants 0xFFFFF6FB40000000 /
rem 0xFFFFF6FB7DA00000 / 0xFFFFF6FB7DBED000):
rem   PDE_BASE = PTE_BASE + (s<<30)
rem   PPE_BASE = PDE_BASE + (s<<21)
rem   PXE_BASE = PPE_BASE + (s<<12)   (PML4E[s] at PXE_BASE+s*8)
rem Every corrected slot walks only the s-self-ref chain + parents
rem already proven present (fault-free). ALSO: chain-B identity =
rem PteAddress == PXE_BASE + s*8 (v25 compared the wrong slot, so
rem B always missed); selfOk is now a BITMASK (bit0 = the PTE
rem space LIVE; bit1 = self frame == System CR3 - EXPECTED 0 in
rem the trigger-script caller context); the PtRd64 range gate is
rem wrap-free (s=0x1FF). Host-proven 101/101 on a TRUE-SEMANTICS
rem world (a REAL 4-level hierarchy + an independent hardware
rem walk - the v25 world shared the engine's wrong formulas,
rem which is why 89/89 passed while the VM died) + TWO class-
rem kills (the v25 engine dies at 0xFFFFD58000000D58 = the exact
rem field read; redacted constants = 15 clean fails); disasm-
rem verified; bench A 13/13 + B 5/5. Test script:
rem trigger-test-v35.ps1 (full K/L/M/J/W regression + the
rem cap-aware W2 + the P ladder with the LIVE selfOk semantics).
rem
rem DRIVER SIZE: v26-RT = 140582 bytes (sha256 c8f79b95...).
rem v25-RT = 141154 (THE F4 BSOD BINARY - DO NOT RUN); v24-RT =
rem 134842 (no page tables: op 12 answers ErrUnsupported(8));
rem v23-RT/v22-RT = BOTH 134330. The bat's pre-flight 1b/1c
rem check size + hash.
rem ============================================================
rem INFINITY Phase D v25 (historical): v24 + THE PAGE-TABLE WALK (F4). The
rem v32 field run (2026-09-27 21:09) PROVED F3 IN SUBSTANCE -
rem W1 all-PASS (eproc=0xFFFFDC89140BF080 canonical OUT-OF-IMAGE
rem via the deref chain, System pid 4 at eproc, names live at
rem +0x5A8, 64 procs/236 pages), W4/W5 clean, 6th consecutive
rem F1/F2 green, zero crashes. The single FAIL was the W2 count
rem tolerance - root-caused to a SCRIPT-side cap-blind
rem calibration (the walk stops at 64 BY DESIGN; this VM ran
rem 102 live). Driver v24 is INNOCENT.
rem
rem v25 ADDS op 12 TranslateVa: VA -> page-table walk through
rem the SELF-MAP (no CR3 switching - the v17/v19 lesson; no
rem physical reads; no kernel calls). PTE_BASE discovery by TWO
rem ordered chains: A = nt!MmPteBase (.data, RVA candidates
rem from 19 real 19041/19045 PDBs) + the 512-value structural
rem check - A gates ALL out-of-image reads, so a drifted patch
rem level refuses CLEANLY (VM alive); B = the PFN bootstrap
rem (MmPfnDatabase -> System CR3 from EPROCESS+0x28 ->
rem _MMPFN.PteAddress -> the s-identity); A and B must AGREE.
rem THE TWO-WAY PROOF: PML4E[s] must point at the System CR3
rem frame - the page tables and the EPROCESS validate each
rem other. Host-proven 89/89 incl. the T26 drifted-world and
rem T32 absent-parent class-kills; disasm-verified; bench A
rem 13/13 + B 5/5. Test script: trigger-test-v35.ps1 (full
rem K/L/M/J/W regression + the CAP-AWARE W2 fix + the P ladder
rem P1..P7 with the two-way proof + the DTB cross-check).
rem
rem DRIVER SIZE: v25-RT = 141154 bytes (sha256 022e6d1c...).
rem v24-RT = 134842 (no page tables: op 12 answers
rem ErrUnsupported(8)); v23-RT/v22-RT = BOTH 134330. The bat's
rem pre-flight 1b/1c check size + hash.
rem ============================================================
rem INFINITY Phase D v24 (historical): v23 + THE DEREF FIX. The v31 field
rem run (2026-09-27 19:51) PROVED the v23 export fix - M1..M4
rem all green (M1 == the v29 value, M4 the correct rc=7), F1+F2
rem re-proven for the 5th time, J 100%, INFCNT 31 exact - but
rem the WALK still refused: payload status=4 (not-System),
rem walk=0, serial [PW] sys=0xFFFFF8071A4FC420. ROOT CAUSE:
rem op 11 passed the RESOLVED SYMBOL VA to the walk.
rem PsInitialSystemProcess is a POINTER VARIABLE in ntoskrnl
rem .data - *(u64*)slot is the System EPROCESS, a pool object
rem OUTSIDE the image. v24 derefs the slot via the same gated
rem in-image reads (no new trust root) and walks from the true
rem EPROCESS. Host-proven 66/66 incl. the T23 chain class-kill
rem (a deref-less build can never pass it), disasm-verified
rem (Resolve call -> range gate -> budget gate -> Rd32 -> the
rem [PW] eproc trace), bench A 13/13 + B 5/5. Test script:
rem trigger-test-v35.ps1 (the same wire steps as v31; the W1
rem success expectations corrected to the v24 semantics).
rem
rem DRIVER SIZE: v24-RT = 134842 bytes (sha256 f8a01814...).
rem v23-RT and v22-RT are BOTH 134330 (v23 = the missing deref:
rem W refuses status=4 not-System; v22 = additionally refuses
rem every M). The bat's pre-flight 1b/1c check size + hash.
rem ============================================================
rem INFINITY Phase D v23 (historical): v22 + THE ONE-CONSTANT FIX. The v30
rem field run (2026-09-27 17:50) was F1-green + J-matrix 100% on
rem the v22 binary, but EVERY M/W resolve refused rc=4 /
rem resolve-failed. ROOT CAUSE (disassembly of the field-proven
rem v21 binary @10fbb): the export-size gate's true bound is
rem 0x100000 (1 MiB), not 0x10000 - the hand-RE dropped a zero
rem and v22 coded it. ntoskrnl 19045's export directory (~0x12000
rem bytes) tripped the wrong 64 KiB bound. Fail-closed held
rem everywhere: zero crashes, all negatives clean. v23 = v22 +
rem 0x10000 -> 0x100000 + banners; wire contract UNTOUCHED.
rem Host-proven 55/55 (incl. the NEW realistic-directory
rem class-kill that FAILS on v22 by construction), bench-proven
rem A 13/13 + B 5/5. Test script: trigger-test-v31.ps1 (the same
rem K/L/M/J/W steps as v30; only the driver-ID texts changed).
rem
rem CAUTION: v22-RT and v23-RT are BOTH 134330 bytes. Only the
rem sha256 tells them apart: v23 = d7562a7d...7c5e8 (GO) /
rem v22 = 276b744c...cb9cc2 (REFUSE - the gate bug). The bat's
rem pre-flight 1c checks the hash automatically.
rem ============================================================
rem INFINITY Phase D v22 (historical): boot installed Windows WITH the v22 RT
rem build (EARLY gRT hooks + DIRECT KUSD reads + THE ANCHOR STACK
rem + THE CONTAINING-WALK + THE EXPORT RESOLUTION + THE EPROCESS
rem WALK). v22 keeps the ENTIRE v21 contract (ops 1/2/7/9/10, the
rem three-window read gate, the K/L/M/J wire) and adds op 11
rem (ReqOp_ProcessWalk): from the F2-resolved
rem PsInitialSystemProcess the driver walks ActiveProcessLinks
rem with double-link LIST_ENTRY consistency, canonical-VA gates,
rem a +-4 GB pool-cluster window, 64-entry / 256-page budgets and
rem LIVE name-slot discovery. Reads OUTSIDE the validated image
rem for the first time - every refusal a clean status, the VM
rem alive (the v19 name-hunting death class is structurally
rem impossible). Test script: trigger-test-v30.ps1 (W steps +
rem the full K/L/M/J regression re-proving F1+F2 on v22).
rem
rem v30 KIT (2026-09-27): driver v22 = v20-source + the RE-DERIVED
rem v21 export machinery (the lost v21 patch was reverse-engineered
rem from the field-proven binary - kx::Rd32 + op-10 decoded to the
rem byte; wire contract IDENTICAL to v28/v29) + ProcessWalk + op 11.
rem Host-tested 43/43 (zero out-of-map reads), bench-validated A+B.
rem The v21 binary (131709) remains the rollback anchor.
rem
rem INFINITY Phase D v21 (historical):
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

rem ---- pre-flight 1: the trigger test script must be v35 ----
if not exist usb-d\trigger-test-v35.ps1 (
  echo [ERROR] usb-d\trigger-test-v35.ps1 not found.
  echo The package ships it pre-placed in usb-d. Re-extract the
  echo full package zip over this folder - do not copy scripts by hand.
  pause
  exit /b 1
)
findstr /I /C:"trigger test v35" usb-d\trigger-test-v35.ps1 >nul 2>&1
if errorlevel 1 (
  echo [ERROR] usb-d\trigger-test-v35.ps1 is NOT the v35 script.
  echo A STALE v34 COPY IS THE SECOND-BSOD SCRIPT: its P1 sends
  echo op-12 - the op that killed the VM twice ^(chain B derefs a
  echo garbage MmPfnDatabase: pdb + pfn*0x30 + 8, fingerprint-proven^).
  echo DO NOT RUN THE v34 SCRIPT. Replace it with the v35 script
  echo from this package ^(v35 never sends op-12^).
  pause
  exit /b 1
)
echo [Phase D] trigger-test-v35.ps1 verified - pre-placed on the boot disk.

rem ---- pre-flight 1b: DRIVER SIZE GUARD (v26-RT = 140582) ----
set DRIVERSIZE=
for %%A in (usb-d\memory.efi) do set DRIVERSIZE=%%~zA
if not "%DRIVERSIZE%"=="140582" (
  echo [ERROR] usb-d\memory.efi is %DRIVERSIZE% bytes - that is NOT
  echo the v26 RT driver ^(v26-RT = 140582 bytes^).
  if "%DRIVERSIZE%"=="120678" (
    echo That size is the v17 RT driver. The v30 ladder with the
    echo v17 driver WILL KILL THE VM ^(the v20 crash class - the old
    echo kernel read switches CR3 to the boot firmware tables^).
  ) else (
    if "%DRIVERSIZE%"=="121253" (
      echo That size is the v18 RT driver ^(no anchors^). The v30 K/L
      echo steps cannot run ^(op 9 unsupported - fail-closed^); only
      echo the J regression would work. Replace with the v22 driver.
    ) else (
      if "%DRIVERSIZE%"=="125450" (
        echo That size is the v19 RT driver ^(anchors, but the walk
        echo stops at the FIRST valid PE - the v25 field run hit
        echo the nested-PE trap and fail-closed^). Only the v20+
        echo containing-walk converges on the true image.
      ) else (
        if "%DRIVERSIZE%"=="128010" (
          echo That size is the v20 RT driver ^(F1-proven, but no
          export resolution^): the K/L/J steps run green, the M
          steps cannot ^(op 10 answers ErrUnsupported^).
        ) else (
          if "%DRIVERSIZE%"=="131709" (
            echo That size is the v21 RT driver ^(the F2 field-proven
            echo build^): the whole K/L/M/J regression runs green but
            echo step W cannot run ^(op 11 answers ErrUnsupported - a
            echo clean refusal, never a crash^). Replace with the v26
            echo driver for the v35 recon + dump steps.
          ) else (
            if "%DRIVERSIZE%"=="141154" (
              echo That size is the v25 RT driver - THE F4 BSOD
              echo BINARY: the v33 field run died 0x50 on op-12's
              echo first PTE-space read ^(the upper-level slot
              echo formulas were wrong - low-USER slots^). DO NOT
              echo RUN IT AGAIN. Replace with this package's v26.
            ) else (
              if "%DRIVERSIZE%"=="134842" (
                echo That size is the v24 RT driver ^(deref-fixed, but NO
                echo page tables^): op 12 answers ErrUnsupported^(8^) - the
                echo P ladder can never run. Pre-flight 1c confirms by hash.
              ) else (
                if "%DRIVERSIZE%"=="134330" (
                  echo That size is the v23 or v22 RT driver ^(both 134330^):
                  echo v23 = the MISSING-DEREF bug - the v31 field run had
                  echo M1..M4 green but W refused payload status=4 not-System
                  echo with walk=0 ^(fail-closed, no crash^); v22 =
                  echo additionally refuses every M resolve. Pre-flight 1c
                  echo names which one you have.
                ) else (
                  echo Unknown driver build. Only the v26 RT driver runs
                  echo the v35 R/D steps.
                )
              )
            )
          )
        )
      )
    )
  )
  echo Fix: copy memory.efi from this package over usb-d\memory.efi,
  echo then run phase-d.bat again.
  pause
  exit /b 1
)
rem ---- pre-flight 1c: HASH GUARD (names the exact driver build) ----
set ISV26=0
set ISV25=0
set ISV24=0
set ISV23=0
set ISV22=0
certutil -hashfile usb-d\memory.efi SHA256 > "%TEMP%\inf-drv-hash.txt" 2>nul
findstr /I /C:"c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb" "%TEMP%\inf-drv-hash.txt" >nul 2>&1 && set ISV26=1
findstr /I /C:"022e6d1c01fb7de7704182bcf230062905c58f5d8677e1b75cdd0582609b398b" "%TEMP%\inf-drv-hash.txt" >nul 2>&1 && set ISV25=1
findstr /I /C:"f8a01814f4ffeb9a9b1595a722c733b0dbf92d5eb5710b25d88d7818dbcf5846" "%TEMP%\inf-drv-hash.txt" >nul 2>&1 && set ISV24=1
findstr /I /C:"d7562a7dddc4227844036f7e397f1580338be74015715419b757bfac0577c5e8" "%TEMP%\inf-drv-hash.txt" >nul 2>&1 && set ISV23=1
findstr /I /C:"276b744c069389aa1d3ee649be56a4ee1e4ff0292ca8475af7529e9cf1cb9cc2" "%TEMP%\inf-drv-hash.txt" >nul 2>&1 && set ISV22=1
del "%TEMP%\inf-drv-hash.txt" >nul 2>&1
if "%ISV26%"=="1" (
  echo [Phase D] memory.efi verified - v26 RT build ^(140582 bytes, sha256 c8f79b95...^).
) else (
  if "%ISV25%"=="1" (
    echo [ERROR] usb-d\memory.efi is the v25 driver ^(141154 bytes,
    echo sha256 022e6d1c...^) - THE F4 BSOD BINARY: the v33 field
    echo run died 0x50 PAGE_FAULT_IN_NONPAGED_AREA on op-12's first
    echo PTE-space read ^(the upper-level slot formulas addressed
    echo low-USER slots; the self-ref read walked PML4E[0] of the
    echo caller process - absent in the trigger script context^).
    echo DO NOT RUN IT AGAIN - replace with this package's v26.
    pause
    exit /b 1
  ) else (
    if "%ISV24%"=="1" (
      echo [ERROR] usb-d\memory.efi is the v24 driver ^(134842 bytes,
      echo sha256 f8a01814...^). v24 is the deref-fixed F3 build but has
      echo NO PAGE TABLES: op 12 answers ErrUnsupported^(8^) - the P
      echo ladder can never run ^(the K/L/M/J/W regression still would^).
      echo Fix: copy this package's memory.efi over usb-d\memory.efi.
      pause
      exit /b 1
    ) else (
      if "%ISV23%"=="1" (
        echo [ERROR] usb-d\memory.efi is the v23 driver ^(134330 bytes,
        echo sha256 d7562a7d...^). v23 has the MISSING-DEREF bug: the v31
        echo field run proved its export fix ^(M1..M4 green^) but the walk
        echo refused - op 11 walked from the PsInitialSystemProcess SYMBOL
        echo VA instead of the EPROCESS it points at ^(payload status=4
        echo not-System, walk=0 - fail-closed, no crash^). F3 can never
        echo prove on v23.
        echo Fix: copy this package's memory.efi over usb-d\memory.efi.
        pause
        exit /b 1
      ) else (
        if "%ISV22%"=="1" (
          echo [ERROR] usb-d\memory.efi is the v22 driver ^(134330 bytes,
          echo sha256 276b744c...^). v22 has the export-size gate bug
          echo ^(0x10000 instead of 0x100000^): the v30 field run refused
          echo EVERY M/W resolve with rc=4 / resolve-failed - fail-closed,
          echo no crash, but F2/F3 can never prove on v22.
          echo Fix: copy this package's memory.efi over usb-d\memory.efi.
          pause
          exit /b 1
        ) else (
          echo [ERROR] the sha256 matches NEITHER v26 ^(c8f79b95...^) NOR
          echo v25 ^(022e6d1c...^) NOR v24 ^(f8a01814...^) NOR v23
          echo ^(d7562a7d...^) NOR v22 ^(276b744c...^) - unknown build.
          echo Replace usb-d\memory.efi with this package's v26 driver.
          pause
          exit /b 1
        )
      )
    )
  )
)

rem ---- pre-flight 2: usb-d must stay pristine ----
for %%E in (qcow2 vhd vhdx vmdk iso wim img raw zip rar 7z exe msi) do (
  if exist "usb-d\*.%%E" (
    echo [ERROR] usb-d contains *.%%E files - disk images, zips or
    echo programs do not belong on the boot disk. usb-d must contain
    echo ONLY: EFI  memory.efi  startup.nsh  trigger-test-v30.ps1
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
    echo   EFI  memory.efi  startup.nsh  trigger-test-v35.ps1
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
echo [Phase D] package v26/v35 - Windows + memory.efi v26 RT boot test ^(F4 RECON + THE .data DUMP: op-12 retired after the 2nd 0x50 - the constant recon + the ground-truth capture, all through the proven image gate^). Mode %MODE%.
echo [Phase D] The banner must say: memory.efi v26 RT ^(kernel data path: direct reads + export resolution + process walk + page tables^).
echo [Phase D] Watch for these milestone lines in serial-phase-d.log:
echo [Phase D]   [INF][RT-EARLY] gRT hooks INSTALLED at load time
echo [Phase D]   [INF][EBS] ExitBootServices hook FIRED   ^(stage 2^)
echo [Phase D]   [INF][VA]  SetVirtualAddressMap ... FIRED ^(stage 3^)
echo [Phase D]   [INF][BLD] live windows build ^(ofs 0x260^)=19045
echo [Phase D]   [INF][HOOK] S OURVAR delete  ^(script canaries + cleanup^)
echo [Phase D]   [INF][RD] mapped va=...  +  mapped read ok=1  ^(THE LADDER^)
echo [Phase D]   [INF][PW] sys=... + walk=N + closed=N  ^(THE F3 WALK, step W^)
echo [Phase D] After the desktop loads do NOT close the VM:
echo [Phase D]   1. inside Windows open PowerShell as Administrator
echo [Phase D]   2. run the trigger test from the boot disk:
echo [Phase D]        D:\trigger-test-v35.ps1
echo [Phase D]      Its FIRST line must say: trigger test v35.
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
echo   2. send the trigger-test-v34 output .txt ^(Desktop, via transfer stick^)
echo   3. if the VM died: also send a photo of the last screen + the
echo      step-0 post-mortem printout of the NEXT run
echo   4. tell me which mode number you used
pause
