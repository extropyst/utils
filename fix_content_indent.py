#!/usr/bin/env python3
"""
Fix indentation inside YAML block scalars 'content: |' by ensuring each line
in the block has at least the minimal indentation (indent of key + 2 spaces).

Usage:
  python scripts/fix_content_indent.py INPUT.yml OUTPUT.yml
"""
import sys
import re


def fix_indent(text: str) -> str:
    lines = text.splitlines()
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        out.append(line)
        m = re.match(r'^(?P<indent>\s*)content:\s*\|\s*$', line)
        if not m:
            i += 1
            continue
        indent = m.group('indent')
        min_indent = len(indent) + 2
        j = i + 1
        # Collect block lines until the next file entry or runcmd/final_message section
        block = []
        end_re = re.compile(r'^\s*-\s+path:\b|^runcmd:|^final_message:')
        while j < n:
            l = lines[j]
            if end_re.match(l):
                break
            block.append(l)
            j += 1

        # Reindent block lines: strip existing leading spaces/tabs and re-add min_indent
        fixed_block = []
        for bl in block:
            if bl.strip() == "":
                fixed_block.append(' ' * min_indent)
            else:
                # remove all leading spaces/tabs and re-indent
                stripped = bl.lstrip(' \t')
                fixed_block.append(' ' * min_indent + stripped)

        out.extend(fixed_block)
        i = j
    return '\n'.join(out) + '\n'


def main(argv):
    if len(argv) != 3:
        print('Usage: fix_content_indent.py INPUT.yml OUTPUT.yml', file=sys.stderr)
        return 2
    inp, outp = argv[1], argv[2]
    with open(inp, 'r', encoding='utf-8') as f:
        src = f.read().replace('\r\n', '\n')
    res = fix_indent(src)
    with open(outp, 'w', encoding='utf-8', newline='\n') as f:
        f.write(res)
    print(f'Wrote: {outp}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
