import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (a,b,c) = newSeqWith(3,get()).map(parseInt).unpack(3)
if (1 + (a - 1) div c) * 3 * b <= a * 2 : echo "YES"
else: echo "NO"
