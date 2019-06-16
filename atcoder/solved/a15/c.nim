import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  var minus = false
  block:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    else: result = 10 * result + k.ord - '0'.ord
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

let n = scan()
let A = newSeqWith(n,scan()).sorted(cmp)
var B : seq[tuple[x,y:int]] = @[]
var aMax = A[^1]
var aMin = A[0]
for i in 1..<n-1:
  let a = A[i]
  if a < 0 :
    B.add((aMax,a))
    aMax -= a
  else:
    B.add((aMin,a))
    aMin -= a
B.add((aMax,aMin))
echo aMax - aMin
for b in B:
  echo b.x," ",b.y


