import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord


type UnionFind[T] = ref object
  parent : seq[T]
proc initUnionFind[T](size:int) : UnionFind[T] =
  new(result)
  result.parent = newSeq[T](size)
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


let n = scan()
let m = scan()
var F = initUnionFind[int](n)
var ans = 0
m.times:
  let x = scan() - 1
  let y = scan() - 1
  let z = scan()
  if F.same(x,y) : continue
  F.merge(x,y)
  # echo(x,"->",y)
  ans += 1
# echo ans
echo n - ans
