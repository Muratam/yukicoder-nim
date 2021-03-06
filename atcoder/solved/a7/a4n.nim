import sequtils,strutils,algorithm,math,macros,future
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  result = 0
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan() # 1e5
let A = newSeqWith(n,scan()) # 1e9
var dp = newSeqWith(n,[0,0,0,0,0])
