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
let d = scan()
proc solve() : seq[int] =
  result = newSeq[int](d)
  while true:
    let k = getchar_unlocked()
    if k == 'd':
      discard getchar_unlocked()
      let next = solve()
    elif k == '+':
    elif k == '*':
    elif k == '}':
    elif k >= '0' and k <= '9':
    else:
      return 0

echo solve()