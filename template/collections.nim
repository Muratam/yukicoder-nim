template QuickBinaryHeap():untyped =
  # 一回分のpop->pushの動作を遅延するので頻繁に削除と追加を刷る場合早いHeap
  type
    Heap*[T] = object
      nodes: seq[T]
      compare: proc(x,y:T):int
      popchunk: bool
  proc newHeap*[T](compare:proc(x,y:T):int): Heap[T] =
    Heap[T](nodes:newSeq[T](),compare:compare,popchunk:false)
  proc compareNode[T](h:Heap[T],i,j:int):int = h.compare(h.nodes[i],h.nodes[j])
  proc size*[T](h:Heap[T]):int = h.nodes.len() - h.popchunk.int
  proc items*[T](h:var Heap[T]):seq[T] =
    if h.popchunk : discard h.popimpl()
    return h.nodes
  proc top*[T](h:var Heap[T]): T =
    if h.popchunk : discard h.popimpl()
    return h.nodes[0]
  proc push*[T](h:var Heap[T],node:T):void =
    if h.popchunk :
      h.nodes[0] = node
      h.shiftdown()
    else: h.pushimpl(node)
  proc pop[T](h:var Heap[T]):T =
    if h.popchunk:
      discard h.popimpl()
    h.popchunk = true
    return h.nodes[0]

  proc shiftdown*[T](h:var Heap[T]): void =
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

  proc pushimpl*[T](h:var Heap[T],node:T):void =
    h.nodes.add(node) #末尾に追加
    var i = h.nodes.len() - 1
    while i > 0: # 末尾から木を整形
      let parent = (i - 1) div 2
      if h.compare(h.nodes[parent],node) <= 0: break
      h.nodes[i] = h.nodes[parent]
      i = parent
    h.nodes[i] = node

  proc popimpl[T](h:var Heap[T]):T =
    result = h.nodes[0] # rootと末尾を入れ替えて木を整形
    h.nodes[0] = h.nodes[^1]
    h.nodes.setLen(h.nodes.len() - 1)
    h.shiftdown()

