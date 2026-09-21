# ANALYSIS-V16 — Field Report Verdict: FULL BRIDGE PROVEN

- Report received: 2026-09-21 (infinity-qemu-test-v16-Report.zip, 861505 B)
- Contents: 2 PowerShell photos (part1/part2, D: was read-only so the
  auto-tee .txt could not be saved), phase-d-boot.png, phase-b-check.png,
  serial-phase-d.log (20624 B, ends at "G INFCNT live" — capture cut when
  the script's step G fired), serial-check.log
- Verdict printed by the script itself: **>>> FULL BRIDGE PROVEN -
  PHASE D COMPLETE <<<** — exactly as predicted before the run.

## Step-by-step (PowerShell, verbatim values)

| Step | Observation | Meaning |
|------|-------------|---------|
| ENV  | PS 5.1.19041.7663, Windows build 10.0.19045.0 | script-side ground truth |
| A/B  | STAGE=4 flags=0xF win_build=19045 os_cr3=0x7FC01000 calls 381→382 | reads LIVE from RAM via hook; B=A+1 = read path PROVEN; **first field observation of stage 4** |
| C    | INFPROBE write Win32=0, read-back 1 byte 0x42, calls 385 | raw NVRAM write path works |
| D    | flags 0xF→0x2F = TRIGGER-SEEN(0x20) SET, calls 389 | hook saw the trigger write |
| E    | InfinityReq 48B ping, req[0..7]=37 13 00 00 EF BE AD DE verified pre-send, calls 392 | real request through the hook |
| E2   | InfinityResp 32B: 37 13 00 00 01 00 00 00 … → seq=0x1337 status=1(Success) bytes=0 addr=0 | **PONG PERFECT** — SlotStatus enum decoded correctly (v15's "WRONG-CONTENT" was the false negative, confirmed) |
| F    | STAGE=4 flags=0x2F calls=394; InfinityReq read-back ABSENT (Win32=203) | RAM-consume design working as intended |
| G    | INFCNT read-back 4 bytes: 02 00 00 00 = **2** | both counted writes (INFTRIGGER + InfinityReq) reached the hook |

## Summary block (all green)

- hook_calls A=381 B=382 C=385 D=389 E=392 F=394 — monotonically
  increasing; every step went through the hook.
- win_build driver-live=19045 = script-side=19045 — live build
  detection through the bridge matches the OS.
- [1] GetVariable path via hook: PROVEN
- [2] SetVariable path via hook: PROVEN (INFCNT=2, flag 0x20)
- [3] INFPROBE landed in NVRAM: YES
- [4] InfinityReq consumed (RAM): YES (PONG proves it)
- [5] NVRAM read-back absent: EXPECTED (v13+ consumes in RAM)
- InfinityResp PING: ANSWERED seq=0x1337 status=1(Success) - PONG PERFECT

## Serial correlation (serial-phase-d.log)

- v16 banners all present: "efi_main v16 boot", "variant: RT (EARLY gRT
  hooks - v16)", screen banner "v16 RT - full bridge proven (phase D
  COMPLETE)", "memory.efi v16 RT (full bridge proven, clean serial
  labels)", "hooks already installed at load (v16 early)".
- Boot chain complete: CR3/ImageBase/mmap/pool/handler/RT-EARLY hooks
  (orig+hook addresses traced)/VA graph/EBS hook/DIAG stage=1.
- Shell→bootmgr chained (G/S BOOT-CTX calls 1..64), kernel load
  (T calls, 100s), EBS FIRED st=0 (stage 2), VA event (stage 3),
  ConvertPointers 16/16 st=0, "virtual mode armed (stage 4)".
- VIRT mode: first Windows GetVariable at call#320, then
  **[BLD] kusd raw 0x260=0x4A65 / 0x308=0 / live windows build
  (ofs 0x260)=19045** — the v16 clean labels (no double "=0x") work.
- Script steps visible in serial: 3 stale-probe deletes, then exactly
  **6 "G INFDIAG live"** = steps A,B,C,D,E,F; "S call#384 VIRT" =
  INFPROBE write; S OURVAR writes = INFTRIGGER + InfinityReq;
  "G OURVAR read" = INFPROBE read-back + InfinityReq absent-probe;
  final line "G INFCNT live" = step G reading the live counter.
- NVRAM check (serial-check.log): INFDIAG frozen at stage=3 flags=0x0B
  win_build=0 os_cr3=0x7FC01000 hook_calls=0x114(276) last_status=0 —
  the frozen boot-time snapshot, exactly the v13+ design (live state
  lives in RAM, served by the hook).

## The one defect found: auto-tee vs READ-ONLY boot disk

- phase-d.bat (since v9) attaches usb-d as `readonly=on` on purpose
  (2026-09-20 FAT corruption lesson). The script lives on that stick
  (D:), so "save the transcript beside the script" can never work in
  the phase-d flow. User photographed the screen instead (2 parts).
- v17 fix: writability probe → fallback Desktop → %TEMP%, plus
  end-of-run file verification and copy-out instructions.

## v16 fixes validated in the field

1. DWORD parser (plain [uint32] math): 19045 / 381-394 / 0x1337 all
   displayed correctly (v15 showed 101 / 121 / 0x37).
2. SlotStatus decode: status=1 named "Success", PONG condition true.
3. [4] relabel: ABSENT read-back presented as EXPECTED.
4. Auto-tee: started fine, but the target dir was read-only (above).
5. Driver cosmetics: serial build lines + screen banner v16, no
   double "=0x" prefix, EBS-time build line relabelled — all confirmed.

## Project state after v16

- **The Infinity UEFI bridge is COMPLETE and field-proven twice**
  (v15 run + v16 honest-instrumentation run): Windows → UEFI runtime
  variable → our hook → processed → response, zero crashes, live
  build detection, stage 4 reached.
- Remaining unproven: the DATA path (payload transport) that the real
  client (Infinity.exe) uses for process memory — ReqOp_Read/Write
  with address+size → response + InfinityData payload.
- v17 (locked): kernel-target reads (pid=0xFFFFFFFF → current-CR3
  walk through ReadPhysical — no dereference path exists for bad VAs),
  KUSD +0x260 round trip expected to return 19045 through the bridge,
  negative VA test expects ErrAccess without crashing, InfinityData
  buffer round trip, ReqOp_Attach decode, final INFCNT=8 accounting,
  auto-tee read-only fix.
