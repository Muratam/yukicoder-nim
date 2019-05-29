# 引数以下の部分和(Fenwick Tree)
type BinaryIndexedTree[T] = ref object
  data: seq[T]
proc newBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
  new(result)
  result.data = newSeq[T](n)
proc len[T](self:BinaryIndexedTree[T]): int = self.data.len()
proc update[T](self:var BinaryIndexedTree[T],i:int,val:T) =
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
