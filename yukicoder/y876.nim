import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>",discardable .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord

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


let n = scan()
let q = scan()
var A = newSeq[int](n+2)
var B = newSeq[int](n+2)
var bit = newBinaryIndexedTree[int](n+2)
for i in 1..n: A[i] = scan()
for i in 1..n:
  B[i] = A[i+1] - A[i]
  if B[i] != 0 : bit.plus i, 1
q.times:
  if scan() == 1:
    let (l,r,x) = (scan()-1,scan(),scan())
    if l >= 1:
      if B[l] != 0: bit.plus l, -1
      B[l] += x
      if B[l] != 0: bit.plus l,  1
    if r < n:
      if B[r] != 0: bit.plus r, -1
      B[r] += x
      if B[r] != 0: bit.plus r,  1
  else:
    let (l,r) = (scan()-1,scan()-1)
    echo bit[r]-bit[l]+1
