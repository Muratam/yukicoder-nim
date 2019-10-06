# セグツリに制約を付けたもの. 定数倍が軽い.
# BIT   :  密な区間[0,t]の可換モノイドの計算 / 一点更新 O(logN)
# セグツリ: 密な区間[s,t]のモノイドの計算 / 一点更新 O(logN)
type BinaryIndexedTree*[T] = ref object
  data*: seq[T]
  apply*: proc(x,y:T):T
  unit*: T
proc newBinaryIndexedTree[T](n:int,apply:proc(x,y:T):T,unit:T):BinaryIndexedTree[T] =
  new(result)
  result.data = newSeq[T](n)
  for i in 0..<result.data.len: result.data[i] = unit
  result.apply = apply
  result.unit = unit
proc len*[T](self:BinaryIndexedTree[T]): int = self.data.len()
# 既にある値を apply 関数で更新する.
proc update*[T](self:var BinaryIndexedTree[T],i:int,val:T) =
  var i = i
  while i < self.len():
    self.data[i] = self.apply(self.data[i],val)
    i = i or (i + 1)
proc until*[T](self:BinaryIndexedTree[T],i:int): T =
  result = self.unit # [0,i] までの演算結果
  var i = i
  if i >= self.data.len: i = self.data.len - 1
  while i >= 0:
    result = self.apply(result,self.data[i])
    i = (i and (i + 1)) - 1
proc `$`[T](self:BinaryIndexedTree[T]): string =
  result = "["
  for i in 0..<self.len.min(100): result &= $(self.until(i)) & ", "
  return result[0..result.len()-2] & (if self.len > 100 : " ...]" else: "]")
proc newMaxBinaryIndexedTree*[T](size:int) : BinaryIndexedTree[T] = # 区間和のセグツリ(= BIT)
  newBinaryIndexedTree[T](size,proc(x,y:T): T = (if x >= y: x else: y),-1e12.T)
proc newMinBinaryIndexedTree*[T](size:int) : BinaryIndexedTree[T] = # 最小値のセグツリ
  newBinaryIndexedTree[T](size,proc(x,y:T): T = (if x <= y: x else: y),1e12.T)
proc newAddBinaryIndexedTree*[T](n:int):BinaryIndexedTree[T] =
  newBinaryIndexedTree[T](n,proc(x,y:T):T=x+y,0)


when isMainModule:
  import unittest
  test "binary indexed tree":
    block:
      var bit = newAddBinaryIndexedTree[int](100)
      bit.update(3, 10)
      bit.update(50,20)
      bit.update(15,-100)
      check: bit.until(2) == 0
      check: bit.until(5) == 10
      check: bit.until(20) == -90
      check: bit.until(80) == -70
      check: bit.until(99) == -70
      check: bit.until(100) == -70
      check: bit.until(101) == -70
      bit.update(50,20)
      check: bit.until(100) == -50
    block:
      var S = newMinBinaryIndexedTree[int](100)
      for i in 0..<100: S.update(i,abs(i - 50))
      check: S.until(100) == 0
      check: S.until(75) == 0
      check: S.until(25) == 25
      check: S.until(0) == 50
      S.update(50,100) # min が進まない方向
      check: S.until(100) == 0 # 更新されない
      check: S.until(75) == 0 # 更新されない
      check: S.until(25) == 25
      check: S.until(0) == 50
      S.update(12,10) # min が 進む方向
      check: S.until(100) == 0
      check: S.until(75) == 0
      check: S.until(25) == 10 # 更新される
      check: S.until(0) == 50
