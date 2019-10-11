# セグツリ
# 密な区間[s,t]のモノイドの計算 / 一点更新 O(logN)
# (= 単位元がありa*(b*c)==(a*b)*c. 最大値・最小値・加算など)

# 範囲取得クエリが A かつ  範囲更新クエリが B なら いもす法 O(A*(B+N))
# 範囲取得クエリが A かつ 1箇所更新クエリが B なら セグメントツリー O((A+B)logN)

import sequtils,math
type
  SegmentTree*[T] = ref object
    n*  : int # 生
    n2* : int # 2のべき乗
    data*:seq[T]
    unit*: T
    apply*:proc(x,y:T):T
# 親は(i-1)/2,子は2i+{1,2}.葉はi+n2-1,根は0
proc newSegmentTree*[T](size:int,apply:proc(x,y:T):T,unit:T) : SegmentTree[T] =
  new(result)
  result.n = size
  result.n2 = size.nextPowerOfTwo()
  result.data = newSeq[T](result.n2+result.n) # 1つは余分に取ってる
  for i in 0..<result.data.len: result.data[i] = unit
  result.unit = unit
  result.apply = apply
# 構築. O(N)
proc newSegmentTree*[T](arr:seq[T],apply:proc(x,y:T):T,unit:T) : SegmentTree[T] =
  new(result)
  result.n = arr.len
  result.n2 = arr.len.nextPowerOfTwo()
  result.unit = unit
  result.apply = apply
  result.data = newSeq[T](result.n2+result.n)
  result.data[^1] = unit
  let offset = result.n2 - 1
  for i,a in arr: result.data[i+offset] = a
  for i in (offset-1).countdown(0):
    if i*2+1 >= result.data.len:
      result.data[i] = unit
    elif i*2+2 >= result.data.len:
      result.data[i] = result.data[i*2+1]
    else:
      result.data[i] = apply(result.data[i*2+1],result.data[i*2+2])
  if result.data.len >= 2:
    result.data[0] = apply(result.data[1],result.data[2])
proc `[]=`*[T](self:var SegmentTree[T],i:int,val:T) =
  var i = i + self.n2 - 1 # 葉から
  self.data[i] = val
  while i > 0: # 根まで
    i = (i - 1) shr 1
    self.data[i] = self.apply(self.data[i*2+1],self.data[i*2+2])
# 葉から見ていく.非再帰
proc queryImpl*[T](self:SegmentTree[T],slice:Slice[int]): T =
  result = self.unit
  var now = 0.max(slice.a)+self.n2-1..(self.n-1).min(slice.b)+self.n2-1
  while now.a < now.b:
    if (now.a and 1) == 0:
      result = self.apply(result,self.data[now.a])
    if (now.b and 1) == 0:
      result = self.apply(self.data[now.b-1],result)
    now.a = now.a shr 1 # 親のちょっと右より
    now.b = (now.b-1) shr 1 # 親のちょっと左より
proc `[]`*[T](self:SegmentTree[T],slice:Slice[int]): T =
  self.queryImpl(slice.a..slice.b+1) # 全範囲を,葉から


proc `[]`*[T](self:SegmentTree[T],i:int): T = self.data[i+self.n2-1]
proc `$`*[T](self:SegmentTree[T]): string =
  var arrs : seq[seq[T]] = @[]
  var left = 0
  var right = 1
  while right <= self.data.len:
    arrs.add self.data[left..<right]
    left = left * 2 + 1
    right = right * 2 + 1
  return $arrs
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

# 範囲がスパースな場合. クエリ先読み+座標圧縮のセグツリ
# 更新クエリ箇所は先読みが必要だが、検索クエリは先読みしなくてよい
import algorithm
import "../../seq/filter"
type SparseSegmentTree*[T,I] = ref object
  segtree*:SegmentTree[T]
  compressed*:CompressedPos[I]
proc newSparceSegmentTree*[T,I](poses:seq[I],apply:proc(x,y:T):T,unit:T):SparseSegmentTree[T,I] =
  new(result)
  result.compressed = poses.newCompressedPos()
  result.segtree = newSegmentTree[T](result.compressed.len,apply,unit)
proc `[]=`*[T,I](self:var SparseSegmentTree[T,I],i:I,val:T) =
  self.segtree[self.compressed[i]] = val
proc `[]`*[T,I](self:SparseSegmentTree[T,I],i:I):T =
  let ia = self.compressed[i]
  if ia == self.compressed.len : return self.segtree.unit
  return self.segtree[ia]
proc `[]`*[T,I](self:SparseSegmentTree[T,I],i:Slice[I]):T =
  let slice = self.compressed[i]
  if slice.a > slice.b : return self.segtree.unit
  return self.segtree[slice]

when isMainModule:
  import unittest
  import math
  test "segment tree":
    block: # max
      var T = newSeq[int](100)
      for i in 0..<100: T[i] = abs(i - 50)
      var S = newMaxSegmentTree[int](100)
      for i,t in T: S[i] = t
      var S2 = T.newSegmentTree(proc(x,y:int): int = (if x >= y: x else: y),-1e12.int)
      if S.data != S2.data:
        check: S.data.len == S2.data.len
        for i in 0..<S.data.len:
          if S.data[i] != S2.data[i]:
            echo i,"::",S.data[i],":",S2.data[i]
      check: S[0..<100] == 50
      check: S[25..75] == 25
      S[50] = 100
      check: S[25..75] == 100
      check: S[50..50] == 100
      check: S[0..25] == 50

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
  test "Sparse Segment Tree":
    block: # スパース時の加算のやつ
      const EPS = 1e-6
      proc `~~`(x, y: float): bool = abs(x - y) < EPS # ≒
      let poses = @[50,-50,50,100,22,421,4214,421,44,4,60,-50]
      var S = newSparceSegmentTree(poses,proc(x,y:float):float=x+y,0.0)
      S[50] = 100.0.float
      S[421] = 500.0.float
      S[-50] = 20.0.float
      S[100] = 10.0.float
      check: S[id(-10000)..10000] ~~ 630.0
      check: S[49..<50] ~~ 0.0
      check: S[49..50] ~~ 100.0
      check: S[50..50] ~~ 100.0
      check: S[50..51] ~~ 100.0
      check: S.compressed.data == @[-50, 4, 22, 44, 50, 60, 100, 421, 4214]
      check: S[58..<421] ~~ 10.0
      check: S[58..421] ~~ 510.0
