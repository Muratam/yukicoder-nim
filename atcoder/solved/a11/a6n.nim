import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

type BinaryIndexedTree[T] = ref object
  data: seq[T] # 引数以下の部分和(Fenwick Tree)
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

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let q = scan()
type QType = tuple[q,a,b:int]
var Q = newSeq[QType](q)
var MIS = initIntSet()
for i in 0..<q:
  let S = stdin.readLine()
  if S == "2" : Q[i] = (2,-1,-1)
  else:
    Q[i] = (let t = S.split().map(parseInt);(t[0],t[1],t[2]))
    MIS.incl Q[i][1]
var M = newSeq[int]()
for x in MIS: M.add x
M = M.sorted(cmp)
var MI = initTable[int,int]()
for i,m in M: MI[m] = i + 1

# M
var bit = newBinaryIndexedTree[int](M.len + 2)
var sumA = newBinaryIndexedTree[int](M.len + 2)
proc findMinIndex():int =
  var l = 0
  # var r = bit.len - 1
  # while r != l:
  #   var x = (l + r) div 2
  #   let la = bit[l].abs
  #   let ra = bit[r].abs
  #   let xa = bit[x].abs
  return l


var sumB = 0
for q in Q:
  let (order,a,b) = q
  if order == 2:
    continue
  sumB += b
  let ai = MI[a]
  sumA.update(0,-a)
  sumA.update(ai,a*2)
  # sumA.update(ai+1,a)
  bit.update(0,-1)
  bit.update(ai,1)
  bit.update(ai+1,1)
  let x = 0 # findMinIndex()
  # abs が一番小さいもののうち最小のもの
  if bit[x] == 0:
    echo M[x]," ",sumB
  else:
    let diff = M[x+1] - M[x]
  echo bit
  echo sumB
  echo sumA
