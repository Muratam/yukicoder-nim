import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let nw = scan()
let W = newSeqWith(nw,scan()).sorted(cmp,Descending)
let nb = scan()
let B = newSeqWith(nb,scan()).sorted(cmp,Descending)
# W が下
var ans = 0
block:
  var size = B[0]
  for w in W:
echo W
echo B