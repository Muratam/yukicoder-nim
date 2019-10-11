import sequtils,math
# 遅延セグメントツリー
# モノイドでの区間の更新・区間の取得ができる

# https://ei1333.github.io/algorithm/segment-tree.html
type LazySegmentTree[T] = ref object
  size : int
  data,lazy:seq[T]
  m1,om0:T
  f,g,h:proc(x,y:T):T
  p:proc(x:T,n:int):T
proc newLazySegmentTree[T](size:int,f,g,h:proc(x,y:T):T,p:proc(x:T,n:int):T,m1,om0:T) : LazySegmentTree[T] =
  new(result)
  result.size = size.nextPowerOfTwo()
  result.data = newSeq[T](result.size*2)
  result.lazy = newSeq[T](result.size*2)
  for i in 0..<result.data.len:
    result.data[i] = m1
    result.lazy[i] = om0
  result.m1 = m1
  result.om0 = om0
  result.f = f
  result.g = g
  result.h = h
  result.p = p
# 構築 O(N)
proc initWithSeq[T](self:LazySegmentTree[T],arr:seq[T]) =
  for i in 0..<self.data.len:
    self.data[i] = self.m1
    self.lazy[i] = self.om0
  for i in 0..<arr.len:
    self.data[i+self.size] = self.arr[i]
  for i in (self.size - 2).countdown(0):
    self.data[i] = self.f(self.data[2*i],self.data[2*i+1])
proc propagate[T](self:var LazySegmentTree[T],i,length:int) =
  if self.lazy[i] == self.om0: return
  if i < self.size:
    self.lazy[2*i+0] = self.h(self.lazy[2*i+0],self.lazy[i])
    self.lazy[2*i+1] = self.h(self.lazy[2*i+1],self.lazy[i])
  self.data[i] = self.g(self.data[i],self.p(self.lazy[i],length))
  self.lazy[i] = self.om0
proc updateImpl[T](self:var LazySegmentTree[T],target,now:Slice[int],i:int,val:T) : T =
  self.propagate(i,now.b - now.a)
  if now.b <= target.a or target.b <= now.a :
    return self.data[i]
  if target.a <= now.a and now.b <= target.b :
    self.lazy[i] = self.h(self.lazy[i],val)
    self.propagate(i,now.b - now.a)
    return self.data[i]
  let next = (now.a + now.b) shr 1
  let left = self.updateImpl(target,now.a..next,2*i+0,val)
  let right = self.updateImpl(target,next..now.b,2*i+1,val)
  self.data[i] = self.f(left,right)
  return self.data[i]
proc queryImpl[T](self:var LazySegmentTree[T],target,now:Slice[int],i:int) : T =
  self.propagate(i,now.b - now.a)
  if now.b <= target.a or target.b <= now.a :
    return self.m1
  if target.a <= now.a and now.b <= target.b :
    return self.data[i]
  let next = (now.a + now.b) shr 1
  let left = self.queryImpl(target,now.a..next,2*i+0)
  let right = self.queryImpl(target,next..now.b,2*i+1)
  return self.f(left,right)
proc update[T](self:var LazySegmentTree[T],target:Slice[int],val:T) =
  discard self.updateImpl(target.a..target.b+1,0..self.size,1,val)
proc update[T](self:var LazySegmentTree[T],i:int,val:T) = self.update(i..i,val)
proc `[]`[T](self:var LazySegmentTree[T],target:Slice[int]): T =
  return self.queryImpl(target.a..target.b+1,0..self.size,1)
proc `[]`[T](self:var LazySegmentTree[T],i:int): T = self[i..i]

# 最大値のStarrySkyTree
# 区間{均等に足す,最大値} が O(log N)
proc newMinStarrySkyTree[T](size:int) : LazySegmentTree[T] =
  proc addimpl(x,y:T):T=x+y
  proc minimpl(x,y:T):T=(if x <= y : x else:y)
  newLazySegmentTree[T](size,
    minimpl,
    addimpl,
    addimpl,
    proc(x:T,n:int):T=x,
    1e12.int,
    0.int,
    )

when isMainModule:
  import unittest
  import math
  test "segmenttree lazy":
    block:
      var S = newMinStarrySkyTree[int](4)
      S.update(0,1)
      S.update(1,2)
      S.update(2,3)
      S.update(3,4)
      echo S[0]
      echo S[1]
      echo S[2]
      echo S[3]
      S.update(0..3,8)
      echo S[0]
      echo S[1]
      echo S[2]
      echo S[3]
