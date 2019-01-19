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

#  7 * 8
# 15 * 20 : x2 + 4
# 31 * 43 : x2 + 3
# 63 * 112 : x2 + ??
# 127 * 256
# 255 * 576

var pre = 0
for i in 1..1000:
  var ans = i.popcount()*i
  echo i,"\t",ans,"\t",pre + ans
  pre += ans