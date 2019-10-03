import nimprof
# van Emde Boas tree
# あらゆる操作が O(loglogu)
# 追加 / 削除 / 最小値 / 最大値 / x以上 / x以下
# http://catupper.hatenablog.com/entry/20120830/1346338855
import tables,math
const NilInt = -1
# とりあえず正の整数のみ
# [0,universe) を扱える
let N = 1e6.int
let NODENUM = N * 4
var universes = newSeq[int](NODENUM)
var bottomSqrtCaches = newSeq[int](NODENUM)
var minValues = newSeq[int](NODENUM)
var maxValues = newSeq[int](NODENUM)
var summaries = newSeq[int](NODENUM)
var clusters = newSeq[Table[int,int]]() # WARN: 遅そう
proc bottomSqrt(x:int):int =
  # clz で一応高速化できそう
  result = 1
  while result * result <= x:
    result = result shl 1
  return result shr 1
proc upSqrt(x:int):int =
  result = 1
  while result * result < x:
    result = result shl 1
  return result
proc newVanEmdeBoasTree(universe:int): int =
  # この値で universe は固定！
  result = clusters.len
  var u = 1
  while u < universe: # WARN: 雑
    u = u shl 1
  universes[result] = u
  bottomSqrtCaches[result] = u.bottomSqrt()
  minValues[result] = NilInt
  maxValues[result] = NilInt
  summaries[result] = NilInt
  clusters .add initTable[int,int]()
proc high(self:int,x:int): int =
  x div bottomSqrtCaches[self]
proc low(self:int,x:int): int =
  x mod bottomSqrtCaches[self]
proc index(self:int,x,y:int): int =
  x * bottomSqrtCaches[self] + y
# TODO:名前をNimlyする
proc insert*(self:int,x:int) =
  if minValues[self] == NilInt:
    minValues[self] = x
    maxValues[self] = x
    return
  var x = x
  if x < minValues[self]:
    swap minValues[self], x
  if universes[self] > 2:
    let hx = self.high(x)
    if hx notin clusters[self]:
      var newHx = bottomSqrtCaches[self].newVanEmdeBoasTree()
      let lx = self.low(x)
      minValues[newHx] = lx
      maxValues[newHx] = lx
      if summaries[self] == NilInt:
        summaries[self] = universes[self].upSqrt.newVanEmdeBoasTree()
      summaries[self].insert(hx)
      clusters[self][hx] = newHx
    else:
      clusters[self][hx].insert(self.low(x))
  if x > maxValues[self]:
    maxValues[self] = x
proc has*(self:int,x:int) : bool =
  if x == minValues[self] or x == maxValues[self]: return true
  if universes[self] == 2 : return false
  let hx = self.high(x)
  if hx notin clusters[self] : return false # WARN:再計算
  return clusters[self][hx].has(self.low(x))

when isMainModule:
  import unittest
  import sequtils
  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  var xorShiftVar* = 88172645463325252.uint64
  xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
  proc xorShift() : uint64 =
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
    xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
    xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
    return xorShiftVar
  proc randomBit*(maxBit:int):int = # mod が遅い場合
    cast[int](xorShift() and cast[uint64]((1 shl maxBit) - 1))
  test "van Emde Boas tree":
    stopwatch:
      var T = newVanEmdeBoasTree(1e12.int)
      for i in 10..<20:
        T.insert(i)
      for i in 0..<30:
        if T.has(i) : echo i
      xorShiftVar = 88172645463325252.uint64
      for i in 0..<N:
        T.insert(randomBit(24))
      var sum = 0
      xorShiftVar = 88172645463325252.uint64
      for i in 0..<N:
        if T.has(randomBit(i)): sum += 1
      echo sum
