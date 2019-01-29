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
let AB = newSeqWith(n,(a:scan(),b:scan())).sortedByIt(- it.a - it.b)
  # .sorted(proc (x,y:tuple[a,b:int]) : int =
  #   if x.a - x.b != y.a - y.b : return (x.a - x.b) - (y.a - y.b)
  #   return  - x.b + y.b
  # )
# echo AB
var aSum = 0
var bSum = 0
for i,ab in AB:
  if i mod 2 == 0 : aSum += ab.a
  else: bSum += ab.b
echo aSum - bSum