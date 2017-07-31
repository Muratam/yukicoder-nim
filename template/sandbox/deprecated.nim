
template BinaryHeap():untyped =
  type
    Heap*[T] = object
      nodes: seq[T]
      compare: proc(x,y:T):int
  proc newHeap*[T](compare:proc(x,y:T):int): Heap[T] =
    Heap[T](nodes:newSeq[T](),compare:compare)
  proc size*[T](h:Heap[T]):int = h.nodes.len()
  proc items*[T](h:Heap[T]):seq[T] = h.nodes.sorted(h.compare) # TODO ASC?
  proc peek*[T](h:Heap[T]): T = h.nodes[0]
  proc push*[T](h:var Heap[T],node:T):void =
    h.nodes.add(node) #末尾に追加
    var i = h.nodes.len() - 1
    while i > 0: # 末尾から木を整形
      let parent = (i - 1) div 2
      if h.compare(h.nodes[parent],h.nodes[i]) <= 0: break
      swap(h.nodes[i],h.nodes[parent])
      i = parent
  proc pop*[T](h:var Heap[T]):T =
    if h.size <= 0: raise newException(Exception,"heap is empty")
    result = h.nodes[0] # rootと末尾を入れ替えて木を整形
    h.nodes[0] = h.nodes[^1]
    h.nodes.setLen(h.nodes.len() - 1)
    let size = h.nodes.len()
    var i = 0
    while true :
      let L = i * 2 + 1
      let R = i * 2 + 2
      if L >= size : break
      let child = if R < size and h.compare(h.nodes[R],h.nodes[L]) <= 0 : R else: L
      if h.compare(h.nodes[i],h.nodes[child]) <= 0: break
      swap(h.nodes[i],h.nodes[child])
      i = child

template CBinaryHeap():untyped =
  type
    # 左から大きい順にソート
    CPriorityQueue {.importcpp: "std::priority_queue", header: "<queue>".} [T] = object
    CPair {.importcpp: "std::pair", header: "<utility>".} [T1,T2] = object
  proc cNewPriorityQueue(T: typedesc): CPriorityQueue[T]
    {.importcpp: "std::priority_queue<'*1>()", nodecl.}
  proc cMakePair[T1,T2](t1:T1,t2:T2):CPair[T1,T2]
    {.importcpp: "std::make_pair(@)", nodecl.}
  proc first[T1,T2](this: CPair[T1,T2]): T1 {.importcpp: "#.first", nodecl.}
  proc second[T1,T2](this: CPair[T1,T2]): T2 {.importcpp: "#.second", nodecl.}
  proc cpop[T](this: CPriorityQueue[T]) {.importcpp: "#.pop(@)", nodecl.}
  proc newPriorityQueue*[T](): CPriorityQueue[T] = cNewPriorityQueue(T)
  proc empty*[T](this:CPriorityQueue[T]):bool {.importcpp: "#.empty(@)", nodecl.}
  proc size*[T](this:CPriorityQueue[T]):int {.importcpp: "#.size(@)", nodecl.}
  proc ctop*[T](this: CPriorityQueue[T]):T {.importcpp: "#.top(@)", nodecl.}
  proc top*[T](this: CPriorityQueue[T]):T {.importcpp: "#.top(@)", nodecl.}
  proc push*[T](this: CPriorityQueue[T],x:T) {.importcpp: "#.push(@)", nodecl.}
  proc pop*[T](this:var CPriorityQueue[T]):T =(result = this.top();this.cpop())
  type
    TupledPriorityQueue[T=tuple[U,V]] = object
      queue : CPriorityQueue[]
  newTupledPriorityQueue[(hoge:int,fuga:int)]()
  proc newPriorityQueue*[T1,T2](): CPriorityQueue[CPair[T1,T2]] = cNewPriorityQueue(CPair[T1,T2])
  proc push*[T1,T2](this:var CPriorityQueue[CPair[T1,T2]],x:(T1,T2)): void =
    this.push(cMakePair(x[0],x[1]))
  proc pop*[T1,T2](this:var CPriorityQueue[CPair[T1,T2]]):(T1,T2) =
    let res = this.top();this.cpop();return (res.first,res.second)
  proc top*[T1,T2](this:var CPriorityQueue[CPair[T1,T2]]):(T1,T2) =
    let res = this.ctop();return (res.first,res.second)


template PairingHeap():untyped =
  type
    NodeObj[T] = object
      head,next:ref NodeObj[T]
      key:T
    Node[T] = ref NodeObj[T]
    ParingHeap*[T] = object
      node: Node[T]
  proc initNode*[T](): Node[T] = new(result)
  proc initParingHeap*[T](): ParingHeap[T] = discard
  proc newNode[T](key:T):Node[T] =
    new(result); result.key = key
  proc merge*[T](n1,n2:var Node[T]) :Node[T] =
    if n1 == nil : return n2
    if n2 == nil : return n1
    if cmp[T](n1.key, n2.key) > 0: swap(n1,n2)
    n2.next = n1.head
    n1.head = n2
    return n1
  proc mergeList[T](s:var Node[T]):Node[T] =
    var n = initNode[T]()
    while s != nil:
      var
        a = s
        b :Node[T] = nil
      s = s.next
      a.next = nil
      if s != nil:
        b = s
        s = s.next
        b.next = nil
      a = merge(a,b)
      a.next = n.next
      n.next = a
    while n.next != nil:
      var j = n.next
      n.next = n.next.next
      s = merge(j,s)
    return s
  proc empty*[T](ph:ParingHeap[T]) :bool = ph.node != nil
  proc top*[T](ph:ParingHeap[T]):T = ph.node.key
  proc push*[T](ph:var ParingHeap[T],key:T):void =
    var n = newNode(key)
    ph.node = merge(ph.node,n)
  proc pop*[T](ph:var ParingHeap[T]):T =
    result = ph.top()
    ph.node = mergeList(ph.node.head)

  template itemsListImpl() {.dirty.} =
    yield L.node.key
    var it = L.node.head
    while it != nil:
      yield it.key
      it = it.next
  iterator items*[T](L: ParingHeap[T]): T = itemsListImpl()
