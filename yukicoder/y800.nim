import sequtils,math
# import algorithm,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
# template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
# proc `^`(n:int) : int{.inline.} = (1 shl n)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let d = scan()
var ans = 0
for x in 1..n:
  for y in 1..n:
    for z in 1..n:
      let w2 = x * x + y * y + z * z - d
      if w2 < 0 : continue
      let w = w2.float.sqrt.int
      if w * w != w2 : continue
      if w > n : continue
      ans += 1
echo ans
