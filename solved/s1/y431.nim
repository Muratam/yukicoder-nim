import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (d1,d2,d3,s) = get().split().map(parseInt).unpack(4)
let D = [d1,d2,d3].sum()
if s == 1 or D < 2: echo "SURVIVED"
else: echo "DEAD"
