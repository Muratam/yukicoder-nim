import sequtils,algorithm
# import ,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scanNatural(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
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
let k = scan() - 1
let X = newSeqWith(n,scanNatural())
let A = newSeqWith(n,scan())
let AXI = toSeq(0..<n).mapIt((a:A[it],x:X[it],i:it)).sortedByIt(it.x)
for i,s in AXI:
  if s.i != k: continue
  var ans = 1
  var id = i .. i
  var ad = s.x-s.a .. s.x+s.a
  while id.a >= 0:
    let t = AXI[id.a]
    if t.x < ad.a: break
    ad.a .min= t.x-t.a

    id.a -= 1
  while id.b < n:
    id.b += 1
  echo id.b.min(n-1) - id.a.max(0) + 1
  quit 0
