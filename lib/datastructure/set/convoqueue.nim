# 複数のsetを組み合わせて不思議なデータ構造を作るやつ.
import "./priorityqueue"
# Min/Maxを取れる PriorityQueue.
# PriorityQueueの~2倍程度の時間で使えるので便利そう.
type MinMaxQueue*[T] = ref object
  minHeap*,maxHeap*,delMinHeap,delMaxHeap: PriorityQueue[T]
  count: int
proc newMinMaxQueue*[T](cmp:proc(x,y:T):int) : MinMaxQueue[T] =
  new(result)
  result.minHeap = newPriorityQueue[T](cmp)
  result.delMinHeap = newPriorityQueue[T](cmp)
  proc revcmp[T](x,y:T):int = cmp[T](y,x)
  result.maxHeap = newPriorityQueue[T](revcmp)
  result.delMaxHeap = newPriorityQueue[T](revcmp)
  result.count = 0
proc len*[T](self:MinMaxQueue[T]):int = self.count
proc push*[T](self: var MinMaxQueue[T], item: T) =
  self.count += 1
  self.minHeap.push(item)
  self.maxHeap.push(item)
proc update*[T](self:var MinMaxQueue[T]) =
  while self.minHeap.len > 0 and self.delMinHeap.len > 0 and self.minHeap.top == self.delMinHeap.top:
    self.minHeap.pop()
    self.delMinHeap.pop()
  while self.maxHeap.len > 0 and self.delMaxHeap.len > 0 and self.maxHeap.top == self.delMaxHeap.top:
    self.maxHeap.pop()
    self.delMaxHeap.pop()
proc min*[T](self: MinMaxQueue[T]): T = self.minHeap.top()
proc max*[T](self: MinMaxQueue[T]): T = self.maxHeap.top()
proc minPop*[T](self:var MinMaxQueue[T]): T {.discardable.} =
  self.count -= 1
  result = self.minHeap.pop()
  self.delMaxHeap.push(result)
  self.update()
proc maxPop*[T](self:var MinMaxQueue[T]): T {.discardable.} =
  self.count -= 1
  result = self.maxHeap.pop()
  self.delMinHeap.push(result)
  self.update()
iterator items*[T](self:MinMaxQueue[T]) : T =
  for x in self.minHeap: yield x
# 中央値を取れる Priority Queue
# 同様の方法で「固定の」k 番目の値を取れるやつも作れる
type MediumQueue*[T] = ref object
  greater*,less* : PriorityQueue[T] # greater 優先
  cmp*: proc(x,y:T):int
proc newMediumQueue*[T](cmp:proc(x,y:T):int) : MediumQueue[T] =
  new(result)
  result.greater = newPriorityQueue[T](cmp)
  proc revcmp[T](x,y:T):int = cmp[T](y,x)
  result.less = newPriorityQueue[T](revcmp)
  result.cmp = cmp
proc len*[T](self:MediumQueue[T]):int =
  self.less.len + self.greater.len
proc push*[T](self: var MediumQueue[T], item: T) =
  if self.greater.len == 0:
    self.greater.push(item)
    return
  if self.cmp(item,self.greater.top) > 0:
    self.greater.push(item)
  else:
    self.less.push(item)
  if self.less.len() > self.greater.len():
    self.greater.push(self.less.pop())
  elif self.greater.len > self.less.len + 1:
    self.less.push(self.greater.pop())
proc top*[T](self: var MediumQueue[T]) : T =
  if self.less.len < self.greater.len:
    return self.greater.top()
  # 偶数の時の中央値なので,どちらでもよい. pop と整合性を合わせてる.
  return self.less.top()
proc pop*[T](self: var MediumQueue[T]) : T {.discardable.} =
  if self.less.len < self.greater.len:
    return self.greater.pop()
  return self.less.pop()

# int,~1e6程度限定で,任意番目の値を取れる.重複OK.
# 座標圧縮もアリ
import "../segmenttree/bit"
import algorithm
type KthQueue* = ref object
  bit: BinaryIndexedTree[int32]
  data: seq[int32]
  count: int
  n: int
proc newKthQueue*(n:int) : KthQueue =
  new(result)
  result.count = 0
  result.n = n + 10
  result.bit = newBinaryIndexedTree[int32](n + 10,proc(x,y:int32):int32=x+y,0)
  result.data = newSeq[int32](n + 10)
proc len*(self:KthQueue):int = self.count
proc contains*(self:KthQueue,item:int) : bool =
  self.data[item] > 0
proc push*(self:KthQueue,item:int) =
  self.bit.update(item,1)
  self.data[item] += 1
  self.count += 1
proc pop*(self:KthQueue,item:int) =
  if item in self: return
  self.bit.update(item,-1)
  self.data[item] -= 1
  self.count -= 1
# 0-indexed. O(logD)
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
proc getKth*(self:KthQueue,k:int): int =
  if self.len <= 0 or self.len <= k or k < 0:
    return -1
  var k = k + 1
  var i = 1 shl (63 - cast[culonglong](self.n).countLeadingZeroBits())
  while true :
    if result + i - 1 < self.n and  self.bit.data[result + i - 1] < k:
      k -= self.bit.data[result + i - 1]
      result += i
    i = i shr 1
    if i <= 0 : return result
# 0-indexed. 同じキーに複数ある場合(2,3,4th)は後ろ(4th) になる
proc isKth*(self:KthQueue,x:int):int =
  if not(x in self) : return -1
  return self.bit.until(x) - 1


when isMainModule:
  import unittest
  import sequtils
  test "kth queue":
    let kthQ = newKthQueue(20)
    for i in @[5,3,20,2,5,8,10,5]: kthQ.push(i)
    for i in 0..<10:
      check: kthQ.getKth(i) == @[2,3,5,5,5,8,10,20,-1,-1][i]
    check: kthQ.isKth(2) == 0
    check: kthQ.isKth(5) == 4
  test "convo queue":
    var p = newMinMaxQueue[int](cmp)
    for i in @[1,-1,3,23,0,10,9,2]: p.push(i)
    check: p.maxPop() == 23
    check: p.minPop() == -1
    check: p.maxPop() == 10
    check: p.minPop() == 0
    p.push(5)
    check: p.maxPop() == 9
    check: p.minPop() == 1
    check: p.maxPop() == 5
    check: p.minPop() == 2
    check: p.minPop() == 3
    # 重複もアリ
    for i in 0..<10: p.push(5)
    p.push(7)
    p.push(3)
    check: p.maxPop() == 7
    check: p.minPop() == 3
    for i in 0..<10:
      check: p.maxPop() == 5
    # Medium Queue
    var MQ = newMediumQueue[int](cmp)
    for i,v in @[1,10,3,111,43,44,4,3,2,1,2,3,4]:
      MQ.push(v)
      check: MQ.top() == @[1,1,3,3,10,10,10,4,4,3,3,3,3,3,3][i]
      # echo MQ.less,MQ.greater
