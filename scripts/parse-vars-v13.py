#!/usr/bin/env python3
"""Parse OVMF_VARS_4M.fd (EDK2 auth variable store): full variable list +
INFDIAG run-history table. Compare v12-checked vs v13-checked files."""

import struct, sys, uuid

INF_GUID = "a1b2c3d4-e5f6-4789-9abc-def012345678"
G_INF = uuid.UUID(INF_GUID).bytes_le
AUTH_HDR = 60  # StartId2 State1 Rsvd1 Attr4 Mono8 TimeStamp16 PubKey4 NameSize4 DataSize4 Guid16

def parse_vars(data):
    found, off = [], 0
    while True:
        i = data.find(b"\xaa\x55", off)  # StartId 0x55AA stored LE
        if i < 0 or i + AUTH_HDR > len(data):
            break
        off = i + 2
        state = data[i+2]
        attr, = struct.unpack_from("<I", data, i+4)
        name_sz, data_sz = struct.unpack_from("<II", data, i+36)
        g = data[i+44:i+60]
        if name_sz == 0 or name_sz > 300 or data_sz > 0x10000:
            continue
        if name_sz % 2:  # UTF-16 names are even-sized
            continue
        body = i + AUTH_HDR
        if body + name_sz + data_sz > len(data):
            continue
        try:
            name = data[body:body+name_sz].decode("utf-16-le").rstrip("\x00")
        except Exception:
            continue
        if not name or any(c < ' ' or c == '\x7f' for c in name):
            continue
        payload = data[body+name_sz:body+name_sz+data_sz]
        found.append(dict(off=i, state=state, attr=attr,
                          guid=str(uuid.UUID(bytes_le=g)), name=name,
                          data=payload))
        off = body + name_sz + data_sz
    return found

def decode_infdiag(d):
    if len(d) != 32 or d[:4] != b"DFNI":
        return None
    stage, flags, wb = struct.unpack_from("<III", d, 4)
    cr3, = struct.unpack_from("<Q", d, 16)
    calls, last = struct.unpack_from("<II", d, 24)
    return dict(stage=stage, flags=flags, win_build=wb, cr3=cr3,
                calls=calls, last=last)

def infdiag_table(vars_, tag):
    print(f"\n--- INFDIAG run-history in {tag} (offset ascending = time ascending) ---")
    print(f"{'offset':>8}  {'st':>2} {'flags':>5} {'build':>5} {'calls':>5}  cr3")
    for v in vars_:
        if v["name"] == "INFDIAG" and v["guid"] == INF_GUID:
            d = decode_infdiag(v["data"])
            if d:
                mark = ""
                print(f"{v['off']:>8X}  {d['stage']:>2} 0x{d['flags']:03X} "
                      f"{d['win_build']:>5} {d['calls']:>5}  0x{d['cr3']:X}{mark}")

def main():
    base = "/home/z/my-project/upload/extracted-v13/"
    files = [("VARS-v12", base + "varsV12/vars/OVMF_VARS_4M.fd"),
             ("VARS-v13", base + "varsV13/vars/OVMF_VARS_4M.fd")]
    allv = {}
    for tag, p in files:
        data = open(p, "rb").read()
        v = parse_vars(data)
        allv[tag] = (v, data)
        print(f"\n{'='*76}\n{tag}: {len(data)} bytes, {len(v)} auth variables parsed")
        inf = [x for x in v if x["guid"] == INF_GUID]
        names = {}
        for x in inf: names.setdefault(x["name"], []).append(x)
        print(f"  Infinity-namespace ({INF_GUID}): " +
              ", ".join(f"{n} x{len(l)}" for n, l in sorted(names.items())))
        for x in inf:
            if x["name"] == "infinityMem":
                print(f"    infinityMem @0x{x['off']:X} attr=0x{x['attr']:X} "
                      f"data={x['data'].hex()} -> pool 0x{struct.unpack('<Q', x['data'][8:16])[0]:X}"
                      if len(x['data']) == 16 else
                      f"    infinityMem @0x{x['off']:X} data={x['data'].hex()}")
        # other vars present (names only)
        others = sorted({x["name"] for x in v if x["guid"] != INF_GUID})
        print(f"  other vars ({len(others)}): {', '.join(others[:30])}")
        infdiag_table(v, tag)
    # cross-file comparison
    v12, d12 = allv["VARS-v12"]; v13, d13 = allv["VARS-v13"]
    print(f"\n{'='*76}\nCROSS-FILE COMPARISON")
    print(f"  identical prefix? first-diff-at:",
          next((hex(i) for i in range(min(len(d12), len(d13))) if d12[i] != d13[i]), "SAME"))
    o12 = [x["off"] for x in v12 if x["name"] == "INFDIAG"]
    o13 = [x["off"] for x in v13 if x["name"] == "INFDIAG"]
    print(f"  INFDIAG entries: v12-file={len(o12)} (last @0x{o12[-1]:X})  "
          f"v13-file={len(o13)} (last @0x{o13[-1]:X})")
    # last INFDIAG of each
    for tag, vv in (("VARS-v12", v12), ("VARS-v13", v13)):
        last = [x for x in vv if x["name"] == "INFDIAG"][-1]
        d = decode_infdiag(last["data"])
        print(f"  {tag} LAST INFDIAG: stage={d['stage']} flags=0x{d['flags']:X} "
              f"win_build={d['win_build']} calls={d['calls']} cr3=0x{d['cr3']:X}")
    # entries only in v13 file (appended after v12 snapshot)
    if o13[0] == o12[0]:
        extra = [x for x in v13 if x["guid"] == INF_GUID and x["off"] > max(o12)]
        print(f"  Infinity entries appended AFTER the v12 file's last INFDIAG:")
        for x in extra:
            d = decode_infdiag(x["data"]) if x["name"] == "INFDIAG" else None
            extra_s = (f"stage={d['stage']} flags=0x{d['flags']:X} calls={d['calls']}"
                       if d else x["data"].hex())
            print(f"    @0x{x['off']:X} {x['name']:<12} {extra_s}")

if __name__ == "__main__":
    main()
