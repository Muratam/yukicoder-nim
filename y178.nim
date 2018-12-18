import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let n = get().parseInt()
let S = newSeqWith(n,get().split().map(parseInt)).mapIt(it[0]+4*it[1])
if S.allIt(it mod 2 == 0) or S.allIt(it mod 2 == 1):
  let m = S.max()
  echo S.mapIt((m - it) div 2).sum()
else: echo -1
