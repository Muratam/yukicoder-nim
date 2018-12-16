import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (k,n,f) = get().split().map(parseInt).unpack(3)
let A = get().split().map(parseInt)
echo max(k * n - A.sum(),-1)
