import sequtils
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
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
let s = scan()
let k = scan()
var dp = newSeqWith(s+1,0)
for si in 0..s:dp[0] = 1
for i in 0..<n:
  var next = newSeqWith(s+1,0)
  for si in 0..s:
    dp[s+i] = dp[]
  dp = next

