import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

template useUnionFind =
  type UnionFind[T] = object
    parent : seq[T]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](self:var UnionFind[T],sx,sy:T) : T {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return ry
    self.parent[rx] = ry
    return ry
useUnionFind()

let n = scan()
var V = newSeq[int](n)
var uf = initUnionFind[int](n)
var lastRoot = 0
scan().times:
  let a = scan()
  let b = scan()
  V[a] += 1
  V[b] += 1
  lastRoot = uf.unite(a,b)

var oddCount = 0
for i,v in V:
  if v == 0 : continue
  if uf.root(i) != lastRoot : quit "NO",0
  if v mod 2 == 0 : continue
  oddCount += 1
  if oddCount > 2 : quit "NO",0
echo "YES"
