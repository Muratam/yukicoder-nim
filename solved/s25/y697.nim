import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10.int32 * result + k.ord.int32 - '0'.ord.int32

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
  proc unite[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return false
    self.parent[rx] = ry
    return true

template useRankingUnionFind =
  type UnionFind[T] = object
    parent : seq[T]
    rank : seq[int16]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    result.rank = newSeq[int16](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return false
    self.parent[rx] = ry
    if self.rank[rx] < self.rank[ry] : self.parent[rx] = ry
    else:
      self.parent[ry] = rx
      if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
    return true

useUnionFind()
let h = scan()
let w = scan()
var uf = initUnionFind[int32](h * w + 1)
var ans = 0
var i = 1.int32
for y in 0..<h:
  for x in 0..<w:
    if getchar_unlocked() == '1':
      ans += 1
      if x > 0 and uf.parent[i-1] != 0:
        if uf.unite(i,i-1): ans -= 1
      if y > 0 and uf.parent[i-w] != 0:
        if uf.unite(i,i-w): ans -= 1
    else:
      uf.parent[i] = 0
    discard getchar_unlocked()
    i += 1
echo ans


# 普通に実装
# let h = scan()
# let w = scan()
# var isWater : array[3001,array[3001,bool]]
# for y in 0..<h:
#   for x in 0..<w:
#     isWater[x][y] = getchar_unlocked() == '1'
#     discard getchar_unlocked()
# const dx = [1.int3232,-1.int3232,0.int3232,0.int3232]
# const dy = [0.int3232,0.int3232,1.int3232,-1.int3232]
# proc check(sx,sy:int3232)  =
#   var X = initQueue[int3232]()
#   var Y = initQueue[int3232]()
#   X.enqueue(sx)
#   Y.enqueue(sy)
#   isWater[sx][sy] = false
#   while X.len() > 0:
#     let x = X.dequeue()
#     let y = Y.dequeue()
#     template regist(nx,ny:int32) =
#       if isWater[nx][ny] :
#         X.enqueue(nx)
#         Y.enqueue(ny)
#         isWater[nx][ny] = false
#     if x > 0: regist(x-1,y)
#     if y > 0: regist(x,y-1)
#     if x < w-1: regist(x+1,y)
#     if y < h-1: regist(x,y+1)
# var ans = 0
# for x in 0.int3232..<w.int3232:
#   for y in 0.int3232..<h.int3232:
#     if not isWater[x][y]: continue
#     check(x,y)
#     ans += 1
# echo ans