# ------------------------------------------------------------
#            | ordered | operate | Type | init/new |   key   |
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

template useBinaryIndexedTree() =
  type BinaryIndexedTree*[CNT:static[int],T] = object
    data: array[CNT,T]
  proc `[]`*[CNT,T](bit:BinaryIndexedTree[CNT,T],i:int): T =
    if i == 0 : return bit.data[0]
    result = 0 # 000111122[2]2223333
    var index = i
    while index > 0:
      result += bit.data[index]
      index -= index and -index # 0111 -> 0110 -> 0100
  proc inc*[CNT,T](bit:var BinaryIndexedTree[CNT,T],i:int,val:T) =
    var index = i
    while index < bit.data.len():
      bit.data[index] += val
      index += index and -index # 001101 -> 001110 -> 010001
  proc `$`*[CNT,T](bit:BinaryIndexedTree[CNT,T]): string =
    result = "["
    for i in 0..bit.data.high: result &= $(bit[i]) & ", "
    return result[0..result.len()-2] & "]"
  proc len*[CNT,T](bit:BinaryIndexedTree[CNT,T]): int = bit.data.len()

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

template useUnionFind =
  type UnionFind[T] = object
    parent : seq[T]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return false
    self.parent[rx] = ry
    return true

template useRankingUnionFind =
  type UnionFind[T] = object
    parent : seq[T]
    rank : seq[int16]
  proc root[T](self:var UnionFind[T],x:T): T =
    if self.parent[x] == x: return x
    self.parent[x] = self.root(self.parent[x])
    return self.parent[x]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    result.parent = newSeqUninitialized[T](size)
    result.rank = newSeq[int16](size)
    for i in 0.int32..<size.int32: result.parent[i] = i
  proc same[T](self:var UnionFind[T],x,y:T) : bool = self.root(x) == self.root(y)
  proc unite[T](self:var UnionFind[T],sx,sy:T) : bool {.discardable.} =
    let rx = self.root(sx)
    let ry = self.root(sy)
    if rx == ry : return false
    self.parent[rx] = ry
    if self.rank[rx] < self.rank[ry] : self.parent[rx] = ry
    else:
      self.parent[ry] = rx
      if self.rank[rx] == self.rank[ry]: self.rank[rx] += 1
    return true

