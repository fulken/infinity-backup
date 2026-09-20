#!/usr/bin/env python3
"""
audit-bat-parens.py — flag parentheses in echo text INSIDE parenthesized
blocks of a .bat file (the classic cmd silent-abort killer).

Heuristic block tracking (adequate for this project's .bat style):
  - a line whose last non-space char is '('            -> depth += 1
  - a line that is exactly ')'                          -> depth -= 1
  - 'do (' at end also handled by rule 1
While depth > 0, any 'echo' line containing '(' or ')' is flagged.

Exit 0 = clean, 1 = flagged lines found.
Usage: audit-bat-parens.py <file.bat> [--allow PROVEN_SUBSTRING]
"""
import sys

def main():
    path = sys.argv[1]
    allow = []
    if len(sys.argv) > 3 and sys.argv[2] == "--allow":
        allow = sys.argv[3:]

    with open(path, encoding="utf-8", errors="replace", newline="") as f:
        lines = f.read().split("\r\n")

    depth = 0
    problems = []
    for i, raw in enumerate(lines, 1):
        line = raw.rstrip()
        if not line or line.startswith("@"):
            pass
        if depth > 0 and line.lower().lstrip().startswith("echo"):
            body = line.lower().lstrip()[4:]
            if "(" in body or ")" in body:
                if any(a in line for a in allow):
                    print(f"  {i:4}  WHITELISTED (proven in production): {line.strip()}")
                else:
                    problems.append((i, line.strip()))
        # depth tracking
        if line.endswith("("):
            depth += 1
        elif line == ")":
            depth = max(0, depth - 1)
        elif line.endswith(") )") or line == ") )":
            pass
    if depth != 0:
        print(f"WARN: final block depth {depth} (unbalanced file?)")

    for i, l in problems:
        print(f"  {i:4}  PAREN-IN-BLOCK ECHO: {l}")
    if problems:
        print(f"FAILED: {len(problems)} risky echo line(s)")
        sys.exit(1)
    print("CLEAN: no parentheses in echo text inside blocks")

if __name__ == "__main__":
    main()
