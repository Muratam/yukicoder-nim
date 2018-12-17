import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,m) = get().split().map(parseInt).unpack(2)
let S = get()
let T = get()
let sa = S.count('A')
let sb = n - sa
let ta = T.count('A')
let tb = m - ta
echo min(sa,ta) + min(sb,tb)
