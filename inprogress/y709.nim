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
let m = scan()
var C = newSeqWith(m,(val:0,cnt:0))
n.times:
  let R = newSeqWith(m,scan())
  var ans = 0
  for i in 0..<m:
    if R[i] < C[i].val : continue
    elif R[i] == C[i].val: C[i].cnt += 1
    else: C[i] = (R[i],1)
