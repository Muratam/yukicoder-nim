# 公式と同じ distinct seq なので使いにくいがかなり速い。
# verified : https://atcoder.jp/contests/abc141/tasks/abc141_d
# https://atcoder.jp/contests/abc141/submissions/7551477
type HeapQueue*[T] = distinct seq[T]
proc newHeapQueue*[T](): HeapQueue[T] {.inline.} = HeapQueue[T](newSeq[T]())
proc newHeapQueue*[T](h: var HeapQueue[T]) {.inline.} = h = HeapQueue[T](newSeq[T]())
proc `[]`[T](h: HeapQueue[T], i: int): T {.inline.} = seq[T](h)[i]
proc `[]=`[T](h: var HeapQueue[T], i: int,v: T) {.inline.} = seq[T](h)[i] = v
proc add[T](h: var HeapQueue[T], v: T) {.inline.} = seq[T](h).add(v)
proc heapCmp[T](x, y: T): bool {.inline.} = (x > y)
proc siftdown[T](heap: var HeapQueue[T], startpos, p: int) =
  var pos = p
  var newitem = heap[pos]
  while pos > startpos:
    let parentpos = (pos - 1) shr 1
    let parent = heap[parentpos]
    if heapCmp(newitem, parent):
      heap[pos] = parent
      pos = parentpos
    else: break
  heap[pos] = newitem
proc siftup[T](heap: var HeapQueue[T], p: int) =
  let endpos = len(heap)
  var pos = p
  let startpos = pos
  let newitem = heap[pos]
  var childpos = 2*pos + 1
  while childpos < endpos:
    let rightpos = childpos + 1
    if rightpos < endpos and not heapCmp(heap[childpos], heap[rightpos]):
      childpos = rightpos
    heap[pos] = heap[childpos]
    pos = childpos
    childpos = 2*pos + 1
  heap[pos] = newitem
  siftdown(heap, startpos, pos)
proc len*[T](h: HeapQueue[T]): int {.inline.} = seq[T](h).len
proc push*[T](heap: var HeapQueue[T], item: T) =
  (seq[T](heap)).add(item)
  siftdown(heap, 0, len(heap)-1)
proc top*[T](heap:var HeapQueue[T]):T = seq[T](heap)[0]
proc pop*[T](heap: var HeapQueue[T]): T =
  let lastelt = seq[T](heap).pop()
  if heap.len > 0:
    result = heap[0]
    heap[0] = lastelt
    siftup(heap, 0)
  else:
    result = lastelt
proc poppush*[T](heap: var HeapQueue[T], item: T) =
  heap[0] = item
  siftup(heap, 0)
proc pushpop*[T](heap: var HeapQueue[T], item: T): T =
  if heap.len > 0 and heapCmp(heap[0], item):
    swap(item, heap[0])
    siftup(heap, 0)
  return item
# for x in seq[T](heap): # アイテムを全て(順序に関係なく)走査する時の書き方
# if false:
#   let n = scan()
#   let m = scan()
#   var pq = newHeapQueue[int]()
#   n.times: pq.push(scan())
#   m.times: pq.poppush(pq.top() shr 1)
#   var ans = 0
#   for x in seq[int](pq): ans += x
#   echo ans
