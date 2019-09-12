import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
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
var S = newBinaryIndexedTree[int](n)
for i in 0..<n:
  S.plus(i,scan())
q.times:
  echo S
  let (_,l,r,x) = (scan(),scan()-1,scan()-1,scan())
  let rm = S[r]
  let lm = S[l-1]
  echo rm - lm - x * (r-l+1)
