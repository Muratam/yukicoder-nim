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

# echo toSeq(0..10)
# echo toSeq("123".items)
# let (n,m) = stdin.readLine().split().map(parseInt).unpack(2)
# let A = stdin.readLine().split().map(parseInt)
# let n = stdin.readLine().parseInt()
# let B = newSeqWith(n,stdin.readLine().parseInt())