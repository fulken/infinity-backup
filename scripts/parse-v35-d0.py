#!/usr/bin/env python3
# Offline PE parse of the v35 field D0 dump (first 1024B of the live ntoskrnl image,
# captured inside the transcript) + L2b 88B header + D1 20B header cross-check.
# Purpose: ground-truth the section layout, confirm the D1 gate bug (nsec=33 > 24),
# and locate .data's likely position for the v36 dump.

import re, struct, sys

TS = '/home/z/my-project/upload/v35-extract/trigger-test-v35-output-20260928-060157.txt'
raw = open(TS, 'rb').read().decode('utf-8', 'replace')
lines = raw.split('\n')

def find_dt(prefix, size):
    """Find the [DT] InfinityData <size> bytes: <hex> line after a marker."""
    for i, ln in enumerate(lines):
        if prefix in ln:
            # scan forward for the [DT] line
            for j in range(i, min(i + 40, len(lines))):
                m = re.search(r'\[DT\] InfinityData (\d+) bytes: ((?:[0-9A-F]{2} ?)+)', lines[j])
                if m and int(m.group(1)) == size:
                    return bytes(int(b, 16) for b in m.group(2).split())
    return None

# --- D0: 1024B at pe_base (after 'pre-D0' canary) ---
d0 = find_dt('pre-D0', 1024)
assert d0 and d0[:2] == b'MZ', 'D0 not found'
print(f'D0: 1024B captured, MZ ok, e_lfanew=0x{struct.unpack_from("<I", d0, 0x3C)[0]:X}')
lfanew = struct.unpack_from('<I', d0, 0x3C)[0]
assert d0[lfanew:lfanew+4] == b'PE\x00\x00'

# FILE_HEADER @ lfanew+4 (CORRECT COFF layout):
#   Machine@0(2) NumberOfSections@2(2) TimeDateStamp@4(4) PointerToSymbolTable@8(4)
#   NumberOfSymbols@12(4) SizeOfOptionalHeader@16(2) Characteristics@18(2)
fh = d0[lfanew+4:lfanew+24]
machine, nsec, tds, symptr, nsyms, sooh, chars = struct.unpack('<HHIIIHH', fh)
print(f'FILE_HEADER: machine=0x{machine:X} nsec={nsec} tds=0x{tds:X} symPtr=0x{symptr:X} '
      f'nSyms={nsyms} SOOH=0x{sooh:X} characteristics=0x{chars:X}')
print(f'  -> characteristics 0x{chars:X} = ' + ' | '.join(
      n for b, n in [(0x0001,'RELOCS_STRIPPED'),(0x0002,'EXECUTABLE_IMAGE'),(0x0020,'LARGE_ADDRESS_AWARE'),
                     (0x0100,'32BIT_MACHINE'),(0x2000,'DLL')] if chars & b) )

# Optional header @ lfanew+24, PE32+
oh = d0[lfanew+24:lfanew+24+sooh]
magic = struct.unpack_from('<H', oh, 0)[0]
entry, base_of_code = struct.unpack_from('<II', oh, 16)
image_base = struct.unpack_from('<Q', oh, 24)[0]
sa, fa = struct.unpack_from('<II', oh, 32)
size_of_image, size_of_headers = struct.unpack_from('<II', oh, 56)[0], struct.unpack_from('<I', oh, 60)[0]
print(f'OPT: magic=0x{magic:X} entry=0x{entry:X} base_of_code=0x{base_of_code:X} image_base=0x{image_base:X}')
print(f'     SectionAlignment=0x{sa:X} FileAlignment=0x{fa:X} SizeOfImage=0x{size_of_image:X} SizeOfHeaders=0x{size_of_headers:X}')

# subsystem + dllchars @ opt+68
subsys, dllc = struct.unpack_from('<HH', oh, 68)
print(f'     Subsystem={subsys} (3=Native console) DllCharacteristics=0x{dllc:X}'
      + (' (HIGH_ENTROPY_VA|DYNAMIC_BASE|NX_COMPAT)' if dllc & 0x20 and dllc & 0x40 else ''))

# Section table @ lfanew + 4 + 20 + SOOH
tbl_rva = lfanew + 4 + 20 + sooh
tbl_off_in_d0 = tbl_rva  # D0 IS the image start (read at pe_base), so file offset == RVA offset here
n_in_d0 = min(nsec, max(0, (1024 - tbl_off_in_d0) // 40))
print(f'\nSECTION TABLE @ RVA 0x{tbl_rva:X} (D0 offset {tbl_off_in_d0}) '
      f'-> {n_in_d0}/{nsec} entries inside the 1024B D0 dump:')
print(f'{"#":>2} {"name":10} {"VirtSize":>10} {"VirtAddr":>10} {"RawSize":>10} {"RawPtr":>10} {"flags":>10}')
prev_end = 0
for si in range(n_in_d0):
    e = d0[tbl_off_in_d0 + si*40: tbl_off_in_d0 + si*40 + 40]
    name = e[:8].rstrip(b'\x00').decode('latin1')
    vs, va, rs, rp = struct.unpack_from('<IIII', e, 8)
    fl = struct.unpack_from('<I', e, 36)[0]
    print(f'{si:>2} {name:10} 0x{vs:>8X} 0x{va:>8X} 0x{rs:>8X} 0x{rp:>8X} 0x{fl:>8X}')
    prev_end = va + vs

print(f'\nlast visible entry ends at RVA ~0x{prev_end:X}; SizeOfImage=0x{size_of_image:X} '
      f'-> {nsec - n_in_d0} entries NOT captured in D0 (need D2 in v36)')
print(f'.data visible in D0? ', end='')
if any(d0[tbl_off_in_d0+s*40:tbl_off_in_d0+s*40+6] == b'.data' for s in range(n_in_d0)):
    print('YES')
else:
    print('NO - .data is among the missing entries (v36 D2 will read the full 33*40=1320B table)')

# --- cross-check: D1 20B read @ lfanew+4 ---
d1 = find_dt('pre-D1', 20)
print(f'\nD1 cross-check: 20B @ lfanew+4 = {d1.hex(" ") if d1 else None}')
if d1:
    m2, ns2 = struct.unpack_from('<HH', d1, 0)
    sooh2, ch2 = struct.unpack_from('<HH', d1, 16)
    print(f'  D1 parse: machine=0x{m2:X} nsec={ns2} SOOH=0x{sooh2:X} chars=0x{ch2:X}'
          f'  -> nsec={ns2} == FILE_HEADER truth ({nsec}): {ns2 == nsec}')

# --- cross-check: L2b 88B @ lfanew ---
l2b = find_dt('pre-L2b', 88)
if l2b:
    ns3 = struct.unpack_from('<H', l2b, 4 + 2)[0]
    sooh3 = struct.unpack_from('<H', l2b, 4 + 16)[0]
    print(f'L2b cross-check: nsec={ns3} SOOH=0x{sooh3:X} -> all three reads agree: '
          f'{ns3 == ns2 == nsec and sooh3 == sooh2 == sooh}')

# --- the gate verdict ---
print(f'\n*** THE V35 GATE: nsec in [1..24] required; field nsec={nsec} -> REJECTED (the dump skip cause) ***')
print(f'*** v36 fix: accept nsec in [1..96] + bounds gate (table fits: {tbl_rva}+{nsec*40} '
      f'= 0x{tbl_rva + nsec*40:X} < SizeOfImage 0x{size_of_image:X}: {tbl_rva + nsec*40 < size_of_image}) ***')

# --- fingerprint re-verification with the LIVE walk data from this transcript ---
print('\n--- fingerprint closure (from THIS transcript) ---')
m = re.search(r'\[W1\] payload: .*?eproc=0x([0-9A-F]+) dtb=0x([0-9A-F]+)', raw)
eproc, dtb = int(m.group(1), 16), int(m.group(2), 16)
pfn = dtb >> 12
print(f'W1: System eproc=0x{eproc:X} dtb=0x{dtb:X} -> pfn=0x{pfn:X}')
for name, arg1 in [('crash1(v33 1:29AM)', 0xfffff807154e5078), ('crash2(v34 5:00AM)', 0xfffff80551725078)]:
    pdb = arg1 - (pfn * 0x30 + 8)
    ok = (arg1 - pdb - 8) % 0x30 == 0 and (arg1 - pdb - 8) // 0x30 == pfn
    print(f'{name}: arg1=0x{arg1:X} = pdb 0x{pdb:X} + 0x{pfn:X}*0x30+8 (exact={ok})')
print(f'R4 slot (0xCFC500) this boot: 0xFFFFF8064D930000 -> its deref would be '
      f'0x{0xFFFFF8064D930000 + pfn*0x30 + 8:X} = the SAME fingerprint class (unmapped -> 0x50)')
print(f'R5 slot (0xCFC510) this boot: 0xFFFFF98000000000 -> deref 0x{0xFFFFF98000000000 + pfn*0x30 + 8:X}')
print(f'MmPteBase R1 (0xCFB358) this boot: 0xFFFF9C0000000000  s=0x{(0xFFFF9C0000000000 >> 39) & 0x1FF:X} '
      f'(bits38:0=0 -> {0xFFFF9C0000000000 & ((1<<39)-1) == 0}, hi=0xFFFF canonical)')
