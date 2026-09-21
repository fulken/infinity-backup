# Worklog — Infinity Project

---
Task ID: 2
Agent: Super Z (main)
Task: Answer user's QEMU setup questions; build and validate the QEMU/OVMF test bench for memory.efi (Phase A + Phase B-lite)

Work Log:
- User asked: does Phase A need Windows? (No — OVMF's EFI Shell suffices) and QEMU/OVMF install order (OVMF is a firmware file, bundled in our package)
- Cloned repo @ uefi-full-migration (a8e41b3), rebuilt baseline memory.efi with gnu-efi 3.0.13 (jammy, CI-matching)
- Built a full no-root QEMU 10.0.11 + OVMF test bench in the sandbox (extracted .debs, resolved libs)
- Created USB ritual replica (BootKit shell + startup.nsh + memory.efi) as QEMU virtual FAT
- Added INFDIAG instrumentation (32-byte NV variable: stage/flags/build/cr3/calls) + scripts/check_diag.py (parses VARS pflash)
- Phase A first run: #GP crash at load — began root-cause analysis:
  - R1: 8 undefined symbols (C++ mangling of gnu-efi functions; no extern "C" in 3.0.13 headers) → wrapped all 9 include sites
  - R2: entry named EfiMain, crt0 wants efi_main → renamed
  - R3: gInfinityMemVarGuid defined global-scope but declared inside namespace UEFIBridge → moved into namespace
  - R4: GLOB_DAT relocs never applied by _relocate (C++ vague-linkage GOT) → -fvisibility=hidden → zero GLOB_DAT
  - R5: crt0 calls efi_main SysV (not EFIAPI) and never calls InitializeLib; ST/BS/RT were garbage → plain-SysV efi_main + InitializeLib call (diagnosed via QMP disassembly: crash in PrintBanner's ClearScreen, RIP=0xB0000 from BDA garbage)
  - R6: C++ named .bss._ZN... sections orphaned OUTSIDE the PE by upstream lds (RuntimeHook::instance_ write hit foreign memory, #PF) → vendored gnuefi-x86_64.ld with .bss* wildcards
- PHASE A GREEN: banner prints, shell reports Success, INFDIAG stage=1 written
- Phase B-lite (Alpine 3.22.2 ISO): boot order fixed via bootindex; FS mappings solved (FS1=disk, FS0=cd)
- B-lite with old EBS-time hook install: Linux hangs pre-console → bisected to gRT hook install
- Reworked: hooks install from EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE (InstallVirtual) + ConvertPointer graph conversion (ConvertPtr.h + ConvertPointers() on all classes)
- Forensics (physical trace array read via QMP xp): event fires BEFORE firmware converts gRT slots (order B); raw hook addresses written at event time end up CORRECTLY converted in final table (verified via physical + virtual dumps of gRT); yet kernel hangs in early calibration loop without ever calling hooks; -smp 2 no help
- PARKED: hook install gated behind INFINITY_ENABLE_RUNTIME_HOOKS (default off, conservative). Safe path (EBS hook, CR3 capture, build detect, conversions) verified boot-safe on Linux
- Final verification run: module loads + Linux boots + stage=1 ✓
- Committed locally: 03a322c (11 files, +389/-32). NOT pushed — awaiting user go-ahead
- Built user package: download/infinity-qemu-test-v1.zip (phase-a.bat / phase-b.bat / phase-b-check.bat + OVMF firmware + usb ritual + Persian README)

Stage Summary:
- 6 real startup blockers fixed (all would have crashed on first real boot; CI never executed the binary)
- Phase A fully validated in QEMU/OVMF; B-lite validated for EBS/VA safety
- Open problem (documented in commit): QEMU/Linux hangs post-SetVirtualAddressMap when gRT hooks present despite correct final table state — must verify on real Windows target
- User's next step: install QEMU on their Windows 10 22H2 machine, run phase-a.bat then phase-b.bat with a Win10 ISO, send back serial logs + dmpstore photo

---
Task ID: 3
Agent: Super Z (main)
Task: Diagnose user's failed Phase B (Windows install never started) and deliver fixed package v2

Work Log:
- User reported: dragged Win10 AIO 22H2 ISO (soft98, 19045.7663 x64) onto phase-b.bat, install never started. User's uploads received in upload/: serial-phase-a.log (GREEN: INFINITY banner + Image loaded Success) and serial-phase-b.log (FAILED: load FS0:\memory.efi -> File not found; shell sat at prompt forever)
- Root cause analysis from serial-phase-b.log:
  - Bug 1: packaged usb/startup.nsh hardcoded FS0:; with the Windows CD attached, FS0 = CD (El Torito), ritual FAT shifted to FS2 -> "File not found"
  - Bug 2: packaged startup.nsh had NO OS-launch command at all (sandbox B-lite had it, packaged one didn't) - the README promise "Windows boots automatically" was never validated with a real Windows ISO
  - Bug 3: phase-b.bat was a smoke test, not an installer: no hard disk (only 512MB FAT), -no-reboot kills the VM at the installer's first reset, vars reset every run
  - User's ISO is FINE: CD mapped with El Torito UEFI entry in their log (soft98 AIO is UEFI-bootable)
- Sandbox re-validation of the phase-C mechanism (scripts/test-phase-c.sh, test-phase-c3.sh):
  - for-loop in .nsh BREAKS after `load memory.efi` (extra iterations, orphan endif/endfor executed as commands, loop vars unreliable) - EDK2 shell script re-seek quirk
  - Direct (non-loop) `if exist` + launch keep working post-load (proven with probes)
  - DESIGN: flat if-exist chains FS0..FS4 for both driver load and bootmgfw launch - no for loops
  - Validated end-to-end twice (incl. final run with the EXACT shipped usb-c/startup.nsh): driver loads from shifted mapping (FS1), \EFI\Microsoft\Boot\bootmgfw.efi found post-load on fake-ESP disk, launched, returned cleanly
- Built package v2 (infinity-qemu-test/):
  - phase-b.bat REWRITTEN as real Windows installer: qcow2 64G disk (qemu-img, bootindex=0), ISO CD (bootindex=1), NO usb ritual, no -no-reboot, persistent NVRAM (if-not-exist copy), WHPX-first with TCG fallback, -cpu max -smp 4 -rtc localtime, e1000e+user net, usb-tablet
  - phase-c.bat NEW: boots installed Windows WITH driver (usb-c FAT bootindex=0 bus=ide.1, win10.qcow2 bootindex=1 bus=ide.0, -no-reboot for diagnostics, serial-phase-c.log)
  - usb-c/ NEW: copy of ritual + validated flat startup.nsh
  - phase-a.bat: one-line fix (vars copy only if missing) to protect installed Windows NVRAM entry
  - README-FA.md rewritten (v2 flow, WHPX + GameLoop warning, press-any-key warning)
  - All .bat/.nsh CRLF-verified
- Delivered: download/infinity-qemu-test-v2.zip (2.8MB)

Stage Summary:
- Phase A: confirmed GREEN on user's real machine (their log)
- Phase B v1 failure was 100% package design bugs, not user's ISO/machine - ISO validated UEFI-bootable from their log
- Phase-C mechanism fully re-validated in sandbox with the exact shipped files
- User next: install Windows via phase-b.bat (drag ISO, press key at CD prompt), then phase-c.bat, then phase-b-check.bat; send INFDIAG photo + serial-phase-c.log
- Open: phase C is the first real test of the EBS/CR3/build-detect chain against a Windows kernel - hang/BSOD is a valid (and important) result to report

---
Task ID: 4
Agent: Super Z (main)
Task: Diagnose user's Phase B install BSOD (IRQL_NOT_LESS_OR_EQUAL) and deliver fixed package v3

Work Log:
- Received user's infinity-qemu-test-Report.zip; analyzed 3 screenshots (VLM) + 2 serial logs
- Findings: BSOD IRQL_NOT_LESS_OR_EQUAL during "Getting files ready" (install.esd apply phase); crash point NONDETERMINISTIC (try1 stuck 0%, try2 died 16%) => race condition in virtualization layer, NOT bad ISO (deterministic) and NOT our driver (memory.efi not loaded in phase B - no banner in serial log, no .sys named on BSOD, file-copy phase completed 100% both times)
- Serial log confirms: GPT partitions created (ESP+MSR+Win) but no boot files on ESP when crashes happened; boot fell HDD->DVD->(timeout)->EFI Shell on last cycle
- Root cause candidates ranked: (1) v2's "-cpu max" with WHPX advertising CPU features WHPX cannot virtualize (APIC/timer) -> IRQL violation under heavy apply load; (2) 4 vCPUs amplifying interrupt races; (3) e1000e NIC extra MSI device. ISO corruption demoted (evidence against)
- Built v3 (infinity-qemu-test/):
  - phase-b.bat v3: WHPX now uses -cpu host (WHPX-canonical model); accel menu [1] WHPX 2 cores / [2] WHPX 1 core / [3] TCG (arg or interactive); -nic none during install; fresh-disk menu (default F = delete old disk+NVRAM after BSOD); BSOD decision-tree printed at exit; WHPX->TCG auto-fallback only on startup failure
  - phase-c.bat v3: same accel menu + -cpu host + -smp 2/1 + -nic none; README note: use SAME mode that installed Windows (fair driver test)
  - README-FA.md v3: full BSOD analysis, decision tree table (mode 1 -> 2 -> 3 -> ISO guilty), updated troubleshooting incl. benign hr=80370300 + Gtk warnings
- Sandbox validation (scripts/validate-v3.sh, qemu 10.0.11 + our OVMF, -m 1024):
  - CRLF verified both .bat (0 non-CRLF lines); batch lint clean (no raw pipes, balanced parens)
  - phase-b TCG command verbatim: boots exactly HDD-first->CD-fallback (BdsDxe lines match intent)
  - phase-c TCG command verbatim: full ritual green - startup.nsh runs, memory.efi loads (Success), correct "Windows not found" on empty disk
  - smp1 wiring variant: parses + runs
- Package: download/infinity-qemu-test-v3.zip (2.8MB, 26 files)
- Fixed sandbox qemu-img gap: downloaded qemu-utils deb -> qemu-utils-root/ (for future disk creation)

Stage Summary:
- Phase B v2 BSOD fully diagnosed: virtualization race, prime suspect -cpu max under WHPX; driver and ISO cleared with evidence
- v3 delivered with mode ladder 2cores->1core->TCG; if even TCG BSODs => ISO verdict (user gets clean ISO next)
- User next: run v3 phase-b.bat mode 1; on BSOD walk the ladder; after desktop -> phase-c.bat same mode -> phase-b-check.bat; send INFDIAG photo + serial-phase-c.log + mode number

---
Task ID: 5-6 (RECOVERED RECORD — work done in sessions whose disk writes were lost; reconstructed from user-side evidence + summary)
Agent: Super Z (main)
Task: v4 package + 3-user test analysis + v5 RT build + phase-d delivery + repo fetch infrastructure

Work Log:
- v3 SAFE delivered -> 3-user test (upload/Windows-Reports.zip, extracted2/): WHPX BSOD even in v3 mode1/2 -> install via TCG (mode 3); OOBE "Why did my PC restart" loop bypassed via registry (SystemSetupInProgress=0 etc.); network healthy; local user creation OK; Phase C with TCG: memory.efi loaded (v3 SAFE, INFDIAG stage 1 only, as designed); phase-b-check initially showed "No matching variables found" (GUID bug) — manual dmpstore with -guid A1B2C3D4-E5F6-4789-9ABC-DEF012345678 read it.
- v4 launcher fixes (from that session): removed -fw_cfg X-Cpuhp-Bitmap (48GB RAM bug), removed -cpu host,-hypervisor, added -R flag.
- v5: first RT build (INFINITY_ENABLE_RUNTIME_HOOKS=1), banner "Build: RT - runtime hooks ENABLED (phase D)", INFDIAG v5 32-byte semantics (stages 1-4), hooks installed from EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE; phase-d.bat (phase-c pattern with RT ritual) + v5 check script; delivered with method: run phase-d -> wait desktop -> shutdown from inside Windows -> phase-b-check.
- Repo fetch infrastructure (fetch-infinity-repo.sh + backups/ + workspace commit 3b82a47) — ALL LOST in a session-rollback (disk state reverted to v3-era commit 748aadb; the worklog entries and v4/v5 artifacts never persisted). The v5 package lives only on the user's machine.

Stage Summary:
- KEY USER RESULT (ReportV5, upload/infinity-qemu-test-ReportV5.zip): RT build booted Windows 10 19045 to the desktop with NO BSOD and NO hang; INFDIAG final = stage 3, flags=1, win_build=0, os_cr3=0. Stage 2 (EBS capture) and stage 4 (hook called by Windows) never recorded. Sandbox Linux-hang fear did NOT reproduce on Windows.
- Lesson recorded: session file writes are not durable — every deliverable must be committed to the workspace git repo immediately.

---
Task ID: 7
Agent: Super Z (main)
Task: Analyze ReportV5; refetch the repo with the admin token (permanent cache); rebuild the entire lost source state as v6 with serial-port diagnostics; sandbox-validate; deliver v6 package

Work Log:
- Analyzed ReportV5: serial-phase-d.log (RT banner + Windows booted from FS0) + serial-check.log (INFDIAG 44 46 4E 49 03 00 00 00 01 00 00 00 = stage 3, flags 1, rest zero) + 2 PNGs via VLM (confirmed logs; also caught the v5 check-script echo flag bug: EDK2 shell rejects '+'/'-' args -> some legend lines printed "Unknown flag").
- Refetched the repo: scripts/fetch-infinity-repo.sh (ephemeral Authorization header; token never on disk; leak checks pass) -> /home/z/my-project/infinity-repo @ uefi-full-migration a8e41b3 (340 commits). Permanent cache: backups/infinity-uefi-full-migration-a8e41b3-20260918-193519.bundle (533M) + tarball (574M) + README.md (tokenless recovery). Too big for the workspace repo -> bundle/tarball/clone gitignored, patches + scripts committed instead.
- Rebuilt the full lost source state on the fresh clone (patch: patches/v6-on-a8e41b3.diff, 13 files +935/-215):
  R1 extern-C wraps (scripts/wrap_extern_c.py on 6 headers), R2/R5 efi_main plain-SysV + InitializeLib, R3 gInfinityMemVarGuid into namespace, R4 -fvisibility=hidden, R6 vendored gnuefi-x86_64.ld with .bss* wildcards.
  NEW v6: include/SerialTrace.h (raw 0x3F8 outb tracing, works in every CPU/firmware mode), include/Diag.h (INFDIAG v6: 32B magic/stage/flags/win_build/os_cr3/hook_calls/last_status + g_diag_busy re-entrancy guard), include/ConvertPtr.h (ConvertPointersAll: graph + orig_* + RT/ST last), RuntimeHook::InstallVirtual (hooks into gRT while slots still physical — order B — firmware converts them), CR3Capture EBS hook full tracing, ConvertSelf on RequestHandler/ProcessFinder/ProcessMemory/SharedMemoryPool, Makefile RT=1 variant + R4/R6 checks, memory-map + LoadedImage type diagnostics in efi_main.
- Built clean (gnuefi-jammy 3.0.13, CI-matching): v6 SAFE (80275B) + v6 RT (114650B), zero GLOB_DAT, zero orphan .bss, no warnings.
- Sandbox validation (scripts/test-v6-linux.sh + iso_extract.py — extracted Alpine 6.12.51-virt EFI-stub kernel + initramfs, booted directly from the EFI shell to dodge GRUB's stuck menu):
  * SAFE: EBS hook FIRED -> orig EBS SUCCESS -> os_cr3=0x3FC01000 -> stage 2 write st=0x0 SUCCESS; kernel SVAM -> VA event -> conversions all st=0x0; Linux booted CLEAN to initramfs busybox shell. FULL GREEN.
  * RT: same EBS/VA chain green, stage 3 written; kernel's first RT call (efi_delete_dummy_variable -> SetVariable) jumped to our HookedSetVariable virtual 0xFFFFFFFEFF6B5640 -> #PF "kernel tried to execute NX-protected page". Our image region IS properly typed (LoadedImage ImageCodeType=5 EfiRuntimeServicesCode, descriptor type=5 attr=RUNTIME|cache, same 1MB descriptor as the firmware's own RT code which executes fine) -> Linux 6.12 maps our pages NX while executing the firmware's — Linux-specific exec-permission behavior, root of the old "Linux hang". Fix path identified for v7 if Windows shows the same: copy image into self-allocated EfiRuntimeServicesCode pages.
- check_diag.py updated to v6 field semantics (validated against real sandbox runs; NVRAM varstore appends -> multiple entries, LAST is current).
- Package v6 (download/infinity-qemu-test-v6.zip, 33 files): new phase-d.bat (RT + serial capture + trigger instructions), trigger-test.ps1 (elevated P/Invoke GetFirmwareEnvironmentVariableW on INFDIAG, double-read trick: if stage bumps to 4 between reads the hook chain is ALIVE), fixed usb-check startup.nsh (v5 echo bug), updated phase-b-check.bat, usb-d/ RT ritual, v6 SAFE deployed to usb/ + usb-c/, README-FA.md v6 (trace guide, stage table, outcome interpretation). All .bat/.ps1 CRLF-verified, phase-d lint clean, deployed-files smoke test GREEN (banner + full [INF] chain + INFDIAG stage 1).

Stage Summary:
- v5 verdict: partial success — RT hooks install cleanly on real Windows (stage 3) without breaking boot; the missing stage 2/4 needed instrumentation, not guesses.
- v6 = v5 + nothing-can-fail-silently: serial [INF] traces through EBS/VA/CVT/HOOK + last_status + Windows-side trigger test. Sandbox-proven on a real OS boot (Linux: stages 1-2-3 all written SUCCESS; SAFE fully green; RT documented NX limitation on Linux).
- User next: phase-d.bat -> desktop -> trigger-test.ps1 (elevated PS inside VM) -> shutdown from Windows -> phase-b-check.bat -> send serial-phase-d.log + INFDIAG photo + trigger output + mode number.
- Open: (a) does Windows map our RT-code pages executable? (BSOD/trace will tell), (b) v7 = image-copy-into-RT-code-pages if needed, (c) Phase D green -> Infinity.exe UEFIVariableBridge integration.

---
Task ID: 8
Agent: Super Z (main)
Task: Analyze user's v6 phase-D report (trigger test v7/v8, error 87); root-cause; build + validate + deliver v7

Work Log:
- Extracted upload/infinity-qemu-test-v6-Report.zip (debug report + serial-phase-d.log + trigger-test-v7/v8.ps1 + 3 screenshots)
- Serial analysis: v6 RT booted Windows FULLY GREEN through stage 3 (EBS FIRED with os_cr3 + build, VA FIRED, hooks installed, all conversions st=0). First time stages 1-3 all recorded on real Windows.
- KEY FINDING (architectural): user's v8 INFDIAG read from inside Windows SUCCEEDED twice (correct Get marshaling) yet ZERO [INF][HOOK] serial lines and stage stayed 3 => Windows never called through our hooked gRT slots. Conclusion: winload snapshots the runtime services table BEFORE SVAM and translates it itself; hooks installed at the VA event (v6) are invisible to the OS. (Linux uses the live table — explains sandbox divergence.)
- ERROR 87 root cause (script): v8 declared SetFirmwareEnvironmentVariable as (name, buffer, size, guid); real order is (name, guid, value, size) => lpGuid received the payload pointer => GUID parse failed => ERROR_INVALID_PARAMETER before the call ever reached the kernel. Also 'INFTRIGGER' is not a driver variable (driver: InfinityReq/InfinityResp/InfinityData). User's privilege fix (v7 script, correct LUID_AND_ATTRIBUTES) confirmed correct and kept.
- Environment recovery: infinity-repo + backups were LOST again (session rollback); refetched via scripts/fetch-infinity-repo.sh (a8e41b3, 340 commits; bundle+tarball recreated). Applied patches/v6-on-a8e41b3.diff. Rebuilt vendored gnuefi-x86_64.ld from gnuefi-jammy 3.0.13 (R6 .bss* wildcards) — this time force-added into the patch (UEFI/build is gitignored; that is why it was missing before).
- v7 driver changes: RuntimeHook::InstallEarly() (hooks into gRT at efi_main, pre-bootmgr => winload snapshot contains our pointers; both translation paths agree on final VA); InstallVirtual() no-ops when already installed; HookEnter() splits BOOT-CTX (pre-va_done: trace-only passthroughs) from OS-runtime calls (post-va_done: stage 4 + hook_calls + DiagWrite); flags bit 0x8 = early hooks; banner v7 RT 'EARLY gRT hooks (phase D2)'.
- Built clean: v7 SAFE 104457B + v7 RT 115838B (zero GLOB_DAT, no orphan .bss). Saved as patches/v7-memory-SAFE.efi / v7-memory-RT.efi.
- Sandbox validation (scripts/test-v7-linux.sh; fixed iso extraction — pycdlib gone, used committed scripts/iso_extract.py; ';1' paths must be quoted):
  * SAFE: full green (load, stage 1, EBS stage 2, VA conversions clean, Linux boots) — no regression.
  * RT: RT-EARLY install at load + 8 BOOT-CTX hook calls chained correctly (incl. st=0x5 for absent vars) + EBS stage 2 + VA 'keeping slots' + conversions st=0 + va_done armed; Linux first RT call reached our hook (NX fault = documented Linux-only limitation). Early install is boot-safe and the full chain is armed.
- trigger-test.ps1 v7 (full rewrite): correct SetFirmwareEnvironmentVariableExW(name, guid, value, size, attrs=0x7) marshaling; privilege struct fix kept; real protocol — 48-byte EfiVarReq PING (op=0xDEADBEEF, seq 0x1337) to InfinityReq, reads+decodes 32-byte EfiVarResp from InfinityResp (expect seq match + status 1), triple INFDIAG read with full field decode (flags incl. EARLY bit, hook_calls), verdict logic.
- Package v7: download/infinity-qemu-test-v7.zip (v7 SAFE in usb/ + usb-c/, v7 RT in usb-d/, phase-d.bat v7, README-FA.md v7, usb-check CRLF fix). check_diag.py: flags 0x8 legend.
- Committed workspace 7a2a94f (incl. sandbox serial evidence in test-v7/artifacts/).

Stage Summary:
- v6 verdict: boot chain 100% green on Windows; the ONLY missing link was WHO calls the hooks — solved by early install (v7).
- v7 = architectural fix (pre-snapshot hook install) + corrected trigger client (Ex API + real protocol). Sandbox-proven boot-safe; Windows proof pending user run.
- User next: extract v7, run phase-d.bat (same mode number), desktop -> trigger-test.ps1 (elevated) -> shutdown from Windows -> phase-b-check.bat; send serial-phase-d.log + trigger output + check photo. Expected: stage 4 + hook_calls>=1 + InfinityResp seq=0x1337 status=1.
- Open: (a) if Windows NX's our RT-code pages (unlikely — user's read proves OVMF RT code executes; our image is same descriptor class) -> v8 = self-allocated RT-code image copy; (b) os_cr3 currently captures the FIRMWARE CR3 at EBS (winload still on firmware page tables; real Windows CR3 appears later) + win_build=0 — CR3-capture strategy needs rework AFTER stage 4 is proven; (c) then Infinity.exe UEFIVariableBridge integration.

---
Task ID: 9
Agent: Super Z (main)
Task: Analyze user's v9 phase-D report (trigger test v10, one PowerShell error); root-cause; deliver fixed trigger-test v11

Work Log:
- Extracted upload/infinity-qemu-test-v9-Report.zip (QEMU-Boot.png + phase-d-trigger screenshot + serial-phase-d.log); analyzed both images via VLM (vlm-v9-trigger.json / vlm-v9-boot.json)
- Serial: driver v8 RT booted FULLY GREEN — early hooks at load, 8 BOOT-CTX chained calls, EBS stage 2 (os_cr3=0x7FC01000, win_build=0), VA event + all ConvertPointers st=0, stage 3, plus "G call#320 VIRT" (virtual-context hook call)
- Trigger screenshot decode: READ1 STAGE=3 flags=0xB hook_calls=20; TRIG1 INFTRIGGER write OK; TRIG2 ping FAILED with PowerShell cast error; RESP read Win32=203; verdict claimed hook_calls grew between reads; trigger_seen 0x20 NOT set
- ROOT CAUSE of the user's "one error": PowerShell parses hex literal 0xDEADBEEF as SIGNED Int32 (-559038737) because top bit set -> [uint32]0xDEADBEEF threw -> op field zeroed in the 48-byte PING -> driver correctly refused -> no InfinityResp (203). Script bug, not driver. Same trap exists in v7 script line 180 ([uint32]$ReqOp_Ping)
- KEY MILESTONE confirmed: hook_calls=20 + VIRT-context serial line = Windows IS calling through our early-installed gRT hooks (v7 architecture proven on real Windows 10 19045). GetVariable path from the running desktop works (INFDIAG reads succeed through the hook)
- OPEN QUESTION (cannot resolve from evidence): do SetVariable calls from Windows reach our hook? TRIG1/TRIG2 returned API success but trigger_seen never set and no resp. Possible: (a) kernel bypasses our SetVariable slot, (b) v8 hook rejects op=0 without setting flag, (c) flag write from hook context fails. v8 driver source + v10 script source were LOST in the session rollback (download/ only has v1-v7; infinity-qemu-test/ is at v7 state)
- Built trigger-test-v11.ps1 (full rewrite): HexLe4 string-based byte builder (no numeric casts), packet self-verification before send (37 13 00 00 EF BE AD DE), cleanup of stale probe vars (EFI delete via size-0), per-step attribution (A/B reads -> GetVariable path; C INFPROBE neutral write + readback -> SetVariable-through-hook + NVRAM landing; D INFTRIGGER -> flag 0x20; E fixed PING -> InfinityResp; F final), null-safe SUMMARY + VERDICT block mapped to next actions
- Validated via scripts/validate-v11.py: pure ASCII, zero dangerous casts (only [uint32]0x1337), braces balanced, HexLe4 simulation = EF BE AD DE, CRLF 353/353 lines, C# PrivilegeCount typo fixed, Add-Type re-run guard, BOM on README
- Packaged download/infinity-trigger-v11.zip (trigger-test-v11.ps1 + README-V11-FA.md Persian guide); committed 6751661 IMMEDIATELY (rollback lesson)

Stage Summary:
- v9 verdict: boot chain + GetVariable hook path PROVEN on real Windows; the single failure was my v10 script's op cast bug; last unproven link = SetVariable -> processing -> response
- v11 is both the fix and the instrument: one run attributes Get-path / Set-path / NVRAM landing / trigger flag / full bridge separately, with a photo-friendly SUMMARY block and verdict mapped to driver actions
- User next: drop trigger-test-v11.ps1 into the v9 share folder, run elevated in VM (no reboot needed if VM still up, else phase-d.bat boot first), send SUMMARY photo + serial-phase-d.log + a zip of their whole infinity-qemu-test-v9 folder (without disk/vars) to restore my lost v8 source/binary
- Open: (a) if Set-path bypasses hook -> v9 driver redesign (serve requests from GetVariable path via shared pool); (b) v8 source rebuild from repo + v7 patch + serial-log-derived delta still pending user's v9 folder; (c) win_build=0 / os_cr3=firmware-CR3 known limitations deferred until phase D completes

---
Task ID: 10
Agent: Super Z (main)
Task: Build the durable git version vault (user request); verify returned v9 package; rescue v8 binaries; inventory what's still missing

Work Log:
- Received upload/infinity-qemu-test-v9.zip (3258234 B, sha256 8789ae45...) — the FULL v9 package returned by the user (no disk/vars, as requested). Verified authentic: trigger-test v10 hash matches VERSION.txt internal manifest (95ecb947...)
- Extracted to upload/extracted-v9-full/. Recovered previously-LOST artifacts: v8 driver binaries (usb/memory.efi SAFE 103437 B = 05d47281..., usb-d/memory.efi RT 115426 B = d8914ad2... — distinct builds from v7's 104457/115838), trigger-test.ps1 v10, refresh-files.bat/.ps1 (live USB-stick transfer via QMP control port 127.0.0.1:5555 — unplug/plug virtual FAT mirroring transfer/), transfer/ folder, phase-d.bat v9 (9895 B, refuses disk images in usb-d), VERSION.txt + hash manifest (v8/v8.1 shared a zip name — that confusion is why VERSION.txt exists)
- KEY DISCOVERY from v9 VERSION.txt: the "PowerShell ZIP error" chain from the user's last session = Windows corrupted trigger-test.ps1 ON THE WRITABLE virtual FAT stick (truncated 11433/14290 B, parse error line 263); v9 fixed it by attaching usb-d READ-ONLY + the refresh-files transfer flow. (This fully explains the earlier hash-mismatch mystery: writes onto the ritual FAT stick.)
- Created version-archive/ (git-tracked durable vault, 19 MB):
  * packages/ = v1, v2, v3, v6, v7, v9 (user copy), trigger-v11
  * reports/ = ALL 6 user report zips rescued out of gitignored upload/ + loose-evidence/ (first phase-a/b logs+pngs, 5 pasted screenshots incl. hash-mismatch & PS-error debugging)
  * README.md = Persian version map, critical hashes, report-to-version mapping, missing list, recovery guide
- Rescued to patches/ (matching v6/v7 pattern): v8-memory-SAFE.efi, v8-memory-RT.efi, trigger-test-v10.ps1
- Committed IMMEDIATELY: 2aca848 (26 files). Git has no remote — local commits are the proven rollback-survival mechanism.
- Missing-list reported to user: v4 zip, v5 zip (both lost in rollbacks, live only on user machine); GITHUB_TOKEN needed only if repo refetch required (clone + backups/ both currently absent; token is deliberately never written to disk)
- infinity-repo/ clone + backups/ bundle do NOT exist right now (lost again); refetch path = scripts/fetch-infinity-repo.sh + user-provided token; v8 source rebuild still pending (Task 9 open b)

Stage Summary:
- Durable vault established: every package, every user report, every driver binary now survives rollbacks
- v8 RT binary (the one that proved Windows calls our hooks, hook_calls=20) + v10 script secured
- User's remaining uploads requested: v4, v5 zips; token only when source rebuild starts
- Next: user runs trigger-test-v11.ps1 (in the running v9 VM via transfer folder); then v8 source rebuild + possibly v12 (serve-from-GetVariable redesign if Set-path bypass confirmed)

---
Task ID: 10-b
Agent: Super Z (main)
Task: Archive user-returned v4 + v5 packages; answer the "which GitHub repo?" question

Work Log:
- Received upload/infinity-qemu-test-v4.zip (2818120 B, sha 4560b053...) + infinity-qemu-test-v5.zip (3264431 B, sha d74cfb58...) — user returned both lost versions
- Verified authentic against worklog history: v4 = launcher fixes + finish-oobe-tcg.bat (OOBE bypass from 3-user test), memory.efi SAFE 73614 B; v5 = FIRST RT BUILD (usb-rt/memory.efi 79295 B) + first phase-d.bat (5871 B) + firmware/memory-v4.efi reference copy, usb/memory.efi v5 SAFE 73733 B
- Rescued binaries to patches/: v4-memory-SAFE.efi, v5-memory-SAFE.efi, v5-memory-RT.efi (binary lineage v4→v8 now complete)
- Copied both zips to version-archive/packages/; README updated (v4/v5 rows, hashes, missing-list — now COMPLETE: v1-v9 + trigger v11)
- Committed 3eeb624
- USER QUESTION: "did you create the folder in MY GitHub? I don't see it in any of my repos" — ANSWERED: the vault is a LOCAL git repo in my sandbox (/home/z/my-project/.git, no remote). Their GitHub token was ONLY ever used ephemerally to CLONE (pull) the source repo — never to push anything. Local commits are the proven rollback-survival mechanism (v1-v7 zips survived rollbacks precisely because committed). Offered: with their token I can create a PRIVATE repo on their GitHub (proposed name: infinity-backup) and push the full archive so it survives even total sandbox loss — awaiting their go-ahead + token + repo name/visibility choice.

Stage Summary:
- Version archive now COMPLETE: all 9 packages + all 6 reports + full binary lineage v4-v8 + v10/v11 scripts
- Only remaining external dependency: GITHUB_TOKEN (repo refetch / optional GitHub push of the vault)
- User decision pending: push vault to their GitHub as private repo (name/visibility to be confirmed by user)

---
Task ID: 11
Agent: Super Z (main)
Task: Create the GitHub backup repo (user-approved: fulken/infinity-backup, private) and push the vault

Work Log:
- User approved the backup plan and provided a fresh GITHUB_TOKEN in chat (broad admin scope; no token commentary requested by user — respected)
- Pre-push security scan of all content to be mirrored: rg for the live token + ghp_ patterns across version-archive/, patches/, scripts/, worklog.md, test-v7/, edk2_Runtime.c — CLEAN
- Workspace repo push rejected by design: its history carries ~80MB of junk (alpine.iso blob, .deb files, qemu-root/ trees tracked before ignore rules existed). Chose a CLEAN MIRROR approach instead
- Wrote scripts/push-infinity-backup.sh (reusable, idempotent): ensures repo exists via API (creates private on 404), clones existing history into disposable staging under backups/, mirrors an EXPLICIT artifact list (version-archive, patches, scripts, worklog.md, edk2_Runtime.c, test-v7/artifacts only — not the 60MB kernel images, README from tracked scripts/infinity-backup-README.md), leak-checks staged content + .git/config BEFORE commit, commits delta, pushes with ephemeral Authorization header (remote URL stays tokenless), post-push leak checks. Same security model as fetch-infinity-repo.sh (token never on disk)
- Wrote scripts/infinity-backup-README.md — Persian repo README (structure table, recovery guide, notes)
- RUN 1 result: repo fulken/infinity-backup created (private, default branch main), 60 files / 27MB mirrored, pushed main @ a81d072, all leak checks green
- Verified from API side: full_name fulken/infinity-backup, private:true, default_branch main, remote HEAD a81d072 matches, root tree = README.md / edk2_Runtime.c / patches / scripts / validation-evidence / version-archive / worklog.md
- Committed script + README to workspace

Stage Summary:
- DUAL STORAGE now live: (1) local workspace git (rollback-proof, proven), (2) user's private GitHub fulken/infinity-backup (total-loss-proof)
- Backup contents: all packages v1-v9 + trigger v11, all 6 user test reports + loose evidence, binary lineage v4-v8, source patches v6/v7, all scripts incl. the backup script itself, sandbox v7 serial evidence, full worklog
- Future updates: re-run scripts/push-infinity-backup.sh with a token (idempotent, keeps backup commit history, fast-forward push)
- User was told: repo URL, private status, what's inside, update mechanism — and that the token was used ephemerally only (no lecture, per their request)
- Next: user runs trigger-test-v11.ps1 in the VM (via transfer folder) and sends SUMMARY photo + serial-phase-d.log; then v8 source rebuild (needs repo refetch w/ token) and possibly v12 (serve-from-GetVariable if Set-path bypass confirmed)

---
Task ID: 12
Agent: Super Z (main)
Task: Analyze user's v11 trigger-test report (V9+trigger-v11-TestReport.zip); reverse-engineer the lost v8 driver from its binary; define v12

Work Log:
- Report contents: 2 PowerShell screenshots (VLM transcribed: vlm-v11-ps1/ps2.json), QEMU-phase-b-check.png, serial-phase-d.log, serial-check.log
- SERIAL (phase-d): boot chain FULLY GREEN again — v8 RT early hooks at load, 9 BOOT-CTX calls traced (#1-8, #64 S, #128 T), EBS stage 2 (os_cr3=0x7FC01000), VA stage 3, all ConvertPointers st=0, "G call#192 VIRT" (post-SVAM winload call through our hook)
- SERIAL (check): INFDIAG final = DFNI, stage=3, flags=0xB, win_build=0, os_cr3=0x7FC01000, hook_calls=0x97=151, last_status=0
- SCRIPT v11: ran 100% CLEAN end-to-end (zero PowerShell errors — the v10 cast bug is dead; PING packet verified 37 13 00 00 EF BE AD DE). Steps: A/B baseline reads (151/151), C INFPROBE write accepted + readback 'B' (NVRAM landing works), D INFTRIGGER accepted, E InfinityReq accepted (48B readback correct), E2 InfinityResp ABSENT (Win32=203), F final (all unchanged). Script's own VERDICT: "hook_calls never moved (driver persist policy may throttle) - deltas inconclusive"
- REVERSE-ENGINEERED v8-memory-RT.efi (scripts/analyze-v8-binary.py + objdump; PE kept its COFF symbols — UEFIBridge::DiagWrite/RuntimeHook::HookedSetVariable/RequestHandler::ProcessSingleVariableRequest all visible):
  * TRACE POLICY: sampled — first 8 calls + every 64th ("FIRST" suffix string, 4 sites, one per hook). Serial silence during the script is EXPECTED, proves nothing about bypass
  * COUNTER: g_diag_hook_calls (xadd at HookEnter, 2 sites G/S) is CUMULATIVE from load (BOOT-CTX + VIRT; trace numbers 1..192 continuous) — the "counts only VIRT" idea was wrong
  * PERSIST POLICY: DiagWrite() has exactly 4 call sites — load (stage 1), EBS (stage 2), VA event (stage 3). INFDIAG in NVRAM is a STALE SNAPSHOT of the last stage transition. hook_calls=151 = the counter value AT THE SVAM-TIME DiagWrite (129 BOOT-CTX through EBS + winload pre-SVAM calls). stage=3/flags=0xB/trigger 0x20 absent — ALL EXPLAINED by the persist policy, NOT by bypass. v8 has ZERO observable persistent signals for desktop-time hook activity
  * HOOKED-SetVariable ROUTING: foreign GUID+name → re-entrancy latch + gate (pool ready && !(flags&4-armed) && calls>16) → e610: POOL REQUEST SWEEP (ProcessOneRequest loop over RequestSlot/ResponseSlot in the 4MB shared pool). OUR GUID: name==InfinityReq → flags|=0x20 + INLINE RequestHandler::ProcessSingleVariableRequest(payload, pool, ...) when DataSize>47 && Data!=NULL (the 48-byte PING is processed IMMEDIATELY INSIDE the SetVariable call); name==InfinityResp → also flags|=0x20; INFTRIGGER path exists too (e6e8). INFDIAG/InfinityReq/InfinityResp also special-cased in HookedGetVariable (f0f8-f2e0 region) — responses are served FROM THE RAM POOL, no NVRAM variable is ever created for InfinityResp
  * IMPLICATION: v8's design is actually SOUND (inline processing + pool-served responses) — IF calls reach the hooks
- VERDICT: the ONLY hard negative signal is InfinityResp ABSENT. Proven: desktop-originated GetVariable(InfinityResp) did NOT reach our hook. Write path (SetVariable InfinityReq/INFTRIGGER) UNDETERMINED (its side effects are all RAM-only/unobservable). Boot-time (winload) calls DO reach our hooks (151 cumulative + #192 post-SVAM). NVRAM landing of desktop writes is proven (INFPROBE 'B', InfinityReq 48B) — but that happens identically whether or not our hook chains them
- v12 DESIGN (observability fix, not a mechanism change): (1) HookedGetVariable on INFDIAG → DiagWrite (freshen) BEFORE chaining, so INFDIAG reads return LIVE RAM state; (2) HookedSetVariable on our-namespace vars → DiagWrite after flags|=0x20, so trigger_seen becomes observable; (3) optionally a persistent req-counter written via orig SetVariable on each InfinityReq. Re-run trigger-test-v11 → full per-path attribution (read path / write path / processing / response serving). THEN decide: if writes DO reach us → only the read path needs a workaround (e.g., response served via a REAL NVRAM variable written by the hook through orig SetVariable, which the desktop CAN read without our hook!). If writes don't reach us either → variable transport is dead on desktop Windows → pivot to the shared-memory pool transport for Infinity.exe (the original ProjectMemory/SharedMemoryPool architecture)
- Blocked on: v8 SOURCE rebuild (repo refetch needed — token available this session; then apply patches/v7-on-a8e41b3.diff + the v8 delta documented above)
- Archived report zip to version-archive/reports/ (766a06a)

Stage Summary:
- v11 instrument + user's run: EXCELLENT quality, zero script errors; every step returned clean data
- Boot-phase hook interception PROVEN (151 calls); desktop-phase READ bypass PROVEN; WRITE path still undetermined — v8's persist policy blinded exactly the signals that would have answered it
- v8 driver fully understood from binary analysis (its lost source is now 90% reconstructable: v7 patch + documented delta)
- Next: refetch repo + rebuild v8 source + v12 (observability) + sandbox validation + package → user re-runs trigger test → definitive desktop-path attribution
- User needs to provide: NOTHING (all evidence in hand; token live for the refetch)


---
Task ID: 13
Agent: Super Z (main)
Task: v12 (observability build) preparation — full pipeline staged; user confirmed the analyzed report WAS from v9+trigger-v11

Work Log:
- User clarified: their test was on infinity-qemu-test-v9 with infinity-trigger-v11 — exactly the V9+trigger-v11-TestReport.zip already fully analyzed in Task 12. Re-verified the evidence chain from upload/extracted-v11-test/ (serial tail ends at "G call#192 VIRT", script A-F all show frozen hook_calls=151, INFCNT did not exist, InfinityResp 203): v11 could NOT discriminate read-path vs write-path bypass (stale-snapshot persist policy blinded hook_calls; sampled serial traces miss the 152..~210 range). Corrected the Task 12 over-statement "read bypass PROVEN": the strict conclusion is NOT(read-through AND write-through) — at least one bypasses, attribution unknown. v12 exists to answer exactly this.
- Confirmed the v12 build blocker: source lives ONLY in private repo fulken/Infinity (branch uefi-full-migration, pin a8e41b3); clone+bundle lost in rollbacks; repo verified private (unauthenticated ls-remote prompts). Token from previous session was ephemeral by design → a fresh token is needed to run the pipeline.
- Wrote scripts/patch-v12.py — the anchored v7→v12 source patcher, 10 edits (D1-D2 Diag.h, R1-R8 RuntimeHook.h): (1) HookEnter cumulative counter + VIRT suffix + NO DiagWrite (v8 policy); (2) INFDIAG read-freshen gated on va_done (read-path attribution + a [DIAG] serial line per freshen); (3) our-namespace SetVariable block: unbounded "S OURVAR write/delete" trace + flag 0x20 + g_diag_req_count++ + WriteReqCount + DiagWrite (write-path attribution); (4) WriteReqCount persists INFCNT through ORIGINAL SetVariable (bypass-safe, always readable from Windows); (5) INFTRIGGER added to IsOurVariable + accepted by HandleOurSetVariable; (6) v12 boot-log markers ("memory.efi v12 RT", "(v12 early)"). All attribution writes gated on g_diag_va_done to preserve boot-log purity + flash wear.
- Wrote scripts/verify-v12-anchors.py and RAN it: reconstructs the v7 new-side text from the v7 diff and proves every anchor occurs EXACTLY ONCE — all 10 anchors OK (patcher is guaranteed to apply cleanly on the a8e41b3+v7diff tree).
- Wrote scripts/build-v12.sh — full pipeline: reuse/refetch repo (token rules unchanged) → worktree @ a8e41b3 → v7 diff → patch-v12.py → build SAFE+RT (gnuefi-jammy 3.0.13, fallback gnuefi-local) → binary string checks (v12 marker/INFCNT/OURVAR/INFTRIGGER in RT; hook strings absent in SAFE) → sandbox validation → package → commit (+optional vault push). Stages individually runnable with --only, sandbox skippable with --skip-sandbox.
- Wrote scripts/test-v12-linux.sh — Alpine EFI-stub sandbox test adapted from test-v7-linux.sh with explicit PASS/FAIL verdicts: RT expects v12 marker, early hooks, BOOT-CTX traces, stage 2/3 writes, (v12 early) line, all CVT st=0, kernel boot, and accepts the documented post-chain NX stop; SAFE expects stage-1 write + full Alpine boot + NO hook lines.
- Wrote infinity-qemu-test/trigger-test-v12.ps1 (v11 + step G INFCNT read + 4-signal SUMMARY + 5-branch VERDICT matrix: full bridge / both-paths-work-processing-failed / reads-only / writes-only / both-bypassed→pool-transport pivot) and README-V12-FA.md (Persian guide: what changed, how to run, what to send, how to read the 4 signals, stage=4 is expected now).
- .gitignore += build-v12-tree/, test-v12/, build/. All scripts syntax-checked (py_compile, bash -n).

Stage Summary:
- v12 is FULLY STAGED: patcher (anchor-verified), build pipeline, sandbox test, test script, Persian README, packaging logic. One command builds it once the repo is available:
  GITHUB_TOKEN='...' bash scripts/build-v12.sh   (≈15 min, mostly the 2 sandbox boots)
- v12 design (only observability, mechanism unchanged): expected signatures — both paths work: hook_calls moves + INFCNT=2 + flags 0x2B + Resp ANSWERED; reads-only: moves + INFCNT absent; writes-only: frozen counts + INFCNT=2; both bypassed: frozen + absent → v13 pivots to SharedMemoryPool transport
- BLOCKED on: fresh GITHUB_TOKEN (repo refetch). Everything else is ready and committed.
- User was told: their v9+v11 test was indeed the one analyzed; v12 will settle which path Windows bypasses; to paste a fresh token so the build can run.

---
Task ID: 14
Agent: Super Z (main)
Task: Run the staged v12 pipeline end-to-end (user supplied fresh token + asked where trigger-test-v12.ps1 is)

Work Log:
- User provided a fresh full-access token and asked why trigger-test-v12.ps1 is not downloadable. Answer: the file existed in the workspace (infinity-qemu-test/) but was never packaged — and testing v12 requires the v12 DRIVER binary (INFCNT etc. only exist in the new build), so the package IS the deliverable.
- Token validated (fulken); repo fulken/Infinity accessible; found this session's earlier repo fetch already cached as bundle+tar.gz in backups/ — clone restored at pin a8e41b3.
- Stage tree: v7 diff + patch-v12.py applied cleanly (all v12 markers verified in source).
- Stage build: first run hit a runtime bug (script cp'd memory.efi from wrong dir — Makefile outputs to UEFI/build/build/) → fixed build-v12.sh with explicit OUT path. SAFE (104457 B) + RT (117490 B) built; R4 GLOB_DAT + R6 orphan .bss checks clean.
- Stage check: initial FAIL on "INFTRIGGER" — false alarm: UEFI var names are UTF-16LE, plain strings(1) can't see them. Fixed the check to use `strings -e l` for INFTRIGGER/INFCNT/InfinityReq. All binary checks PASS (plus ASCII markers: v12 banner, v12 early, OURVAR traces).
- Stage sandbox: harness launched in background died silently between tool calls (QEMU survived + completed on its own); re-ran in foreground. RT (boot A): FULL PASS — v12 banner, hooks at load, BOOT-CTX 1-8/64, stage2 EBS, VA fired + v12-early keep-slots, stage3 write, all CVT st=0, kernel EFI-stub boot, documented post-chain NX stop. SAFE (boot B): initial FAIL on "Welcome to Alpine" — investigated: the ARCHIVED v7 SAFE run (test-v7/artifacts/serial-lB.log) hit the IDENTICAL initramfs boot-media mount quirk (vvfat under TCG, recovery shell) and was accepted; the v12 B-verdict was stricter than the proven v7 baseline. Fixed verdict to the driver's contract (stage=1 write + Linux boots + /init runs + no hook lines); "Welcome to Alpine" demoted to NOTE either way. B re-run: PASS (4/4 + quirk NOTE, same as v7).
- Stage package: download/infinity-qemu-test-v12.zip built from the v9 template + v12 binaries + trigger-test-v12.ps1 (root, usb-d/, transfer/ — 3 copies) + README-V12-FA.md + VERSION.txt (sha256 of both efis + script) + phase-d.bat re-badged to v12. Archived to version-archive/packages/.
- Stage commit + vault push: workspace git commit + fulken/infinity-backup refreshed via push-infinity-backup.sh (token ephemeral, leak-checked).

Stage Summary:
- v12 IS BUILT, VALIDATED AND PACKAGED: download/infinity-qemu-test-v12.zip
- Driver lineage: fulken/Infinity @ a8e41b3 + v7 diff + patch-v12.py; SAFE sha256 1E858C03..., RT sha256 8AC7DF0C...
- Sandbox: RT PASS 11/11, SAFE PASS 4/4 (media-mount quirk documented, identical to archived v7)
- Script fixes committed back: build-v12.sh (OUT path, UTF-16 check), test-v12-linux.sh (B verdict = driver contract)
- User flow: unzip -> phase-d.bat -> VM boots Windows (v12 RT, serial shows "memory.efi v12 RT") -> trigger-test-v12.ps1 elevated -> send SUMMARY photo + serial-phase-d.log
- The 4-signal verdict matrix (README-V12-FA.md) will attribute the desktop bypass: full bridge / reads-only / writes-only / both-bypassed (-> v13 pool transport pivot)

---
Task ID: 15
Agent: Super Z (main)
Task: Fix v12 fresh-install blocker — phase-d.bat pre-flight aborted with "trigger-test.ps1 is NOT the v10 script"

Work Log:
- User did a clean reinstall (kept disk\ + vars\ where Windows lives), extracted v12, ran phase-d.bat -> immediate abort: pre-flight 1 still checked usb-d\trigger-test.ps1 (v10, findstr "trigger test v10", 14290 bytes) but the v12 package correctly ships usb-d\trigger-test-v12.ps1 instead. Nothing ran, VM untouched — pure packaging bug in my v12 sed pass (banners updated, guard not).
- Full template scan for stale refs: phase-d.bat lines 26-27/56-73/84/98/134-136/149-150/207/113 + stale root README-FA.md (v9 guide). VERSION.txt regenerated (fine), refresh-files + startup.nsh + transfer readme clean/generic.
- Wrote scripts/patch-v12-bat.py (R0-R8 anchored replacements, CRLF-preserving — first run failed on Python universal-newline \r\n translation, fixed with newline="" on read). Output: infinity-qemu-test/phase-d.bat (10015 B) = v9 template + v12 guard ("trigger test v12" via findstr on usb-d\trigger-test-v12.ps1) + v12 banners (package v12 / memory.efi v12 RT observability) + v12 on-desktop instructions (D:\trigger-test-v12.ps1, first line "trigger test v12") + v12 next-steps.
- build-v12.sh package stage now copies the patched phase-d.bat (seds -> one refresh-files no-op left) and REMOVES the stale v9 README-FA.md from the package root (README-V12-FA.md is the only guide now).
- Repackaged. VERIFIED against the actual zip: usb-d = exactly 4 items (EFI, memory.efi 117490B = v12 RT string-verified, startup.nsh, trigger-test-v12.ps1 16499B); guard simulation: file exists + "trigger test v12" matches 2x -> findstr errorlevel 0 -> PASSES; only remaining old-name mention = historical corruption comment (lines 9-10, intentional).
- User's kept vars\ is FINE for the test: the v12 boot itself rewrites INFDIAG at stage 1/2/3 transitions, and the script discriminates live (stage=4, moving counts) vs stale (stage=3 frozen) — stale NVRAM is part of what v12 attributes. The Windows boot entry in their vars must NOT be wiped (it is how the VM boots Windows).
- Committed v12.1 (git) + vault push.

Stage Summary:
- FIXED DELIVERABLE: download/infinity-qemu-test-v12.zip (3266979 B) — re-extract over the old folder (or fresh) and phase-d.bat proceeds past pre-flight
- Binaries UNCHANGED (same sha256 as v12 build — only the .bat/readme/packaging fixed)
- Guard semantics now: usb-d\trigger-test-v12.ps1 must exist + contain "trigger test v12"

---
Task ID: 16
Agent: Super Z (main)
Task: Fix v12 flash-close: phase-d.bat window opens and instantly closes, no output

Work Log:
- Symptom (user, after re-extracting the v12.1 zip): double-click phase-d.bat -> cmd flashes shut, zero output, nothing runs. Different from the previous pre-flight abort (that one printed + paused).
- Diagnosis: silent instant abort = cmd.exe batch PARSE abort. Audited every hunk of my patched phase-d.bat vs the proven v9 template: the only novel paren construct was my R2 error message "echo A stale old copy (v10/v11) cannot read the v12 signals" INSIDE the "if errorlevel 1 (" block. A mid-text ")" in echo text closes the block prematurely -> cmd aborts the whole script silently. (Template's own in-block paren line "(the VM must be running...v9+)" has the paren at argument START and is production-proven since v9; plain-echo/rem parens are outside blocks = safe.)
- Fix: rephrased both R2 lines paren-free ("A stale old copy - v10 or v11 - cannot read the v12 / signals INFCNT and live INFDIAG - wrong verdict.").
- Wrote scripts/audit-bat-parens.py (mechanical paren-in-block-echo audit; heuristic depth tracker). Ran it on template + patched: BOTH flag the exact same 15 later-file lines (known false positives of my heuristic — those lines are production-proven since v9 and structurally untouched), and the patched file now has ZERO paren shapes that the proven template does not also have. Final diff review: 5 paren-bearing changed lines, all safe inherited shapes (2x rem, 1x block opener syntax, 1x proven arg-start paren, 1x top-level echo).
- Repackaged download/infinity-qemu-test-v12.zip (3266966 B). Binaries + trigger script unchanged. Committed v12.2 + vault push.
- User also given the standard debug trick: if a .bat ever flash-closes again, open cmd first, cd to the folder, run phase-d.bat from there — the window stays and shows the real error.

Stage Summary:
- FIXED: download/infinity-qemu-test-v12.zip — phase-d.bat parses again (paren-free guard block)
- Root cause: my error message put a ")" inside a cmd block — classic batch killer
- No wine/cmd in sandbox; fix proven structurally (paren usage now identical to the production-proven v9 file)
- Deliverable unchanged otherwise: same v12 driver binaries, same trigger-test-v12.ps1

---
Task ID: 17
Agent: Super Z (main)
Task: Analyze v12 BSOD test report; design+build+ship v13 (safe observability)

Work Log:
- Report (infinity-qemu-test-v12-TestReport.zip): 3 photos (VLM: PS transcript / BSOD KMODE_EXCEPTION_NOT_HANDLED at 21% / boot) + serial-phase-d.log (400 lines).
- SERIAL: boot chain 100% green (v12 banner, early hooks, BOOT-CTX 1-8/64/128, EBS stage2 flags=0xB, VA event + v12-early keep-slots + stage3, ALL CVT st=0, armed stage4, G #256/#320 VIRT). LAST LINE TRUNCATED: "[INF][DIAG] write stage=4 flags=0x" = the v12 INFDIAG read-freshen DiagWrite — the desktop INFDIAG read REACHED HookedGetVariable.
- PS transcript: banner + [ENV] Win10 19045 + privilege OK + [CLR] + step A header, then BSOD. [CLR] = 5 deletes on OUR names/GUID (INFPROBE INFTRIGGER InfinityReq InfinityResp INFCNT); serial has ZERO "S OURVAR" traces -> desktop SetVariable BYPASSES the hook.
- ATTRIBUTION (v12 run, at the cost of one BSOD): READ path reaches hook (PROVEN); WRITE path bypasses (PROVEN). v12's design goal achieved in one run.
- BSOD root cause: the freshen = DiagWrite -> gRT->SetVariable (busy-gated to ORIG) = an NVRAM write from INSIDE the kernel's GetVariable dispatch; KMODE_EXCEPTION mid-print (concurrent-context signature). Disassembled DiagWrite (COFF symbols survived): call [rax+0x58] then pure-IO print; print cannot fault -> fault was in the concurrent other context triggered by the orig SetVariable call. Root lesson: NEVER call orig SetVariable from inside a runtime hook on the Windows dispatch path.
- v13 DESIGN (mechanism unchanged; observability made safe): (1) HookedGetVariable SERVES INFDIAG + INFCNT reads from LIVE RAM (GUID-checked, va_done-gated, standard buffer protocol incl. BUFFER_TOO_SMALL size query) - zero orig calls, zero NVRAM writes; (2) our-var S-hook block: "S OURVAR write/delete" trace + flag 0x20 + g_diag_req_count++ (RAM ONLY - WriteReqCount/DiagWrite removed); (3) INFTRIGGER in IsOurVariable + accepted by HandleOurSetVariable (as v12); (4) cumulative HookEnter counter (as v12); (5) v13 boot markers. HandleOurGetVariable (base repo) serves only InfinityResp/InfinityData from RAM (INFDIAG fell through to chain - explains v11's stale reads).
- Wrote scripts/patch-v13.py (D1 D2 R1 R2 R3 R5 R6 R7 R8, anchored on the v7 tree; all applied clean). Fixed one typo (missing // on a comment line -> GCC error) via Edit.
- Wrote scripts/build-v13.sh + scripts/test-v13-linux.sh (sed-derive) + scripts/patch-v13-bat.py (v13 phase-d.bat with dynamic script size 16303; paren-free guard echoes per the v12.2 lesson).
- Wrote infinity-qemu-test/trigger-test-v13.ps1 (v12 base + live-RAM semantics: step G INFCNT = live count 0/2, writeOk = cnt>=1 or flag, v14-direction verdicts) + README-V13-FA.md (Persian: what BSOD was, what v13 changes, evidence ask incl. vars\OVMF_VARS_4M.fd).
- BUILD: SAFE 104457 B, RT 118002 B; R4/R6 clean. CHECKS: all ASCII markers (v13 RT banner, INFDIAG live, INFCNT live, OURVAR, v13 early) + u16 names (INFTRIGGER INFCNT INFDIAG InfinityReq) PASS; SAFE clean.
- SANDBOX: A (RT) PASS 11/11 (v13 banner, hooks at load, BOOT-CTX, stage2/3, v13-early, armed, CVT st=0, kernel boot, NX stop); B (SAFE) PASS 4/4 (stage1, kernel, /init, no hook lines; media-mount quirk NOTE same as archived v7).
- PACKAGE: download/infinity-qemu-test-v13.zip (3266658 B; usb-d = 4 items, script 16303 B in root+usb-d+transfer, guard simulation passes, phase-d.bat 10025 B says package v13 + v13 banner; paren audit = same 15 template-inherited false positives as proven v9/v12.2, zero new shapes). Archived to version-archive/packages/. Committed + vault pushed.

Stage Summary:
- v12 verdict (from the crashed run): READ path REACHES our hook; WRITE path BYPASSES it; orig-SetVariable-from-inside-a-hook = BSOD class
- v13 SHIPPED: download/infinity-qemu-test-v13.zip — same test mission, zero crash class (hooks never call orig SetVariable at runtime; INFDIAG/INFCNT answered from live RAM)
- Expected v13 run (if v12 evidence holds): hook_calls MOVES between A/B, INFCNT=0, InfinityResp ABSENT -> VERDICT: reads-only -> v14 pivots to GetVariable-path/pool transport (ProjectMemory architecture)
- User also asked to send vars\OVMF_VARS_4M.fd (contains the freshen's last successful write: stage=4) for confirmation


---
Task ID: 18
Agent: Super Z (main)
Task: Analyze v13 test report (logs + 3 photos + vars v12/v13) incl. build-detection check; build v14

Work Log:
- Report: infinity-qemu-test-v13-Report.zip -> serial-check.log + serial-phase-d.log + phase-b-check.png + phase-d-PowerShell-Part1/2.png + varsV12Checked.zip + varsV13Checked.rar.
- SERIAL (phase-d): boot chain 100% green (v13 banner, early hooks, BOOT-CTX, stage 1/2/3, CVT st=0, armed, G call#256/#320 VIRT). windows build=0 at EBS (as in EVERY run since v6). Serial capture truncated at call#320 (pre-desktop) - desktop-phase serial evidence absent.
- VLM photos: [ENV] Win build 10.0.19045.0 (script-side detection CORRECT); steps A..F all hook_calls=251 FROZEN; INFCNT 203; InfinityResp 203; INFPROBE/INFTRIGGER/InfinityReq writes Win32=0; script verdict = "both paths bypassed". phase-b-check photo == serial-check.log (INFDIAG stage=3 flags=0xB calls=251).
- VARS FORENSICS (wrote scripts/parse-vars-v13.py; OVMF auth variable store, 60-byte AUTH headers, StartId AA55 LE): BOTH files are the SAME store continued (identical prefix to 0x229BA). Full INFDIAG run-history decoded (18 boots since v6-era): v9+v11 run = the 151-calls group; v12 runs = 276-calls groups; v13 run = final group ending stage=3 calls=251 (matches dmpstore check). VARS-v12 last INFDIAG = stage=4 flags=0xF calls=341 -> THE V12 FRESHEN WRITE LANDED IN NVRAM (binary proof). VARS-v13 appended exactly: INFDIAG s1/s2/s3 + INFPROBE='B' + INFTRIGGER + InfinityReq(1337-DEADBEEF) ALL state 0x3F VAR_ADDED -> desktop writes landed in NVRAM. Serial has ZERO "S OURVAR" traces. InfinityMem live with pool 0x7D816000 (EDK2 in-place update, no new entry; matches v13 CVT log). Windows-side bypass vs hook-side misclassification could not be distinguished from the vars evidence alone -> led to the code audit.
- ROOT CAUSE FOUND (the headline): gnu-efi 3.0.13 CompareGuid/RtCompareGuid is memcmp-like (disassembled: component subtraction OR -> 0 iff EQUAL). Two call sites used EDK2-BOOLEAN semantics: (1) v13 serve gate "CompareGuid(...) == TRUE" -> 0==1 FALSE for MATCHING GUID -> RAM serve DEAD CODE -> reads chained to stale NVRAM (explains frozen 251 + INFCNT 203 EXACTLY); (2) BASE-REPO IsOurVariable "CompareGuid(...) != TRUE return FALSE" -> matching GUID rejected as not-ours (latent since a8e41b3) -> no S OURVAR traces, no counts, writes chained + landed (fakes "write bypass" across v9-v13). v12 freshen gate was NAME-ONLY (no GUID check) - that is why it FIRED: desktop reads PROVEN to reach the hook (still the only solid path fact). Write path now UNKNOWN (bug masked it); HookedSetVariable->orig->NVRAM chain PROVEN SAFE by the 3 accidental v13 chains.
- BUILD DETECTION (user question): script-side correct (10.0.19045). Driver-side win_build=0 always: at EBS the CPU still runs on FIRMWARE page tables (EBS CR3 == UEFI CR3 == 0x7FC01000 in every log since v6); the KUSD VA 0xFFFFF78000000000 is not mapped there -> TranslateVA fails at PML4 -> 0. Fix: direct volatile read of NtBuildNumber at KUSD+0x308 inside hook contexts (global page, mapped in every address space, cannot fault) + ProcessFinder lazy offsets refresh (EBS-time build=0 had left FindByName fail-closed forever).
- v14 BUILT (scripts/patch-v14.py: F1a/F1b GUID fixes, F2a/F2b live KUSD build capture at serve+write paths, F3 dual-write chain-after-handle + write-gated 0x20 flag, R5 banners, P1 finder lazy refresh; make-v14-script.py + trigger-test-v14.ps1 with win_build driver-vs-script SUMMARY line + verdict-order fix; patch-v14-bat.py from pristine patches/phase-d-v13.bat; README-V14-FA.md; build-v14.sh + test-v14-linux.sh). Build hit 2 patcher bugs (comment lines missing //) -> fixed, rebuilt.
- VALIDATED: binary checks 11/11 PASS (v14 RT banner, guid fix + live build, INFDIAG/INFCNT live, OURVAR, live windows build, v14 early, u16 names; SAFE clean). Sandbox RT(A) PASS + SAFE(B) PASS (same documented initramfs media-mount quirk NOTE as v7/v13). Package guard simulation PASS (usb-d = 4 items, findstr "trigger test v14" matches).
- SHIPPED: download/infinity-qemu-test-v14.zip (3269865 B; SAFE 104969 B sha256 6f6e1d10..., RT 119026 B sha256 51e8132b...). Committed 3eee5e5. No token this session -> vault push skipped (local commit is the rollback copy).

Stage Summary:
- v13 test verdict REVISED: "both bypassed" was an ARTIFACT of the GUID comparison bug; reads = PROVEN reach (v12 freshen), writes = UNKNOWN (masked by the same bug); the v13 run itself proved BSOD-free and the S-chain->NVRAM path safe
- v13 NVRAM forensics: full 18-boot INFDIAG history decoded; v12 freshen landing proven; InfinityMem (pool 0x7D816000) live
- v14 SHIPPED: GUID semantics fixed + live KUSD build capture (SUMMARY now shows driver-side vs script-side build) + dual-write chain; re-run the same trigger test for the REAL verdict (full bridge is now possible: PING -> RAM handling -> InfinityResp served)
- Expected v14 outcomes: full bridge (A/B moving + INFCNT=2 + 0x2B + Resp ANSWERED) / reads-only (INFCNT=0) / genuinely both-bypassed (frozen + absent) -> v15 pool pivot decision
- BLOCKED on: user runs the v14 package (no token needed for anything else)
---
Task ID: 19
Agent: Super Z (main)
Task: Durable backup refresh — user warned GitHub vault was stale (files at risk of session loss)

Work Log:
- User message: GitHub not updated since v13 vault push; files could be lost on session rollback. Correct — Task 18 (v14) ended with "no token this session -> vault push skipped, local commit only".
- Gap audit found THREE at-risk evidence sets living only in upload/ (gitignored = wiped on rollback): (1) infinity-qemu-test-v12-TestReport.zip, (2) infinity-qemu-test-v13-Report.zip, (3) vars forensics evidence (varsV12Checked.zip, varsV13Checked.rar, raw OVMF_VARS_4M.fd of both sessions) — the binary proof of the v12 freshen landing + v13 desktop writes.
- Archived all three: reports -> version-archive/reports/; vars -> version-archive/reports/vars-forensics-v12-v13/ (checked zips + raw .fd files).
- version-archive/README.md updated: packages table now has v12/v13/v14 rows (with verdict-history notes incl. the CompareGuid artifact revision), SHA256 section extended (v12-v14 package + driver hashes; noted v13 SAFE == v12 SAFE binary-identical), reports table + vars-forensics row added, binaries/patches section now lists v12-v14 efi + patch-v{12,13,14}.py lineage, "missing" list updated to "archive complete: v1-v14".
- scripts/infinity-backup-README.md (the vault README) updated: v1-v14 lineage, vars forensics mention, v14-ready-to-run state, restore chain (a8e41b3 -> v7 diff -> patch-v12 -> v13 -> v14).
- Git hygiene: untracked the build-v13-tree/build-v14-tree gitlinks (always-dirty submodule entries; rebuildable from infinity-repo + patches — same policy as build-v12-tree/) and added them to .gitignore. Workspace status now 100% clean.
- Committed ac5fefe "backup-complete: archive v12/v13 test reports + NVRAM vars forensics ...". Everything durable is now in the workspace git. Vault push (fulken/infinity-backup) still needs the ephemeral GITHUB_TOKEN from the user — script unchanged (scripts/push-infinity-backup.sh).

Stage Summary:
- Local durability DONE: all v14-era evidence + reports + vars now committed; nothing at-risk left in gitignored paths
- Vault push PENDING on user token (last vault state = v13-era; local has v14 + evidence on top)
- Ready command once token provided: GITHUB_TOKEN='...' bash scripts/push-infinity-backup.sh
---
Task ID: 20
Agent: Super Z (main)
Task: Receive GitHub token from user (authorized on-disk storage) + execute pending vault push

Work Log:
- User provided a fine-grained PAT (github_pat_...) — 7-day expiry (until ~2026-09-28), admin permissions, explicit authorization to store it on disk for reuse during its validity ("put it somewhere at hand"). User explicitly declined cautionary commentary. Token value is NOT written into worklog (worklog is mirrored to the vault).
- Storage: /home/z/my-project/.secrets/github-token (chmod 600, single line, pure token). Tracked in the WORKSPACE git (be8ef8a) so it survives session rollback — the workspace repo has no remote, so exposure stays local-machine-only.
- Firewall rules around the token: (1) .secrets/ is NOT in the vault mirror list (mirror = version-archive, patches, scripts, worklog, edk2_Runtime.c, README) — never mirrored; (2) push script step [4/6] leak-check aborts any push where the token value appears in staged content; (3) post-push check verifies remote URL + .git stay tokenless; (4) redact() scrubs token from all script output.
- push-infinity-backup.sh upgraded: token resolution now env-var-first with fallback to .secrets/github-token (future sessions can push by just running the script — no re-asking the user while the PAT lives). Header comment updated to reflect the user authorization (2026-09-21).
- VAULT PUSH EXECUTED: fulken/infinity-backup 75f1c58..c444399, now 7 commits. Vault now carries: v14 package + binaries, v12/v13 test reports, vars-forensics-v12-v13 (raw OVMF_VARS_4M.fd + dmpstore outputs), updated README maps (v1-v14), patched push script, worklog through Task 19. 99 files, 40M. All leak checks green.
- Workspace commits: ac5fefe (evidence archival) -> 789c11f (worklog 19) -> be8ef8a (token store + script). Status clean (0 dirty).

Stage Summary:
- Vault (fulken/infinity-backup) is CURRENT through v14 + all evidence; local workspace git mirrors the same + token store
- Token usability window: ~2026-09-28; after expiry a new PAT from the user is needed (fetch + push both)
- Next vault pushes: just run scripts/push-infinity-backup.sh (token auto-read)
- Project status unchanged otherwise: v14 package ready for the user's real-machine test (GUID fix + live KUSD build); verdict full-bridge vs reads-only vs both-bypassed comes from that run
---
Task ID: 21
Agent: Super Z (main)
Task: Analyze v14 BSOD report; root-cause; design+build+validate+ship v15

Work Log:
- Report: infinity-qemu-test-v14-Report.zip -> 3 photos (PS transcript / BSOD KMODE_EXCEPTION_NOT_HANDLED 60% / boot) + serial-phase-d.log (428 lines). Archived to version-archive/reports/ FIRST (durability).
- FIELD RESULTS BEFORE THE CRASH (v14's fixes WORKED): boot chain 100% green (v14 banners, EBS, VA, CVT st=0, armed). [CLR]: 3x "S OURVAR delete" (GUID fix proven — IsOurVariable now matches; the 5-delete step traces 3 because INFPROBE/INFCNT are not our-names). Step A: "G INFDIAG live" = FIRST successful RAM serve. Script transcript matches: [CLR] completed, step A/B header printed, then BSOD.
- ROOT CAUSE (the headline, disassembly-proven): SerialTrace::Hex64/Hex32 used 'static const char* k = "0123456789ABCDEF"' — the compiler materialized k as a POINTER SLOT in .data.rel.ro (disasm: mov r8,QWORD PTR [rip+0x10b05] # ...Hex64()::k; then movzx eax,BYTE PTR [r8+rax*1]). The slot holds the LOAD-TIME physical address; NOT in the ConvertGraph list; after Windows boots the stale address is unmapped -> the FIRST Hex64 call from the Windows kernel context = #PF = KMODE BSOD. Evidence fit: (a) serial truncates EXACTLY mid "[BLD] live KUSD read implausible =0x" — after Puts("=0x") (rip-relative, safe) and before the first Hex64 digit (stale-pointer deref); (b) EVERY prior post-VA trace ("G call#320 VIRT", "S OURVAR delete", "G INFDIAG live") is Begin/Puts/Putc/Dec — string literals are rip-relative LEAs; the [BLD] KV was the FIRST post-VA hex print EVER; (c) outb loops cannot fault (proven by the working traces). v12's BSOD gets REINTERPRETED: it truncated mid "flags=0x" (DiagWrite's Hex32) — SAME bug; the orig-SetVariable-in-dispatch theory was wrong (v13's 3 + v14's 5 chain runs all landed safely, no crash).
- SECONDARY bug: the v14 KUSD read returned an IMPLAUSIBLE value — +0x308 is NOT NtBuildNumber on live Win10 19045 x64 (base-repo "#111 fix" comment wrong; 0x260 is the classic x64 offset).
- v15 AUDITS before writing the patch: (1) all statics in runtime-reachable code — only the two SerialTrace k pointers are unfixed stale slots (kOurGuid is an object = rip-relative safe; main.c statics are objects/arrays; instance_/orig_*/RH/PF/PM/SMP pointers are ConvertGraph-converted); (2) library calls in serve paths — CopyMem->RtCopyMem, StrCmp->RtStrCmp, CompareGuid->RtCompareGuid all in-image runtime-safe loops (disasm-verified); (3) step E risk: script op=0xDEADBEEF == ReqOp_Ping exactly, and the PING handler is RAM-only (no finder/PM/page-walks) — the v15 run has ZERO untested dangerous paths (finder/Attach never run; ProcessSingleVariableRequest's Read/Write/Attach ops need a real payload the test script never sends).
- v15 BUILT (scripts/patch-v15.py V1a/V1b/V2a/V2b/V3a/V3b/V4a-e/V5, anchored on the v14 tree; build-v15.sh + test-v15-linux.sh + make-v15-script.py (17430 B script) + patch-v15-bat.py (from pristine patches/phase-d-v13.bat) + README-V15-FA.md). Two patcher iterations: V3b anchor had wrong indent (comment is col-0); post-patch sanity check initially flagged its own explanatory comment (regex now targets code-level declarations only).
- THE CRITICAL DISASSEMBLY PROOF (v15 RT): Hex64/Hex32 now emit 'lea r8,[rip+...] # ...Hex64()::k' (address COMPUTED, not loaded) at 140 sites; ZERO 'mov reg,QWORD PTR [rip+...] # ...Hex()::k' pointer loads remain (the 2 surviving QWORD loads near k are CONSTANT DATA — the INFDIAG magic 0x494E4644 and sizeof values, byte-dump-verified). build-v15.sh check stage now enforces both patterns permanently.
- VALIDATED: binary checks PASS (v15 RT banner, hex-safe serial + kusd probe, kusd raw 0x260/0x308, INFDIAG/INFCNT live, OURVAR, v15 early, u16 names; SAFE clean). Sandbox RT(A) PASS (full green chain incl. v15 banners, stage 1/2/3, CVT st=0, armed, kernel boot, documented NX stop — same as every version since v6) + SAFE(B) PASS (stage 1, kernel, /init, no hook lines, same initramfs quirk NOTE as v7).
- PACKAGE: download/infinity-qemu-test-v15.zip (3270130 B; SAFE 105032 B sha256 3f273436..., RT 120229 B sha256 af1acda4...; usb-d = 4 items, script 17430 B in root+usb-d+transfer, guard simulation PASS, phase-d.bat 10038 B with v15 banners; paren audit = the same 16 template-inherited shapes as the field-proven v13/v14 bats, zero new shapes). Archived to version-archive/packages/.
- README maps updated (v15 row + v14 report row + v15 hashes). Committed 780edcb + vault pushed (fulken/infinity-backup 05ba4a2..fa8f460, 9 commits).

Stage Summary:
- v14 verdict: GUID fixes + RAM serve + dual-write chains ALL WORK (field-proven in the 30 seconds before the crash); the BSOD was the SerialTrace hex-table pointer slot — NOT a design flaw of the observability architecture
- v12 BSOD root cause REVISED: same hex-table bug; orig-SetVariable chaining is now 8x field-proven safe
- v15 SHIPPED: download/infinity-qemu-test-v15.zip — crash class dead (arrays), KUSD offset settled empirically next run (raw values of BOTH candidates traced on serial)
- Expected v15 run: A/B moving + INFCNT=2 + flags 0x2B + InfinityResp ANSWERED + SUMMARY line "win_build driver-live=19045 script-side=19045" -> FULL BRIDGE
- BLOCKED on: user runs the v15 package (extract over old folder -> phase-d.bat must say "package v15" -> trigger-test-v15.ps1 elevated -> photos + serial-phase-d.log)

---
Task ID: 22
Agent: Super Z (main)
Task: v15 report analysis (BEST RESULT OF PROJECT) + workspace-rollback recovery re-archive + SPICE clipboard add-on

Work Log:
- Rollback discovered: workspace git at v12.2 (83d1ba2, 2026-09-20 18:21); no
  v13/v14/v15 sources, no Task 17-21 worklog entries, no .secrets token, no
  reflog/dangling/stash survivors, no env token. upload/ survived with ALL user
  evidence (v12/v13/v14/v15 reports + v13 forensics). During the analysis the
  real Tasks 17-21 were not yet available - provisional reconstruction entries
  17-R..21-R were written locally (superseded later the same day by the real
  vault entries; the reconstruction's only substantive misses: the v12 BSOD
  orig-call theory, and not knowing v15 was already vault-pushed)
- Extracted upload/infinity-qemu-test-v15-Report.zip (6 files: boot + PS Part1/
  Part2 photos + phase-b-check photo + 2 serial logs). VLM-transcribed both PS
  photos (upload/vlm-v15-ps1.json, upload/vlm-v15-ps2.json)
- ANALYSIS (full record: version-archive/reports/ANALYSIS-V15.md):
  * v15 verdict matrix: [1] GetVariable path via hook PROVEN (hook_calls live
    121->122->125->129->132->134, stage=4, flags=0x0F); [2] SetVariable path
    via hook PROVEN (INFCNT=2 = INFTRIGGER+InfinityReq, flags 0x0F->0x2F);
    [3] foreign/NVRAM path intact (INFPROBE 'B' readback, chained st=0 all over
    boot); [5] InfinityResp = 32 bytes returned, seq 0x1337 echoed CORRECTLY,
    but status=1 bytes=0 addr=0 -> request processing is the ONLY remaining
    defect. NO BSOD, script completed, clean phase-b-check after
  * KUSD live read WORKS: raw +0x260=0x4A65 (=19045, Win10 22H2 exactly
    matches script-side), +0x308=0; v15 picks 0x260 - Task 21's offset
    prediction confirmed empirically
  * Script cosmetic bugs found: byte-truncating display of win_build (19045->
    "101"), hook_calls (377->"121"), resp seq (0x1337->"0x37"); raw data is
    CORRECT. Step [4] "InfinityReq landed" expectation stale for RAM-consume
    design (ABSENT readback is correct v13+ behavior)
  * NVRAM INFDIAG after test = frozen stage-3 snapshot, hook_calls=251 =
    EXACTLY v13's value -> boot path deterministic/unchanged
- Re-archived (rollback recovery, before the vault was available): v12/v13/v14/
  v15 report zips + extracted-v14/ + extracted-v15/ (+VLM jsons) ->
  version-archive/reports/; ANALYSIS-V15.md written as the durable record
- SPICE clipboard add-on (user request #2, zero-disruption design):
  infinity-qemu-test/clipboard-addon/ = phase-d-spice.bat (same QEMU chain as
  phase-d + virtio-serial-pci + spicevmc vdagent port + -spice
  addr=127.0.0.1,port=5930,disable-ticketing=on; NO trigger-version guard on
  purpose so it works next to any package version; spicevmc pre-flight probe;
  WHPX 1/2 + TCG fallback; usb-d pristine gates kept) + spice-connect.bat
  (remote-viewer lookup: where + ProgramFiles VirtViewer* x2 + LocalAppData)
  + README-SPICE-FA.md (Persian: guest=spice-guest-tools which user already
  has, host=virt-viewer MSI from virt-manager.org, usage + troubleshooting)
  + VERSION-CLIPBOARD.txt (sha256s). CRLF-converted; paren-audited (mechanical
  balance 0/0, audit WARN confirmed as the known heuristic false positive);
  packaged -> download/infinity-clipboard-addon.zip (14090 B). Display adapter
  deliberately kept at default std VGA (no qxl) = minimal hardware delta
- User re-pasted the PAT (same 7-day validity ~2026-09-28); stored again at
  .secrets/github-token chmod 600; .gitignore confirmed

Stage Summary:
- PROJECT STATE: the bridge WORKS - both desktop paths intercept+answer through
  the hook, stable, with live build detection. At analysis time the one open
  question was response status=1 (resolved in Task 23: it IS Success - the
  bridge is COMPLETE; script expectations were the only defect). v16 = script
  dword parsing + expectation fixes + auto-tee output + banner cosmetics
- DELIVERED: download/infinity-clipboard-addon.zip (SPICE copy-paste, no
  project disruption, original phase-d.bat untouched)

---
Task ID: 23
Agent: Super Z (main)
Task: Vault recovery executed (PAT received) - restore v13/v14/v15 from vault + re-push + status=1 source diagnosis

Work Log:
- PAT re-pasted by user; validated (login fulken); stored .secrets/github-token
  (600). Vault state: private, HEAD 4f1d537 (pushed 2026-09-20 22:46, = Task
  21's fa8f460+1). The lost v15 session HAD pushed everything - no user
  round-trip needed for the v15 package after all
- Cloned vault -> backups/vault-restore; real worklog Tasks 17-21 recovered
  (key facts vs the reconstruction: v12+v14 BSODs = the SAME SerialTrace
  hex-table .data.rel.ro pointer-slot bug, disassembly-proven in Task 21;
  orig-SetVariable chaining is field-proven SAFE 8x; KUSD +0x260 is the
  correct x64 offset, +0x308 was a wrong base-repo comment; Tasks 1-16
  byte-identical between local and vault)
- Restored to workspace: patches/v13+v14+v15 efi pairs + phase-d-v13.bat;
  scripts build/patch/test v13+v14+v15 toolchain + make-v14/15-script.py +
  parse-vars-v13.py + token-fallback push script; packages v13/v14/v15 (archive
  + download/); reports/vars-forensics-v12-v13/; version-archive/README.md
  (v15-era); scripts/infinity-backup-README.md. Removed the duplicate
  v13-report-extracted/ (superseded by the vault's canonical vars-forensics
  dir + v13 report zip). Worklog reconciled: vault base (Tasks 1-21 real) +
  Task 22 above
- push-infinity-backup.sh: added clipboard-addon to the mirror list
  (addons/clipboard-addon) next to the inherited token-file fallback
- VAULT PUSH: synced today's v15 analysis + report + ANALYSIS-V15.md +
  clipboard addon + restored consistency
- status=1 DIAGNOSIS (source-level, definitive): refetched fulken/Infinity
  (fetch-infinity-repo.sh, bundle+tarball re-cached in backups/) + rebuilt the
  v15 tree (build-v15.sh --only tree at build-v15-tree/). READ THE CODE:
  * SharedMemoryProtocol.h enum SlotStatus: Pending=0, **Success=1**,
    ErrGeneric=2, ErrTimeout=3, ErrAccess=4, ... -> the v15 response
    {seq=0x1337, status=1, bytes=0, addr=0} is a PERFECT PONG
  * ReqOp enum: ReqOp_Ping = 0xDEADBEEF exactly (the script's op matched)
  * RequestHandler.h ProcessSingleVariableRequest: case ReqOp_Ping ->
    resp->status = SlotStatus_Success (inline path)
  * RuntimeHook.h: InfinityReq write (>=48B) -> CaptureLiveWindowsBuild() +
    handler_->ProcessSingleVariableRequest(req, last_resp_, ...) +
    last_resp_size_=32 -> return EFI_SUCCESS (RAM-consumed); InfinityResp read
    -> served from last_resp_ with full size protocol (BUFFER_TOO_SMALL etc.)
  => CONCLUSION: the v15 run achieved the FULL BRIDGE end-to-end. The script's
  "WRONG-CONTENT status=1" + "request processing failed" verdict was a FALSE
  NEGATIVE written against a wrong status=0 expectation (the enum has always
  been 1=Success since the base repo). ANALYSIS-V15.md corrected with a
  post-analysis correction section; v16 is script-side only (E2 expectation,
  dword parsing, [4] relabel, auto-tee) + optional driver cosmetics (v7 RT
  banner string, 0x=0x prefix, EBS-time offset). v17 direction: data-bearing
  round trips (ReqOp_Read of KUSD build dword through the bridge)
- Vault re-pushed after the correction (see below)

Stage Summary:
- Workspace = vault = post-v15-verdict state; single source of truth restored
- **HEADLINE: the Infinity UEFI bridge is COMPLETE and field-proven — desktop
  Windows SetVariable(GetVariable) round-trips through the hooked runtime
  services with a correct PONG, zero crashes, live build detection**
- v16 scope (script-only + cosmetics) locked; v17 direction = data path

---
Task ID: 24
Agent: Super Z (main)
Task: Build v16 (script truth fixes + driver cosmetics) per the locked Task-23 scope

Work Log:
- Restored the rollback-lost deployed files from the shipped v15 package:
  infinity-qemu-test/trigger-test-v15.ps1 (17430 B, sha matches zip root
  AND usb-d copies) + README-V15-FA.md (the make-v16 base)
- scripts/patch-v16.py: 12 cosmetic edits anchored on the exact v15 tree
  (all 12 anchors dry-run verified count==1 BEFORE patching): C1/C2 serial
  build lines (v15/v7 -> v16), C3/C4 the STALE SCREEN banners (said "v7 RT -
  EARLY gRT hooks (phase D2)" since phase D2 - now "v16 RT - full bridge
  proven (phase D COMPLETE)"; same padded width), C5/C6 efi_main/variant
  lines, C7 the "0x=0x" fix (KV appends "=0x" itself; labels
  "kusd raw 0x260=0x" -> "kusd raw 0x260"), C8/C8b KVD trailing spaces,
  C9/C10 RT-EARLY/RT-VA banners, C11 the EBS "windows build=0" line
  relabelled to "(EBS-time; 0 is normal - live probe fills)" + proven
  wording comment, C12 stale WindowsOffsets.h "0x308" header comment ->
  empirical truth (0x260=19045 live, 0x308 read 0)
- TWO patch iterations: C3/C4 first wrote the closing quote BEFORE the
  \r\n escape (invalid C, caught by the SAFE compile) - quote moved after
  the in-string \r\n, widths kept at v7 parity (57/59)
- scripts/make-v16-script.py -> trigger-test-v16.ps1 (19894 B, LF like v15,
  structurally tokenized: braces/parens/quotes balanced, no bare exit): S1
  header (v16 story), S2 Start-Transcript auto-tee (timestamped
  trigger-test-v16-output-*.txt beside the script; every exit routed
  through __Finish which stops the transcript), S3 all 4 abort paths ->
  __Finish, S4 banner, S5 THE DWORD FIX (U32 now plain [uint32] math - no
  -shl at all, immune to PS's byte-preserving shift semantics that
  truncated v15 displays: 19045->"101", 377->"121", 0x1337->"0x37"), S6
  A/B note, S7 E2 SlotStatus decode (0=Pending 1=Success 2=ErrGeneric
  3=ErrTimeout 4=ErrAccess 5=ErrInvalid 6=ErrNoBridge 7=ErrNotFound
  8=ErrUnsupported; ANSWERED = seq echoed + status=1; "PONG PERFECT"
  text), S8 consumption evidence (reqConsumed = INFCNT>=2 or PONG;
  NVRAM read-back ABSENT = EXPECTED), S9 [4] relabel, S10 verdict
  branches (v17 directions; full-bridge branch announces the data path),
  S11 frozen note, S12 build note + END banner + transcript stop
- scripts/patch-v16-bat.py -> phase-d.bat v16 (10322 B): pure v-bump of
  the pristine phase-d-v13.bat + 2 v16 additions (auto-save instruction
  block; [BLD] kusd milestone line). First iteration had a paren in the
  milestone line (17th audit shape) -> rewritten paren-free = EXACTLY the
  16 field-proven shapes. Multi-line bat anchors need \r\n (CRLF file)
- scripts/build-v16.sh + scripts/test-v16-linux.sh: v16 pipeline. TWO
  check-section fixes: (1) kBuildLine turned out to be DEAD CODE
  (compiler-eliminated since the v7 era) - the LIVE screen banner is the
  wide string, checked via strings -e l; (2) `set -o pipefail` +
  `strings | grep -q` is a SIGPIPE RACE (grep -q exits on first match ->
  strings dies 141 -> pipeline "fails" with the string present) - strings
  now collected into variables, greps use -qF herestrings
- BUILD: v16-memory-SAFE.efi 105032 B (sha 020d69c76e30f156...) +
  v16-memory-RT.efi 120229 B (sha b9ca2c6b5ce113c0...) - same sizes as
  v15 (cosmetics only). CHECKS: SAFE (clean + u16 banner + 2 strings),
  RT (10 strings incl. "memory.efi v16 RT", "full bridge proven, clean
  serial labels", "kusd raw 0x260/0x308" clean labels, "v16 early",
  "EBS-time; 0 is normal", "efi_main v16 boot"; double-prefix label ABSENT;
  4 u16 names; RT u16 screen banner) + VA-safety disassembly: 0 stale
  pointer loads, 140 rip-relative LEA hex sites (identical to v15 - the
  hex code is untouched)
- SANDBOX: A (RT) PASS - full green chain (v16 banners, stage 1/2/3, CVT
  st=0 all, armed, kernel boot, documented NX stop, no double-prefix BLD)
  + B (SAFE) PASS (stage 1, kernel, /init, no hook lines, same initramfs
  quirk NOTE as v7/v15)
- README-V16-FA.md (Persian): the v15 verdict correction story, what v16
  changes, expected ">>> FULL BRIDGE PROVEN" output, no-photos flow
- PACKAGE: download/infinity-qemu-test-v16.zip (3273344 B; SAFE 105032 B,
  RT 120229 B; 3 identical script copies root+usb-d+transfer; bat size
  line 19894 matches; VERSION.txt hashes all match; guard simulation
  PASS; no stale versioned files; paren audit = the 16 field-proven
  shapes). Archived to version-archive/packages/
- U32 SIMULATION against the REAL v15 field bytes: win 65 4A 00 00 -> v15
  displayed 101, v16 will display 19045; calls 79 01 00 00 -> 121 -> 377;
  seq 37 13 00 00 -> 0x37 -> 0x1337; PONG condition (seq==0x1337 and
  status==1) now evaluates TRUE
- version-archive/README.md: v16 table row + v15/v16 zip + driver hashes +
  the v15 REPORT row (best result of the project, with the source-level
  correction)

Stage Summary:
- v16 SHIPPED: download/infinity-qemu-test-v16.zip - the v15 bridge with
  honest instrumentation; driver is FUNCTIONALLY IDENTICAL to v15
  (cosmetics only), the script now tells the truth
- Expected v16 run: ">>> FULL BRIDGE PROVEN - PHASE D COMPLETE <<<" +
  "[5] ... PONG PERFECT" + win_build driver-live=19045 script-side=19045
  + [4] consumed YES - and the run self-documents via the auto-tee .txt
- BLOCKED on: user runs the v16 package (extract over old folder ->
  phase-d.bat must say "package v16" -> trigger-test-v16.ps1 elevated ->
  send the trigger-test-v16-output-*.txt + serial-phase-d.log, no photos)
- v17 direction (locked): data-bearing round trips - ReqOp_Read of a
  known-safe dword (e.g. KUSD build) through the bridge, proving the DATA
  path (payload + crc) that the real client (Infinity.exe) uses
---
Task ID: 25
Agent: Super Z (main)
Task: Analyze the v16 field report (verdict confirmation) + design/build/ship v17 (the data-path proof)

Work Log:
- USER PROBLEM REPORT (Persian): the run went exactly as predicted and
  the report was sent, BUT the auto-tee .txt could not be saved - the
  user's D: drive is READ-ONLY, so they photographed the PowerShell
  window in 2 parts + sent the reports (upload/infinity-qemu-test-v16-
  Report.zip, 861505 B)
- v16 REPORT ANALYSIS: extracted to upload/extracted-v16 (4 PNGs +
  serial-phase-d.log 20624 B + serial-check.log); VLM OCR of both
  PowerShell parts (vlm-v16-ps1/2.json) + boot/check shots
  (vlm-v16-boot-check.json). VERDICT = ">>> FULL BRIDGE PROVEN - PHASE
  D COMPLETE <<<" - the script's own verdict, exactly as predicted:
  * A/B live reads: STAGE=4 flags=0xF win_build=19045 calls 381->382
    (B=A+1 = read path PROVEN; FIRST field observation of stage 4)
  * C INFPROBE raw NVRAM write+readback OK; D flags 0xF->0x2F =
    TRIGGER-SEEN(0x20) SET; E PING req verified pre-send
  * E2 InfinityResp: 37 13 00 00 01 00 00 00 ... = seq=0x1337 echoed
    + status=1(Success) + bytes=0 -> PONG PERFECT (the E2 fix works;
    v15's false-negative is dead and buried)
  * F: InfinityReq read-back ABSENT (Win32=203) = expected RAM-consume;
    G: INFCNT=2 (both counted writes reached the hook)
  * SUMMARY all green: hook_calls 381/382/385/389/392/394 monotonic,
    win driver-live=19045=script-side
  * serial-phase-d.log correlates PERFECTLY: 6x "G INFDIAG live" =
    steps A-F, "S call#384 VIRT" = INFPROBE write, kusd BLD lines
    (0x4A65/0x0/19045 - the clean labels work), log ends at "G INFCNT
    live" = step G firing; NVRAM check = frozen stage-3 snapshot
    (os_cr3=0x7FC01000, hook_calls=0x114) - exactly the v13+ design
- THE D: MYSTERY SOLVED: phase-d.bat (since v9) attaches usb-d as
  readonly=on ON PURPOSE (2026-09-20 FAT-corruption lesson) - the
  script lives on that stick, so "save transcript beside the script"
  could NEVER work. v17 must probe writability and fall back
- ANALYSIS-V16.md written (version-archive/reports/), report zip +
  extracted evidence + VLM jsons archived there too
- v17 DESIGN (source-read driven): RequestHandler.h variable path
  ReqOp_Read uses ProcessMemory::ReadVA which needs target_cr3_
  (set ONLY by ReqOp_Attach - no emulator in the clean VM). The
  field-proven KUSD read (CaptureLiveWindowsBuild) is a DIRECT
  dereference (VA-gated) - but that has a #PF path for bad VAs. THE
  SOLUTION: kernel-target reads via the CURRENT CR3 + the EXISTING
  page-walk: phys_->ReadVA(va, ReadCr3(), ...) - TranslateVA checks
  canonical+present BEFORE any dereference, all data reads are
  physical via the UEFI identity map (CR3-switch dance) => a bad VA
  returns ErrAccess, there is NO #PF/#GP path at all. This is also
  the EXACT mechanism the real client uses for process reads - proving
  it proves the product core. ReadCr3() inside the gRT hook = the
  calling Windows thread's kernel CR3, which maps KUSD
- scripts/patch-v17.py (11 anchors, all count==1 verified dry-run
  first): F1 SharedMemoryProtocol.h KERNEL_TARGET_PID=0xFFFFFFFF
  (inline constexpr, ABI-neutral, protocol v2 unchanged); F2
  ProcessMemory.h ReadKernelVA (current-CR3 walk, no kernel fallback
  for writes); F3 RequestHandler.h variable-path ReqOp_Read kernel
  branch + SerialTrace KV/KVD("RD","kern va"/"kern read ok") literals
  (rip-relative LEAs - NOT pointer slots, the v12/v14 BSOD rule);
  C1-C8 cosmetics (serial lines, screen banners padded to the exact
  v16 58-char width, efi_main/variant/RT-EARLY/RT-VA -> v17)
- BUILD: v17-memory-SAFE.efi 105032 B (identical size to v16 - SAFE
  links out the handler kernel branch) + v17-memory-RT.efi 120678 B
  (+449 = the kernel-read code). R4 GLOB_DAT 0, R6 orphan .bss clean
- CHECKS: all v17 strings present (incl. "kern va"/"kern read ok"),
  no double-prefix KV label, u16 names + banners, VA-safety
  disassembly: 141 rip-relative LEA hex sites (v16 had 140), 0
  pointer-slot loads, .data.rel.ro did not grow vs v16
- SANDBOX: A (RT) 13/13 PASS (full green chain + v17 banners +
  documented NX stop); B (SAFE) PASS (stage 1, kernel, /init, no hook
  lines, same known initramfs quirk note). NOTE: the [RD] kern lines
  cannot fire in the Linux sandbox (they need a Windows-side
  InfinityReq kernel read) - binary string checks cover them
- SCRIPT: scripts/make-v17-script.py -> trigger-test-v17.ps1 (30240
  B, 9 anchored edits from the v16 script): transcript writability
  probe (beside script -> Desktop -> TEMP) + end-of-run file
  verification + copy-out instructions (transfer stick +
  refresh-files.bat); NEW steps H..N: H InfinityData 32B pattern
  round trip (byte-exact), I ReqOp_Attach decode (expect
  ErrNotFound(7) on clean VM), J kernel read KUSD+0x260 x4
  (pid=FFFFFFFF; expect data 65 4A 00 00 = 19045 = script-side), K
  +0x308 (expect 0), L x8 chunk consistency with J, M non-canonical
  0xDEADBEEF00000000 (expect ErrAccess(4), no crash), N final INFCNT
  (expect 8 = 2 baseline + 6 new); SUMMARY [6][7][8][9] + INFCNT
  accounting; verdict branch ">>> DATA PATH PROVEN - FULL PROTOCOL
  COMPLETE <<<" above the v16 branches (stale-driver case degrades
  honestly to the v16 verdict)
- AUDIT (scripts/audit-v17-script.py): braces/parens/brackets
  balanced (herestring-aware), no bare exit, 5 __Finish sites, guard
  marker present, H..N headers exactly once, hex-literal safety
  (64-bit values via [Convert]::ToUInt64 - the v10 rule; KERNEL_PID
  via [Convert]::ToUInt32), verdict ordering; 4 audit-script false
  positives fixed (herestring opener at line end, comment dashes
  substring, hex inside display strings, header-comment verdict
  match). $I/$i case-insensitivity checked: zero uses of $i after
  step I -> safe
- BAT: scripts/patch-v17-bat.py (18 anchored subs from the v16 bat,
  idempotent re-run guard added) -> phase-d.bat v17: guard
  "trigger test v17", size line 30240 B, banner expectation "kernel
  data path: current-CR3 reads", the auto-save block REWRITTEN
  (first WRITABLE drive - the boot stick is read-only by design),
  [INF][RD] milestone lines, stale-warning v10..v16. Paren audit:
  the same 16 field-proven shapes as v16 (verified against the v16
  package bat), ZERO new risky lines
- README-V17-FA.md (Persian): the v16 verdict news, the D: read-only
  explanation, the H..N table, expected output, the transfer-stick
  file-out flow, v18 direction
- PACKAGE: download/infinity-qemu-test-v17.zip (3283127 B) - verified:
  usb-d exactly 4 items, 3 identical script copies (md5), VERSION.txt
  hashes match, bat says package v17 + size line, guard simulation
  PASS. Archived to version-archive/packages/
- version-archive/README.md: v17 row (packages table), v17 file
  hashes, v16 REPORT row (the field-confirmed FULL BRIDGE verdict)
- COMMIT 0a3540e + VAULT PUSHED (fulken/infinity-backup main HEAD
  29ea325, 14 commits)

Stage Summary:
- v16 FIELD RESULT OFFICIALLY CONFIRMED: the Infinity bridge is
  COMPLETE and twice field-proven. Project milestone reached.
- v17 SHIPPED: download/infinity-qemu-test-v17.zip - kernel-target
  reads (pid=0xFFFFFFFF -> current-CR3 page-walk -> physical reads
  only, no fault path), script steps H..N replicate the real
  Infinity.exe data flow, J must return 19045 through the bridge,
  transcript read-only fix included
- Expected v17 run: ">>> DATA PATH PROVEN - FULL PROTOCOL COMPLETE
  <<<" + "[J] data: 4 bytes: 65 4A 00 00" + MATCH line + serial
  [INF][RD] kern va/kern read ok lines
- BLOCKED on: user runs the v17 package (extract over old folder ->
  phase-d.bat must say "package v17" -> trigger-test-v17.ps1 elevated
  -> send the trigger-test-v17-output-*.txt - now saved on a writable
  drive with copy-out instructions - + serial-phase-d.log)
- v18 direction (locked): attach to a real emulator process inside
  the VM (e.g. run an Android emulator) and read PROCESS memory
  through the bridge - the production integration step
