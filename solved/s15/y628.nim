import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
let n = get().parseInt()
var res = initTable[string,int]()
n.times:
  let _ = get().parseInt()
  let (_,s) = get().split().map(parseInt).unpack(2)
  for t in get().split():
    if res.hasKey(t): res[t] += s
    else : res[t] = s
let S = toSeq(res.pairs).sorted((x,y)=>(
  if x[1] != y[1]: y[1] - x[1] elif x[0] > y[0]: 1 else: -1 ))
for s in S[0..<min(10,S.len())]:echo s[0]," ",s[1]
