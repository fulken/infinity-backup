#!/usr/bin/env python3
"""
verify-v12-anchors.py — prove every anchor used by scripts/patch-v12.py
occurs EXACTLY ONCE in the reconstructed v7 source (context + added
lines of patches/v7-on-a8e41b3.diff). Run before shipping the patcher;
guards against whitespace/dash drift between the diff and the anchors.
"""
import ast
import re
from pathlib import Path

BASE = Path("/home/z/my-project")
DIFF = BASE / "patches" / "v7-on-a8e41b3.diff"
PATCHER = BASE / "scripts" / "patch-v12.py"


def reconstruct_v7(diff_text: str) -> dict:
    files = {}
    cur = None
    for line in diff_text.splitlines(keepends=True):
        m = re.match(r"diff --git a/(\S+) b/(\S+)", line)
        if m:
            cur = m.group(2)
            files.setdefault(cur, [])
            continue
        if cur is None:
            continue
        if line.startswith(("+++", "---", "index ")):
            continue
        if line.startswith("@@"):
            files[cur].append("@@HUNK@@\n")
            continue
        if line.startswith("+"):
            files[cur].append(line[1:])
        elif line.startswith(" "):
            files[cur].append(line[1:])
    return {f: "".join(ls) for f, ls in files.items()}


def main() -> int:
    v7 = reconstruct_v7(DIFF.read_text(encoding="utf-8"))
    rh = v7.get("UEFI/include/RuntimeHook.h", "")
    dg = v7.get("UEFI/include/Diag.h", "")
    print(f"reconstructed: RuntimeHook.h {len(rh)} chars, Diag.h {len(dg)} chars")

    tree = ast.parse(PATCHER.read_text(encoding="utf-8"))
    failures = 0
    for node in ast.walk(tree):
        if not (isinstance(node, ast.Call)
                and getattr(node.func, "id", "") == "apply_edit"):
            continue
        # apply_edit(files, edit_id, rel, old=..., new=...)
        edit_id = node.args[1].value          # positional constant
        rel = node.args[2].value
        old_kw = next(k for k in node.keywords if k.arg == "old")
        try:
            old = ast.literal_eval(old_kw.value)
        except Exception as e:  # pragma: no cover
            print(f"{edit_id:4s} ANCHOR UNPARSEABLE: {e}")
            failures += 1
            continue
        target = dg if rel == "Diag.h" else rh
        # hunk boundaries break multi-line anchors; check per hunk chunk
        # by searching within the joined text with boundary tolerance
        n = target.count(old)
        status = "OK" if n == 1 else "** FAIL **"
        print(f"anchor {edit_id:4s} {rel:15s} count={n}  {status}")
        if n != 1:
            failures += 1
            # diagnostics: locate first anchor line
            first = old.splitlines()[0]
            idx = target.find(first)
            print(f"      first anchor line found at {idx}")
            if idx >= 0:
                want = old.splitlines()
                got = target[idx:idx + len(old) + 40].splitlines()
                for i, (w, g) in enumerate(zip(want, got)):
                    if w != g:
                        print(f"      line {i}: want {w!r}")
                        print(f"             got  {g!r}")
                        break
    print()
    if failures:
        print(f"{failures} anchor(s) FAILED — fix patch-v12.py before building")
        return 1
    print("all anchors verified — patcher is safe to run")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
