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
# ============================================================
# INFINITY bridge trigger test v36  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v35 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v36 is SCRIPT-ONLY, the
# 4th run of the SAME field-proven binary; op-12 stays RETIRED
# (zero sends - it killed the VM twice, both fingerprint-confirmed).
#
# THE v36 STORY (one bug found, one bug fixed):
#   The v35 field run was a FULL SUCCESS *except* the dump: 78 s,
#   zero crashes, the 9th green K/L/M/J/W regression, W2 now PASS
#   (exit-race tolerant), and the RECON captured everything:
#     - MmPteBase @ pe_base+0xCFB358 = 0xFFFF9C0000000000, s=0x138
#       - PTE-BASE SHAPED live. Chain A's RVA is CORRECT here.
#     - ALL FIVE researched MmPfnDatabase RVAs are WRONG on this
#       build: R3/R6/R7 dead, R4 (0xCFC500) = a page-aligned
#       module-base-class pointer (THE killer slot - deref would be
#       pdb+0x1AD*0x30+8, the exact fingerprint of both BSODs),
#       R5 (0xCFC510) = 0xFFFFF98000000000 (same weak-check poison).
#     - step 0 gave BOTH crashes' full args: both decompose as
#       pdb + 0x1AD*0x30 + 8 with the live System dtb pfn = 0x1AD.
#   THE DUMP SKIPPED ITSELF: the v35 D1 plausibility gate wanted
#   nsec <= 24, but this kernel LEGITIMATELY has 33 sections (the
#   hotpatch-era layout: .rdata, .pdata, .idata, .edata, PROTDATA,
#   GFIDS, Pad1, .text, PAGE, PAGELK, POOLCODE, PAGEKD, ... + the
#   tail where .data and the recon RVAs live). Fail-closed did its
#   job - the VM survived and the skip was LOUD, not silent. THIS
#   is why the .bin/.manifest.txt files were never created (they
#   were NOT lost - the dump never started).
#
# v36 = the SAME crash-proof kit with the gate fixed:
#   - D1 now accepts nsec in [1..96] (PE's practical maximum).
#   - D2 assembles the section table from <=1024B chunk reads
#     (33*40 = 1320 B exceeds the proven single-read size).
#   - The RECON runs again: a fresh-boot MmPteBase + the poison
#     slots re-read on the SAME boot the dump lands from - the
#     offline analysis matches the dumped .data bytes against the
#     live R-values, zero cross-boot assumptions.
#   - The dump: minutes of [D] progress lines with ETA, resumable;
#     ntoskrnl-data-*.bin + .manifest.txt land on the Desktop.
#
# ============================================================
# INFINITY bridge trigger test v35  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER - UNCHANGED from v35 (memory.efi v26 RT,
# 140582 bytes, sha256 c8f79b95...921bb). v35 is SCRIPT-ONLY: it
# runs the SAME field-proven driver and simply NEVER SENDS op-12.
#
# THE v35 STORY (why the P-ladder is gone):
#   v34 = THE SECOND F4-ERA BSOD (0x50 PAGE_FAULT_IN_NONPAGED_AREA
#   inside PowerShell, same as v33). The v34 run's step 0 captured
#   the v33 crash's FULL bugcheck args:
#     0x50 (0xfffff807154e5078, 0, 0xfffff8071d08707c, 0)
#   and 0xfffff807154e5078 - 0xfffff807154e0000 = 0x5078 =
#   0x1AD*0x30 + 8 EXACTLY: pfn 0x1AD (the v33 boot's System DTB
#   0x1AD000 >> 12), stride 0x30 (sizeof _MMPFN), +8 (.PteAddress).
#   THE FINGERPRINT NAMES THE KILLER: op-12's chain B --
#     pdb + pfn*0x30 + 8 ; PT_R64(slot)   [a RAW deref]
#   with pdb = a GARBAGE page-aligned kernel pointer read from a
#   WRONG nt!MmPfnDatabase RVA (the 5 researched candidates do not
#   match this build; the only validation was canonical+aligned,
#   which random kernel pointers pass). NOT the v25 formulas: with
#   chain A's correct base, the old formula addresses stay INSIDE
#   the mapped PTE space and can only return wrong data, never
#   fault. The v26 formula fix was real but irrelevant to both
#   deaths -- chain B's unvalidated deref survived it ("constants
#   intact") and killed the VM a second time.
#
# WHAT v35 DOES INSTEAD (all through the L1-L5-PROVEN op-1 image
# gate -- zero out-of-image reads, the VM cannot die from this):
#   [R] RECON: read the 7 candidate qwords + the op-11 dtb echo;
#       shape-check the pteBase candidates (PS mirror of the
#       driver's ValidPteBase + the collision guards s=0x100
#       [MmSystemRangeStart] / 0x1EF [KUSD] - and display the
#       deadly arithmetic (pdb + pfn*0x30 + 8) for the record.
#   [D] THE .data DUMP: the whole .data section, 1024B chunks,
#       self-verified + resumable + manifest. The offline analysis
#       of this dump pins the TRUE MmPteBase (and whatever else
#       this build's .data holds at the candidate RVAs) -- and the
#       v36 walk kit ships with VERIFIED constants. No more
#       researched-RVA guessing (it cost two VMs).
#   op-12 is RETIRED THIS RUN: nothing in v35 sends it. The v34
#   script on the stick is DO-NOT-RUN (its P1 is the BSOD op).
#
# ============================================================
# INFINITY bridge trigger test v34  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v26 DRIVER (memory.efi v26 RT - "anchors + exports
# + process walk + page tables (F4)", 140582 bytes, sha256
# c8f79b95...921bb). v26 = v25 + THE FORMULA FIX - the v33 run
# was the FIRST F4-ERA BSOD (0x50 PAGE_FAULT_IN_NONPAGED_AREA,
# inside op-12, never returned): v25 addressed the upper page-table
# levels at PTE_BASE + shifted-vpn*8, which are LOW-USER PTE slots
# - the first PTE-space read walked PML4E[0] of the CALLER process
# (absent in the trigger script's context) and faulted. v26 reads
# the TRUE level bases:
#   PDE_BASE = PTE_BASE + (s<<30)
#   PPE_BASE = PDE_BASE + (s<<21)
#   PXE_BASE = PPE_BASE + (s<<12)     (PML4E[s] lives at PXE+s*8)
# - exact-matched against the published classic pre-1607 s=0x1ED
# constants (0xFFFFF6FB40000000 / 0xFFFFF6FB7DA00000 /
# 0xFFFFF6FB7DBED000). Every corrected slot walks only the
# s-self-ref chain + parents already proven present (fault-free).
#
# ALSO FIXED IN v26:
#   - chain-B identity: PteAddress == PXE_BASE + s*8 (the PML4's
#     own PTE slot; v25 compared PTE_BASE + s*8 -> B always missed)
#   - selfOk is now a BITMASK: bit0 = the PTE space is LIVE (the
#     self-ref slot read present + sane frame); bit1 = self frame
#     == System CR3 - EXPECTED 0 HERE: this PowerShell process runs
#     on ITS OWN PML4, and the self-ref read through the CURRENT
#     page tables points at the CALLER's PML4, not System's. The
#     v25 expectation (selfOk==1 meaning frame==SystemCR3) was
#     wrong for the caller context.
#   - the PtRd64 range gate is wrap-free (s=0x1FF would overflow)
#   - host 101/101 on a TRUE-SEMANTICS world (a REAL 4-level
#     hierarchy served by an independent hardware walk - the v25
#     world shared the engine's wrong formulas, which is why 89/89
#     passed while the VM died) + class-kills: the v25 engine dies
#     at 0xFFFFD58000000D58 = the EXACT field BSOD read; redacted
#     constants = 15 clean fails. Disasm-verified; bench A 13/13.
#
# The P-ladder expectations are UNCHANGED (same 80B payload, same
# statuses, same P7 DTB cross-check) except selfOk's bit semantics.
#
# ============================================================
# INFINITY bridge trigger test v33  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v25 DRIVER (memory.efi v25 RT - "anchors + exports
# + process walk + page tables (F4)", 141154 bytes, sha256
# 022e6d1c...09b398b). v25 = v24 + op 12 TranslateVa: VA ->
# page-table walk through the SELF-MAP (no CR3 switching - the
# v17/v19 lesson; no physical reads; no kernel calls). PTE_BASE
# discovery via TWO ordered chains: A = nt!MmPteBase (.data, RVA
# candidates 0xCFB358/0xCFA358 from 19 real 19041/19045 PDBs) with
# the 512-value structural check (A gates ALL out-of-image reads:
# a drifted patch level refuses CLEANLY, VM alive); B = the PFN
# bootstrap (MmPfnDatabase -> System CR3 from EPROCESS+0x28 ->
# _MMPFN.PteAddress -> the s-identity); A and B must AGREE. The
# TWO-WAY PROOF: PML4E[s] must point at the System CR3 frame - the
# page tables and the EPROCESS validate each other. Host-proven
# 89/89 incl. the T26 drifted-world and T32 absent-parent
# class-kills; disasm-verified; bench A 13/13 + B 5/5.
#
# ALSO: the W2 count-tolerance is now CAP-AWARE (the v32 root
# cause: the walk stops at 64 BY DESIGN; this VM ran 102 live
# processes, so the old |walked-live|<=3 could never pass).
# v33 compares walked against min(live,64).
#
# op-11 payload grew ADDITIVELY: dtb@1056 (the System
# DirectoryTableBase, PCID-masked) - the P7 cross-check source.
#
# ============================================================
# INFINITY bridge trigger test v32  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v24 DRIVER (memory.efi v24 RT - "anchors + exports
# + process walk + page tables (F4)", 141154 bytes, sha256
# 022e6d1c...09b398b).
# v24 = v23 + THE DEREF FIX: the v31 run proved the v23 export fix
# (M1..M4 all green) but the WALK still refused with payload
# status=4 (not-System): op-11 was passing the RESOLVED SYMBOL VA
# (0xFFFFF8071A4FC420 - the in-image .data slot) to the walk
# instead of the EPROCESS it POINTS AT. v24 derefs the slot via
# the same gated in-image reads (no new trust root) and walks
# from the true System EPROCESS - a pool object OUTSIDE the image.
# Host-proven 66/66 incl. the T23 chain class-kill; disasm-verified.
#
# DRIVER SIZE CHECK: v26-RT = 140582 bytes - THE v35 DRIVER TOO
# (v35 is script-only; the v26 binary is UNCHANGED and its op-1/
# op-11 paths are 8-times field-proven; its op-12 is simply never
# called). THE v34 SCRIPT IS DO-NOT-RUN (its P1 = the second BSOD).
# v25-RT = 141154 (THE FIRST F4 BSOD BINARY - DO NOT RUN: chain B
# derefs a garbage MmPfnDatabase -> 0x50; fingerprint-proven in the
# v34 report: 0xfffff807154e5078 = pdb + 0x1AD*0x30 + 8).
# v24-RT = 134842 (no page tables: op 12 answers ErrUnsupported(8)).
# v23-RT and v22-RT are BOTH 134330 (v23 = the missing-deref bug: W
# refuses status=4 not-System with walk=0; v22 = additionally
# refuses every M).
# v26 sha256 = c8f79b95...921bb (v25 = 022e6d1c...09b398b, v24 =
# f8a01814...dbcf5846). phase-d.bat checks all of it.
#
# W1 SUCCESS NOW MEANS (v24 semantics, corrected from v31):
#   payload.status=0(Ok), count 1..64, sysEntry@1032 = the DEREF'd
#   EPROCESS: canonical (>= 0xFFFF800000000000) AND OUTSIDE
#   [pe_base, pe_base+pe_size) AND == entries[0].eproc with pid 4.
#   The symbol cross-check (serial [PW] sys= == M1's va) is read
#   from serial-phase-d.log, not the payload.
#   v25 ADDS dtb@1056 (u64: the System DirectoryTableBase from
#   EPROCESS+0x28, PCID-masked) - payload 1056 -> 1064B; P7
#   cross-checks it against op-12's cr3.
#
# v32 CHANGES (script-only): header/transcript/banner/END marker
# v32 + driver-ID texts + the corrected W1 success expectations.
# THE WIRE CONTRACT, THE STEPS, THE PAYLOAD LAYOUT, THE INFCNT
# ARITHMETIC: UNCHANGED from the field-run v31.
# ============================================================
# ============================================================
# INFINITY bridge trigger test v31  (run INSIDE the Windows VM,
# in an ELEVATED PowerShell: "Run as Administrator")
#
# REQUIRES the v23 DRIVER (memory.efi v23 RT - "anchors + exports
# + process walk (F3)", 134330 bytes, sha256 d7562a7d...7c5e8).
# v23 = v22 + THE ONE-CONSTANT FIX: the export-size gate bound
# 0x10000 -> 0x100000 (the v21 field-binary truth @10fbb: lea
# edx,[rax-0x28]; cmp edx,0xfffd8 - the f3-design hand-RE had
# dropped a zero). The v30 run refused every M/W resolve because
# ntoskrnl 19045's export directory (~0x12000 bytes) tripped the
# wrong 64 KiB bound - fail-closed, zero crashes, F1 + the whole
# J matrix green on the very same v22 binary.
#
# CAUTION: v22-RT and v23-RT are BOTH 134330 bytes - size alone
# CANNOT tell them apart. v23 sha256 = d7562a7d...7c5e8
# (v22 = 276b744c...cb9cc2 - the buggy one). phase-d.bat checks
# the hash for you before every run.
#
# v31 CHANGES (script-only): header/transcript/banner/END marker
# v31 + the driver-ID texts below. THE WIRE CONTRACT, THE STEPS,
# THE EXPECTATIONS, THE INFCNT ARITHMETIC: UNCHANGED from v30.
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
    $transPath = Join-Path $spot ("trigger-test-v36-output-$stamp.txt")
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
Write-Host '==== INFINITY trigger test v36 (v26 driver UNCHANGED: F4 ATTEMPT 3 FINISHED - the RECON is COMPLETE (MmPteBase SHAPED s=0x138 live; all 5 researched pfnDb RVAs wrong; both BSODs fingerprint-confirmed as chain B); the v35 dump SKIPPED itself because its gate wanted <=24 sections and ntoskrnl legally has 33 - v36 = the SAME crash-proof kit (op-12 still RETIRED, zero sends) with the gate fixed + the section table read in <=1024B chunks: full K/L/M/J/W regression + RECON + THE .data DUMP) ===='
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
        if ($m.Length -gt 420) { $m = $m.Substring(0, 420) + '...' }
        Write-Host ("      BUGCHECK {0}: {1}" -f $e.TimeCreated, $m)
        # v35: extract the 4 hex args for the fingerprint check
        if ($m -match 'bugcheck was:\s*(0x[0-9a-fA-F]+)\s*\(([^)]+)\)') {
            Write-Host ("      ARGS: {0} ({1})  <- v36: the v33+v34 0x50s are BOTH fingerprint-CONFIRMED" -f $Matches[1], $Matches[2].Trim())
            Write-Host '      (arg1 - a page-aligned kernel ptr = 0x5078 = 0x1AD*0x30+8 = chain B). Any NEW 0x50: same arithmetic'
        }
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
Write-Host '      -> v35: C:\Windows\Minidump\*.dmp (if any) holds the same evidence in'
Write-Host '         full - a screenshot/list of that folder is welcome but NOT required.'

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
Write-Host '--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v26 containing-walk) ---'
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
Write-Host ' dies at W1/W4/W5 -> the F3 walk path (v24; v23 = 134330 B and its MISSING DEREF refuses W with payload status=4' +
                     '  not-System walk=0 - the v31 field signature; v22 = also refuses every M). Never a crash by construction.'
Write-Host '                  Sizes now differ: v24-RT = 134842 bytes (sha256 f8a01814...dbcf5846); v23/v22 = 134330.' +
                     '  phase-d.bat checks size + hash before every run.'
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
# (v24 driver: resolve -> DEREF the pointer slot -> walk the EPROCESS; v23 = missing deref, refuses not-System; v21 = ErrUnsupported)
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
        $wDtb    = U64 $W1.Data 1056     # v25: the System DirectoryTableBase
        $wPayloadTxt = ("status={0} count={1} closed={2} stored={3} name_ofs=0x{4:X} pages={5} eproc=0x{6:X} dtb=0x{7:X}" -f $wSt, $wCount, $wClosed, $wStored, $wOfs, $wPages, $wSys, $wDtb)
        Write-Host ("     [W1] payload: {0}" -f $wPayloadTxt)
        if ($wSt -ne 0) {
            Write-Host ("     [W1] WALK REFUSED (payload status={0}) - the VM is alive; serial [PW] names the refusal" -f $wSt)
        } else {
            # v24 semantics (corrected from v31): sysEntry@1032 is the
            # DEREF-ed System EPROCESS - the value the in-image
            # PsInitialSystemProcess slot points at - NOT the symbol VA.
            # (v31 expected entries[0].eproc == M1's VA: the very
            # misconception that caused the v23 driver bug. The symbol
            # cross-check - serial [PW] sys= == M1's va - is read from
            # serial-phase-d.log, not the payload.) HERE we prove F3's
            # actual claim: the EPROCESS is DYNAMIC POOL DATA OUTSIDE
            # the validated image, and the walk starts there.
            $kPwMinKernel = [UInt64]'0xFFFF800000000000'
            $eprocCanon   = ($wSys -ge $kPwMinKernel)
            $eprocOutside = ($wSys -lt $peBase) -or ($wSys -ge ($peBase + $peSize))
            $e0pid = U32 $W1.Data 0
            $e0eproc = U64 $W1.Data 8
            $e0flags = U32 $W1.Data 4
            $e0name = [System.Text.Encoding]::ASCII.GetString($W1.Data, 16, 8)
            Write-Host ("     [W1] eproc=0x{0:X} (canonical={1} outside-image={2}) - serial [PW] sys= must equal the M1 va 0x{3:X}" -f $wSys, $eprocCanon, $eprocOutside, $mVa)
            Write-Host ("     [W1] entries[0]: pid={0} eproc=0x{1:X} flags={2} name='{3}'" -f $e0pid, $e0eproc, $e0flags, $e0name)
            $w1Ok = ($wCount -ge 1) -and ($wCount -le 64) -and $eprocCanon -and $eprocOutside -and ($e0pid -eq 4) -and ($e0eproc -eq $wSys)
            if ($w1Ok) {
                Write-Host '     [W1] PASS: entries[0] = System pid 4 AT THE EPROCESS - and the EPROCESS sits OUTSIDE [pe_base, pe_base+pe_size)'
                Write-Host '     [W1] PASS: PROCESS DATA OUTSIDE THE IMAGE - the F3 claim itself, reached via the deref chain'
            } else {
                Write-Host '     [W1] FAIL: eproc not canonical/out-of-image, or entries[0] is not System@eproc (see above + serial [PW])'
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
                        if (-not $liveIds.ContainsKey([int]$ep) -and $ep -ne 4) {
                            # v35 exit-race re-query (the v34 FAIL was pid 656:
                            # walked but gone by the Get-Process snapshot)
                            $still = $null
                            try { $still = Get-Process -Id ([int]$ep) -ErrorAction Stop } catch {}
                            if ($null -ne $still) {
                                $missing++
                                Write-Host ("     [W2] pid {0} not in the snapshot BUT alive on re-query (protected?)" -f $ep)
                            } else {
                                Write-Host ("     [W2] pid {0} EXITED between walk and snapshot (tolerated, v35)" -f $ep)
                            }
                        }
                    }
                }
                # v33 CAP-AWARE (the v32 root cause): the driver's walk
                # stops at kPwMaxEntries=64 BY DESIGN (host-proven T19a-d;
                # the v32 field run: walked=64 live=102). Compare against
                # min(live,64); membership (missing==0) is unchanged.
                $liveCap = [Math]::Min($liveProcs.Count, 64)
                $cntDelta = [Math]::Abs([int]$wCount - $liveCap)
                Write-Host ("     [W2] walked={0} live={1} (cap-aware expected={2}) delta={3} checked={4} missing={5}" -f $wCount, $liveProcs.Count, $liveCap, $cntDelta, $checked, $missing)
                if ($liveProcs.Count -gt 64) { Write-Host "     [W2] NOTE: live > the driver's 64-entry cap (by design, not a bug) - count checked against the cap" }
                $w2Ok = ($missing -le 1) -and ($cntDelta -le 3)
                if ($w2Ok) { Write-Host '     [W2] PASS: the walked list matches the live process list (cap-aware; exit races <=1 tolerated)' }
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
        Write-Host ("     [W1] WALK REFUSED (resp status={0}({1})) - is memory.efi the v24 build? (v24 = 134842 B sha256 f8a01814...; v23 = 134330 B, the missing-deref bug, refuses W with payload status=4 not-System; v22 = refuses every M too)" -f $W1.Status, (Stat-Name $W1.Status))
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

# ============================================================
# [14b] step R: THE CONSTANT RECON (v35 - op-12 is RETIRED)
# Both field BSODs died INSIDE op-12 at chain B's raw deref of a
# garbage MmPfnDatabase (pdb + pfn*0x30 + 8; the v34 step-0 args
# proved it by arithmetic). v35 NEVER SENDS op-12. Instead it reads
# the same candidate slots through the L1-L5-PROVEN op-1 image
# gate (zero out-of-image reads - this block cannot fault):
#   R1/R2   nt!MmPteBase candidates (chain A's inputs)
#   R3..R7  nt!MmPfnDatabase candidates (chain B's poison - the
#           actual values THIS build has at the researched RVAs)
#   R8      the System DTB (op-11's dtb@1056 echo) -> the pfn of
#           the fingerprint arithmetic
# ============================================================
$rSent = 0
$dumpSent = 0
$reconPteOk = $false
$reconPteS = -1
$reconTxt = 'not-run'
$reconPoison = @()
if ($anOk) {
    Write-Host ''
    Write-Host '--- step R: the constant RECON (op-1 image-gated 8B reads; op-12 RETIRED this run) ---'
    Write-Host '     (both BSODs died at chain B dereferencing a garbage MmPfnDatabase;'
    Write-Host '      v35 reads the candidate slots through the PROVEN image gate instead -'
    Write-Host '      the same bytes, zero out-of-image reads, the VM cannot die here)'

    $cands = @(
        @{ n='R1'; rva=0xCFB358; what='MmPteBase cand#1 (17/19 PDBs)' },
        @{ n='R2'; rva=0xCFA358; what='MmPteBase cand#2 (2/19 PDBs)' },
        @{ n='R3'; rva=0xCFC508; what='MmPfnDatabase cand#1 (11/19)' },
        @{ n='R4'; rva=0xCFC500; what='MmPfnDatabase cand#2 (3/19)' },
        @{ n='R5'; rva=0xCFC510; what='MmPfnDatabase cand#3 (3/19)' },
        @{ n='R6'; rva=0xCFB500; what='MmPfnDatabase cand#4 (1/19)' },
        @{ n='R7'; rva=0xCFB508; what='MmPfnDatabase cand#5 (1/19)' }
    )
    $seqR = 0x1A01
    foreach ($cd in $cands) {
        Write-Host ''
        Write-Host ('--- step {0}: qword @ pe_base+0x{1:X} - {2} ---' -f $cd.n, $cd.rva, $cd.what)
        Canary ("pre-" + $cd.n)
        $rr = $null
        try { $rr = Send-Req (New-Req $seqR 1 'FFFFFFFF' 8 ('{0:X16}' -f ($peBase + [uint64]$cd.rva)) $null) }
        catch { Write-Host ("[!] {0} threw: {1}" -f $cd.n, $_.Exception.Message) }
        $rSent++
        $seqR++
        $qv = [UInt64]0; $qOk = $false
        if ($null -ne $rr -and $null -ne $rr.Resp -and $rr.Status -eq 1 -and $null -ne $rr.Data -and $rr.Data.Length -ge 8) {
            $qv = U64 $rr.Data 0; $qOk = $true
        }
        if ($qOk) {
            Write-Host ("     [{0}] qword = 0x{1:X16}" -f $cd.n, $qv)
            if ($cd.n -eq 'R1' -or $cd.n -eq 'R2') {
                $lo  = $qv -band [UInt64]'0x0000007FFFFFFFFF'
                $hi  = $qv -shr 48
                $sIx = [int](($qv -shr 39) -band [UInt64]0x1FF)
                if (($lo -eq 0) -and ($hi -eq [UInt64]0xFFFF) -and ($sIx -ge 0x100)) {
                    if (($sIx -eq 0x100) -or ($sIx -eq 0x1EF)) {
                        Write-Host ("     [{0}] SHAPE-VALID but s=0x{1:X} is a COLLISION slot (0x100=MmSystemRangeStart," -f $cd.n, $sIx)
                        Write-Host '      0x1EF=KUSD) - cannot be the true self-map; treat as a drifted RVA (report it)'
                    } else {
                        Write-Host ("     [{0}] *** PTE-BASE SHAPED: s=0x{1:X} - the live MmPteBase on this build ***" -f $cd.n, $sIx)
                        Write-Host '      (randomized per boot - a static value here would mean a drifted RVA;'
                        Write-Host '       the offline dump analysis settles it; chain A would accept this'
                        if (-not $reconPteOk) { $reconPteOk = $true; $reconPteS = $sIx }
                    }
                } else {
                    Write-Host ("     [{0}] NOT pte-base shaped (bits38:0=0x{1:X16} hi=0x{2:X}) - this RVA is not MmPteBase here" -f $cd.n, $lo, $hi)
                }
            } else {
                $aligned = ($qv -band [UInt64]0xFFF) -eq 0
                $canon   = ($qv -ge [UInt64]'0xFFFF800000000000') -and ($qv -ne 0)
                if ($canon -and $aligned) {
                    $reconPoison += ('{0}=0x{1:X16}' -f $cd.n, $qv)
                    Write-Host ("     [{0}] a PAGE-ALIGNED KERNEL POINTER - chain B's weak check PASSES this" -f $cd.n)
                    if ($wDtb -gt 0) {
                        $pfnIx  = [int]((($wDtb -band [UInt64]'0x000FFFFFFFFFF000') -shr 12))
                        $deadly = $qv + [UInt64]($pfnIx * 0x30) + [UInt64]8
                        Write-Host ("      its deref would be 0x{0:X16} (pdb + {1}*0x30 + 8) - compare the v34" -f $deadly, $pfnIx)
                        Write-Host '      crash args in step 0 above: THE FINGERPRINT CLASS (unmapped => 0x50)'
                    }
                } else {
                    Write-Host ("     [{0}] not a kernel pointer (0/low/user value) - chain B would skip it" -f $cd.n)
                }
            }
        } else {
            Write-Host ("     [{0}] FAIL: no data (status={1}) - see raw above" -f $cd.n, $(if ($null -ne $rr) { $rr.Status } else { 'none' }))
        }
    }

    # ---- R8: the System DTB + the fingerprint pfn ----
    Write-Host ''
    Write-Host '--- step R8: the System DTB (op-11 dtb@1056 echo) - the fingerprint pfn ----'
    if ($wDtb -gt 0) {
        $pfnR8 = [int]((($wDtb -band [UInt64]'0x000FFFFFFFFFF000') -shr 12))
        Write-Host ("     [R8] dtb=0x{0:X}  pfn=0x{1:X}  (the v33 fingerprint: pdb + 0x{1:X}*0x30 + 8 = pdb + 0x{2:X})" -f $wDtb, $pfnR8, ($pfnR8 * 0x30 + 8))
        $reconTxt = 'RECON COMPLETE (a pte-base-shaped MmPteBase candidate found; the pfnDb poison captured)'
        if (-not $reconPteOk) { $reconTxt = 'RECON COMPLETE (NO pte-base-shaped candidate - a drifted build; the dump decides)' }
    } else {
        Write-Host '     [R8] SKIPPED (W1 did not echo a dtb - the walk refused?)'
        $reconTxt = 'RECON PARTIAL (no W dtb echo)'
    }
} else {
    Write-Host ''
    Write-Host '--- step R: SKIPPED (anchors not converged - nothing to recon) ---'
    $reconTxt = 'SKIPPED (anchors)'
}

# ============================================================
# [15a] step D: THE .data DUMP (the ground-truth capture - v35)
# The whole .data section through the SAME op-1 image gate, 1024B
# per request. This is what the offline analysis uses to pin the
# TRUE constants for this exact build (the end of researched-RVA
# guessing - it cost two VMs). Self-verified + resumable + manifest.
# EXPECT ~2000-4000 chunks: minutes of quiet hook traffic. The
# progress line shows the ETA. NOTHING here can fault: every read
# is inside [pe_base, pe_base+pe_size) - the L1-L5-proven gate.
# ============================================================
$dumpOk = $false
$dumpPath = $null
$dumpHashTxt = ''
$dumpInfoTxt = 'not-run'
if ($anOk -and ($lfanew -gt 0)) {
    Write-Host ''
    Write-Host '--- step D: the .data dump (op-1 image-gated 1024B chunks; minutes; resumable) ---'

    # ---- D0: the self-verify read - 1024B @ pe_base must echo L1/L2a ----
    Canary 'pre-D0'
    $d0 = $null
    try { $d0 = Send-Req (New-Req 0x1B00 1 'FFFFFFFF' 1024 ('{0:X16}' -f $peBase) $null) }
    catch { Write-Host ("[!] D0 threw: {0}" -f $_.Exception.Message) }
    $rSent++
    $d0Ok = ($null -ne $d0 -and $null -ne $d0.Resp -and $d0.Status -eq 1 -and $null -ne $d0.Data -and $d0.Data.Length -ge 256 -and $d0.Data[0] -eq 0x4D -and $d0.Data[1] -eq 0x5A -and ((U32 $d0.Data 0x3C) -eq [uint32]$lfanew))
    if ($d0Ok) {
        Write-Host '     [D0] PASS: the 1024B read path echoes MZ + e_lfanew == L1/L2a - big-chunk reads proven live'
    } else {
        Write-Host '     [D0] FAIL: the 1024B self-verify mismatched - the dump is SKIPPED (fail-closed; report it)'
    }

    if ($d0Ok) {
        # ---- D1: the section table (NumberOfSections + SizeOfOptionalHeader) ----
        Canary 'pre-D1'
        $d1 = $null
        try { $d1 = Send-Req (New-Req 0x1B01 1 'FFFFFFFF' 20 ('{0:X16}' -f ($peBase + [uint64]$lfanew + 4)) $null) }
        catch { Write-Host ("[!] D1 threw: {0}" -f $_.Exception.Message) }
        $rSent++
        $nsec = 0; $optSize = 0; $dataRva = 0; $dataVs = 0
        if ($null -ne $d1 -and $null -ne $d1.Resp -and $d1.Status -eq 1 -and $null -ne $d1.Data -and $d1.Data.Length -ge 20) {
            $nsec    = [int]($d1.Data[2]) -bor ([int]($d1.Data[3]) -shl 8)
            $optSize = [int]($d1.Data[16]) -bor ([int]($d1.Data[17]) -shl 8)
        }
        Write-Host ("     [D1] sections={0} SizeOfOptionalHeader=0x{1:X}" -f $nsec, $optSize)
        # v36: the v35 field run PROVED nsec=33 is LEGAL on this build (the
        # hotpatch-era kernel: .rdata/.pdata/.idata/.edata/PROTDATA/GFIDS/
        # Pad1/.text/PAGE*/POOLCODE/PAGEKD/... + the tail sections = 33).
        # The v35 gate (-le 24) rejected the LEGITIMATE header and skipped
        # the dump BY DESIGN (fail-closed, VM alive, skip loud). PE's
        # practical maximum is 96 sections - that is the new bound.
        if ($nsec -ge 1 -and $nsec -le 96 -and $optSize -ge 0xE0 -and $optSize -le 0x400) {
            # ---- D2: the section array - find .data ----
            # v36: 33 sections x 40B = 1320B > the proven 1024B single-read
            # size, so the table is ASSEMBLED from <=1024B chunk reads
            # (each retried x3 with 150 ms sleeps, exactly like the dump
            # loop) - no unproven-size read anywhere in the kit
            Canary 'pre-D2'
            $secRva = $lfanew + 0x18 + $optSize
            $secLen = $nsec * 40
            $d2 = $null
            try {
                $d2List = New-Object System.Collections.Generic.List[byte]
                $d2Off  = [uint64]$secRva
                $d2Seq  = 0x1B02
                while ($d2Off -lt [uint64]($secRva + $secLen)) {
                    $d2Len = [int][Math]::Min(1024, ([uint64]$secRva + [uint64]$secLen) - $d2Off)
                    $d2c = $null
                    for ($try = 1; $try -le 3; $try++) {
                        try { $d2c = Send-Req (New-Req $d2Seq 1 'FFFFFFFF' $d2Len ('{0:X16}' -f ($peBase + $d2Off)) $null) } catch {}
                        if ($null -ne $d2c -and $null -ne $d2c.Resp -and $d2c.Status -eq 1 -and $null -ne $d2c.Data -and $d2c.Data.Length -eq $d2Len) { break }
                        $d2c = $null
                        Start-Sleep -Milliseconds 150
                    }
                    if ($null -eq $d2c) { throw ("section-table chunk @RVA 0x{0:X} failed x3" -f $d2Off) }
                    $d2List.AddRange($d2c.Data)
                    $d2Off += [uint64]$d2Len
                    $d2Seq++
                    $rSent++
                }
                $d2 = @{ Data = $d2List.ToArray() }
                Write-Host ("     [D2] section table assembled: {0} bytes in {1} chunk read(s)" -f $d2.Data.Length, ($d2Seq - 0x1B02))
            } catch { Write-Host ("[!] D2 threw: {0}" -f $_.Exception.Message) }
            if ($null -ne $d2 -and $null -ne $d2.Data -and $d2.Data.Length -ge $secLen -and (($secRva + $secLen) -le [int]$peSize)) {
                for ($si = 0; $si -lt $nsec; $si++) {
                    if ($d2.Data[($si * 40)] -eq 0x2E) {
                        $nm = [System.Text.Encoding]::ASCII.GetString($d2.Data, ($si * 40), 8).TrimEnd([char]0)
                        if ($nm -eq '.data') {
                            $dataVs  = [int](U32 $d2.Data ($si * 40 + 8))
                            $dataRva = [int](U32 $d2.Data ($si * 40 + 12))
                            break
                        }
                    }
                }
                if ($dataRva -gt 0 -and $dataVs -gt 0 -and (($dataRva + $dataVs) -le [int]$peSize)) {
                    Write-Host ("     [D2] .data RVA=0x{0:X} size=0x{1:X} ({2} bytes) - dumping" -f $dataRva, $dataVs, $dataVs)

                    # ---- the dump loop (resumable via the .marker file) ----
                    $spot2 = Split-Path -Parent $transPath
                    $dumpBase = Join-Path $spot2 'ntoskrnl-data'
                    $dumpPath = "$dumpBase.bin"
                    $mkPath   = "$dumpBase.marker"
                    $chunkSz  = 1024
                    $total    = [int](($dataVs + $chunkSz - 1) / $chunkSz)
                    $startAt  = 0
                    $mkTxt    = ("pe_base=0x{0:X};rva=0x{1:X};vs=0x{2:X};chunk={3}" -f $peBase, $dataRva, $dataVs, $chunkSz)
                    if ((Test-Path $mkPath) -and (Test-Path $dumpPath)) {
                        $mkOld = Get-Content $mkPath -ErrorAction SilentlyContinue
                        if ("$mkOld" -eq "$mkTxt") {
                            $have = (Get-Item $dumpPath).Length
                            if (($have % $chunkSz) -eq 0) {
                                $startAt = [int]($have / $chunkSz)
                                Write-Host ("     [D] RESUMING: an identical-boot marker found - continuing at chunk {0}/{1}" -f $startAt, $total)
                            }
                        } else {
                            Write-Host '     [D] a stale marker (different boot/bounds) - starting a fresh dump'
                        }
                    }
                    if ($startAt -eq 0) {
                        [System.IO.File]::WriteAllText($mkPath, $mkTxt)
                    }
                    $sw = [System.Diagnostics.Stopwatch]::StartNew()
                    $fs = $null
                    try {
                        if ($startAt -eq 0) { $fs = [System.IO.File]::Create($dumpPath) }
                        else               { $fs = [System.IO.File]::Open($dumpPath, 'Append') }
                        $failAt = -1
                        for ($ci = $startAt; $ci -lt $total; $ci++) {
                            $off = [uint64]($dataRva + ($ci * $chunkSz))
                            $len = $chunkSz
                            $remain = [int]($dataVs - ($ci * $chunkSz))
                            if ($remain -lt $len) { $len = $remain }
                            $rchunk = $null
                            for ($try = 1; $try -le 3; $try++) {
                                try { $rchunk = Send-Req (New-Req (0x2000 + $ci) 1 'FFFFFFFF' $len ('{0:X16}' -f ($peBase + $off)) $null) } catch {}
                                if ($null -ne $rchunk -and $null -ne $rchunk.Resp -and $rchunk.Status -eq 1 -and $null -ne $rchunk.Data -and $rchunk.Data.Length -eq $len) { break }
                                $rchunk = $null
                                Start-Sleep -Milliseconds 150
                            }
                            if ($null -eq $rchunk) { $failAt = $ci; break }
                            $fs.Write($rchunk.Data, 0, $len)
                            $dumpSent++
                            if ((($ci + 1) % 64) -eq 0 -or ($ci + 1) -eq $total) {
                                $done = ($ci + 1) - $startAt
                                $rate = [double]$done / [double]$sw.Elapsed.TotalSeconds
                                $etaS = [int](($total - $ci - 1) / [Math]::Max($rate, 0.01))
                                Write-Host ("     [D] chunk {0}/{1}  (through RVA 0x{2:X})  rate={3:N1}/s  ETA~{4}m{5:d2}s" -f ($ci + 1), $total, ($off + [uint64]$len), $rate, [int]($etaS / 60), ($etaS % 60))
                            }
                        }
                        $fs.Close(); $fs = $null
                        if ($failAt -ge 0) {
                            Write-Host ("     [D] chunk {0} FAILED x3 - the dump stopped THERE (the .bin holds everything" -f $failAt)
                            Write-Host '      before it; RERUN the script - the marker file resumes from this point)'
                            $dumpInfoTxt = ("PARTIAL: stopped at chunk {0}/{1}" -f $failAt, $total)
                        } else {
                            $dumpOk = $true
                            $dumpInfoTxt = ("COMPLETE: {0} chunks, {1} bytes" -f $total, (Get-Item $dumpPath).Length)
                            try {
                                $h = Get-FileHash -Algorithm SHA256 -Path $dumpPath -ErrorAction Stop
                                $dumpHashTxt = $h.Hash
                            } catch { $dumpHashTxt = 'hash-failed' }
                            Write-Host ("     [D] DUMP COMPLETE: {0} bytes -> {1}" -f (Get-Item $dumpPath).Length, $dumpPath)
                            Write-Host ("     [D] sha256 = {0}" -f $dumpHashTxt)
                        }
                    } finally {
                        if ($null -ne $fs) { $fs.Close() }
                    }
                    # ---- the manifest ----
                    $man = @()
                    $man += ("# ntoskrnl .data dump manifest - generated by trigger-test-v36")
                    $man += ("pe_base=0x{0:X}" -f $peBase)
                    $man += ("pe_size=0x{0:X}" -f $peSize)
                    $man += ("lfanew=0x{0:X}" -f $lfanew)
                    $man += ("data_rva=0x{0:X}" -f $dataRva)
                    $man += ("data_vs=0x{0:X}" -f $dataVs)
                    $man += ("chunk=1024  total_chunks={0}" -f $total)
                    $man += ("dump={0}" -f $dumpInfoTxt)
                    $man += ("sha256={0}" -f $dumpHashTxt)
                    $man += ("w_dtb=0x{0:X}" -f $wDtb)
                    foreach ($k in @('R1','R2','R3','R4','R5','R6','R7')) {
                        $cRva = 0
                        if     ($k -eq 'R1') { $cRva = 0xCFB358 } elseif ($k -eq 'R2') { $cRva = 0xCFA358 }
                        elseif ($k -eq 'R3') { $cRva = 0xCFC508 } elseif ($k -eq 'R4') { $cRva = 0xCFC500 }
                        elseif ($k -eq 'R5') { $cRva = 0xCFC510 } elseif ($k -eq 'R6') { $cRva = 0xCFB500 }
                        else                 { $cRva = 0xCFB508 }
                        $man += ("recon_{0}_rva=0x{1:X}" -f $k, $cRva)
                    }
                    [System.IO.File]::WriteAllLines("$dumpBase.manifest.txt", $man)
                    Write-Host ("     [D] manifest -> {0}.manifest.txt" -f $dumpBase)
                    Write-Host '     [D] SEND THE .bin + .manifest.txt + this .txt OUT with the usual report zip.'
                } else {
                    Write-Host '     [D2] .data not found / out of bounds in the section table - dump SKIPPED (report it)'
                    $dumpInfoTxt = 'SKIPPED (no .data section / bounds)'
                }
            } else {
                Write-Host '     [D2] FAIL: the section-table read failed - dump SKIPPED (report it)'
                $dumpInfoTxt = 'SKIPPED (section-table read failed)'
            }
        } else {
            Write-Host '     [D1] FAIL: implausible section-table header - dump SKIPPED (report it)'
            $dumpInfoTxt = 'SKIPPED (implausible headers)'
        }
    }
} else {
    Write-Host ''
    Write-Host '--- step D: SKIPPED (anchors not converged or no e_lfanew) ---'
    $dumpInfoTxt = 'SKIPPED (anchors)'
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
$expFinal = if ($cntVal -ge 0) { $cntVal + 8 + $anSent + $mNameWrites + $wSent + $rSent + $dumpSent } else { '?' }
Write-Host ("    INFCNT final = {0}   (expect G+8+{4}+{5}+{6}+{7}+{8} = {1}: H's InfinityData write (+1)," -f $cntFinal, $expFinal, '', '', $anSent, $mNameWrites, $wSent, $rSent, $dumpSent)
Write-Host '     the 7 ladder InfinityReq writes (+7), the K/L + M export requests (+anSent), the M symbol-NAME InfinityData writes (+mNameWrites), the W walk requests (+wSent), the R recon requests (+rSent) and the D dump chunks (+dumpSent); requests are consumed in RAM and deletes never count)'
$mTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
         elseif ($m1Ok -and $m2Ok -and $m2ReadOk -and $m3Ok -and $m3ReadOk -and $m4Ok) { 'PROVEN - resolve + cross-validated reads + negative' }
         else { 'PARTIAL/FAILED - see the M-step lines above + serial [XS]/[KPCR]' }
Write-Host ("[13] F2 export resolution (M1..M4) : {0}" -f $mTxt)
$wTxt = if (-not $anOk) { 'SKIPPED (fail-closed)' }
        elseif ($w1Ok -and $wNamesOk -and $w2Ok -and $w4Ok -and $w5Ok) { "PROVEN - {0} processes walked, System at the pool EPROCESS + live-list cross-check green" -f $wCount }
        elseif ($wCount -ge 1) { 'PARTIAL - the walk ran but a cross-check failed (see the W-step lines + serial [PW])' }
        else { "REFUSED ($wPayloadTxt) - serial [PW] names the reason" }
Write-Host ("[14] F3 process walk (W1..W5)    : {0} (v35 field: the cap-aware W2 PASSed)" -f $wTxt)
$f4Sum = "RECON THIS RUN (op-12 retired after the 2nd 0x50): {0}; dump: {1}" -f $reconTxt, $dumpInfoTxt
Write-Host ("[15] F4 constants recon (R1..R8) : {0}" -f $f4Sum)
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
    Write-Host ("{0} processes counted, System pid 4 at the DEREF-ed pool EPROCESS (serial [PW] sys= equals the M1 VA)," -f $wCount)
    Write-Host 'names discovered live. The first arbitrary-kernel-VA reads are proven -'
    Write-Host 'fail-closed held the whole way (W4 negatives clean, VM alive).'
    Write-Host 'Next: F4 (PTE/page-table base for arbitrary-VA validation), then Infinity.exe.'
} elseif ($anOk -and $wCount -ge 1) {
    Write-Host ''
    Write-Host '>>> F3 PARTIAL: the walk ran but a cross-check failed - see the W lines. <<<'
    Write-Host 'Serial [PW] lines matter - send them + the output .txt.'
$f4Ok = $anOk -and $reconPteOk -and $dumpOk
if ($f4Ok) {
    Write-Host ''
    Write-Host '>>> F4 RECON COMPLETE + GROUND-TRUTH DUMP CAPTURED (the VM SURVIVED) <<<'
    Write-Host 'A pte-base-shaped MmPteBase candidate was found in-image (s below) and the'
    Write-Host ('whole .data section is on the stick ({0}). The offline analysis pins' -f $dumpInfoTxt)
    Write-Host 'the TRUE constants for THIS build; the v27/v36 walk kit ships with them'
    Write-Host 'VERIFIED - chain B is retired until then, and its replacement must'
    Write-Host 'pass a mapped-by-construction proof before any deref.'
    Write-Host ("recon pte-base s=0x{0:X}  w_dtb=0x{1:X}" -f $reconPteS, $wDtb)
    Write-Host 'Next: the offline dump analysis, then the v27/v36 walk kit (attempt 4).'
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F4 RECON PARTIAL (no pte-base-shaped candidate or the dump did not complete) <<<'
    Write-Host 'That is NOT a failure of the bridge: the researched RVAs are simply not this'
    Write-Host ("build's layout. The dump ({0}) + the .txt are exactly what the offline" -f $dumpInfoTxt)
    Write-Host 'analysis needs - send everything. The VM is alive by construction.'
}
} elseif ($anOk) {
    Write-Host ''
    Write-Host '>>> F3 NOT PROVEN THIS RUN (the walk refused or was skipped). <<<'
    Write-Host 'Refusals are clean by design - the payload status + serial [PW] name it.'
}
Write-Host '==== END v36 ===='

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
