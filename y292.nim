import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (S,T,U) = get().split().unpack(3)
let t = T.parseInt()
let u = U.parseInt()
for i,s in S:
  if i != t and i != u : stdout.write s
echo ""