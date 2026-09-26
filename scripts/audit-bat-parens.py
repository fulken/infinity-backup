#!/usr/bin/env python3
# ============================================================================
# audit-bat-parens.py — class-kill scanner for the phase-d.bat paren bug.
#
# BUG CLASS (bit us in v12.2 AND shipped again in v25):
#   an `echo` line containing an UNESCAPED `)` inside a cmd parenthesized
#   block closes the block early; the trailing text corrupts the enclosing
#   if/for statement -> parse abort -> the cmd window closes instantly.
#   An unescaped `(` in echo text inside a block is the same landmine.
#
# POLICY (strict, matches the existing file convention):
#   echo text must use ^(^ ^)^ escapes EVERYWHERE - even at top level,
#   so the audit is context-free and cannot miss a block edge case.
#
# Usage:  python3 audit-bat-parens.py <file.bat> [file2.bat ...]
# Exit 0 = clean, 1 = violations found (prints each offending line).
# ============================================================================
import sys

def scan(path):
    bad = []
    with open(path, "rb") as fh:
        raw = fh.read()
    # LF-only is the field-proven format; flag CRLF silently (other audits own that)
    text = raw.replace(b"\r\n", b"\n").replace(b"\r", b"\n").decode("ascii", "replace")
    for n, line in enumerate(text.split("\n"), 1):
        s = line.strip()
        low = s.lower()
        # comments / labels / blank
        if not s or low.startswith("rem ") or low.startswith("::") or s.startswith(":"):
            continue
        # only echo statements carry the risk class
        if not (low.startswith("echo ") or low.startswith("echo\t") or low == "echo"):
            continue
        body = s[4:].strip() if len(s) > 4 else ""
        # find parens NOT escaped with ^
        for i, ch in enumerate(body):
            if ch not in "()":
                continue
            if i > 0 and body[i - 1] == "^":
                continue  # properly escaped
            bad.append((n, s))
            break
    return bad

def main():
    if len(sys.argv) < 2:
        print("usage: audit-bat-parens.py <file.bat> [...]", file=sys.stderr)
        return 2
    total = 0
    for path in sys.argv[1:]:
        bad = scan(path)
        if bad:
            print(f"[FAIL] {path}:")
            for n, line in bad:
                print(f"  line {n}: unescaped paren in echo: {line}")
            total += len(bad)
        else:
            print(f"[PASS] {path}: no unescaped parens in echo lines")
    if total:
        print(f"AUDIT FAILED: {total} offending line(s) - escape with ^( and ^)")
        return 1
    print("ALL CHECKS PASSED")
    return 0

if __name__ == "__main__":
    sys.exit(main())
