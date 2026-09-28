#!/usr/bin/env python3
# ============================================================================
# make-v34.py — build trigger-test-v34.ps1 from the FIELD-RUN v33 script
#
# v34 story (what this patch encodes):
#   v33 field run (2026-09-28 01:16): F1/F2/F3 green a 7th time, the
#   cap-aware W2 PROVEN, the op-11 dtb echo PROVEN (0x1AD000) — and
#   then P1 = THE FIRST F4-ERA BSOD (0x50 PAGE_FAULT_IN_NONPAGED_AREA):
#   the engine died INSIDE pt::Translate, never returned, [PT]=0.
#   Root cause (walk-level, engine-side): v25's upper-level PTE-space
#   slot formulas (PML4E/PDPTE/PDE at PTE_BASE + shifted-vpn*8)
#   addressed LOW-USER PTE slots — the first PTE-space read (the
#   self-ref at PTE_BASE + s*8) walked PML4E[0] of the CALLER process,
#   absent in the trigger script's context -> fault.
#
# v26 driver (what v34 expects):
#   - the TRUE level bases: PDE/PPE/PXE_BASE = PTE_BASE + (s<<30) /
#     + (s<<21) / + (s<<12) — exact-matched against the published
#     classic s=0x1ED constants (0xFFFFF6FB40000000 / 7DA00000 /
#     7DBED000); a1..a3 corrected, a4 (MiGetPteAddress) unchanged
#   - chain-B identity = PteAddress == PXE_BASE + s*8 (the PML4's own
#     PTE slot — v25 compared PTE_BASE + s*8 so B could never agree)
#   - selfOk is now a BITMASK: bit0 = the PTE space is LIVE (self-ref
#     slot present + sane frame); bit1 = self frame == System CR3 —
#     EXPECTED 0 in the caller context (the live PML4 is the trigger
#     script's OWN process page, not System's; the v25 "== CR3"
#     expectation was wrong for this context and would have failed
#     the verdict even without the crash)
#   - PtRd64 range gate wrap-free (s=0x1FF would have overflowed u64)
#   - host 101/101 on a TRUE-SEMANTICS world (a REAL 4-level hierarchy
#     + an independent hardware walk — the v25 synthetic world shared
#     the engine's wrong formulas: seam #5, why 89/89 passed while the
#     VM died) + TWO class-kills (the v25 engine dies at
#     0xFFFFD58000000D58 = the exact field read; S1-redacted = 15
#     clean fails); disasm-verified; bench A 13/13 + B 5/5
#
# v34 CHANGES (anchored on the field-run v33 text):
#   1. v34 header + transcript + banner + END
#   2. driver-ID texts: the v26 driver (140582 bytes; v25 = the F4
#      BSOD binary — DO NOT RUN)
#   3. K label v20..v26
#   4. the step-P intro: the corrected proof structure
#   5. P1 selfOk check: == 1 -> bit0 (the LIVE bit) + the bit1 note
#   6. the F4 verdict + [15] summary: the corrected language
#   THE P-LADDER WIRE EXPECTATIONS CARRY OVER UNCHANGED (same 80B
#   payload, same statuses, same P7 DTB cross-check).
#
# Usage: python3 scripts/make-v34.py
# ============================================================================
import sys, pathlib, hashlib

BASE = pathlib.Path('/home/z/my-project')
SRC = BASE / 'patches' / 'trigger-test-v33.ps1'
DST = BASE / 'patches' / 'trigger-test-v34.ps1'

V26_SHA = 'c8f79b95570cf57a731ddc8eb9d98448fb170331631809b71182329b856921bb'
V25_SHA = '022e6d1c01fb7de7704182bcf230062905c58f5d8677e1b75cdd0582609b398b'

text = SRC.read_text(encoding='utf-8')

def rep(old, new, label, count=1):
    global text
    n = text.count(old)
    if n != count:
        print(f'[{label}] FATAL: anchor found {n} times (need {count})')
        sys.exit(1)
    text = text.replace(old, new)
    print(f'[{label}] OK')

# =========================================================
# 1. v34 header above the v33 header
# =========================================================
rep(
"""# ============================================================
# INFINITY bridge trigger test v33  (run INSIDE the Windows VM,""",
"""# ============================================================
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
# INFINITY bridge trigger test v33  (run INSIDE the Windows VM,""",
'header')

# =========================================================
# 2. transcript name
# =========================================================
rep('trigger-test-v33-output-', 'trigger-test-v34-output-', 'transcript')

# =========================================================
# 3. banner
# =========================================================
rep(
"Write-Host '==== INFINITY trigger test v33 (v25 driver: F4 PAGE-TABLE TRANSLATION - the self-map walk with the two-chain PTE_BASE discovery + the two-way proof; full K/L/M/J/W regression + the cap-aware W2 fix + the P ladder) ===='",
"Write-Host '==== INFINITY trigger test v34 (v26 driver: F4 ATTEMPT 2 - the level-base FORMULA FIX after the v33 0x50 BSOD: the true self-map slots, the LIVE selfOk semantics; full K/L/M/J/W regression + the cap-aware W2 + the P ladder) ===='",
'banner')

# =========================================================
# 4. driver-ID texts
# =========================================================
rep(
"""# DRIVER SIZE CHECK: v25-RT = 141154 bytes. v24-RT = 134842 (no
# page tables: op 12 answers ErrUnsupported(8)). v23-RT and v22-RT are
# BOTH 134330 (v23 = the missing-deref bug: W refuses status=4
# not-System with walk=0; v22 = additionally refuses every M).
# v25 sha256 = 022e6d1c...09b398b (v24 = f8a01814...dbcf5846).
# phase-d.bat checks all of it.""",
"""# DRIVER SIZE CHECK: v26-RT = 140582 bytes. v25-RT = 141154 (THE
# F4 BSOD BINARY 0x50 - DO NOT RUN: op-12's first PTE-space read
# faults in the caller context; root-caused in the v33 report).
# v24-RT = 134842 (no page tables: op 12 answers ErrUnsupported(8)).
# v23-RT and v22-RT are BOTH 134330 (v23 = the missing-deref bug: W
# refuses status=4 not-System with walk=0; v22 = additionally
# refuses every M).
# v26 sha256 = c8f79b95...921bb (v25 = 022e6d1c...09b398b, v24 =
# f8a01814...dbcf5846). phase-d.bat checks all of it.""",
'driver-id')

# =========================================================
# 5. K label
# =========================================================
rep(
"'--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v25 containing-walk) ---'",
"'--- step K: ReqOp_Anchors (op=9) - F1 anchor discovery (v20..v26 containing-walk) ---'",
'k-label')

# =========================================================
# 6. step-P intro: the corrected proof structure
# =========================================================
rep(
"""    Write-Host '--- step P: op 12 TranslateVa - the page-table walk (v25) ---'
    Write-Host '     (PTE_BASE discovery: chain A = nt!MmPteBase .data + the 512-value structural'
    Write-Host '      check; chain B = MmPfnDatabase -> CR3 -> _MMPFN.PteAddress -> the s-identity;'
    Write-Host '      A and B must agree. The TWO-WAY PROOF: PML4E[s] -> the System CR3 frame.)'""",
"""    Write-Host '--- step P: op 12 TranslateVa - the page-table walk (v26: the formula fix) ---'
    Write-Host '     (PTE_BASE discovery: chain A = nt!MmPteBase .data + the 512-value structural'
    Write-Host '      check; chain B = MmPfnDatabase -> CR3 -> _MMPFN.PteAddress -> the s-identity;'
    Write-Host '      A and B must AGREE - the two independent chains ARE the two-way proof.'
    Write-Host '      selfOk bit0 = the PTE space is LIVE (self-ref present, sane frame);'
    Write-Host '      bit1 = self frame == System CR3 - EXPECTED 0 in this caller context:'
    Write-Host '      this PowerShell process runs on its OWN PML4, not the System page.)'""",
'p-intro')

# =========================================================
# 7. P1 selfOk: the bit semantics + the honest bit1 note
# =========================================================
rep(
"        $p1Ok = ($p1Rc -eq 1) -and $ptbCanon -and $frameOk -and $maskOk -and ($p1SelfOk -eq 1)",
"        $p1Ok = ($p1Rc -eq 1) -and $ptbCanon -and $frameOk -and $maskOk -and (($p1SelfOk -band 1) -eq 1)",
'p1-selfok-check')

rep(
"""            Write-Host '     [P1] PASS: THE TWO-WAY PROOF - PML4E[s] points at the System CR3 frame (the page tables and the EPROCESS validated each other)'""",
"""            Write-Host '     [P1] PASS: THE PTE SPACE IS LIVE - the self-ref slot read present with a sane frame (selfOk bit0)'
            if (($p1SelfOk -band 2) -ne 0) {
                Write-Host '     [P1] NOTE: selfOk bit1 SET - the caller page tables ARE the System process own (unusual for a trigger run, but consistent)'
            } else {
                Write-Host ('     [P1] NOTE: selfOk bit1 clear - EXPECTED: the live PML4 is this PowerShell process own page; System CR3 0x{0:X} (EPROCESS+0x28) is a different frame' -f $p1Cr3)
            }""",
'p1-selfok-note')

# =========================================================
# 8. the F4 verdict block: the corrected language
# =========================================================
rep(
"""    Write-Host '>>> F4 PROVEN: PAGE-TABLE TRANSLATION + RESIDENCY VALIDATION <<<'
    Write-Host 'PTE_BASE discovered by TWO independent chains (nt!MmPteBase + the PFN'
    Write-Host 'bootstrap) and the TWO-WAY PROOF holds: PML4E[s] points at the System'
    Write-Host ("CR3 (0x{0:X}) from the EPROCESS+0x28 - the page tables and the EPROCESS" -f $p1Cr3)
    Write-Host 'validated each other. The kernel image, the EPROCESS, the KUSD window and'
    Write-Host 'the IDT are all PTE-backed present - the residency assumption is GONE.'
    Write-Host 'No CR3 switching, no physical reads, no kernel calls - the self-map only.'
    Write-Host 'Next: Infinity.exe (the userspace client on the proven transport).'""",
"""    Write-Host '>>> F4 PROVEN: PAGE-TABLE TRANSLATION + RESIDENCY VALIDATION <<<'
    Write-Host 'PTE_BASE discovered by TWO independent chains (nt!MmPteBase + the PFN'
    Write-Host 'bootstrap) and they AGREE - that agreement IS the two-way proof: the kernel'
    Write-Host ('.data global and the page-table metadata (System CR3 0x{0:X} via EPROCESS+0x28)' -f $p1Cr3)
    Write-Host 'derive the SAME base independently. The PTE space is LIVE (self-ref'
    Write-Host 'present, sane frame) and the kernel image,'
    Write-Host 'the EPROCESS, the KUSD window and the IDT are all PTE-backed present -'
    Write-Host 'the residency assumption is GONE.'
    Write-Host 'No CR3 switching, no physical reads, no kernel calls - the self-map only.'
    Write-Host 'Next: Infinity.exe (the userspace client on the proven transport).'""",
'f4-verdict')

# =========================================================
# 9. [15] summary line
# =========================================================
rep(
"$f4Sum = if ($f4Ok) { 'PROVEN - two-chain PTE_BASE + the two-way proof + PTE-backed residency' } elseif ($anOk -and ($null -ne $P1)) { 'REFUSED/PARTIAL - see the P lines' } else { 'SKIPPED (anchors)' }",
"$f4Sum = if ($f4Ok) { 'PROVEN - two-chain PTE_BASE agreement + LIVE self-ref + PTE-backed residency' } elseif ($anOk -and ($null -ne $P1)) { 'REFUSED/PARTIAL - see the P lines' } else { 'SKIPPED (anchors)' }",
'summary-15')

# =========================================================
# 10. END marker
# =========================================================
rep("Write-Host '==== END v33 ===='", "Write-Host '==== END v34 ===='", 'end')

# =========================================================
# post-checks
# =========================================================
assert 'trigger test v34' in text, 'banner missing'
assert '140582 bytes' in text, 'v26 size missing'
assert 'c8f79b95...921bb' in text, 'v26 hash missing'
assert '(($p1SelfOk -band 1) -eq 1)' in text, 'selfOk bit0 check missing'
assert 'PTE SPACE IS LIVE' in text, 'selfOk LIVE note missing'
assert 'bit1 clear - EXPECTED' in text, 'bit1 note missing'
assert 'v20..v26' in text, 'K label missing'
assert text.count('$pSent++') == 6, 'pSent count wrong (must stay 6)'
assert '$liveCap = [Math]::Min($liveProcs.Count, 64)' in text, 'cap fix damaged'
assert 'U64 $W1.Data 1056' in text, 'dtb parse damaged'
assert '$wDtb -eq $p1Cr3' in text, 'P7 cross-check damaged'
assert '==== END v34 ====' in text, 'END missing'
# the P-ladder wire expectations must be UNCHANGED from the field v33
for anchor in (
    "'FFFFF78000000260'",                      # P3 target
    "'0000800000000000'",                      # P5 negative
    "'00007FF000000000'",                      # P6 negative
    'New-Req 0x1A01 12', 'New-Req 0x1A02 12',
    'New-Req 0x1A03 12', 'New-Req 0x1A04 12',
    'New-Req 0x1A05 12', 'New-Req 0x1A06 12',
):
    assert anchor in text, f'P wire damaged: {anchor}'
DST.write_text(text, encoding='utf-8')
h = hashlib.sha256(text.encode('utf-8')).hexdigest()
print(f'wrote {DST}: {len(text)} bytes, {len(text.splitlines())} lines, sha256 {h[:16]}...')
