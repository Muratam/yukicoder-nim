import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
var A = newSeqWith(n,scan()).sorted(cmp)
let BC = newSeqWith(m,(b:scan(),c:scan())).sortedByIt(-it.c)
var ai = 0
for bc in BC:
  # echo bc,A,":ai:",ai
  let (b,c) = bc
  var ok = true
  b.times:
    if A[ai] >= c :
      ok = false
      break
    A[ai] = c
    ai += 1
  if not ok : break
  if ai >= A.len : break
echo A.sum()
