# intsets は使うべきではないというやつ

import intsets
import times #,sets,intsets,algorithm,tables,hashes
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
var xorShiftVar = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc randomBit(maxBit:int):int = # mod が遅い場合
  cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))

let n = 1e6.int
var A = initIntSet()
stopwatch:
  for _ in 0..<n:
    A.incl randomBit(32)
  echo "incl ",A.len
var B = initIntSet()
block:
  for _ in 0..<n:
    B.incl randomBit(32)
stopwatch:
  var C = A * B
  echo "and",[A.len,B.len,C.len]
  var k = 0
  for ki in C:
    k = ki
    break
  C.excl k
  echo "del C",[A.len,B.len,C.len]
