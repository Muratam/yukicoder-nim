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

let (gx,cx,px) = (scan(),scan(),scan())
var (gy,cy,py) = (0,0,0)
(gx+cx+px).times:
  let s = getchar_unlocked()
  if s == 'G' : gy += 1
  if s == 'C' : cy += 1
  if s == 'P' : py += 1

# var win = gx.max(gy) + cx.max(cy) + px.max(py)
# echo [[gx,cx,px],[gy,cy,py]]
# echo win
