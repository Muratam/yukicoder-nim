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
# proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
# proc scan(): int = scanf("%lld\n",addr result)
#### random ####
var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc random*(maxIndex: int): int =
  cast[int](xorShift() mod maxIndex.uint64)
proc randomBit*(maxBit:int):int = # mod が遅い場合
  cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
proc shuffleAt*[T](x: var openArray[T],at:Slice[int]) =
  let d = at.b - at.a + 1
  for i in at.b.countdown(at.a):
    swap(x[i], x[at.a+random(d)])
proc shuffle*[T](x: var openArray[T]) =
  for i in x.high.countdown(1):
    swap(x[i], x[random(i)])


let n = scan()
let A = newSeqWith(n,scan())
