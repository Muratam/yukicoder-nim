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

var A = newSeqWith(16,scan())
const dist = toSeq(1..15) & 0
while true:
  if A == dist : quit "Yes",0
  if A[^1] == 0 : quit "No",0
  proc slide():bool =
    for i,a in A:
      if a != 0 : continue
      template impl(di:int,cond) =
        if i+di < A.len and cond and A[i+di] == dist[i] :
          swap(A[i],A[i+di])
          return true
      impl(1,i mod 4 != 3)
      impl(4,i<12)
      impl(-4,i>=4)
      impl(-1,i mod 4 != 0)
    return false
  if not slide() : quit "No",0