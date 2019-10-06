import "./segmenttree"
import sequtils,math
type
  SegmentTree2D[T] = ref object
    w,h : int
    data:seq[SegmentTree[T]]
    unit: T
    apply:proc(x,y:T):T
proc newSegmentTree2D[T](w,h:int,apply:proc(x,y:T):T,unit:T) : SegmentTree2D[T] =
  new(result)
  result.w = w.nextPowerOfTwo()
  result.h = h.nextPowerOfTwo()
  result.unit = unit
  result.apply = apply
  result.data = newSeq[SegmentTree[T]](result.w * 2)
  for i in 0..<result.data.len:
    result.data[i] = newSegmentTree[T](h,apply,unit)
proc `[]=`*[T](self:var SegmentTree2D[T],x,y:int,val:T) =
  var x = x + self.w - 1
  self.data[x][y] = val
  while x > 0:
    x = (x - 1) shr 1
    self.data[x][y] = self.apply(self.data[x * 2 + 1][y],self.data[x * 2 + 2][y])
proc queryImpl*[T](self:SegmentTree2D[T],target,ys,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.unit
  if target.a <= now.a and now.b <= target.b : return self.data[i][ys]
  let next = (now.a + now.b) shr 1
  let vl = self.queryImpl(target, ys, now.a..next, i*2+1)
  let vr = self.queryImpl(target, ys, next..now.b, i*2+2)
  return self.apply(vl,vr)
proc `[]`*[T](self:SegmentTree2D[T],xs,ys:Slice[int]): T =
  return self.queryImpl(xs.a..xs.b+1,ys,0..self.w,0)
proc `[]`*[T](self:SegmentTree2D[T],x,y:int): T = self[x..x,y..y]

proc `$`*[T](self:SegmentTree2D[T]): string =
  var arrs = newSeqWith(self.w,newSeq[T](self.h))
  for x in 0..<self.w:
    for y in 0..<self.h:
      arrs[x][y] = self[x..x,y..y]
  return $arrs


# 最大値のセグツリ
proc newMaxSegmentTree2D*[T](w,h:int) : SegmentTree2D[T] =
  newSegmentTree2D[T](w,h,proc(x,y:T):T=(if x >= y: x else: y),-1e12.T)
# 最小値のセグツリ
proc newMinSegmentTree2D*[T](w,h:int) : SegmentTree2D[T] =
  newSegmentTree2D[T](w,h,proc(x,y:T):T=(if x <= y: x else: y),-1e12.T)
# 区間和のセグツリ
proc newCumulativeSum2D*[T](w,h:int) : SegmentTree2D[T] =
  newSegmentTree2D[T](w,h,proc(x,y:T):T= x + y,0.T)

when isMainModule:
  import unittest
  import math
  test "segment tree 2D":
    block:
      var S = newMaxSegmentTree2D[int](4,4)
      for x in 1..2:
        for y in 1..2:
          S[x,y] = 5
      check: S[0..<2,0..<2] == 5
      check: S[0..<4,0..0] == -1e12.int
      check: S[1..<2,0..<4] == 5
