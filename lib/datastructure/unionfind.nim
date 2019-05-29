# Union-Find
# 同一集合の判定/マージ が 実質 O(1)
type UnionFind[T] = ref object
  parent : seq[T]
proc newUnionFind[T](size:int) : UnionFind[T] =
  new(result)
  result.parent = newSeqUninitialized[T](size)
  for i in 0.int32..<size.int32: result.parent[i] = i
proc root[T](self:var UnionFind[T],x:T): T =
  if self.parent[x] == x: return x
  self.parent[x] = self.root(self.parent[x])
  return self.parent[x]
proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
proc merge[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
  var rx = self.root(sx)
  var ry = self.root(sy)
  if rx == ry : return false
  if self.parent[ry] < self.parent[rx] : swap(rx,ry)
  if self.parent[rx] == self.parent[ry] : self.parent[rx] -= 1
  self.parent[ry] = rx
  return true
proc count[T](self:var UnionFind[T],x:T):int = # 各木の要素数
  for p in self.parent:
    if p == self.parent[x]: result += 1
