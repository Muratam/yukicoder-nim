import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,a) = get().split().map(parseInt).unpack(2)
let X = get().split().map(parseInt)
if X.sum() == a * X.len(): echo "YES"
else: echo "NO"
