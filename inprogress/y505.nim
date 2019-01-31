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

let n = scan()
let A = newSeqWith(n,scan())
var ans = 0
if A.filterIt(it < -1).len mod 2 == 0:
  for i,a in A:
    if a == 0 : continue
    if a.abs() == 1 :
      ans += 1
      continue
    ans *= a.abs()
  echo ans
else:
  for i,a in A:
    if a == 0 : continue
    if a.abs() == 1 :
      ans += 1
      continue
    ans *= a.abs()
  echo ans
