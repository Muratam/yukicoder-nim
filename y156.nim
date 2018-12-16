import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,m) = get().split().map(parseInt).unpack(2)
let C = get().split().map(parseInt).sorted(cmp)
let B = C.foldl(a & (a[^1] + b),@[0])[1..^1]
for i,b in B:
  if m < b:
    echo i
    quit(0)
echo n