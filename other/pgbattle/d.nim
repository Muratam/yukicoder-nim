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
var A = newSeqWith(n,scan())
var cost = 0
for i in 1..<n-1:
  if A[i-1] < A[i] and A[i] > A[i + 1]:
    let next = max(A[i-1],A[i+1])
    cost += abs(next - A[i])
    A[i] = next
  elif A[i-1] > A[i] and A[i] < A[i + 1]:
    let next = min(A[i-1],A[i+1])
    cost += abs(next - A[i])
    A[i] = next
for i in 0..<n-1:
  cost += abs(A[i] - A[i+1])
echo cost
