import sequtils
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
const EPS = 1e-8
# proc `~~` *(x, y: float): bool = abs(x - y) < EPS # ≒
# proc `~~<` *(x, y: float): bool = x < y + EPS # ≒


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let L = newSeqWith(n,scan().float)
let k = scan()
proc getK(size:float):int =
  for l in L:
    result += ((l + EPS) / size).int
var x = 0.0
var y = L.max()
while true:
  let kx = x.getK()
  let ky = y.getK()
  let km = (x/2+y/2).getK()
  if ky < k : y = m
