import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let HW = newSeqWith(3,get().split().map(parseInt).unpack(2))
let res = (0..<3).mapIt((n:["A","B","C"][it],h:HW[it][0],w:HW[it][1]))
  .sorted((x,y)=>(if x.h != y.h: y.h - x.h else: x.w - y.w))
for r in res: echo r.n