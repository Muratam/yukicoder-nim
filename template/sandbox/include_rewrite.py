#! /usr/bin/python3
"""rewrite #?include "hoge" => file, onetime"""
"py code.nim | pbcopy"
import re
import sys
if len(sys.argv) < 2:
    print("input file name")
    quit()
filepath = sys.argv[1]
with open(filepath) as f:
    lines = f.readlines()

res = []
for line in lines:
    found = re.findall(r'#?include "(.+)"', line)
    if not found:
        res.append(line)
        continue
    with open(found[0]) as f:
        content = f.read() + "\n"
    res.append(content)
print("".join(res))
