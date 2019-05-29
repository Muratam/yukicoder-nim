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
proc queryImpl[T](self:SegmentTree[T],a,b,k,l,r:int) : T =
  if r <= a or b <= l : return self.infinity
  if a <= l and r <= b : return self.data[k]
  let vl = self.queryImpl(a,b,k*2+1,l,(l+r) shr 1)
  let vr = self.queryImpl(a,b,k*2+2,(l+r) shr 1,r)
  return self.cmp(vl,vr)
proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
  return self.queryImpl(slice.a,slice.b+1,0,0,self.n)
proc `$`[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[int]] = @[]
  var l = 0
  var r = 1
  while r <= self.data.len:
    arrs.add self.data[l..<r]
    l = l * 2 + 1
    r = r * 2 + 1
  return $arrs

when isMainModule:
  import unittest
  import math
  test "segment tree":
    block:
      var S = newSegmentTree[int](100,SaveMax)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 50
      check: S[25..75] == 25
      S[50] = 100
      check: S[25..75] == 100
      check: S[50..50] == 100
      check: S[0..25] == 50
    block:
      var S = newSegmentTree[int](100,SaveMin)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 0
      check: S[25..75] == 0
      S[50] = 100
      check: S[25..75] == 1
      check: S[50..50] == 100
      check: S[0..25] == 25
