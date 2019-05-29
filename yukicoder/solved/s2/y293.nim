import sequtils,strutils,macros
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b) = stdin.readLine().split().unpack(2)
if a.len() > b.len(): echo a
elif a.len() < b.len() : echo b
else:
  for i in 0..<a.len():
    let sa = a[i]
    let sb = b[i]
    if sa == sb : continue
    if (sa == '4' and sb == '7') or (sa > sb and (sa != '7' or sb != '4')): echo a
    else: echo b
    break
# 1474836608
# 1607425306