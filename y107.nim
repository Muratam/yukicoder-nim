import sequtils
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)



proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
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
let D = newSeqWith(n,scan()))
var ans = 0
proc solve(hp,maxHP,i:int)=
  if i >= n :
    ans .max= hp
    return
  solve(,,i+1)
solve(100,100,0)
echo ans
