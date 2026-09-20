#!/usr/bin/env python3
"""Minimal ISO9660 file extractor (no dependencies).

Usage: iso_extract.py <iso> /BOOT/VMLINUZ_VIRT.;1 <outfile> [more pairs...]

Walks the ISO9660 directory records from the PVD root. Names are
compared case-insensitively with optional ';1' suffix stripping.
"""
import struct
import sys

SECT = 2048


class Iso:
    def __init__(self, path):
        self.f = open(path, "rb")
        # find the PVD (LBA 16..)
        for lba in range(16, 32):
            self.f.seek(lba * SECT)
            sect = self.f.read(SECT)
            if sect[1:6] == b"CD001" and sect[0] == 1:
                self.pvd = sect
                break
        else:
            raise SystemExit("no Primary Volume Descriptor found")
        # root directory record at offset 156, 34 bytes
        self.root = self.pvd[156:156 + 34]

    def _children(self, rec):
        """Yield (name, lba, length, is_dir) for a directory record."""
        lba = struct.unpack("<I", rec[2:6])[0]
        length = struct.unpack("<I", rec[10:14])[0]
        self.f.seek(lba * SECT)
        data = self.f.read(length)
        pos = 0
        while pos < len(data):
            reclen = data[pos]
            if reclen == 0:  # records don't cross sector boundaries
                pos = (pos // SECT + 1) * SECT
                continue
            r = data[pos:pos + reclen]
            pos += reclen
            name_len = r[32]
            name = r[33:33 + name_len].decode("latin-1")
            if name in ("\x00", "\x01"):
                continue  # self / parent
            ent_lba = struct.unpack("<I", r[2:6])[0]
            ent_len = struct.unpack("<I", r[10:14])[0]
            flags = r[25]
            is_dir = bool(flags & 2)
            yield name, ent_lba, ent_len, is_dir

    def _norm(self, name):
        # strip version suffix ';1' and the dot before it, uppercase
        return name.split(";")[0].rstrip(".").upper()

    def find(self, path):
        """Return (lba, length) for an absolute path like /BOOT/VMLINUZ."""
        parts = [self._norm(p) for p in path.split("/") if p]
        rec = self.root
        for i, part in enumerate(parts):
            for name, lba, length, is_dir in self._children(rec):
                if self._norm(name) == part:
                    if i == len(parts) - 1:
                        return lba, length
                    if not is_dir:
                        raise SystemExit(f"{part} is a file, not a dir")
                    rec = self._mkrec(lba, length)
                    break
            else:
                raise SystemExit(f"path component not found: {part}")
        raise SystemExit("empty path")

    def _mkrec(self, lba, length):
        # Build a proper minimal directory record: extent at [2:6],
        # data length at [10:14], flags(dir) at [25], name at [33].
        r = bytearray(34)
        r[0] = 34  # record length
        r[2:6] = struct.pack("<I", lba)
        r[6:10] = struct.pack(">I", lba)
        r[10:14] = struct.pack("<I", length)
        r[14:18] = struct.pack(">I", length)
        r[25] = 0x02  # directory flag
        r[32] = 1
        r[33:34] = b"\x00"
        return bytes(r)

    def extract(self, path, out):
        lba, length = self.find(path)
        self.f.seek(lba * SECT)
        remaining = length
        with open(out, "wb") as o:
            while remaining > 0:
                chunk = self.f.read(min(SECT * 64, remaining))
                if not chunk:
                    break
                o.write(chunk)
                remaining -= len(chunk)
        return length


def main():
    if len(sys.argv) < 4 or (len(sys.argv) - 2) % 2:
        print(__doc__)
        return 1
    iso_path = sys.argv[1]
    iso = Iso(iso_path)
    args = sys.argv[2:]
    for src, dst in zip(args[0::2], args[1::2]):
        n = iso.extract(src, dst)
        print(f"extracted {src} -> {dst} ({n} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
