import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

import math
type
  Queue*  [T] = object ## A queue.
    data: seq[T]
    rd, wr, count, mask: int

proc initQueue*[T](initialSize: int = 4): Queue[T] =
  assert isPowerOfTwo(initialSize)
  result.mask = initialSize-1
  newSeq(result.data, initialSize)
proc len*[T](q: Queue[T]): int {.inline.}= result = q.count
proc front*[T](q: Queue[T]): T {.inline.}=
  result = q.data[q.rd]
proc back*[T](q: Queue[T]): T {.inline.} =
  result = q.data[q.wr - 1 and q.mask]
proc `[]`*[T](q: Queue[T], i: Natural) : T {.inline.} =
  return q.data[q.rd + i and q.mask]
proc `[]`*[T](q: var Queue[T], i: Natural): var T {.inline.} =
  return q.data[q.rd + i and q.mask]
proc `[]=`* [T] (q: var Queue[T], i: Natural, val : T) {.inline.} =
  q.data[q.rd + i and q.mask] = val
iterator items*[T](q: Queue[T]): T =
  var i = q.rd
  for c in 0 ..< q.count:
    yield q.data[i]
    i = (i + 1) and q.mask
iterator pairs*[T](q: Queue[T]): tuple[key: int, val: T] =
  var i = q.rd
  for c in 0 ..< q.count:
    yield (c, q.data[i])
    i = (i + 1) and q.mask
proc add*[T](q: var Queue[T], item: T) =
  var cap = q.mask+1
  if unlikely(q.count >= cap):
    var n = newSeq[T](cap*2)
    for i, x in pairs(q):  # don't use copyMem because the GC and because it's slower.
      shallowCopy(n[i], x)
    shallowCopy(q.data, n)
    q.mask = cap*2 - 1
    q.wr = q.count
    q.rd = 0
  inc q.count
  q.data[q.wr] = item
  q.wr = (q.wr + 1) and q.mask
template default[T](t: typedesc[T]): T =
  var v: T
  v
proc pop*[T](q: var Queue[T]): T {.inline, discardable.} =
  dec q.count
  result = q.data[q.rd]
  q.data[q.rd] = default(type(result))
  q.rd = (q.rd + 1) and q.mask
proc enqueue*[T](q: var Queue[T], item: T) =  q.add(item)
proc dequeue*[T](q: var Queue[T]): T =  q.pop()

proc `$`*[T](q: Queue[T]): string =
  result = "["
  for x in items(q):  # Don't remove the items here for reasons that don't fit in this margin.
    if result.len > 1: result.add(", ")
    result.add($x)
  result.add("]")


# SPFA (ベルマンフォード) O(EV) : 二点間の最短路(負の閉路でも動作)
const INF = 1e12.int
type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)

proc SPFA(E:seq[seq[Edge]],start:int,dirty:var seq[bool]): seq[int] =
  # import queues
  # 負の閉路検出が可能な単一始点最短路 : O(EV)
  result = newSeqWith(E.len,INF)
  var P = newSeq[bool](E.len)
  var C = newSeq[int](E.len)
  var q = initQueue[int]()
  q.enqueue(start)
  result[start] = 0
  P[start] = true
  C[start] += 1
  while q.len > 0:
    let src = q.pop()
    P[src] = false
    for e in E[src]:
      if dirty[src] :
        dirty[e.dst] = true
      if result[src] + e.cost >= result[e.dst] : continue
      result[e.dst] = result[src] + e.cost
      if P[e.dst] : continue
      C[e.dst] += 1
      P[e.dst] = true
      if C[e.dst] - 1 >= E.len : # 負の閉路のときは追加しない
        result[e.dst] = INF
        dirty[e.dst] = true
        continue
      q.enqueue(e.dst)



let n = scan()
let m = scan()
let p = scan()
var E = newSeqWith(n,newSeq[Edge]())
for _ in 0..<m:
  let a = scan() - 1
  let b = scan() - 1
  let c = -(scan() - p)
  E[a].add((b,c))
var dirty = newSeq[bool](E.len)
discard E.SPFA(0,dirty)
let spfa = E.SPFA(0,dirty)
# echo spfa
# echo dirty

let ans = -spfa[n-1]
if dirty[n-1] : echo -1
# if ans == -INF: echo -1
elif ans < 0 : echo 0
else: echo ans
