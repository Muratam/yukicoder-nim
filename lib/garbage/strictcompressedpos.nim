# 強い制約の座標圧縮(指定外の位置はエラー)
# あまり速度が変わらない...
import tables
type StrictCompressedPos*[T] = ref object
  table*: Table[T,int]
proc len*[T](self:StrictCompressedPos[T]):int = self.table.len
proc newStrictCompressedPos*[T](poses:seq[T]):StrictCompressedPos[T] =
  new(result)
  result.table = initTable[T,int]()
  var i = 0
  var pre :T
  for p in poses.sorted(cmp[T]):
    if i > 0 and pre == p : continue
    result.table[p] = i
    pre = p
    i += 1
proc `[]`*[T](self:StrictCompressedPos[T],i:T):int = self.table[i]
proc `[]`*[T](self:StrictCompressedPos[T],i:Slice[T]): Slice[int] =
  self.table[i.a]..self.table[i.b]
proc `$`*[T](self:StrictCompressedPos[T]): string = $self.table

type SparseStrictSegmentTree*[T,I] = ref object
  segtree*:SegmentTree[T]
  compressed*:StrictCompressedPos[I]
proc newSparceStrictSegmentTree*[T,I](poses:seq[I],apply:proc(x,y:T):T,unit:T):SparseStrictSegmentTree[T,I] =
  new(result)
  result.compressed = poses.newStrictCompressedPos()
  result.segtree = newSegmentTree[T](result.compressed.len,apply,unit)
proc `[]=`*[T,I](self:var SparseStrictSegmentTree[T,I],i:I,val:T) =
  self.segtree[self.compressed[i]] = val
proc `[]`*[T,I](self:SparseStrictSegmentTree[T,I],i:I):T =
  let ia = self.compressed[i]
  if ia == self.compressed.len : return self.segtree.unit
  return self.segtree[ia]
proc `[]`*[T,I](self:SparseStrictSegmentTree[T,I],i:Slice[I]):T =
  let slice = self.compressed[i]
  if slice.a > slice.b : return self.segtree.unit
  return self.segtree[slice]
