import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
# {key: val}.newOrderedTable.
#future: dump  lc[(x,y,z) | (x <- 1..n, y <- x..n, z <- y..n, x*x + y*y == z*z),tuple[a,b,c: int]]

template main(MAIN_BODY:untyped):untyped =
  if isMainModule:
    MAIN_BODY

template iterations():untyped =
  template rep(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template each[T](arr:var seq[T],elem,body:untyped):untyped =
    for _ in 0..<arr.len:(proc (elem:var T):auto = body)(arr[_])


template assignOperators():untyped =
  template `+=`(x,y:typed):void = x = x + y
  template `-=`(x,y:typed):void = x = x - y
  template `*=`(x,y:typed):void = x = x * y
  template `/=`(x,y:typed):void = x = x / y
  template `^=`(x,y:typed):void = x = x xor y
  template `&=`(x,y:typed):void = x = x and y
  template `|=`(x,y:typed):void = x = x or y
  template `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y
  template `max=`(x,y:typed):void = x = max(x,y)
  template `min=`(x,y:typed):void = x = min(x,y)
  template `gcd=`(x,y:typed):void = x = gcd(x,y)
  template `lcm=`(x,y:typed):void = x = lcm(x,y)


template bitOperators():untyped =
  # countBits32 / isPowerOfTwo / nextPowerOfTwo
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4

template mathUtils():untyped =
  proc getIsPrimes(n:int) :seq[bool] =
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false
  proc getPrimes(n:int):seq[int] =
    # [2,3,5,...<n]
    let isPrime = getIsPrimes(n)
    result = newSeq[int](0)
    for i,p in isPrime:
      if p : result.add(i)
  proc power(x,n:int,modulo:int = 0): int =
    #繰り返し二乗法での x ** n
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
    result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
    if modulo > 0: result = result mod modulo

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
