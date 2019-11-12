# Union-Find
# 同一集合の判定/マージ が 実質 O(1)
# 0..<n までの要素を管理する.
type UnionFind = seq[int]
proc initUnionFind*(size:int) : UnionFind =
  when NimMajor * 100 + NimMinor <= 18: result = newSeq[int](size)
  else: result = newSeqUninitialized[int](size)
  for i in 0.int32..<size.int32: result[i] = i
proc root*(self:var UnionFind,x:int): int =
  if self[x] == x: return x
  self[x] = self.root(self[x])
  return self[x]
proc same*(self:var UnionFind,x,y:int) : bool = self.root(x) == self.root(y)
proc merge*(self:var UnionFind,sx,sy:int) : bool {.discardable.} =
  var rx = self.root(sx)
  var ry = self.root(sy)
  if rx == ry : return false
  if self[ry] < self[rx] : swap(rx,ry)
  if self[rx] == self[ry] : self[rx] -= 1
  self[ry] = rx
  return true
proc count*(self:var UnionFind,x:int):int = # 木毎の要素数(最初は全て1)
  let root = self.root(x)
  for p in self:
    if self.root(p) == root: result += 1

# モノイドを乗っけた union-find
# マージすると,根はその集合全てに可換モノイドを適用した値になる
type MonoidUnionFind*[T] = ref object
  uf: UnionFind
  apply: proc(x,y:T): T
  data: seq[T]
proc newMonoidUnionFind*[T](arr:seq[T],apply:proc(x,y:T): T) : MonoidUnionFind[T] =
  new(result)
  result.uf = initUnionFind(arr.len)
  result.data = arr
  result.apply = apply
proc root*[T](self: var MonoidUnionFind[T],x:int): int = self.uf.root(x)
proc same*[T](self: var MonoidUnionFind[T],x,y:int) : bool = self.uf.same(x,y)
proc merge*[T](self:var MonoidUnionFind[T],sx,sy:int) : bool {.discardable.} =
  if self.same(sx,sy) : return false
  let srx = self.data[self.root(sx)]
  let sry = self.data[self.root(sy)]
  self.uf.merge(sx,sy)
  let r = self.root(sx)
  self.data[r] = self.apply(srx,sry)
proc rootElem*[T](self: var MonoidUnionFind[T],x:int): T = self.data[self.uf.root(x)]


when isMainModule:
  import unittest
  import sequtils
  test "unionfind":
    var F = initUnionFind(100)
    proc counts(self:var UnionFind):seq[int] =
      result = newSeq[int](self.len)
      for p in self: result[self.root(p)] += 1
    proc forestCount():int = F.counts.filterIt(it > 0).len()
    check: F.count(0) == 1
    check: forestCount() == 100

    check: not F.same(10,20)
    check: F.merge(10,20)
    check: F.same(10,20)
    check: not F.merge(10,20)

    check: F.merge(0,20)
    check: F.count(10) == 3
    check: forestCount() == 98

    check: F.merge(11,21)
    check: F.count(11) == 2
    check: forestCount() == 97
  test "monoid+unionfind":
    let a = newSeqWith(10,1)
    var uf = a.newMonoidUnionFind(proc(x,y:int):int = x + y)
    uf.merge(0,8)
    uf.merge(9,8)
    uf.merge(0,5)
    uf.merge(2,3)
    uf.merge(4,6)
    uf.merge(4,8)
    check: toSeq(0..9).mapIt(uf.rootElem(it)) == @[6, 1, 2, 2, 6, 6, 6, 1, 6, 6]
