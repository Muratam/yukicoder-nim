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

let m = scan()
let d = scan()
var ans = 0
for mi in 1..m:
  for di in 1..d:
    let di1 = di mod 10
    let di2 = di div 10
    if di1 >= 2 and di2 >= 2 and di1 * di2 == mi:
      ans += 1
echo ans
