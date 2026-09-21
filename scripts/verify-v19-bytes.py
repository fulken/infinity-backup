#!/usr/bin/env python3
"""Verify every byte-math expectation hardcoded in the v19 self-test,
plus re-verify the v18-report truncation evidence."""

def le(*bs):  # little-endian value of bytes
    v = 0
    for b in reversed(bs):
        v = (v << 8) | b
    return v

checks = []
def ck(name, got, want):
    checks.append((name, got, want, got == want))

# --- v19 self-test expectations ---
ck('U32 37 13 00 00 -> 0x1337', le(0x37, 0x13, 0, 0), 0x1337)
ck('U32 65 4A 00 00 -> 19045', le(0x65, 0x4A, 0, 0), 19045)
ck('U32 FF FF FF FF -> 0xFFFFFFFF', le(1, 1, 1, 1) * 0xFFFFFFFF // le(1, 1, 1, 1), 0xFFFFFFFF) if False else ck('U32 FF FF FF FF -> 0xFFFFFFFF', le(0xFF, 0xFF, 0xFF, 0xFF), 0xFFFFFFFF)
ck('U64 00 10 C0 7F 00 00 00 00 -> 0x7FC01000', le(0x00, 0x10, 0xC0, 0x7F, 0, 0, 0, 0), 0x7FC01000)

# HexLe4 'DEADBEEF' -> EF BE AD DE
hb = bytes.fromhex('DEADBEEF')[::-1]
ck('HexLe4 DEADBEEF -> EF BE AD DE', tuple(hb), (0xEF, 0xBE, 0xAD, 0xDE))

# New-Req 0x1999 1 'FFFFFFFF' 4 '0000800000000000'
req = bytearray(48)
req[0:4] = (0x1999).to_bytes(4, 'little')
req[4:8] = (1).to_bytes(4, 'little')
req[8:12] = (0xFFFFFFFF).to_bytes(4, 'little')
req[12:16] = (4).to_bytes(4, 'little')
req[16:24] = (0x0000800000000000).to_bytes(8, 'little')
ck('req[0]=0x99 req[1]=0x19 req[4]=0x01', (req[0], req[1], req[4]), (0x99, 0x19, 0x01))
ck('req[8..11] = FF FF FF FF', tuple(req[8:12]), (0xFF, 0xFF, 0xFF, 0xFF))
ck('req[12] = 0x04', req[12], 0x04)
ck('req[16..23] = 00 00 00 00 00 80 00 00', tuple(req[16:24]), (0, 0, 0, 0, 0, 0x80, 0, 0))

# J-step needle: 19045 -> 65 4A 00 00
ck('19045 LE = 65 4A 00 00', tuple((19045).to_bytes(4, 'little')), (0x65, 0x4A, 0, 0))

# --- v18 report truncation evidence (why v19 exists) ---
ck('v18 INFDIAG offset12 65 4A 00 00 = 19045 (driver truth)', le(0x65, 0x4A, 0, 0), 19045)
ck('v18 shown win_build 101 = LOW BYTE 0x65 of 19045', 19045 & 0xFF, 101)
ck('v18 INFDIAG offset24 3B 01 00 00 = 315 real hook_calls', le(0x3B, 0x01, 0, 0), 315)
ck('v18 shown hook_calls 59 = LOW BYTE 0x3B of 315', 315 & 0xFF, 59)
ck('v18 shown seq 0x37 = LOW BYTE of 0x1337', 0x1337 & 0xFF, 0x37)
ck('v18 PONG raw 37 13 00 00 01 00 00 00 = seq 0x1337 status 1 (byte-perfect)',
   (le(0x37, 0x13, 0, 0), le(0x01, 0, 0, 0)), (0x1337, 1))

# old broken U32 (byte -shl truncation simulation): only byte[0] survives
def old_u32(b): return b[0]  # 0x13 -shl 8 truncated to byte 0 etc -> everything but b[0] ORs away
ck('OLD U32(37 13 00 00) collapsed to 0x37 (the v18 bug)', old_u32([0x37, 0x13, 0, 0]), 0x37)
ck('OLD U32 would fail New-Req assert: 0x55 != 0x1555', old_u32([0x55, 0x15, 0, 0]) == 0x1555, False)

ok = all(c[3] for c in checks)
for name, got, want, passed in checks:
    print(f"{'PASS' if passed else 'FAIL'}  {name}  (got {got!r}, want {want!r})")
print('=' * 50)
print('ALL BYTE-MATH CHECKS:', 'PASS' if ok else 'FAIL')
raise SystemExit(0 if ok else 1)
