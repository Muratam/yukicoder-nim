import sequtils,algorithm,math
template `max=`*(x,y) = x = max(x,y)

template useUnionFind() =
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

useUnionFind()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type Edge = tuple[cost,src,dst:int]
proc kruskal(E:seq[Edge],maxN:int) : int = #  0..<maxN, unionfind
  # 最小全域木 とそのコストを返却
  var uf = initUnionFind[int](maxN)
  for e in E.sortedByIt(it.cost):
    if uf.same(e.src,e.dst) : continue
    uf.merge(e.src,e.dst)
    result .max= e.cost
    if uf.same(0,maxN-1): break # 繋げたい点があれば


let n = scan()
var X = newSeq[int](n)
var Y = newSeq[int](n)
for i in 0..<n:
  X[i] = scan()
  Y[i] = scan()
var E = newSeq[Edge]()
for a in 0..<n:
  for b in (a+1)..<n:
    var d = (X[a] - X[b])*(X[a] - X[b])
    d += (Y[a] - Y[b])*(Y[a] - Y[b])
    E &= (d,a,b)

let ans = E.kruskal(n)
for i in ans.float.sqrt.int..int.high:
  var i = i div 10 * 10
  if i * i < ans : continue
  quit $i,0