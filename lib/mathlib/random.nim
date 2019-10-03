import times
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
    let j = random(i.uint64).int
    swap(x[i], x[j])

# 時間ギリギリまでサーチ.
import times
template timeUpSearch(milliSec:int,body) =
  # 時間計測は 1e5 回で100ms.
  # この回数以上探索するなら, for i in 0..<100: body にする
  while (cpuTime() - startTime) * 1000 < milliSec:
    body

when isMainModule:
  import unittest
  test "random":
    for i in 0..<1000:
      check: random(2) <= 1
    for i in 0..<1000:
      check: randomBit(4) < 16
    # シード値固定
    xorShiftVar = 88172645463325252.uint64
    for i in 0..<6:
      check: random(10) == @[2,5,2,3,6,9][i]
