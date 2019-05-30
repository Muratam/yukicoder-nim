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
