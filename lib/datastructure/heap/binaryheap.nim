# BinaryHeap : 追加 / 最小値検索 / 最小値Pop O(log(N)) / (mergeもしたければ skewheap)
# https://github.com/nim-lang/Nim/blob/version-1-0/lib/pure/collections/heapqueue.nim#L58
# pop を１回遅らせる実装の方が速いが(var が付いて)使いにくいのでこちら
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

when isMainModule:
  import unittest
  test "binary heap":
    block: # 最小値
      var pq = newBinaryHeap[int](cmp)
      pq.push(30)
      pq.push(10)
      pq.push(20)
      check: pq.pop() == 10
      check: pq.top() == 20
      check: pq.pop() == 20
      pq.push(0)
      check: pq.pop() == 0
      check: pq.pop() == 30
    block: # 最大値
      var pq = newBinaryHeap[int](revcmp)
      pq.push(30)
      pq.push(10)
      pq.push(20)
      check: pq.pop() == 30
      check: pq.pop() == 20
      pq.push(0)
      check: pq.pop() == 10
      check: pq.pop() == 0
