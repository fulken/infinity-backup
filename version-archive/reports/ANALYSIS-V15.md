# INFINITY — v15 Test Report Analysis (user run, 2026-09-21)

- Report: `infinity-qemu-test-v15-Report.zip` → `extracted-v15/` (photos transcribed via VLM: `vlm-v15-ps1.json`, `vlm-v15-ps2.json`)
- Driver: memory.efi **v15 RT "hex-safe serial + kusd probe"** (serial line 83)
- Guest: Windows 10 22H2 **build 19045** (PowerShell 5.1.19041.7663)
- Boot mode: phase-d (usb-d read-only stick + OVMF pflash), same chain as v9–v14

## VERDICT — best result of the whole project

**BOTH hook paths are now PROVEN from the Windows desktop, the v14 BSOD is fixed,
the live KUSD build read works, and the machine survived the entire trigger script.
The only remaining defect is the request→response processing: InfinityResp comes
back with a well-formed header (seq echoed) but `status=1`, `bytes_transferred=0`.**

Script SUMMARY (verbatim from Part2 photo):

```
hook_calls  A=121 B=122 C=125 D=129 E=132 F=134     (LIVE and moving)
stage F=4  flags F=0x2F  trigger_seen(0x20)=SET
winbuild   driver-live=101  script-side=19045       (see script-bug note below)
INFCNT live RAM count (our-var writes that reached the hook) = 2
[1] GetVariable path via hook : PROVEN (hook_calls moves between reads)
[2] SetVariable path via hook : PROVEN (INFCNT=2, flag 0x20)
[3] INFPROBE landed in NVRAM  : YES (raw firmware write path works)
[4] InfinityReq landed, op ok : NO
[5] InfinityResp PING         : WRONG-CONTENT seq=0x37 status=1
VERDICT: Both paths reach the hook (reads + writes), but the response was not
served - the request processing path failed inside the driver.
```

Per-signal decoding:

| Signal | Evidence | Meaning |
|---|---|---|
| Read path | hook_calls 121→122→125→129→132→134 (raw dword 0x179→…), stage=4, flags=0x0F | every desktop GetVariable passes through our hook; INFDIAG is answered LIVE from RAM (freshen+count) |
| Write path | INFCNT=2 (INFTRIGGER + InfinityReq), flags 0x0F→0x2F (bit 0x20 = trigger-seen), serial "S OURVAR write" ×2 | our-namespace SetVariable calls reach the hook and are consumed in RAM (NOT chained to NVRAM — hence step F "InfinityReq read-back: ABSENT (203)" is EXPECTED, not a failure) |
| Foreign path intact | INFPROBE (neutral GUID) write→read-back 'B' (0x42); boot log full of "G/S/T chained st=0" | raw NVRAM write path via orig chaining unharmed |
| KUSD live read | serial: `kusd raw 0x260=0x4A65`, `kusd raw 0x308=0`, `live windows build (ofs 0x260) =19045` | build detection WORKS: 0x4A65 = 19045 = Win10 22H2. v15 probes both offsets and picks the plausible one. (Empirical fact on this guest: +0x260 holds the build, +0x308 reads 0. Field-name attribution deliberately not asserted — the probe-both-and-pick approach is version-robust.) |
| Stability | serial log complete through step G, script printed `==== END v15 ====` and returned to a clean PS prompt, then a clean phase-b-check boot | **no BSOD, no hang** |

## v14 BSOD — root cause PROVEN (from surviving extracted-v14/serial-phase-d.log)

Line 428-429 of the v14 log:

```
[INF][HOOK] G INFDIAG live
[INF][BLD] live KUSD read implausible =0x
```

The log **ends mid-line at `=0x`** — the machine died INSIDE the serial hex
formatter while printing the KUSD value read at trigger time. Sequence of events:
the v14 GUID fix had just activated the our-var RAM paths (INFDIAG was served
live — line 428 proves it), then the very next print of the KUSD dword killed
the machine. v15 fixed exactly this with:
1. **hex-safe serial** — custom VA-safe hex printer replacing the old formatted-print call in hook context (note the cosmetic leftover `0x=0x` double prefix in v15's own [BLD] lines — same print path, harmless);
2. **kusd probe** — dual-offset probe (0x260 and 0x308) instead of the fixed 0x308 read that returned 0 (and whose formatted print crashed).

So the v14 suspects list resolves to: NOT the GUID fix (that was correct and is why
v15 works), NOT the S-hook chain (chaining stayed clean), but the **serial print
formatting inside the VIRT-mode hook path**.

## NVRAM after the test (phase-b-check, serial-check.log)

`dmpstore INFDIAG -guid A1B2C3D4-…` (fresh boot, driver not loaded):

```
44 46 4E 49 03 00 00 00 0B 00 00 00 00 00 00 00   DFNI stage=3 flags=0x0B win_build=0
00 10 C0 7F 00 00 00 00 FB 00 00 00 00 00 00 00   os_cr3=0x7FC01000 hook_calls=0xFB(251) last_st=0
```

= the frozen stage-3 snapshot (written at boot-stage transitions only, by design —
live reads are answered from RAM). `hook_calls=251` matches v13's frozen value
EXACTLY → the boot-time path is deterministic and unchanged v13→v15. `win_build=0`
in the snapshot is expected: the EBS-time read (serial "windows build=0") still
happens before KUSD is populated / at the wrong offset; only the trigger-time live
probe fills the real value.

## Script-side cosmetic bugs (trigger-test-v15.ps1 — fix in v16 script)

The driver's raw data is CORRECT; the script displays some fields byte-truncated:

| Field | Raw (correct) | Script displayed |
|---|---|---|
| win_build | `65 4A 00 00` = 0x4A65 = **19045** | "101" (0x65 low byte) |
| hook_calls | `79 01 00 00` = 0x179 = **377** | "121" (0x79 low byte) |
| resp sequence | `37 13 00 00` = **0x1337** (echoed correctly!) | "0x37" (low byte) |

So the SUMMARY line "winbuild driver-live=101 script-side=19045 (equal = build
detection works)" actually resolves to **equal** (19045 == 19045): build detection
is confirmed working; only the display truncated it. The response sequence echo is
also CORRECT (0x1337 in = 0x1337 out) — the response header is well-formed; the
defect is purely `status=1, bytes_transferred=0, out_address=0`.
Also: step [4] "InfinityReq landed, op ok: NO" tests an NVRAM-landing expectation
inherited from v11-era scripts; under the v13+ RAM-consume design, ABSENT is the
expected result and should be re-labelled.

## Open items → v16

1. **Request processing**: InfinityResp = {seq=0x1337 ✓, status=1 ✗, bytes=0, addr=0}.
   Candidates: (a) op-code/layout mismatch between the script's PING (48 B:
   seq=0x1337, op=0xDEADBEEF) and the v15 handler's parser; (b) v15 handler
   stubbed to ack-only while the lost session focused on the crash fix;
   (c) response slot treated as uninitialized. Needs the v15 SOURCE
   (vault `05ba4a2` or newer) — or binary RE of the user's v15 memory.efi.
2. Script: dword-correct parsing + re-labelled expectations + auto-tee output
   to the transfer stick (so future tests need neither photos nor clipboard).
3. Cosmetic: boot banner still says "Build: v7 RT" (serial line 62); [BLD]
   double "0x=0x" prefix; EBS-time build capture reads 0.

## Workspace rollback (2026-09-21) — recovery state

- Local git rolled back to **v12.2 (83d1ba2, 2026-09-20 18:21)**: all v13/v14/v15
  source, build scripts, Task 17–21 worklog entries and the stored PAT
  (`.secrets/github-token`, Task 20) were lost locally.
- Vault `fulken/infinity-backup` @ `05ba4a2` (99 files / 40 MB) holds everything
  through v14 + evidence (per Task 19/20). Whether the lost v15 session pushed
  is unknown until we can clone (needs PAT re-paste from the user — the 7-day
  token from Task 20 is still valid until ~2026-09-28 but no local copy survives).
- Re-archived today from surviving `upload/` evidence: v12/v13/v14/v15 report
  zips + extracted-v14 + extracted-v15 (+VLM jsons) + the whole extracted-v13
  (incl. NVRAM forensics varsV12/varsV13 OVMF_VARS_4M.fd dumps).
- v13 conclusions (corrected by v14 forensics, now fully proven by v15): the
  "desktop bypass" theory is dead — BOTH paths reach the hook; v13's frozen
  counters / absent responses were CompareGuid-bug artifacts all along.
