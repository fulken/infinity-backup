#!/usr/bin/env python3
# ============================================================================
# ps-structcheck.py — string-aware bracket/brace/paren stack checker for
# PowerShell scripts. Strips comments, single/double-quoted strings and
# here-strings, then stack-parses () {} [] over CODE ONLY and verifies:
#   - every opener closes (and nothing closes unopened)
#   - depth never goes negative
#   - depth returns to 0 at end of file
# Usage: ps-structcheck.py <file.ps1> [<file2.ps1> ...]
# Exit: 0 = structurally clean, 1 = problems (printed with line numbers)
# ============================================================================
import sys

def strip_noncode(line, state):
    # state: dict(with(in_squote, in_dquote, in_hsq, in_hdq))
    out = []
    i, n = 0, len(line)
    while i < n:
        c = line[i]
        st = state
        if st['in_hsq'] or st['in_hdq']:
            # here-string closers: '@ or "@ alone at line start
            if i == 0:
                if st['in_hsq'] and line.startswith("'@") and line[2:].strip() == '':
                    st['in_hsq'] = False
                    break
                if st['in_hdq'] and line.startswith('"@') and line[2:].strip() == '':
                    st['in_hdq'] = False
                    break
            i += 1
            continue
        if st['in_squote']:
            if c == "'":
                if i + 1 < n and line[i+1] == "'":   # '' escape
                    i += 2; continue
                st['in_squote'] = False
            i += 1
            continue
        if st['in_dquote']:
            if c == '`':                              # backtick escape
                i += 2; continue
            if c == '"':
                if i + 1 < n and line[i+1] == '"':
                    i += 2; continue
                st['in_dquote'] = False
            i += 1
            continue
        # code context
        if c == '#':
            break                                     # comment to EOL
        if c == "'" and line.startswith("@'", max(0, i - 1)) is False and False:
            pass
        if c == '<' and i + 1 < n and line[i+1] == '#':
            break                                     # block comment start (rare) - treat to EOL
        if c == '@' and i + 1 < n and line[i+1] == "'" and line[i+2:].strip() == '':
            st['in_hsq'] = True; i += 2; continue
        if c == '@' and i + 1 < n and line[i+1] == '"' and line[i+2:].strip() == '':
            st['in_hdq'] = True; i += 2; continue
        if c == "'":
            st['in_squote'] = True; i += 1; continue
        if c == '"':
            st['in_dquote'] = True; i += 1; continue
        if c == '`':                                  # escape in code (line continuation)
            i += 2; continue
        out.append(c)
        i += 1
    return ''.join(out)

def check(path):
    state = {'in_squote': False, 'in_dquote': False, 'in_hsq': False, 'in_hdq': False}
    pairs = {')': '(', '}': '{', ']': '['}
    stack = []
    errs = []
    for ln, raw in enumerate(open(path, encoding='utf-8', errors='replace'), 1):
        code = strip_noncode(raw.rstrip('\n'), state)
        for ch in code:
            if ch in '([{':
                stack.append((ch, ln))
            elif ch in ')]}':
                if not stack:
                    errs.append(f'{path}:{ln}: closing {ch!r} with empty stack')
                else:
                    o, oln = stack.pop()
                    if o != pairs[ch]:
                        errs.append(f'{path}:{ln}: {ch!r} closes {o!r} opened at line {oln}')
    if state['in_squote'] or state['in_dquote']:
        errs.append(f'{path}: ends inside a quoted string')
    if state['in_hsq'] or state['in_hdq']:
        errs.append(f'{path}: ends inside a here-string')
    for ch, oln in stack:
        errs.append(f'{path}: {ch!r} opened at line {oln} never closed')
    return errs

bad = 0
for p in sys.argv[1:]:
    errs = check(p)
    if errs:
        bad = 1
        for e in errs: print(e)
    else:
        print(f'{p}: STRUCTURALLY CLEAN (code-only brackets balanced, strings/comments stripped)')
sys.exit(bad)
