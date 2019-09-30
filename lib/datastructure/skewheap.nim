import algorithm
# SkewHeapNode :: Merge も log(N) な BinaryHeap
type
  SkewHeapNode*[T] = ref object
    L,R: SkewHeapNode[T]
    top*: T
  SkewHeap*[T] = ref object
    root*:SkewHeapNode[T]
    cmp*:proc(x,y:T):int
    size*: int
proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc newSkewHeapNode[T](val:T):SkewHeapNode[T] =
  new(result)
  result.top = val
proc newSkewHeap*[T](cmp:proc(x,y:T):int):SkewHeap[T] =
  new(result)
  result.cmp = cmp
  result.size = 0
proc merge[T](self:var SkewHeap[T],a,b:var SkewHeapNode[T]):SkewHeapNode[T] =
  if a == nil: return b
  if b == nil: return a
  if self.cmp(a.top,b.top) > 0 : swap(a,b)
  a.R = self.merge(a.R,b)
  swap(a.L,a.R)
  return a
proc top*[T](self:SkewHeap[T]): T = self.root.top
proc len*[T](self:SkewHeap[T]): int = self.size
proc isEmpty*[T](self: SkewHeap[T]) : bool = self.len == 0
proc push*[T](self:var SkewHeap[T],val:T) =
  var a = newSkewHeapNode[T](val)
  self.root = self.merge(self.root,a)
  self.size += 1
proc pop*[T](self:var SkewHeap[T]): T =
  result = self.root.top
  self.root = self.merge(self.root.L,self.root.R)
  self.size -= 1
proc merge*[T](self,other:var SkewHeap[T]) : SkewHeap[T] =
  new(result)
  result.size = self.size + other.size
  result.root = self.merge(self.root,other.root)
  result.cmp = self.cmp
  self = nil
  other = nil
proc toSeq[T](a:SkewHeapNode[T]): seq[T] =
  # 木の深さは無限に深くなるので再帰で書かない
  if a == nil : return @[]
  var arr = newSeq[T]()
  var nows = newSeq[SkewHeapNode[T]]()
  nows.add a
  while nows.len > 0:
    let now = nows.pop()
    arr.add now.top
    if now.L != nil: nows.add now.L
    if now.R != nil: nows.add now.R
  return arr
proc toSeq*[T](self:SkewHeap[T]): seq[T] = self.root.toSeq().sorted(self.cmp)
proc `$`[T](a:SkewHeapNode[T]): string = $a.toSeq()
proc `$`*[T](self:var SkewHeap[T]): string = $self.toSeq()
iterator items*[T](self:SkewHeap[T]): T =
  for v in self.toSeq(): yield v

when isMainModule:
  import unittest
  test "skew heap":
    block: # 最小値
      var h = newSkewHeap[int](cmp)
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
      var h = newSkewHeap[int](revcmp)
      h.push(30)
      h.push(10)
      h.push(20)
      check: h.pop() == 30
      check: h.pop() == 20
      h.push(0)
      check: h.pop() == 10
      check: h.pop() == 0
    block: # merge
      var h1 = newSkewHeap[int](cmp)
      h1.push(30)
      h1.push(10)
      h1.push(20)
      var h2 = newSkewHeap[int](cmp)
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
