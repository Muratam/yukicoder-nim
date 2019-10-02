# 引数以下の部分和(Fenwick Tree)
# 区間に加算 が O(logN)
type BinaryIndexedTree[T] = ref object
  data: seq[T]
proc newBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
  new(result)
  result.data = newSeq[T](n)
proc len[T](self:BinaryIndexedTree[T]): int = self.data.len()
proc plus[T](self:var BinaryIndexedTree[T],i:int,val:T) =
  var i = i
  while i < self.len():
    self.data[i] += val
    i = i or (i + 1)
proc `[]`[T](self:BinaryIndexedTree[T],i:int): T =
  var i = i
  while i >= 0:
    result += self.data[i]
    i = (i and (i + 1)) - 1
proc `$`[T](self:BinaryIndexedTree[T]): string =
  result = "["
  for i in 0..<self.len.min(100): result &= $(self[i]) & ", "
  return result[0..result.len()-2] & (if self.len > 100 : " ...]" else: "]")


when isMainModule:
  import unittest
  test "binary indexed tree":
    var bit = newBinaryIndexedTree[int](100)
    bit.plus(3,10)
    bit.plus(50,20)
    bit.plus(15,-100)
    check:bit[2] == 0
    check:bit[5] == 10
    check: bit[20] == -90
    check: bit[80] == -70
    check: bit[99] == -70
