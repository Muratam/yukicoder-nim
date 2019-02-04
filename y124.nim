import sequtils
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
proc dijkestra(E:seq[seq[int]], start:int) :seq[int] =
  type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
  const INF = 1e10.int
  var costs = newSeqWith(E.len,INF)
  var opens = newBinaryHeap[Edge](proc(a,b:Edge): int = a.cost - b.cost)
  opens.push((start,0))
  while opens.size() > 0:
    let (src,cost) = opens.pop()
    if costs[src] != INF : continue
    costs[src] = cost
    for e in E[src]:
      if costs[e] != INF : continue
      opens.push((e,cost + 1))
  return costs


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let w = scan()
let h = scan()
var M = newSeqWith(w,newSeq[int](h))
for y in 0..<h:
  for x in 0..<w:
    M[x][y] = scan()
if (w + h) mod 2 != 0 : quit "not implemented"
proc encode(x,y:int):int = x * h + y
var E = newSeqWith(w*h,newSeq[int]())
proc check(x1,y1,x2,y2,x3,y3:int):bool =
  if x1 < 0 or x1 >= w : return false
  if x2 < 0 or x2 >= w : return false
  if x3 < 0 or x3 >= w : return false
  if y1 < 0 or y1 >= h : return false
  if y2 < 0 or y2 >= h : return false
  if y3 < 0 or y3 >= h : return false
  let (w1,w2,w3) = (M[x1][y1],M[x2][y2],M[x3][y3])
  if w1 == w3 or w1 == w2 or w2 == w3: return false
  if w1 < w2 and w2 < w3 : return false
  if w1 > w2 and w2 > w3 : return false
  return true
proc append(x1,y1,x2,y2,x3,y3:int):bool {.discardable.}=
  if not check(x1,y1,x2,y2,x3,y3) : return false
  let src = encode(x1,y1)
  let dst = encode(x3,y3)
  E[src] &= dst
  E[dst] &= src
  return true
for x in 0..<w:
  for y in 0..<h:
    if (x + y) mod 2 == 1 : continue
    # 4方向
    append(x,y,x+1,y,x+2,y)
    if not append(x,y,x+1,y,x+1,y+1): append(x,y,x,y+1,x+1,y+1)
    append(x,y,x,y+1,x,y+2)
    if not append(x,y,x+1,y,x+1,y-1): append(x,y,x,y-1,x+1,y-1)
echo E.dijkestra(encode(0,0))
