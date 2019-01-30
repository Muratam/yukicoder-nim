import sequtils
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

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
      let E = i * 2 + 1
      let R = i * 2 + 2
      if E >= size : break
      let child = if R < size and h.compareNode(R,E) <= 0 : R else: E
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
const INF = int.high div 4

# ダイクストラ : O(ElogV) コストが負でないときの(startからの)最短路
type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
proc dijkestra(E:seq[seq[Edge]], start:int) :seq[int] =
  var costs = newSeqWith(E.len,INF)
  var roots = newSeqWith(E.len,"")
  type Root = tuple[dst,cost:int,root:string]
  var opens = newBinaryHeap[Root](
    proc(a,b:Root): int =
    if a.cost != b.cost : return a.cost - b.cost
    if a.root == b.root : return 0
    return if a.root < b.root : 1 else: -1
  )
  opens.push((start,0,""))
  while opens.size() > 0:
    let (src,cost,root) = opens.pop()
    if costs[src] < cost : continue
    costs[src] = cost
    for e in E[src]:
      if costs[e.dst] < cost + e.cost : continue
      roots[e.dst] = roots[src] & chr(src + '0'.ord)
      opens.push((e.dst,cost + e.cost,root & chr(src + '0'.ord)))
  echo roots
  return costs


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
let s = scan()
let g = scan()
var E = newSeqWith(n,newSeq[Edge]())
m.times:
  let a = scan()
  let b = scan()
  let c = scan()
  E[a] &= (b,c)
  E[b] &= (a,c)

echo E.dijkestra(0)