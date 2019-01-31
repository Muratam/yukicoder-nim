import sequtils,intsets
# import ,math,tables
# import sets,,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

template useUnionFind() =
  type UnionFind[T] = object
    parent : seq[T]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    return self.root(self.parent[x])
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc merge[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    var rx = self.root(sx)
    var ry = self.root(sy)
    if rx == ry : return false
    if rx > ry : swap(rx,ry)
    self.parent[ry] = rx
    return true
useUnionFind()

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

# 先に全部壊しておいて逆に直していく
let n = scan() # 1e5
let m = scan() # 2e5
let q = scan() # 1e5
var E = newSeqWith(n,newSeq[int]())
m.times:
  let a = scan() - 1
  let b = scan() - 1
  E[a] &= b
  E[b] &= a
var F = newSeqWith(n,newSeq[int]())
let CD = newSeqWith(q,(scan()-1,scan()-1))
for cd in CD:
  let (c,d) = cd
  F[c] &= d
  F[d] &= c
var uf = initUnionFind[int](n)
var ans = newSeqWith(n,-1)
for i in 0..<n:
  var I = initIntSet()
  for e in E[i]: I.incl e
  for f in F[i]: I.excl f
  for j in I: uf.merge(i,j)
  echo I
var nodes = newSeqWith(n,newSeq[int]())
for i in (q-1).countdown(0):
  let (c,d) = CD[i]
  if uf.same(c,0): ans[d] = i + 1
  elif uf.same(d,0): ans[c] = i + 1
  else: uf.merge(c,d)
for i in 0..<n: discard uf.root(i)
echo uf
echo ans