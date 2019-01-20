import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (n,k) = get().split().map(parseInt).unpack(2)
let A = newSeqWith(n,get().parseInt()).sorted(cmp,Descending)
var will = initIntSet()
will.incl(0)
for a in A:
  for w in toSeq(will.items):
    if w + a <= k : will.incl(w + a)
echo toSeq(will.items).max()