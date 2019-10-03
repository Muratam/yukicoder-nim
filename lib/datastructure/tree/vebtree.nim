import nimprof
# van Emde Boas tree
# あらゆる操作が O(loglogu)
# 追加 / 削除 / 最小値 / 最大値 / x以上 / x以下
# http://catupper.hatenablog.com/entry/20120830/1346338855
import tables,math
const NilInt = -1
# とりあえず正の整数のみ
type VanEmdeBoasTree = ref object
  universe:int
  bottomSqrtCache:int
  minValue:int
  maxValue:int
  summary: VanEmdeBoasTree
  cluster: Table[int,VanEmdeBoasTree] # WARN: は? サイズが小さいのかな？
# [0,universe) を扱える
var bosSum = 0
proc bottomSqrt(x:int):int =
  # WARN: おそそう
  # キャッシュできそう(universeに依存なので)
  result = 1
  while result * result <= x:
    result = result shl 1
  bosSum += 1
  return result shr 1
var upsSum = 0
proc upSqrt(x:int):int =  # WARN: おそそう
  result = 1
  while result * result < x:
    result = result shl 1
  upsSum += 1
  return result

var nodeSum = 0
proc newVanEmdeBoasTree*(universe:int = 1e9.int): VanEmdeBoasTree =
  new(result)
  result.universe = 1
  while result.universe < universe: # WARN: 雑
    result.universe = result.universe shl 1
  result.bottomSqrtCache = result.universe.bottomSqrt()
  # この値で universe は固定！
  result.minValue = NilInt
  result.maxValue = NilInt
  result.summary = nil
  result.cluster = initTable[int,VanEmdeBoasTree]()
  nodeSum += 1
proc high(self:var VanEmdeBoasTree,x:int): int =
  x div self.bottomSqrtCache
proc low(self:var VanEmdeBoasTree,x:int): int =
  x mod self.bottomSqrtCache
proc index(self:var VanEmdeBoasTree,x,y:int): int =
  x * self.bottomSqrtCache + y
# 名前をNimlyする
proc insert*(self:var VanEmdeBoasTree,x:int) =
  if self.minValue == NilInt:
    self.minValue = x
    self.maxValue = x
    return
  var x = x
  if x < self.minValue:
    swap self.minValue, x
  if self.universe > 2:
    let hx = self.high(x)
    if hx notin self.cluster:
      var newHx = self.bottomSqrtCache.newVanEmdeBoasTree()
      let lx = self.low(x)
      newHx.minValue = lx
      newHx.maxValue = lx
      if self.summary == nil:
        self.summary = self.universe.upSqrt.newVanEmdeBoasTree()
      self.summary.insert(hx)
      self.cluster[hx] = newHx
    else:
      self.cluster[hx].insert(self.low(x))
  if x > self.maxValue:
    self.maxValue = x
proc has*(self:var VanEmdeBoasTree,x:int) : bool =
  if x == self.minValue or x == self.maxValue: return true
  if self.universe == 2 : return false
  let hx = self.high(x)
  if hx notin self.cluster : return false # WARN:再計算
  return self.cluster[hx].has(self.low(x))

when isMainModule:
  import unittest
  import sequtils
  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  test "van Emde Boas tree":
    stopwatch:
      var T = newVanEmdeBoasTree(1e12.int)
      for i in 10..<20:
        T.insert(i)
      for i in 0..<30:
        if T.has(i) : echo i
      for i in 0..<200000:
        T.insert(i)
      var sum = 0
      for i in 0..<200000:
        if T.has(i): sum += 1
      echo sum
      echo "--"
      echo nodeSum
      echo bosSum
      echo upsSum
