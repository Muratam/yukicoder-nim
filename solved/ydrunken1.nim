import sequtils,strutils,algorithm
# import algorithm,math,tables
# import times,macros,queues,bitops,,intsets,sets
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

type YIType = tuple[y:int,i:int]


proc envzero6(str:string):string=
  result = ""
  for i in 0..<0.max(6-str.len):
    result &= "0"
  return result & str

let n = scan()
let m = scan()
var YI = newSeqWith(n + 1,newSeq[YIType]())
for i in 0..<m:
  let p = scan()
  let y = scan()
  YI[p].add((y,i))
for i in 0..n:
  YI[i] = YI[i].sortedByIt(it.y)
var results = newSeq[string](m)
for i in 0..n:
  for j in 0..<YI[i].len:
    let my = YI[i][j]
    results[my.i] = envzero6($i) & envzero6($(j+1))
for i in 0..<m:
  echo results[i]
