import sequtils,algorithm,math,tables,times
import sets,intsets,queues,heapqueue,bitops,strutils
GC_disableMarkAndSweep()
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var seed = 0
proc next():int32 =
  seed = seed xor (seed shl 13)
  seed = seed xor (seed shr 7)
  seed = seed xor (seed shl 17)
  return cast[int32](seed shr 33)

let n = scan()
let q = scan()
seed = scan()
10000.times: discard next()
var A = newSeq[int32](n)
for i in 0..<n: A[i] = next()
A.sort(cmp)
const size = 1 shl 15
const divi = 16
var AA = newSeqWith(size,newSeq[int32]())
for a in A: AA[(a shr divi).int] &= a
for i in 0..<AA.len: AA[i].sort(cmp)
echo AA.mapIt(it.len)[AA.len div 2]
var B = newSeq[int32](size)
block:
  var cnt = 0
  for i in 0..<size:
    B[i] = cnt.int32
    cnt += AA[i].len()
let t = cpuTime()
var ans = 0
for i in 0..<q:
  let x = next()
  let cnt = B[x shr divi] + AA[x shr divi].lowerBound(x)
  ans = ans xor (cnt * i)
echo ans
# echo AA.mapIt(it.len)[AA.len div 4]
# echo (cpuTime() - t) * 1000