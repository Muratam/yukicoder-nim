# Union-Find
# 同一集合の判定/マージ が 実質 O(1)
# 0..<n までの要素を管理する
type UnionFind[T] = ref object
  parent : seq[T]
proc newUnionFind*[T](size:int) : UnionFind[T] =
  new(result)
  when NimMajor == 0 and NimMinor <= 18: result.parent = newSeq[T](size)
  else: result.parent = newSeqUninitialized[T](size)
  for i in 0.int32..<size.int32: result.parent[i] = i
proc root*[T](self:var UnionFind[T],x:T): T =
  if self.parent[x] == x: return x
  self.parent[x] = self.root(self.parent[x])
  return self.parent[x]
proc same*[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
proc merge*[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
  var rx = self.root(sx)
  var ry = self.root(sy)
  if rx == ry : return false
  if self.parent[ry] < self.parent[rx] : swap(rx,ry)
  if self.parent[rx] == self.parent[ry] : self.parent[rx] -= 1
  self.parent[ry] = rx
  return true
proc count*[T](self:var UnionFind[T],x:T):int = # 木毎の要素数(最初は全て1)
  let root = self.root(x)
  for p in self.parent:
    if self.root(p) == root: result += 1
proc counts*[T](self:var UnionFind[T]):seq[int] =
  result = newSeq[int](self.parent.len)
  for p in self.parent: result[self.root(p)] += 1


when isMainModule:
  import unittest
  import sequtils
  test "unionfind":
    var F = newUnionFind[int](100)
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
