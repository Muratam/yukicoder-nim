# for old nim
import math, typetraits
type Deque*[T] = object
  data: seq[T]
  head, tail, count, mask: int
proc initDeque*[T](initialSize: int = 4): Deque[T] =
  assert isPowerOfTwo(initialSize)
  result.mask = initialSize-1
  newSeq(result.data, initialSize)
proc len*[T](deq: Deque[T]): int {.inline.} =
  result = deq.count
template emptyCheck(deq) =
  when compileOption("boundChecks"):
    if unlikely(deq.count < 1):
      raise newException(IndexError, "Empty deque.")
template xBoundsCheck(deq, i) =
  when compileOption("boundChecks"):
    if unlikely(i >= deq.count):
      raise newException(IndexError,
                        "Out of bounds: " & $i & " > " & $(deq.count - 1))
proc `[]`*[T](deq: Deque[T], i: Natural) : T {.inline.} =
  xBoundsCheck(deq, i)
  return deq.data[(deq.head + i) and deq.mask]
proc `[]`*[T](deq: var Deque[T], i: Natural): var T {.inline.} =
  xBoundsCheck(deq, i)
  return deq.data[(deq.head + i) and deq.mask]
proc `[]=`* [T] (deq: var Deque[T], i: Natural, val : T) {.inline.} =
  xBoundsCheck(deq, i)
  deq.data[(deq.head + i) and deq.mask] = val
iterator items*[T](deq: Deque[T]): T =
  var i = deq.head
  for c in 0 ..< deq.count:
    yield deq.data[i]
    i = (i + 1) and deq.mask
iterator mitems*[T](deq: var Deque[T]): var T =
  var i = deq.head
  for c in 0 ..< deq.count:
    yield deq.data[i]
    i = (i + 1) and deq.mask
iterator pairs*[T](deq: Deque[T]): tuple[key: int, val: T] =
  var i = deq.head
  for c in 0 ..< deq.count:
    yield (c, deq.data[i])
    i = (i + 1) and deq.mask
proc contains*[T](deq: Deque[T], item: T): bool {.inline.} =
  for e in deq:
    if e == item: return true
  return false
proc expandIfNeeded[T](deq: var Deque[T]) =
  var cap = deq.mask + 1
  if unlikely(deq.count >= cap):
    var n = newSeq[T](cap * 2)
    for i, x in pairs(deq):
      shallowCopy(n[i], x)
    shallowCopy(deq.data, n)
    deq.mask = cap * 2 - 1
    deq.tail = deq.count
    deq.head = 0
proc addFirst*[T](deq: var Deque[T], item: T) =
  expandIfNeeded(deq)
  inc deq.count
  deq.head = (deq.head - 1) and deq.mask
  deq.data[deq.head] = item
proc addLast*[T](deq: var Deque[T], item: T) =
  expandIfNeeded(deq)
  inc deq.count
  deq.data[deq.tail] = item
  deq.tail = (deq.tail + 1) and deq.mask
proc peekFirst*[T](deq: Deque[T]): T {.inline.}=
  emptyCheck(deq)
  result = deq.data[deq.head]
proc peekLast*[T](deq: Deque[T]): T {.inline.} =
  emptyCheck(deq)
  result = deq.data[(deq.tail - 1) and deq.mask]
template destroy(x: untyped) =
  reset(x)
proc popFirst*[T](deq: var Deque[T]): T {.inline, discardable.} =
  emptyCheck(deq)
  dec deq.count
  result = deq.data[deq.head]
  destroy(deq.data[deq.head])
  deq.head = (deq.head + 1) and deq.mask
proc popLast*[T](deq: var Deque[T]): T {.inline, discardable.} =
  emptyCheck(deq)
  dec deq.count
  deq.tail = (deq.tail - 1) and deq.mask
  result = deq.data[deq.tail]
  destroy(deq.data[deq.tail])
proc clear*[T](deq: var Deque[T]) {.inline.} =
  for el in mitems(deq): destroy(el)
  deq.count = 0
  deq.tail = deq.head
proc shrink*[T](deq: var Deque[T], fromFirst = 0, fromLast = 0) =
  if fromFirst + fromLast > deq.count:
    clear(deq)
    return
  for i in 0 ..< fromFirst:
    destroy(deq.data[deq.head])
    deq.head = (deq.head + 1) and deq.mask
  for i in 0 ..< fromLast:
    destroy(deq.data[deq.tail])
    deq.tail = (deq.tail - 1) and deq.mask
  dec deq.count, fromFirst + fromLast
proc `$`*[T](deq: Deque[T]): string =
  result = "["
  for x in deq:
    if result.len > 1: result.add(", ")
    result.add $x
  result.add("]")
