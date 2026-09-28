#!/usr/bin/env python3
# Parse the [DT] InfinityData hex dumps from the v37 transcript to recover the
# FULL section table (33 x 40 = 1320 B in 2 chunks) and the PE headers.
import re, struct

TX = "/home/z/my-project/upload/v37-extract/trigger-test-v37-output-20260928-085014.txt"
raw = open(TX, "rb").read().decode("utf-8", "replace")

# All [DT] InfinityData NNNN bytes: <hex...> lines (multi-line hex payloads)
# Format in transcript: "[DT] InfinityData 1024 bytes: 4D 5A 90 00 ..." (single line)
hexes = re.findall(r"\[DT\] InfinityData (\d+) bytes: ((?:[0-9A-F]{2} )+[0-9A-F]{2})", raw)
print(f"found {len(hexes)} [DT] payloads")

# D-step payloads are the ones after the step-D banner; identify by content:
# chunk containing "4D 5A 90 00" at offset 0 = D0 (image RVA 0)
# the two chunks summing to 1320 = D2 (section table)
dts = [(int(n), bytes.fromhex(h.replace(" ", ""))) for n, h in hexes]

d0 = next(b for n, b in dts if n == 1024 and b[:2] == b"MZ")
sec_chunks = [b for n, b in dts if len(b) in (1024, 296) and b[:2] != b"MZ"]
print("payload sizes:", [n for n, b in dts][-8:])

# --- Parse PE headers from D0 (first 1024 B of the image at RVA 0) ---
e_lfanew = struct.unpack_from("<I", d0, 0x3C)[0]
print(f"\ne_lfanew=0x{e_lfanew:X}")
assert d0[e_lfanew:e_lfanew+4] == b"PE\x00\x00"
machine, nsec, _, _, _, szopt, _ = struct.unpack_from("<HHIIIHH", d0, e_lfanew+4)
print(f"machine=0x{machine:X} sections={nsec} SizeOfOptionalHeader=0x{szopt:X}")
opt = e_lfanew + 24
magic = struct.unpack_from("<H", d0, opt)[0]
print(f"opt magic=0x{magic:X} (0x20b = PE32+)")
size_of_image = struct.unpack_from("<I", d0, opt+56)[0]
print(f"SizeOfImage=0x{size_of_image:X}")

# --- Section table: D2 chunks (1024 + 296 = 1320 = 33*40) ---
sec_table = b"".join(sec_chunks)
print(f"\nsection table bytes: {len(sec_table)} (expect {nsec*40})")

# sanity: the table should begin with a plausible name (printable)
first_name = sec_table[:8]
print("first section name:", first_name)

print(f"\n{'#':>2}  {'name':<10} {'VSize':>10} {'VirtAddr':>10} {'RawSize':>10} {'PtrRaw':>10}  chars")
sections = []
for i in range(nsec):
    off = i * 40
    hdr = sec_table[off:off+40]
    if len(hdr) < 40:
        print(f"{i+1:>2}  TRUNCATED")
        break
    name = hdr[:8].rstrip(b"\x00").decode("latin1")
    vsize, va, rsize, praw = struct.unpack_from("<IIII", hdr, 8)
    chars = struct.unpack_from("<I", hdr, 36)[0]
    sections.append((name, va, vsize, rsize, praw, chars))
    flag = " <== ALMOSTRO" if "ALMOS" in name else ""
    print(f"{i+1:>2}  {name:<10} 0x{vsize:08X} 0x{va:08X} 0x{rsize:08X} 0x{praw:08X}  0x{chars:08X}{flag}")

# --- Where does the table start? find .rdata header offset inside D0 ---
idx = d0.find(b".rdata")
print(f"\n'.rdata' appears in D0 (image RVA 0..0x400) at offset 0x{idx:X}")
print(f"=> section table starts at RVA 0x{(idx if idx>=0 else 0):X}" if idx >= 0 else "")

# --- check: does ANY section contain the known targets 0xCFB358 / 0xCFC420? ---
print("\n-- containment check for known Mm targets --")
for tgt in (0xCFB358, 0xCFC420, 0xCFC698 if False else 0xCFC420):
    hit = [s for s in sections if s[1] <= tgt < s[1] + s[2]]
    print(f"RVA 0x{tgt:X}: " + (f"inside {hit[0][0]} [0x{hit[0][1]:X}..0x{hit[0][1]+hit[0][2]:X})" if hit else "NOT inside any section"))

# also .data extent for the v36 dump cross-check (1025488 B = 0xFA4D0)
d = [s for s in sections if s[0] == ".data"]
if d:
    n, va, vs, rs, pr, ch = d[0]
    print(f"\n.data: VA=0x{va:X} VSize=0x{vs:X} ({vs} B) end=0x{va+vs:X}")
    print(f"v36 dump size 1025488 == .data VSize? {vs == 1025488}")
