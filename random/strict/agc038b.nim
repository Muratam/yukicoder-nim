{.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# 速度重視で乱択する場合用の Xor-Shift
var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc random*(maxIndex: int): int =
  cast[int](xorShift() mod maxIndex.uint64)
proc randomBit*(maxBit:int):uint64 = # mod が遅い場合
  xorShift() and cast[uint64]((1 shl maxBit) - 1)
proc shuffle*[T](x: var openArray[T]) =
  for i in countdown(x.high, 1):
    swap(x[i], x[random(i)])
proc argMax[T](arr:seq[T]): int =
  let maxVal = arr.max()
  for i,a in arr:
    if a == maxVal: return i


let startTime = cpuTime()
let n = scan()
let m = scan()
let A = newSeqWith(n,newSeqWith(m,scan()-1))
var ans = 1e12.int
var opens = newSeqWith(m,1)
var tr = 0
while cpuTime() - startTime < 1.9:
  for i in 0..<m:
    opens[i] = 1.min(opens[i])
  if opens.sum() == 0 : break
  tr += 1
  for ni in 0..<n:
    for mi in 0..<m:
      if opens[A[ni][mi]] > 0:
        opens[A[ni][mi]] += 1
        break
  let maxI = opens.argMax()
  ans .min= 0.max(opens[maxI] - 1)
  opens[maxI] = 0
echo ans
# echo tr
