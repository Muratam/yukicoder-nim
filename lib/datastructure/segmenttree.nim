# セグツリ 区間[s,t)の最小(最大)値 / 更新 O(log(N))
import sequtils,math
type
  SegmentTree[T] = ref object
    data:seq[T]
    n : int
    rawSize:int
    infinity: T
    cmp:proc(x,y:T):T
  SegmentTreeType = enum SaveMin , SaveMax
proc newSegmentTree[T](size:int,segType:SegmentTreeType) : SegmentTree[T] =
  new(result)
  if segType == SaveMin: # 最小値
    proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
    result.infinity = 1e12.T
    result.cmp = minimpl
  elif segType == SaveMax: # 最大値
    proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
    result.infinity = -1e12.T
    result.cmp = maximpl
  else:
    doAssert false
  result.n = size.nextPowerOfTwo()
  result.rawSize = size
  result.data = newSeqWith(result.n * 2,result.infinity)
proc `[]=`[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n - 1
  self.data[i] = val
  while i > 0:
    i = (i - 1) shr 1
    self.data[i] = self.cmp(self.data[i * 2 + 1],self.data[i * 2 + 2])
proc queryImpl[T](self:SegmentTree[T],target,now:Slice[int],k:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.infinity
  if target.a <= now.a and now.b <= target.b : return self.data[k]
  let next = (now.a + now.b) shr 1
  let vl = self.queryImpl(target, now.a..next, k*2+1)
  let vr = self.queryImpl(target, next..now.b, k*2+2)
  return self.cmp(vl,vr)
proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
  return self.queryImpl(slice.a..slice.b+1,0..self.n,0)

proc `$`[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[int]] = @[]
  var l = 0
  var r = 1
  while r <= self.data.len:
    arrs.add self.data[l..<r]
    l = l * 2 + 1
    r = r * 2 + 1
  return $arrs

proc findIndexImpl[T](self:SegmentTree[T],target,now:Slice[int],k,d:int = 0) : int =
  if now.b <= target.a or target.b <= now.a : return -1
  if target.a <= now.a and now.b <= target.b : return k
  let next = (now.a + now.b) shr 1
  let vl = self.findIndexImpl(target,now.a..next,k*2+1,d+1)
  let vr = self.findIndexImpl(target,next..now.b,k*2+2,d+1)
  if vl == -1: return vr
  if vr == -1: return vl
  if self.data[vl] == self.cmp(self.data[vl],self.data[vr]): return vl
  else: return vr
proc findIndex[T](self:SegmentTree[T],slice:Slice[int]): int =
  var index = self.findIndexImpl(slice.a..slice.b+1,0..self.n,0)
  while index < self.n - 1:
    let l = index * 2 + 1
    if self.data[l] == self.data[index] : index = l
    else: index = l + 1
  return index - (self.n - 1)



when isMainModule:
  import unittest
  import math
  test "segment tree":
    block:
      var S = newSegmentTree[int](100,SaveMax)
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
      var S = newSegmentTree[int](100,SaveMin)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 0
      check: S[25..75] == 0
      S[50] = 100
      check: S[25..75] == 1
      check: S[50..50] == 100
      check: S[0..25] == 25
