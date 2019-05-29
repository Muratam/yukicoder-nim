import sequtils
import times
template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

template useBinaryIndexedTree() = # 部分和検索 / 更新 O(log(N))
  type BinaryIndexedTree[T] = ref object
    data: seq[T] # 引数以下の部分和(Fenwick Tree)
  proc initBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
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
useBinaryIndexedTree()
let n = scan()
var E : array[200010,seq[int]]
for i in 1..<n: E[scan()] &= i
var bit = initBinaryIndexedTree[int](200010)
proc solve(x:int): int =
  result += bit[x]
  bit.update(x, 1)
  for e in E[x]: result += solve(e)
  bit.update(x, -1)
echo solve(0)