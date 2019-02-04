import sequtils,queues
# import algorithm,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
# template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)

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
# http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=GRL_1_B&lang=jp
const INF = 1e10.int



let n = scan()
let m = scan()
let start = scan()
var E = newSeqWith(n,newSeq[Edge]())
m.times:
  let src = scan()
  let dst = scan()
  let cost = scan()
  E[src] &= (dst,cost)
let ans = E.SPFA(start)
if ans.len == 0 : quit "NEGATIVE CYCLE",0
for a in ans:
  if a == INF : echo "INF"
  else: echo a