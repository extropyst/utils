#!/usr/bin/env python3
"""Restore heredoc content when cloud-init pasted into provider UI produced literal \n sequences.

Usage: restore_heredocs.py input.yml > output.yml

Algorithm (heuristic): detect block scalars starting with | or > and for indented following lines
replace literal "\\n" sequences with real newlines and unescape runs of $ signs.
"""
import sys, re

def process(text):
    lines = text.splitlines()
    out=[]
    i=0
    while i<len(lines):
        line = lines[i]
        out.append(line)
        if line.rstrip().endswith('|') or line.rstrip().endswith('>'):
            indent = len(line)-len(line.lstrip(' '))
            i+=1
            while i<len(lines):
                l = lines[i]
                cur_indent = len(l)-len(l.lstrip(' '))
                if l.strip()=='' or cur_indent>indent:
                    new = l.replace('\\n','\n')
                    new = re.sub(r'\${3,}','$$', new)
                    out.append(new)
                    i+=1
                else:
                    break
            continue
        i+=1
    return '\n'.join(out)

if __name__=='__main__':
    if len(sys.argv)<2:
        print('Usage: restore_heredocs.py input.yml', file=sys.stderr)
        sys.exit(2)
    with open(sys.argv[1],'r',encoding='utf-8') as f:
        text = f.read()
    print(process(text))
