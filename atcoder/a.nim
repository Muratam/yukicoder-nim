{.checks:off.}
type BinaryIndexedTree*[T] = ref object
  data*: seq[T]
  apply*: proc(x,y:T):T
  unit*: T
proc newBinaryIndexedTree*[T](n:int,apply:proc(x,y:T):T,unit:T):BinaryIndexedTree[T] =
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
# 速度にこだわるなら構築の定数倍も大事だよね.速いよ.
proc newBinaryIndexedTree*[T](arr:seq[T],apply:proc(x,y:T):T,unit:T):BinaryIndexedTree[T] =
  new(result)
  result.data = arr
  result.apply = apply
  result.unit = unit
  for i in 0..<arr.len:
    let x = i or (i+1)
    if x < arr.len:
      result.data[x] = result.apply(result.data[i],result.data[x])
proc `$`*[T](self:BinaryIndexedTree[T]): string =
  result = "["
  for i in 0..<self.len: result .add $(self.until(i)) & ", "
  result .add "]"
proc newMaxBinaryIndexedTree*[T](size:int) : BinaryIndexedTree[T] = # 区間和のセグツリ(= BIT)
  newBinaryIndexedTree[T](size,proc(x,y:T): T = (if x >= y: x else: y),-1e12.T)
proc newMinBinaryIndexedTree*[T](size:int) : BinaryIndexedTree[T] = # 最小値のセグツリ
  newBinaryIndexedTree[T](size,proc(x,y:T): T = (if x <= y: x else: y),1e12.T)
proc newAddBinaryIndexedTree*[T](n:int):BinaryIndexedTree[T] =
  newBinaryIndexedTree[T](n,proc(x,y:T):T=x+y,0)


import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

proc inversionNumber[T](arr:seq[T]) : int =
  if arr.len <= 1 : return 0
  var bit = newAddBinaryIndexedTree[int](arr.len)
  for i,a in arr:
    result += i - bit.until(a)
    bit.update(a,1)


let n = scan()
var A = newSeq[int](n)
for i in 0..<n: A[i] = scan()
echo A.inversionNumber()
