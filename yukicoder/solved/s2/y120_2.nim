import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

import algorithm
type BinaryHeap*[T] = ref object
  data*: seq[T]
  cmp*:proc(x,y:T):int
proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc `[]`[T](heap: BinaryHeap[T], i: Natural): T {.inline.}= heap.data[i]
proc siftdown[T](heap: var BinaryHeap[T], startpos, p: int) =
  var pos = p
  var newitem = heap[pos]
  while pos > startpos:
    let parentpos = (pos - 1) shr 1
    let parent = heap[parentpos]
    if 0 <= heap.cmp(newitem, parent): break
    heap.data[pos] = parent
    pos = parentpos
  heap.data[pos] = newitem
proc siftup[T](heap: var BinaryHeap[T], p: int) =
  let endpos = len(heap)
  var pos = p
  let startpos = pos
  let newitem = heap[pos]
  var childpos = 2*pos + 1
  while childpos < endpos:
    let rightpos = childpos + 1
    if rightpos < endpos and 0 <= heap.cmp(heap[childpos], heap[rightpos]):
      childpos = rightpos
    heap.data[pos] = heap[childpos]
    pos = childpos
    childpos = 2*pos + 1
  heap.data[pos] = newitem
  siftdown(heap, startpos, pos)

proc len*[T](heap: BinaryHeap[T]): int = heap.data.len
proc push*[T](heap: var BinaryHeap[T], item: T) =
  heap.data.add(item)
  siftdown(heap, 0, len(heap)-1)
proc pop*[T](heap: var BinaryHeap[T]): T =
  let lastelt = heap.data.pop()
  if heap.len > 0:
    result = heap[0]
    heap.data[0] = lastelt
    siftup(heap, 0)
  else:
    result = lastelt
proc top*[T](heap: var BinaryHeap[T]): T = heap.data[0]
proc poppush*[T](heap: var BinaryHeap[T], item: T): T =
  result = heap[0]
  heap.data[0] = item
  siftup(heap, 0)
proc pushpop*[T](heap: var BinaryHeap[T], item: T): T =
  if heap.len > 0 and 0 > heap.cmp(heap[0], item):
    swap(item, heap[0])
    siftup(heap, 0)
  return item
proc clear*[T](heap: var BinaryHeap[T]) = heap.data.setLen(0)
proc toSeq*[T](heap: BinaryHeap[T]): seq[T] = heap.data.sorted(cmp)
proc `$`*[T](heap: BinaryHeap[T]): string = $heap.toSeq()
iterator items*[T](heap:BinaryHeap[T]) : T =
  for v in heap.toSeq(): yield v
proc newBinaryHeap*[T](cmp:proc(x,y:T):int) : BinaryHeap[T]=
  new(result)
  result.data = @[]
  result.cmp = cmp

var q = newBinaryHeap[int](revcmp)

proc solve() : int =
  let n = scan()
  var L = newSeq[int](n)
  for i in 0..<n: L[i] = scan()
  L.sort(cmp)
  var R = @[1]
  for i in 1..<n:
    if L[i-1] == L[i] : R[^1] += 1
    else: R .add 1
  if R.len < 3: return 0
  q.clear()
  for r in R: q.push(r)
  while true:
    let a = q.pop() - 1
    let b = q.pop() - 1
    let c = q.pop() - 1
    if a < 0 or b < 0 or c < 0 : return
    result += 1
    q.push(b)
    q.push(c)
    q.push(a)

scan().times: echo solve()
