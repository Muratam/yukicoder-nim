import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (w,h) = get().split().map(parseInt).unpack(2)
let P = newSeqWith(w,toSeq(get().items).mapIt(it == '1'))
proc solve(mx,my:int):float =
  result = 0.0
  for x in 0..<w:
    for y in 0..<h:
      if not P[x][y]: continue
      result += ((y-my)*(y-my)+(x-mx)*(x-mx)).float.sqrt
var ans = 1e10
for my in 0..<h: ans .min= solve(-1,my)
for mx in 0..<w: ans .min= solve(mx,-1)
for my in 0..<h: ans .min= solve(w,my)
for mx in 0..<w: ans .min= solve(mx,h)
echo ans