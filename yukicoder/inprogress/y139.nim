import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

# let n = scan()
# let l = scan()
# let XWT = newSeqWith(n,(x:scan(),xw:scan(),t:scan()))
# var t = 0
# t = XWT[0].x
# if (t div XWT[0].t) mod 2 != 1 or
  # (t / T[i]) mod 2 == 0 : 青
