# セグツリ 区間[s,t)の最小(最大)値 / 更新 O(log(N))
import sequtils,math
type
  SegmentTree*[T] = ref object
    n* : int
    data*:seq[T]
    infinity*: T
    cmp*:proc(x,y:T):T
proc newSegmentTree*[T](size:int,infinity:T,cmp:proc(x,y:T):T) : SegmentTree[T] =
  new(result)
  result.n = size.nextPowerOfTwo()
  result.data = newSeqWith(result.n * 2,infinity)
  result.infinity = infinity
  result.cmp = cmp
proc `[]=`*[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n - 1
  self.data[i] = val
  while i > 0:
    i = (i - 1) shr 1
    self.data[i] = self.cmp(self.data[i * 2 + 1],self.data[i * 2 + 2])
proc queryImpl*[T](self:SegmentTree[T],target,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.infinity
  if target.a <= now.a and now.b <= target.b : return self.data[i]
  let next = (now.a + now.b) shr 1
  let vl = self.queryImpl(target, now.a..next, i*2+1)
  let vr = self.queryImpl(target, next..now.b, i*2+2)
  return self.cmp(vl,vr)
proc `[]`*[T](self:SegmentTree[T],slice:Slice[int]): T =
  return self.queryImpl(slice.a..slice.b+1,0..self.n,0)
proc `[]`*[T](self:SegmentTree[T],i:int): T = self[i..i]
proc `$`*[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[T]] = @[]
  var l = 0
  var r = 1
  while r <= self.data.len:
    arrs.add self.data[l..<r]
    l = l * 2 + 1
    r = r * 2 + 1
  return $arrs
# 目的の値を返すindexを返す
proc findIndexImpl*[T](self:SegmentTree[T],target,now:Slice[int],i,d:int = 0) : int =
  if now.b <= target.a or target.b <= now.a : return -1
  if target.a <= now.a and now.b <= target.b : return i
  let next = (now.a + now.b) shr 1
  let vl = self.findIndexImpl(target,now.a..next,i*2+1,d+1)
  let vr = self.findIndexImpl(target,next..now.b,i*2+2,d+1)
  if vl == -1: return vr
  if vr == -1: return vl
  if self.data[vl] == self.cmp(self.data[vl],self.data[vr]): return vl
  else: return vr
proc findIndex*[T](self:SegmentTree[T],slice:Slice[int]): int =
  var index = self.findIndexImpl(slice.a..slice.b+1,0..self.n,0)
  while index < self.n - 1:
    let l = index * 2 + 1
    if self.data[l] == self.data[index] : index = l
    else: index = l + 1
  return index - (self.n - 1)

proc newMaxSegmentTree*[T](size:int) : SegmentTree[T] =
  # 最大値のセグツリ
  proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
  result = newSegmentTree[T](size,-1e12.T,maximpl[T])
proc newMinSegmentTree*[T](size:int) : SegmentTree[T] =
  # 最小値のセグツリ
  proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
  result = newSegmentTree[T](size,1e12.T,minimpl[T])
proc newAddSegmentTree*[T](size:int) : SegmentTree[T] =
  # 区間和のセグツリ
  proc addimpl[T](x,y:T): T = x + y
  result = newSegmentTree[T](size,0.T,addImpl[T])


when isMainModule:
  import unittest
  import math
  test "segment tree":
    block:
      var S = newMaxSegmentTree[int](100)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 50
      check: S[25..75] == 25
      check: S.findIndex(0..<100) == 0
      S[50] = 100
      check: S[25..75] == 100
      check: S[50..50] == 100
      check: S[0..25] == 50
      check: S.findIndex(0..<100) == 50
    block:
      var S = newMinSegmentTree[int](100)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 0
      check: S[25..75] == 0
      S[50] = 100
      check: S[25..75] == 1
      check: S[50..50] == 100
      check: S[0..25] == 25
    block:
      var S = newAddSegmentTree[int](100)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<1] == 50
      check: S[0..<2] == 99
      check: S[0..<3] == 147
      check: S[1..<3] == 97
