{.checks:off.}
# import nimprof
import algorithm,sequtils
import "../../mathlib/random"
# SkewHeapNode :: Merge も log(N) な BinaryHeap
type SkewHeapFactory*[T] = ref object
  cmp:proc(x,y:T):int
  nodes: seq[T]
  L,R:seq[int32]
  empties: seq[int32]
type SkewHeap*[T] = ref object
  f: SkewHeapFactory[T]
  root:int32
  size:int
const NilIndex = -1.int32
proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc newSkewHeapFactory*[T](cmp:proc(x,y:T):int):SkewHeapFactory[T] =
  new(result)
  result.cmp = cmp
  result.nodes = @[]
  result.L = @[]
  result.R = @[]
  result.empties = @[]
proc newSkewHeap*[T](factory:SkewHeapFactory[T]):SkewHeap[T] =
  new(result)
  result.f = factory
  result.root = NilIndex
  result.size = 0
proc newSkewHeapNode[T](self:SkewHeap[T],val:T):int32 =
  if self.f.empties.len > 0:
    result = self.f.empties.pop()
    self.f.nodes[result] = val
    self.f.L[result] = NilIndex
    self.f.R[result] = NilIndex
    return result
  result = self.f.nodes.len.int32
  self.f.nodes.add val
  self.f.L.add NilIndex
  self.f.R.add NilIndex
proc merge[T](self:SkewHeap[T],a,b:var int32):int32 =
  if a == NilIndex: return b
  if b == NilIndex: return a
  if self.f.cmp(self.f.nodes[a],self.f.nodes[b]) > 0 : swap(a,b)
  self.f.L[a] = self.merge(self.f.L[a],b)
  swap(self.f.L[a],self.f.R[a])
  return a
proc top*[T](self:SkewHeap[T]): T = self.f.nodes[self.root]
proc len*[T](self:SkewHeap[T]): int = self.size
proc isEmpty*[T](self: SkewHeap[T]) : bool = self.len == 0
proc push*[T](self:SkewHeap[T],val:T) =
  var a = self.newSkewHeapNode(val)
  self.root = self.merge(self.root,a)
  self.size += 1
proc pop*[T](self:SkewHeap[T]): T{.discardable.} =
  result = self.top()
  self.f.empties.add self.root
  self.root = self.merge(self.f.L[self.root],self.f.R[self.root])
  self.size -= 1
proc merge*[T](self,other:var SkewHeap[T]) : SkewHeap[T] =
  new(result)
  result.size = self.size + other.size
  result.root = self.merge(self.root,other.root)
  result.f = self.f
  self = nil
  other = nil
iterator items*[T](self:SkewHeap[T]): T =
  var stack = @[self.root]
  while stack.len > 0:
    let now = stack.pop()
    if now == NilIndex: continue
    yield self.f.nodes[now]
    if self.f.R[now] != NilIndex:
      stack.add self.f.R[now]
    if self.f.L[now] != NilIndex:
      stack.add self.f.L[now]
proc toSequence*[T](self:SkewHeap[T]): seq[T] = toSeq(self.items).sorted(self.f.cmp)
proc `$`*[T](self: SkewHeap[T]): string = $self.toSequence()

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
block:
  stopwatch:
    let n = 1e6.int
    var S = newSkewHeapFactory[int](cmp).newSkewHeap()
    for _ in 0..n: S.push randomBit(32)
    discard S.pop()
    for _ in 0..n-10: S.pop()
    discard S.pop()


when isMainModule:
  import unittest
  test "skew heap":
    block: # 最小値
      var f = newSkewHeapFactory[int](cmp)
      var h = f.newSkewHeap()
      h.push(30)
      h.push(10)
      h.push(20)
      check: h.pop() == 10
      check: h.pop() == 20
      h.push(0)
      check: not h.isEmpty()
      check: h.len() == 2
      check: h.pop() == 0
      check: h.pop() == 30
      check: h.isEmpty()
    block: # 最大値
      var f = newSkewHeapFactory[int](revcmp)
      var h = f.newSkewHeap()
      h.push(30)
      h.push(10)
      h.push(20)
      check: h.pop() == 30
      check: h.pop() == 20
      h.push(0)
      check: h.pop() == 10
      check: h.pop() == 0
    block: # merge
      var f = newSkewHeapFactory[int](cmp)
      var h1 = f.newSkewHeap()
      h1.push(30)
      h1.push(10)
      h1.push(20)
      var h2 = f.newSkewHeap()
      h1.push(35)
      h1.push(15)
      h1.push(25)
      var h = h1.merge(h2)
      check: h1 == nil
      check: h2 == nil
      check: h != nil
      for i,v in @[10,15,20,25,30,35]:
        check: h.len == 6 - i
        check: h.pop() == v
