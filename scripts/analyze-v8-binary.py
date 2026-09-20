#!/usr/bin/env python3
"""Analyze v8-memory-RT.efi: locate trace-policy strings + xrefs in disassembly."""
import re, subprocess, sys

EFI = "/home/z/my-project/patches/v8-memory-RT.efi"
DIS = "/home/z/my-project/backups/v8-dis.txt"

# Section map (from objdump -h): .text VMA 0x4000 file 0x2800 size 0xc460
#                                .data VMA 0x12000 file 0xf000 size 0x8fa8
TEXT_VMA, TEXT_OFF, TEXT_SZ = 0x4000, 0x2800, 0xC460
DATA_VMA, DATA_OFF, DATA_SZ = 0x12000, 0xF000, 0x8FA8

blob = open(EFI, "rb").read()

def find_str_vma(s):
    """Find ASCII string in file, return list of .data VMAs."""
    out = []
    needle = s.encode() + b"\x00"
    start = 0
    while True:
        i = blob.find(needle, start)
        if i < 0: break
        if DATA_OFF <= i < DATA_OFF + DATA_SZ:
            out.append(DATA_VMA + (i - DATA_OFF))
        start = i + 1
    return out

dis = open(DIS, errors="replace").read() if __import__("os").path.exists(DIS) else None
if dis is None:
    dis = subprocess.run(["objdump", "-d", EFI], capture_output=True, text=True).stdout
    open(DIS, "w").write(dis)

targets = {
    "fmt_call#":  find_str_vma(" call#"),
    "str_VIRT":   find_str_vma(" VIRT"),
    "str_FIRST":  find_str_vma(" FIRST"),
    "str_BOOTCTX":find_str_vma("BOOT-CTX"),
    "stage4_msg": find_str_vma("virtual mode armed"),
    "diag_stage": find_str_vma("g_diag_stage"),
}

for name, addrs in targets.items():
    print(f"{name}: {[hex(a) for a in addrs]}")

# find lea/mov instructions referencing these addresses (RIP-relative)
print("\n--- xrefs (rip-relative lea) ---")
lines = dis.splitlines()
xref_re = re.compile(r"^\s+([0-9a-f]+):\s+(?:48 8d 0d|48 8d 15|48 8d 05|4c 8d) ([0-9a-f ]+)\s+lea\s+.*# ([0-9a-fx]+)")
hits = {}
for ln in lines:
    m = xref_re.search(ln)
    if not m: continue
    addr = int(m.group(3), 16)
    for name, addrs in targets.items():
        if addr in addrs:
            hits.setdefault(name, []).append((int(m.group(1), 16), ln.strip()))

for name, refs in hits.items():
    print(f"\n### {name} referenced from {len(refs)} place(s):")
    for a, ln in refs[:12]:
        print(f"  {hex(a)}: {ln}")
