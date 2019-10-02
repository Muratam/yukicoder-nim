# 区間に値を均等に足す・区間の最大値を求める が O(log N)
import sequtils,math
type StarrySkyTree[T] = ref object
  n : int
  data:seq[T]
  lazy:seq[T]
  infinity:T
  cmp:proc(x,y:T):T

proc newStarrySkyTree[T](size:int,infinity:T) : StarrySkyTree[T] =
  new(result)
  result.n = size.nextPowerOfTwo()
  result.data = newSeqWith(result.n*2,0)
  result.lazy = newSeqWith(result.n*2,0)
  result.infinity = infinity

proc plusImpl[T](self:var StarrySkyTree[T],target,now:Slice[int],i:int,val:T) =
  if now.b <= target.a or target.b <= now.a : return
  if target.a <= now.a and now.b <= target.b :
    self.lazy[i] += val
    return
  let next = (now.a + now.b) shr 1
  let left = (i-self.n) * 2
  let right = left + 1
  self.plusImpl(target, now.a..next, left ,val)
  self.plusImpl(target, next..now.b, right ,val)
  self.data[i] = self.cmp(self.data[left] + self.lazy[left],self.data[right] + self.lazy[right])
proc plus[T](self:var StarrySkyTree[T],slice:Slice[int],val:T) =
  self.plusImpl(slice.a..slice.b+1,0..self.n,2*self.n-2,val)

proc searchImpl[T](self:StarrySkyTree[T],target,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.infinity
  if target.a <= now.a and now.b <= target.b : return self.data[i] + self.lazy[i]
  let next = (now.a + now.b) shr 1
  let left = (i-self.n)*2
  let right = (i-self.n)*2+1
  let vl = self.searchImpl(target, now.a..next, left)
  let vr = self.searchImpl(target, next..now.b, right)
  return self.lazy[i] + self.cmp(vl,vr)

proc `[]`[T](self:StarrySkyTree[T],slice:Slice[int]): T =
  return self.searchImpl(slice.a..slice.b+1,0..self.n,2*self.n-2)

proc newMaxStarrySkyTree[T](size:int) : StarrySkyTree[T] =
  # 最大値のセグツリ
  result = newStarrySkyTree[T](size,-1e12.T)
  proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
  result.cmp = maximpl[T]
proc newMinStarrySkyTree[T](size:int) : StarrySkyTree[T] =
  # 最小値のセグツリ
  result = newStarrySkyTree[T](size,1e12.T)
  proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
  result.cmp = minimpl[T]



when isMainModule:
  import unittest
  import math
  test "starry sky tree":
    block:
      var S = newMinStarrySkyTree[int](10)
      S.plus(0..<5 , 10)
      for i,v in @[10, 10, 10, 10, 10, 0, 0, 0, 0, 0]: check: S[i..i] == v
      check: S[0..<10] == 0
      S.plus(4..<10 , 5)
      for i,v in @[10, 10, 10, 10, 15, 5, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 5
      S.plus(1..<6 , -1)
      for i,v in @[10, 9, 9, 9, 14, 4, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 4
      check: S[0..<5] == 9
      check: S[5..<10] == 4
    block:
      var S = newMaxStarrySkyTree[int](10)
      S.plus(0..<5 , 10)
      for i,v in @[10, 10, 10, 10, 10, 0, 0, 0, 0, 0]: check: S[i..i] == v
      check: S[0..<10] == 10
      S.plus(4..<10 , 5)
      for i,v in @[10, 10, 10, 10, 15, 5, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 15
      S.plus(1..<6 , -1)
      for i,v in @[10, 9, 9, 9, 14, 4, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 14
      check: S[0..<5] == 14
      check: S[5..<10] == 5
