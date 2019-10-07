# セグツリ
# 密な区間[s,t]のモノイドの計算 / 一点更新 O(logN)
# (= 単位元がありa*(b*c)==(a*b)*c. 最大値・最小値・加算など)

# 範囲取得クエリが A かつ  範囲更新クエリが B なら いもす法 O(A*(B+N))
# 範囲取得クエリが A かつ 1箇所更新クエリが B なら セグメントツリー O((A+B)logN)

import sequtils,math
type
  SegmentTree*[T] = ref object
    n* : int
    data*:seq[T]
    unit*: T
    apply*:proc(x,y:T):T
# 親は(i-1)/2,子は2i+{1,2}.葉はi+n-1,根は0
proc newSegmentTree*[T](size:int,apply:proc(x,y:T):T,unit:T) : SegmentTree[T] =
  new(result)
  result.n = size.nextPowerOfTwo()
  result.data = newSeq[T](result.n*2)
  for i in 0..<result.data.len: result.data[i] = unit
  result.unit = unit
  result.apply = apply
proc `[]=`*[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n - 1 # 葉から
  self.data[i] = val
  while i > 0: # 根まで
    i = (i - 1) shr 1
    self.data[i] = self.apply(self.data[i*2+1],self.data[i*2+2])
proc queryImpl*[T](self:SegmentTree[T],target,now:Slice[int],i:int) : T =
  if now.b <= target.a or target.b <= now.a : return self.unit # 探索範囲外
  if target.a <= now.a and now.b <= target.b : return self.data[i] # 完全に範囲内
  let next = (now.a + now.b) shr 1
  let vl = self.queryImpl(target, now.a..next, i*2+1) # 左を
  let vr = self.queryImpl(target, next..now.b, i*2+2) # 右を
  return self.apply(vl,vr)
proc `[]`*[T](self:SegmentTree[T],slice:Slice[int]): T =
  self.queryImpl(slice.a..slice.b+1,0..self.n,0) # 全範囲を,根から
proc `[]`*[T](self:SegmentTree[T],i:int): T = self[i..i]
proc `$`*[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[T]] = @[]
  var left = 0
  var right = 1
  while right <= self.data.len:
    arrs.add self.data[left..<right]
    left = left * 2 + 1
    right = right * 2 + 1
  return $arrs
# 目的の値を返すindexを返す. apply(x,y) == x or y となる演算にのみ有効
proc findIndexImpl*[T](self:SegmentTree[T],target,now:Slice[int],i,d:int = 0) : int =
  if now.b <= target.a or target.b <= now.a : return -1
  if target.a <= now.a and now.b <= target.b : return i
  let next = (now.a + now.b) shr 1
  let vl = self.findIndexImpl(target,now.a..next,i*2+1,d+1)
  let vr = self.findIndexImpl(target,next..now.b,i*2+2,d+1)
  if vl == -1: return vr
  if vr == -1: return vl
  if self.data[vl] == self.apply(self.data[vl],self.data[vr]): return vl
  else: return vr
proc findIndex*[T](self:SegmentTree[T],slice:Slice[int]): int =
  var index = self.findIndexImpl(slice.a..slice.b+1,0..self.n,0)
  while index < self.n - 1:
    let left = index * 2 + 1
    if self.data[left] == self.data[index] : index = left
    else: index = left + 1
  return index - (self.n - 1)
# 最大値・最小値・和
proc newMaxSegmentTree*[T](size:int) : SegmentTree[T] = # 最大値のセグツリ
  newSegmentTree[T](size,proc(x,y:T): T = (if x >= y: x else: y),-1e12.T)
proc newMinSegmentTree*[T](size:int) : SegmentTree[T] = # 最小値のセグツリ
  newSegmentTree[T](size,proc(x,y:T): T = (if x <= y: x else: y),1e12.T)
proc newAddSegmentTree*[T](size:int) : SegmentTree[T] = # 区間和のセグツリ
  newSegmentTree[T](size,proc(x,y:T): T = x + y,0.T)

# T(生値) -> R(集約値) を噛ましてくれるセグツリのラッパー
type MappedSegmentTree*[T,R] = ref object
  data*:seq[T]
  segtree*:SegmentTree[R]
  mapFunc*:proc(base:T):R
proc newMappedSegmentTree*[T,R](size:int,mapFunc:proc(x:T):R,apply:proc(x,y:R):R,unit:R) : MappedSegmentTree[T,R] =
  new(result)
  result.mapFunc = mapFunc
  result.segtree = newSegmentTree[R](size,apply,unit)
  result.data = newSeq[T](size)
proc `[]=`*[T,R](self:var MappedSegmentTree[T,R],i:int,val:T) =
  self.data[i] = val; self.segtree[i] = self.mapFunc(val)
proc `[]`*[T,R](self:var MappedSegmentTree[T,R],i:int): T = self.data[i]
proc `[]`*[T,R](self:var MappedSegmentTree[T,R],slice:Slice[int]): R = self.segtree[slice]
proc findIndex*[T,R](self:MappedSegmentTree[T,R],slice:Slice[int]): int = self.segtree.findIndex[slice]

when isMainModule:
  import unittest
  import math
  test "segment tree":
    block: # max
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
    block: # min
      var S = newMinSegmentTree[int](100)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<100] == 0
      check: S[25..75] == 0
      S[50] = 100
      check: S[25..75] == 1
      check: S[50..50] == 100
      check: S[0..25] == 25
    block: # 加算
      var S = newAddSegmentTree[int](100)
      for i in 0..<100: S[i] = abs(i - 50)
      check: S[0..<1] == 50
      check: S[0..<2] == 99
      check: S[0..<3] == 147
      check: S[1..<3] == 97
    block: # 文字列を全部結合したやつを持ってくれる例
      var T = newSegmentTree[string](10,proc(x,y:string):string=x&y,"")
      T[0] = "aiueo"
      T[3] = "aaaa"
      T[8] = "aiueoao"
      check: T[9] == ""
      check: T[8] == "aiueoao"
      check: T[8..8] == "aiueoao"
      check: T[0..2] == "aiueo"
      check: T[0..3] == "aiueoaaaa"
      check: T[0..100] == "aiueoaaaaaiueoao"
    block: # 文字列の長さの和を持ってくれる例
      var T = newMappedSegmentTree(10,proc(x:string):int=x.len,proc(x,y:int):int=x+y,0)
      T[0] = "aiueo"
      T[3] = "aaaa"
      T[8] = "aiueoao"
      when NimMajor * 100 + NimMinor >= 19:
        check: T[9] == ""
      else:
        check: T[9] == nil
      check: T[8] == "aiueoao"
      check: T[8..8] == 7
      check: T[0..2] == 5
      check: T[0..3] == 9
      check: T[0..100] == 16
    block: # 最大値と最小値と総和を持ってくれる例
      type All = tuple[vsum,vmax,vmin:int]
      var S = newMappedSegmentTree(
        100,
        proc(x:int) : All = (x,x,x),
        proc(x,y:All) : All = (
          x.vsum+y.vsum,
          (if x.vmax > y.vmax:x.vmax else:y.vmax),
          (if x.vmin < y.vmin:x.vmin else:y.vmin)),
        (0,-1e12.int,1e12.int))
      S[10] = 100
      S[12] = 200
      S[14] = 500
      check:S[10..14] == (800,500,100)
