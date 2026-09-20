#!/usr/bin/env python3
"""Dump guest memory via QMP after the crash (OVMF dead-loops there).

Connects to the QMP unix socket, runs human-monitor-command to
read registers and the stack around the faulting RSP.
"""
import json
import socket
import sys
import time

SOCK = sys.argv[1] if len(sys.argv) > 1 else "/home/z/my-project/test-a/qmp.sock"
CMDS = [
    "info registers",
    "x/16i $rip-24",
    "x/16gx $rsp",
    "x/8gx 0x7F6B0000",
]

def main():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(SOCK)
    f = s.makefile("rw")

    def rd():
        while True:
            line = f.readline()
            if not line:
                return None
            msg = json.loads(line)
            if "event" in msg:
                continue
            return msg

    rd()  # greeting (single JSON line)
    f.write(json.dumps({"execute": "qmp_capabilities"}) + "\n")
    f.flush()
    print(json.dumps(rd()))
    for cmd in CMDS:
        f.write(json.dumps({
            "execute": "human-monitor-command",
            "arguments": {"command-line": cmd},
        }) + "\n")
        f.flush()
        r = rd()
        out = (r or {}).get("return", "")
        print(f"\n===== {cmd} =====")
        print(out)

if __name__ == "__main__":
    main()
