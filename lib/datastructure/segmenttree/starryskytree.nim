# 可換モノイド演算での区間更新 / モノイド演算での区間取得.
import sequtils,math
type StarrySkyTree[T] = ref object
  n : int
  data:seq[T]
  updateFun:proc(x,y:T):T
  lazy:seq[T]
  unit:T
  apply:proc(x,y:T):T

proc newStarrySkyTree[T](size:int,apply:proc(x,y:T):T,unit:T,updateFun:proc(x,y:T):T,init:T) : StarrySkyTree[T] =
  new(result)
  result.n = size.nextPowerOfTwo()
  result.data = newSeq[T](result.n*2)
  result.lazy = newSeq[T](result.n*2)
  for i in 0..<result.data.len:
    result.data[i] = init
    result.lazy[i] = init
  result.updateFun = updateFun
  result.unit = unit
  result.apply = apply
proc updateImpl[T](self:var StarrySkyTree[T],target,now:Slice[int],i:int,val:T) =
  if now.b <= target.a or target.b <= now.a : return
  if target.a <= now.a and now.b <= target.b :
    self.lazy[i] = self.updateFun(self.lazy[i],val)
    return
  let next = (now.a + now.b) shr 1
  let left = (i-self.n) * 2
  let right = left + 1
  self.updateImpl(target, now.a..next, left ,val)
  self.updateImpl(target, next..now.b, right ,val)
  let vl = self.updateFun(self.data[left] , self.lazy[left])
  let vr = self.updateFun(self.data[right] , self.lazy[right])
  self.data[i] = self.apply(vl,vr)
proc update[T](self:var StarrySkyTree[T],slice:Slice[int],val:T) =
  self.updateImpl(slice.a..slice.b+1,0..self.n,2*self.n-2,val)
proc searchImpl[T](self:StarrySkyTree[T],target,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a :
    return self.unit
  if target.a <= now.a and now.b <= target.b :
    return self.updateFun(self.data[i], self.lazy[i])
  let next = (now.a + now.b) shr 1
  let left = (i-self.n)*2
  let right = (i-self.n)*2+1
  let vl = self.searchImpl(target, now.a..next, left)
  let vr = self.searchImpl(target, next..now.b, right)
  return self.updateFun(self.lazy[i],self.apply(vl,vr))
proc `[]`[T](self:StarrySkyTree[T],slice:Slice[int]): T =
  return self.searchImpl(slice.a..slice.b+1,0..self.n,2*self.n-2)

# 最大値のStarrySkyTree
# 区間{均等に足す,最大値} が O(log N)
proc newMaxStarrySkyTree[T](size:int) : StarrySkyTree[T] =
  newStarrySkyTree[T](size,proc(x,y:T):T=(if x >= y: x else: y),-1e12.T,proc(x,y:T):T=x+y,0.T)
# 最小値のStarrySkyTree
# 区間{均等に足す,最小値} が O(log N)
proc newMinStarrySkyTree[T](size:int) : StarrySkyTree[T] =
  newStarrySkyTree[T](size,proc(x,y:T):T=(if x <= y: x else: y),1e12.T,proc(x,y:T):T=x+y,0.T)

when isMainModule:
  import unittest
  import math
  test "Starry Sky Tree":
    block:
      var S = newMinStarrySkyTree[int](10)
      S.update(0..<5 , 10)
      for i,v in @[10, 10, 10, 10, 10, 0, 0, 0, 0, 0]: check: S[i..i] == v
      check: S[0..<10] == 0
      S.update(4..<10 , 5)
      for i,v in @[10, 10, 10, 10, 15, 5, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 5
      S.update(1..<6 , -1)
      for i,v in @[10, 9, 9, 9, 14, 4, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 4
      check: S[0..<5] == 9
      check: S[5..<10] == 4
    block:
      var S = newMaxStarrySkyTree[int](10)
      S.update(0..<5 , 10)
      for i,v in @[10, 10, 10, 10, 10, 0, 0, 0, 0, 0]: check: S[i..i] == v
      check: S[0..<10] == 10
      S.update(4..<10 , 5)
      for i,v in @[10, 10, 10, 10, 15, 5, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 15
      S.update(1..<6 , -1)
      for i,v in @[10, 9, 9, 9, 14, 4, 5, 5, 5, 5]: check: S[i..i] == v
      check: S[0..<10] == 14
      check: S[0..<5] == 14
      check: S[5..<10] == 5
    block: # 区間Add,区間Min-IndexFind
      # type WithIndex[T] = ... と書くと最新のNimは落ちる
      let S = newStarrySkyTree[tuple[v,i:int]](
          20,
          proc(x,y:tuple[v,i:int]):tuple[v,i:int] =
            (if x.v <= y.v: x else: y),
          (v:1e12.int,i: -1), # この結果は異なる(indexを持てない単位元なため)
          proc(x,y:tuple[v,i:int]):tuple[v,i:int]=
          (v:x.v+y.v,i:x.i),
          (v:0,i: -1))

    block: # 区間の更新が min なもの
      proc minImpl(x,y:int):int=(if x <= y: x else: y)
      var S = newStarrySkyTree(10,minImpl,1e12.int,minImpl,1e12.int)
      S.update(0..3,20)
      S.update(2..6,10)
      S.update(8..9,100)
      check: S[0..<2] == 20
      check: S[2..4] == 10
      check: S[7..9] == 100
      check: S[0..10] == 10
