#!/usr/bin/env bash
# Normalize cloud-init YAML with heredocs so it's pasteable into provider UI.
# - Converts literal "\n" sequences inside heredoc content back into real newlines
# - Removes excessive escaping of $ signs

set -euo pipefail
if [[ $# -lt 1 ]]; then
  echo "Uso: $0 <cloud-init.yml>"
  exit 2
fi
infile="$1"
outfile="${infile%.yml}.fixed.yml"

echo "Leyendo $infile -> $outfile"

python - <<'PY'
import sys, re
p = sys.argv
infile = p[1]
with open(infile,'r',encoding='utf-8') as f:
    s = f.read()

# Replace literal "\\n" inside lines that look like heredoc content markers (content: |)
# Very heuristic: replace occurrences of \\n# anchored to lines inside a block scalar by detecting '|' and subsequent indented lines.

out_lines=[]
lines = s.splitlines()
i=0
while i < len(lines):
    line = lines[i]
    out_lines.append(line)
    if line.rstrip().endswith('|'):
        # collect indented block
        indent = len(line) - len(line.lstrip(' '))
        i += 1
        while i < len(lines):
            l = lines[i]
            cur_indent = len(l) - len(l.lstrip(' '))
            if l.strip()=='' or cur_indent>indent:
                # inside block: replace literal \n with newline and unescape multiple $ signs
                new = l.replace('\\n','\n')
                # collapse runs of $ like $$$$2y$$$$ to $$2y$$ using a regex
                new = re.sub(r'\${3,}','$$', new)
                out_lines.append(new)
                i += 1
            else:
                break
        continue
    i+=1

out = '\n'.join(out_lines)
with open(outfile,'w',encoding='utf-8') as f:
    f.write(out)
print('WROTE', outfile)
PY

echo "Archivo normalizado creado: $outfile"
