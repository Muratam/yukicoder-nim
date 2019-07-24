import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# 最長増加部分列 O(NlogN)
# import cset
proc LIS[T](arr:seq[T]) : seq[T] =
  var S = initSet[T]()
  for a in arr:
    var up = S.upper_bound(a)
    if up != S.`end`(): S.erase(*up)
    S.insert a
  return S.mapIt(it)

let n = scan()
echo @[1,3,13,5,2,3,4,5,7,12,144,15,66].LIS()
