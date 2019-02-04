import sequtils,queues
# import algorithm,math,tables
# import times,macros,queues,bitops,strutils,intsets,sets
# import rationals,critbits,ropes,nre,pegs,complex,stats,heapqueue,sugar
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
# template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)

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

useBinaryHeap()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

type Edge = tuple[dst,cap,cost,rev:int]
proc initFlow(maxSize:int):seq[seq[Edge]] = newSeqWith(maxSize,newSeq[Edge]())
proc add(G:var seq[seq[Edge]],src,dst,cap,cost:int) =
  G[src].add((dst,cap,cost,G[dst].len))
  G[dst].add((src,0,-cost,G[src].len - 1))
proc minCostFlow(E:var seq[seq[Edge]],start,goal,flow:int): int = # O(FElogV)
  # start -> goal へ flow 流した時の最小費用流
  # 最短経路を求め,最短経路に目一杯流す
  # 注意 : ダイクストラなので負の閉路があった場合は不可能
  const INF = 1e10.int
  var flow = flow
  var prev = newSeq[tuple[src,index:int]](E.len) # 直前の辺
  var H = newSeq[int](E.len) # ポテンシャル
  proc dijkestra(E:var seq[seq[Edge]]): seq[int] =
    type P = tuple[len,src:int] # 最短距離と頂点番号
    result = newSeqWith(E.len,INF)
    var pq = newBinaryHeap[P](
      proc(x,y:P):int = (if x.len != y.len : x.len - y.len else: x.src - y.src))
    pq.push((0,start))
    result[start] = 0
    while pq.size > 0:
      let p = pq.pop()
      if result[p.src] < p.len : continue
      for i,e in E[p.src]:
        if e.cap <= 0 : continue
        let next = result[p.src] + e.cost + H[p.src] - H[e.dst]
        if result[e.dst] <= next : continue
        result[e.dst] = next
        prev[e.dst] = (p.src,i)
        pq.push((result[e.dst],e.dst))

  while flow > 0: # ダイクストラでHを更新
    let D = E.dijkestra()
    if D[goal] == INF : return -1 # 流せない
    for i in 0..<E.len:H[i] += D[i]
    # 最短経路に目一杯流す
    var d = flow
    var v = goal
    while v != start:
      d = d.min(E[prev[v].src][prev[v].index].cap)
      v = prev[v].src
    flow -= d
    result += d * H[goal]
    v = goal
    while v != start:
      E[prev[v].src][prev[v].index].cap -= d
      E[v][E[prev[v].src][prev[v].index].rev].cap += d
      v = prev[v].src

# 最小費用流
let start = 0
let goal = 1
let r = scan() # 2 -> @900
let g = scan() # 3 -> @1000
let b = scan() # 4 -> @1100
let (rn,gn,bn) = (2,3,4)
let n = 2000
var E = newSeqWith(n,newSeq[Edge]())
let flow = r + g + b
E.add(start,rn,r,0)
E.add(start,gn,g,0)
E.add(start,bn,b,0)
for i in 5..1995:
  E.add(rn,i,1,abs(900-i))
  E.add(gn,i,1,abs(1000-i))
  E.add(bn,i,1,abs(1100-i))
  E.add(i,goal,1,0)
echo E.minCostFlow(start,goal,flow)