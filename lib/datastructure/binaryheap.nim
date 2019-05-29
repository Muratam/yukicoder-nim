# PriorytyQueue
# 追加 / 最小値検索 / 最小値Pop O(log(N))
type
  BinaryHeap*[T] = ref object
    nodes: seq[T]
    compare: proc(x,y:T):int
    popchunk: bool

proc revcmp[T](x,y:T):int = cmp[T](y,x)
proc newBinaryHeap*[T](compare:proc(x,y:T):int): BinaryHeap[T] =
  new(result)
  result.nodes = newSeq[T]()
  result.compare = compare
proc compareNode[T](h:BinaryHeap[T],i,j:int):int = h.compare(h.nodes[i],h.nodes[j])
proc size*[T](h:BinaryHeap[T]):int = h.nodes.len() - h.popchunk.int
proc items*[T](h:var BinaryHeap[T]):seq[T] =
  if h.popchunk : discard h.popimpl()
  return h.nodes
proc top*[T](h:var BinaryHeap[T]): T =
  if h.popchunk : discard h.popimpl()
  return h.nodes[0]
proc push*[T](h:var BinaryHeap[T],node:T):void =
  if h.popchunk :
    h.nodes[0] = node
    h.shiftdown()
  else: h.pushimpl(node)
proc pop*[T](h:var BinaryHeap[T]):T =
  if h.popchunk: discard h.popimpl()
  h.popchunk = true
  return h.nodes[0]

proc shiftdown[T](h:var BinaryHeap[T]): void =
  h.popchunk = false
  let size = h.nodes.len()
  var i = 0
  while true :
    let L = i * 2 + 1
    let R = i * 2 + 2
    if L >= size : break
    let child = if R < size and h.compareNode(R,L) <= 0 : R else: L
    if h.compareNode(i,child) <= 0: break
    swap(h.nodes[i],h.nodes[child])
    i = child

proc pushimpl[T](h:var BinaryHeap[T],node:T):void =
  h.nodes.add(node) #末尾に追加
  var i = h.nodes.len() - 1
  while i > 0: # 末尾から木を整形
    let parent = (i - 1) div 2
    if h.compare(h.nodes[parent],node) <= 0: break
    h.nodes[i] = h.nodes[parent]
    i = parent
  h.nodes[i] = node

proc popimpl[T](h:var BinaryHeap[T]):T =
  result = h.nodes[0] # rootと末尾を入れ替えて木を整形
  h.nodes[0] = h.nodes[^1]
  h.nodes.setLen(h.nodes.len() - 1)
  h.shiftdown()


when isMainModule:
  import unittest
  test "binary heap":
    block: # 最小値
      var pq = newBinaryHeap[int](cmp)
      pq.push(30)
      pq.push(10)
      pq.push(20)
      check: pq.pop() == 10
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
