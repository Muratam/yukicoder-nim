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
let A = newSeqWith(n,scan())
var x1 = 0
for i,a in A:
  if i mod 2 == 0: x1 += a
  else:  x1 -= a
var results = newSeq[int]()
results.add x1
var x = x1
for i in 0..<n-1:
  x = 2 * A[i] - x
  results.add x
echo results.mapIt($it).join(" ")
