
template useBinaryIndexedTree() =
  type BinaryIndexedTree*[CNT:static[int],T] = object
    data: array[CNT,T] # 引数以下の部分和(Fenwick Tree)
  proc len*[CNT,T](bit:BinaryIndexedTree[CNT,T]): int = bit.data.len()
  proc update*[CNT,T](bit:var BinaryIndexedTree[CNT,T],i:int,val:T) =
    var i = i
    while i < bit.len():
      bit.data[i] += val
      i = i or (i + 1)
  proc `[]`*[CNT,T](bit:BinaryIndexedTree[CNT,T],i:int): T =
    var i = i
    while i >= 0:
      result += bit.data[i]
      i = (i and (i + 1)) - 1
  proc `$`*[CNT,T](bit:BinaryIndexedTree[CNT,T]): string =
    result = "["
    for i in 0..<bit.len.min(100): result &= $(bit[i]) & ", "
    return result[0..result.len()-2] & (if bit.len > 100 : " ...]" else: "]")

template useBinaryHeap() =
  type
    BinaryHeap*[T] = object
      nodes: seq[T]
      compare: proc(x,y:T):int
      popchunk: bool
  proc newBinaryHeap*[T](compare:proc(x,y:T):int): BinaryHeap[T] =
    BinaryHeap[T](nodes:newSeq[T](),compare:compare,popchunk:false)
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

template useUnionFind() =
  type UnionFind[T] = object
    parent : seq[T]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc merge[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    var rx = self.root(sx)
    var ry = self.root(sy)
    if rx == ry : return false
    if self.parent[ry] < self.parent[rx] : swap(rx,ry)
    if self.parent[rx] == self.parent[ry] : self.parent[rx] -= 1
    self.parent[ry] = rx
    return true

template useSegmentTree() = discard
  # 区間[s,t]の最小値 O(log(N))
  # 1箇所の値変更 O(log(N))
  # Sparse Table は 初期化O(nlog(n)) / 探索 O(log(log(n)))
  # 多次元のBIT

#            | ordered | operate | Type | init/new |   key   |
# ------------------------------------------------------------
#   intset   |         |         | bool |   init   |   int   |
#    set     |         |  + - *  | bool |          |  int8   |
#  hashset   |    o    |  + - *  | bool |   init   |    *    |
# countTable |    o    |         | int  |   init   |    *    |
#   table    |         |         |  *   |   new    |    *    |
#  critbits  |         | prefix  |  *   |          | string  |

template useStack() = # consider using deques queues
  type Stack*[T] = ref object
    data: seq[T]
    size: int
    index: int
  proc newStack*[T](size: int = 64): Stack[T] =
    new(result)
    result.data = newSeq[T](size)
    result.size = size
    result.index = -1
  proc deepCopy*[T](self: Stack[T]): Stack[T] =
    new(result)
    result.size = self.size
    result.index = self.index
    result.data = self.data
  proc isEmpty*[T](self: Stack[T]): bool = self.index < 0
  proc isValid*[T](self: Stack[T]): bool = self.index >= 0 and
      self.index < self.size
  proc len*[T](self: Stack[T]): int =
    if self.isEmpty(): return 0
    return self.index + 1
  proc top*[T](self: Stack[T]): T =
    assert self.isValid()
    return self.data[self.index]
  proc pop*[T](self: var Stack[T]): T {.discardable.} =
    assert self.index >= 0
    result = self.top()
    self.index -= 1
  proc push*[T](self: var Stack[T], elem: T) =
    self.index += 1
    if self.index < self.size:
      self.data[self.index] = elem
    else:
      self.data.add(elem)
      self.size += 1
  proc `$`*[T](self: Stack[T]): string = $(self.data[..self.index])
