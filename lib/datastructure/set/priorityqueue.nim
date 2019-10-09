# PriorityQueue :
# O(log(N)): 追加 / 最小値Pop
# O(1) : 最小値取得
# https://github.com/nim-lang/Nim/blob/version-1-0/lib/pure/collections/heapqueue.nim#L58
# pop を１回遅らせる実装の方が速いが(var が付いて)使いにくいのでこちら

import algorithm
type PriorityQueue*[T] = ref object
  data*: seq[T]
  cmp*:proc(x,y:T):int{.noSideEffect.}
proc ascending*[T](x,y:T):int{.noSideEffect.} = (x - y).int # 最小値
proc descending*[T](x,y:T):int{.noSideEffect.} = (y - x).int # 最大値
proc `[]`[T](heap: PriorityQueue[T], i: Natural): T {.inline.}= heap.data[i]
proc siftdown[T](heap: var PriorityQueue[T], startpos, p: int) =
  var pos = p
  var newitem = heap[pos]
  while pos > startpos:
    let parentpos = (pos - 1) shr 1
    let parent = heap[parentpos]
    if 0 <= heap.cmp(newitem, parent): break
    heap.data[pos] = parent
    pos = parentpos
  heap.data[pos] = newitem
proc siftup[T](heap: var PriorityQueue[T], p: int) =
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
proc len*[T](heap: PriorityQueue[T]): int = heap.data.len
proc push*[T](heap: var PriorityQueue[T], item: T) =
  heap.data.add(item)
  siftdown(heap, 0, len(heap)-1)
proc pop*[T](heap: var PriorityQueue[T]): T {.discardable.} =
  let lastelt = heap.data.pop()
  if heap.len > 0:
    result = heap[0]
    heap.data[0] = lastelt
    siftup(heap, 0)
  else:
    result = lastelt
proc top*[T](heap: var PriorityQueue[T]): T = heap.data[0]
proc poppush*[T](heap: var PriorityQueue[T], item: T): T =
  result = heap[0]
  heap.data[0] = item
  siftup(heap, 0)
proc pushpop*[T](heap: var PriorityQueue[T], item: T): T =
  if heap.len > 0 and 0 > heap.cmp(heap[0], item):
    swap(item, heap[0])
    siftup(heap, 0)
  return item
proc clear*[T](heap: var PriorityQueue[T]) = heap.data.setLen(0)
proc toSequence*[T](heap: PriorityQueue[T]): seq[T] = heap.data.sorted(cmp)
proc `$`*[T](heap: PriorityQueue[T]): string = $heap.toSequence()
iterator items*[T](heap:PriorityQueue[T]) : T =
  for v in heap.toSequence(): yield v
proc newPriorityQueue*[T](cmp:proc(x,y:T):int{.noSideEffect.}) : PriorityQueue[T]=
  new(result)
  result.data = @[]
  result.cmp = cmp

when isMainModule:
  import unittest
  test "Priority Queue":
    block: # 最小値
      var pq = newPriorityQueue[int](ascending)
      pq.push(30)
      pq.push(10)
      pq.push(20)
      check: pq.pop() == 10
      check: pq.top() == 20
      check: pq.pop() == 20
      pq.push(0)
      check: pq.pop() == 0
      check: pq.pop() == 30
      var pq2 = newPriorityQueue[int](proc(x,y:int):int = x - y)
      pq2.push(30)
      pq2.push(10)
      pq2.push(20)
      check: pq2.pop() == 10
      check: pq2.top() == 20
      check: pq2.pop() == 20
      pq2.push(0)
      check: pq2.pop() == 0
      check: pq2.pop() == 30

    block: # 最大値
      var pq = newPriorityQueue[int](descending)
      pq.push(30)
      pq.push(10)
      pq.push(20)
      check: pq.pop() == 30
      check: pq.pop() == 20
      pq.push(0)
      check: pq.pop() == 10
      check: pq.pop() == 0
