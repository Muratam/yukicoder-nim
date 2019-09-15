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

let n = scan()
let k = scan()
let q = scan()
var P = newSeqWith(n,0)
q.times:
  let i = scan() - 1
  P[i] += 1
var sumP = 0
for p in P: sumP += p
for p in P:
  if k - q + p <= 0:
    echo "No"
  else:
    echo "Yes"
