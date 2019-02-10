# セグツリ
template useSegmentTree() = # 区間[s,t)の最小(最大)値 / 更新 O(log(N))
  proc minimpl[T](x,y:T): T = (if x <= y: x else: y)
  proc maximpl[T](x,y:T): T = (if x >= y: x else: y)
  type SegmentTree[T] = ref object
    data:seq[T] # import math
    n : int
    rawSize:int
    infinity: T
    cmp:proc(x,y:T):T
  proc initSegmentTree[T](
      size:int,
      infinity:T = T(1e10),
      cmp: proc (x,y:T):T = minimpl[T]) : SegmentTree[T] =
    new(result)
    result.infinity = infinity
    result.cmp = cmp
    result.n = size.nextPowerOfTwo()
    result.rawSize = size
    result.data = newSeqWith(result.n * 2,result.infinity)
  proc `[]=`[T](self:var SegmentTree[T],i:int,val:T) =
    var i = i + self.n - 1
    self.data[i] = val
    while i > 0:
      i = (i - 1) shr 1
      self.data[i] = self.cmp(self.data[i * 2 + 1],self.data[i * 2 + 2])
  proc queryImpl[T](self:SegmentTree[T],a,b,k,l,r:int) : T =
    if r <= a or b <= l : return self.infinity
    if a <= l and r <= b : return self.data[k]
    let vl = self.queryImpl(a,b,k*2+1,l,(l+r) shr 1)
    let vr = self.queryImpl(a,b,k*2+2,(l+r) shr 1,r)
    return self.cmp(vl,vr)
  proc `[]`[T](self:SegmentTree[T],slice:Slice[int]): T =
    return self.queryImpl(slice.a,slice.b+1,0,0,self.n)

  proc `$`[T](self:SegmentTree[T]): string =
    var arrs : seq[seq[int]] = @[]
    var l = 0
    var r = 1
    while r <= self.data.len:
      arrs &= self.data[l..<r]
      l = l * 2 + 1
      r = r * 2 + 1
    return $arrs
# BIT
template useBinaryIndexedTree() = # 部分和検索 / 更新 O(log(N))
  type BinaryIndexedTree[T] = ref object
    data: seq[T] # 引数以下の部分和(Fenwick Tree)
  proc initBinaryIndexedTree[T](n:int):BinaryIndexedTree[T] =
    new(result)
    result.data = newSeq[T](n)
  proc len[T](self:BinaryIndexedTree[T]): int = self.data.len()
  proc update[T](self:var BinaryIndexedTree[T],i:int,val:T) =
    var i = i
    while i < self.len():
      self.data[i] += val
      i = i or (i + 1)
  proc `[]`[T](self:BinaryIndexedTree[T],i:int): T =
    var i = i
    while i >= 0:
      result += self.data[i]
      i = (i and (i + 1)) - 1
  proc `$`[T](self:BinaryIndexedTree[T]): string =
    result = "["
    for i in 0..<self.len.min(100): result &= $(self[i]) & ", "
    return result[0..result.len()-2] & (if self.len > 100 : " ...]" else: "]")
# スライド最小値
template useSlideMin() = # 固定サイズの最小値を O(1)
  proc slideMin[T](arr:seq[T],width:int,paddingLast:bool = false) : seq[T] =
    let size = if paddingLast : arr.len else: arr.len-width+1
    result = newSeqWith(size,-1)
    var deq = initDeque[int]()
    for i in 0..<arr.len:
      # while deq.len > 0 and arr[deq.peekLast()] >= arr[i] : deq.popLast() # 最小値の場合
      while deq.len > 0 and arr[deq.peekLast()] <= arr[i] : deq.popLast() # 最大値の場合
      deq.addLast(i)
      let l = i - width + 1
      if l < 0:continue
      result[l] = arr[deq.peekFirst()]
      if deq.peekFirst() == l: deq.popFirst()
    if not paddingLast : return
    # 後ろに最後の数字を詰めて同じサイズにする
    for i in arr.len-width+1..<arr.len:
      result[i] = arr[deq.peekFirst()]
      if deq.peekFirst() == i: deq.popFirst()
# PriorytyQueue
template useBinaryHeap() = # 追加 / 最小値検索 / 最小値Pop O(log(N))
  type
    BinaryHeap*[T] = ref object
      nodes: seq[T]
      compare: proc(x,y:T):int
      popchunk: bool
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
# ロリハ
template useRollingHash() = # 構築 O(|S|) / 部分文字列検索 O(1)
  type RollingHash = ref object
    modA,modB : int
    baseA,baseB : int
    A,B: seq[int]  # baseA 進数表示
    AP,BP: seq[int] # pow(baseA,n)
  proc initRollingHash(
      S:string, baseA:int=17, baseB:int=19,
      modA:int=1_0000_0000_7.int, modB:int=1_0000_0000_9.int) : RollingHash =
    new(result)
    result.baseA = baseA
    result.baseB = baseB
    result.modA = modA
    result.modB = modB
    result.A = newSeq[int](S.len + 1)
    result.B = newSeq[int](S.len + 1)
    result.AP = newSeq[int](S.len + 1)
    result.BP = newSeq[int](S.len + 1)
    result.AP[0] = 1
    result.BP[0] = 1
    for i in 0..<S.len: result.A[i+1] = (result.A[i] * baseA + S[i].ord) mod modA
    for i in 0..<S.len: result.B[i+1] = (result.B[i] * baseB + S[i].ord) mod modB
    for i in 0..<S.len: result.AP[i+1] = (result.AP[i] * baseA) mod modA
    for i in 0..<S.len: result.BP[i+1] = (result.BP[i] * baseB) mod modB
  proc hash(self:RollingHash,l,r:int):(int,int) = # [l,r)
    ((self.AP[r-l] * self.A[l] - self.A[r] + self.modA) mod self.modA,
    (self.BP[r-l] * self.B[l] - self.B[r] + self.modB) mod self.modB)
  # 67800 と 678 は 67800 == 678 * 100 で得られる
# Union-Find
template useUnionFind() = # 同一集合の判定/マージ が 実質 O(1)
  type UnionFind[T] = ref object
    parent : seq[T]
  proc initUnionFind[T](size:int) : UnionFind[T] =
    new(result)
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
# stack
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

#            | ordered | operate | Type | init/new |   key   |
# ------------------------------------------------------------
#   intset   |         |         | bool |   init   |   int   |
#    set     |         |  + - *  | bool |          |  int8   |
#  hashset   |    o    |  + - *  | bool |   init   |    *    |
# countTable |    o    |         | int  |   init   |    *    |
#   table    |         |         |  *   |   new    |    *    |
#  critbits  |         | prefix  |  *   |          | string  |
# Sparse Table は 初期化O(nlog(n)) / 探索 O(log(log(n)))
# 多次元のBIT
