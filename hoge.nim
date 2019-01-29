type UnionFind[T] = object
  parent : seq[T]
proc initUnionFind[T](size:int) : UnionFind[T] =
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

# import random,times
# let f = cpuTime()
# const n = 4000000
# var uf = initUnionFind[int](n+1)
# for _ in 0..n*2:
#   uf.merge(rand(n) div 2,rand(n))
# echo uf.parent[^100..^1]
# echo (cpuTime() - f) * 1000