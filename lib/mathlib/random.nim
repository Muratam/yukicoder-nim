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
proc randomBit*(maxBit:int):int = # mod が遅い場合
  cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
proc shuffleAt*[T](x: var openArray[T],at:Slice[int]) =
  let d = at.b - at.a + 1
  for i in at.b.countdown(at.a):
    swap(x[i], x[at.a+random(d)])
proc shuffle*[T](x: var openArray[T]) =
  for i in x.high.countdown(1):
    swap(x[i], x[random(i)])
proc randomString*(maxLen:int): string =
  let size = 1 + random(maxLen - 1)
  var S = newSeq[char](size)
  for i in 0..<size: S[i] = chr(random(26) + 'A'.ord)
  return cast[string](S)
proc randomStringFast*(maxBit:int,kindBit:int=4):string =
  let size = 1 + randomBit(maxBit)
  var S = newSeq[char](size)
  const A = 'A'.ord
  for i in 0..<size: S[i] = cast[char](randomBit(kindBit) + A)
  return cast[string](S)


when isMainModule:
  import unittest
  import sequtils
  test "random":
    for i in 0..<1000:
      check: random(2) <= 1
    for i in 0..<1000:
      check: randomBit(4) < 16
    # シード値固定
    xorShiftVar = 88172645463325252.uint64
    check: toSeq(0..10).mapIt(random(10)) == @[2, 5, 2, 3, 6, 9, 1, 3, 6, 5, 9]
    xorShiftVar = 88172645463325252.uint64
    var S = toSeq(0..10)
    shuffle(S)
    check: S == @[5, 9, 8, 10, 1, 6, 4, 3, 0, 7, 2]
    xorShiftVar = 88172645463325252.uint64
    S = toSeq(0..10)
    S.shuffleAt(3..8)
    check: S == @[0, 1, 2, 5, 6, 4, 8, 7, 3, 9, 10]
