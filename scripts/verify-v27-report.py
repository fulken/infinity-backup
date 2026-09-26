#!/usr/bin/env python3
"""verify-v27-report.py — machine-verify the v27 field report (driver v20 + trigger v27).

Expected GREEN run per the v27 ship contract:
  K CONVERGED (state=1 reason=0, real pe_base/pe_size)
  L1 MZ | L2a e_lfanew in range | L2b 88-byte payload: PE sig + AMD64 + SizeOfImage==payload
  L3 8 entry bytes = FIRST real kernel-code read via requests
  L4/L5 ErrAccess(4) gate negatives
  J1..J7 regression green | INFCNT 17 | verdict F1 PROVEN | footer | zero new events
Cross-checks transcript vs serial ([AN] trace, [RD] pairs, J7 no-[RD]).
"""
import re, sys, pathlib

BASE = pathlib.Path("/home/z/my-project/upload/v27-extract")
TR = (BASE / "trigger-test-v27-output-20260926-193645.txt").read_text(encoding="utf-8-sig", errors="replace")
SL = (BASE / "serial-phase-d.log").read_text(encoding="utf-8", errors="replace")

fails, passes = [], []
def chk(name, cond, detail=""):
    (passes if cond else fails).append(name + (f"  [{detail}]" if detail else ""))

# --- transcript structure ---
chk("T-footer", "==== END v27 ====" in TR)
chk("T-start/end", "transcript start" in TR and "transcript end" in TR)
chk("T-selftest", "all passed" in TR)

# --- K converged ---
m = re.search(r"\[K\] payload: state=(\d+) reason=(\d+) pe_base=(0x[0-9A-F]+) pe_size=(0x[0-9A-F]+) idt_base=(0x[0-9A-F]+)", TR)
chk("K-payload-present", m is not None)
if m:
    state, reason, pe_base, pe_size, idt = int(m[1]), int(m[2]), int(m[3],16), int(m[4],16), int(m[5],16)
    chk("K-state=1", state == 1, f"state={state}")
    chk("K-reason=0", reason == 0, f"reason={reason}")
    chk("K-pe_size=0x1046000", pe_size == 0x1046000, hex(pe_size))
    chk("K-range-16MB", 0x1000000 <= pe_size <= 0x2000000)
    chk("K-unlocked-line", "ANCHORS CONVERGED" in TR)

# --- L1 ---
chk("L1-MZ", re.search(r"\[L1\] PASS: 4D 5A = MZ", TR) is not None)
# --- L2a ---
m2a = re.search(r"\[L2a\] PASS: e_lfanew=(0x[0-9A-F]+)", TR)
chk("L2a-pass", m2a is not None and 0x40 <= int(m2a[1],16) <= 0x400, m2a[1] if m2a else "?")
# --- L2b: the v27 fix proof ---
chk("L2b-DT-88", "[DT] InfinityData 88 bytes: 50 45 00 00 64 86" in TR)
chk("L2b-sig", "sig PE\\0\\0=True  machine AMD64=True" in TR)
mrb = re.search(r"entry RVA=(0x[0-9A-F]+)\s+SizeOfImage=(0x[0-9A-F]+)", TR)
chk("L2b-size==payload", mrb is not None and int(mrb[2],16) == 0x1046000, mrb[2] if mrb else "?")
chk("L2b-pass", "L2b] PASS + SizeOfImage == the anchor payload" in TR)
chk("L2b-no-122", "Win32=122" not in TR)  # the v26 bug class is dead
# --- L3 ---
chk("L3-8bytes", "[L3] PASS: 8 entry-point bytes back: 48 83 EC 38 4C 89 7C 24" in TR)
# --- L4/L5 negatives (segmented by the pre-L canaries) ---
seg_l4 = TR.split("pre-L4")[1].split("pre-L5")[0] if "pre-L4" in TR else ""
chk("L4-reject", "[L4] PASS" in seg_l4 and "status=4(ErrAccess)" in seg_l4)
seg_l5 = TR.split("pre-L5")[1].split("LADDER DECISION")[0] if "pre-L5" in TR else ""
chk("L5-reject", "[L5] PASS" in seg_l5 and "status=4(ErrAccess)" in seg_l5)
# --- J regression ---
for j, pat in [("J1",r"19045 FOUND"),("J2",r"19045 FOUND"),("J3",r"expected 0"),("J4",r"expected 0"),
               ("J5",r"dword\[0\]=19045"),("J6",r"status=4\(ErrAccess\)"),("J7",r"status=4\(ErrAccess\)")]:
    seg = TR.split(f"step J{j[1]}:")[1][:1400] if f"step J{j[1]}:" in TR else ""
    chk(f"{j}-green", bool(seg) and re.search(pat, seg) is not None)
# --- INFCNT ---
chk("N-INFCNT-17", re.search(r"INFCNT read-back: 4 bytes: 11 00 00 00", TR) is not None)
chk("N-INFCNT-17-sum", "INFCNT final = 17" in TR)
# --- verdict ---
chk("VERDICT-F1-PROVEN", ">>> F1 PROVEN: ANCHORS CONVERGED + VALIDATED-IMAGE READS VIA REQUESTS <<<" in TR)
chk("VERDICT-PHASE-E", "KERNEL DATA PATH VIA REQUESTS PROVEN - PHASE E COMPLETE" in TR)

# --- serial cross-checks ---
def sl_after(tag, n=1):
    lines = SL.splitlines()
    out = []
    for i, l in enumerate(lines):
        if tag in l:
            out.extend(lines[i:i+n])
    return "\n".join(out)
an = sl_after("[AN]", 40)
chk("S-AN-sidt==idt", f"sidt base=0x{idt:016X}" in an if m else False, f"0x{idt:016X}" if m else "?")
for w in ("v1","v2","v3"):
    chk(f"S-AN-walk-{w}-conv", f"walk {w}=0x{pe_base:016X}" in an if m else False)
chk("S-AN-skip-ge1", an.count("skipped=1") >= 3)
chk("S-AN-converged", "CONVERGED" in an)
rd = re.findall(r"\[RD\] mapped va=(0x[0-9A-F]+)\r?\n(?:\[[^\]]*\])+ mapped read ok=(\d)", SL)
chk("S-RD-12-pairs", len(rd) == 12, f"got {len(rd)}")
vmap = {  # expected va -> expected ok
    "L1": (pe_base, 1), "L2a": (pe_base+0x3C, 1), "L2b": (pe_base+0x118, 1),
    "L3": (pe_base+int(mrb[1],16), 1),
    "L4": (pe_base-0x1000, 0), "L5": (pe_base+0x1046000, 0),
    "J1": (0x7FFE0260, 1), "J2": (0xFFFFF78000000260, 1), "J3": (0x7FFE0308, 1),
    "J4": (0xFFFFF78000000308, 1), "J5": (0x7FFE0260, 1), "J6": (0x0000800000000000, 0),
}
for i, (step, (va, ok)) in enumerate(vmap.items()):
    got = rd[i] if i < len(rd) else ("?", -1)
    chk(f"S-RD-{step}", int(got[0],16) == va and int(got[1]) == ok, f"got {got[0]} ok={got[1]}")
chk("S-RD-order", [x[0] for x in rd][:4] == [f"0x{pe_base:016X}", f"0x{pe_base+0x3C:016X}", f"0x{pe_base+0x118:016X}", f"0x{pe_base+0x990010:016X}"] if m and mrb else False)
# J7 must have NO [RD] after the J6 pair (pre-read pid reject)
chk("S-RD-J7-absent", len(rd) == 12)  # exactly 12 pairs, none extra for J7

# --- event log: no NEW events from this run (run at 19:36) ---
ev = TR.split("post-mortem")[1].split("[SELFTEST]")[0] if "post-mortem" in TR else ""
chk("T-events-old-only", "9/26/2026 8:20:29 AM" in ev and "9/27" not in ev and "7:3" not in ev)

print(f"PASSED {len(passes)}")
for p in passes: print(f"  [PASS] {p}")
if fails:
    print(f"\nFAILED {len(fails)}")
    for f in fails: print(f"  [FAIL] {f}")
    sys.exit(1)
print("\nALL CHECKS PASSED — v27 FIELD RUN IS FULLY GREEN")
