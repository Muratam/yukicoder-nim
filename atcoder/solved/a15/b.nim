import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  var minus = false
  block:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    else: result = 10 * result + k.ord - '0'.ord
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1


let n = scan()
let XY = newSeqWith(n,(x:scan(),y:scan()))
if n <= 2:
  echo 1
  quit 0

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
  for i in 0..<self.parent.len:
    result[self.root(i)] += 1


proc solve(p,q:int) :int =
  var uf = newUnionFind[int](n)
  for i in 0..<n:
    for j in (i+1)..<n:
      let p1 = XY[i].x - XY[j].x
      let q1 = XY[i].y - XY[j].y
      if (p1 == p and q1 == q) or (p1 == -p and q1 == -q):
        uf.merge(i,j)
  return uf.counts.filterIt(it > 0).len


var ans = 1e12.int
for i in 0..<n:
  for j in (i+1)..<n:
    let p = XY[i].x - XY[j].x
    let q = XY[i].y - XY[j].y
    ans .min= solve(p,q)
echo ans
