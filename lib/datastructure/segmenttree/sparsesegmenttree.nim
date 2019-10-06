# 範囲がスパースな場合. クエリ先読み+座標圧縮のセグツリ
# 更新クエリ箇所は先読みが必要だが、検索クエリは先読みしなくてよい
import algorithm
import "../../seq/search"
import "./segmenttree"
type SparseSegmentTree[T,I] = ref object
  segtree*:SegmentTree[T]
  compressed*:CompressedPos[I]
proc newSparceSegmentTree*[T,I](poses:seq[I],apply:proc(x,y:T):T,unit:T):SparseSegmentTree[T,I] =
  new(result)
  result.compressed = poses.newCompressedPos()
  result.segtree = newSegmentTree[T](result.compressed.len,apply,unit)
proc `[]=`[T,I](self:var SparseSegmentTree[T,I],i:I,val:T) =
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
