import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

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


let n = scan()
let m = scan()
let v = n + m - 1
var dsts = newSeqWith(n+1,newSeq[int]())
var srcs = newSeqWith(n+1,newSeq[int]())
v.times:
  let a = scan()
  let b = scan()
  dsts[a].add b
  srcs[b].add a

proc topologicalSort(edges:seq[seq[int]]) : seq[int] =
  # edges : n -> m の隣接リスト
  var visited = newSeqWith(edges.len,0)
  var tsorted = newSeq[int]()
  proc visit(node:int) =
    visited[node] += 1
    if visited[node] > 1: return
    for edge in edges[node]: visit(edge)
    tsorted .add node
  for n in 0..<edges.len: # 孤立点除去 ?
    visit(n)
  return tsorted.filterIt(visited[it] > 1 or edges[it].len > 0)

let topo = dsts.topologicalSort().reversed()
var parents = newSeqWith(n+1,-1)
for t in topo:
  let dst = dsts[t]
  for d in dst:
    parents[d] = t
# echo parents
# var dp = newSeqWith(n+1,-1) # rank
# dp[root] = 0
# type RankAndIndex = tuple[rank,i:int] # rankの低い順に
# var pq = newBinaryHeap[RankAndIndex](proc(x,y:RankAndIndex):int =  x.rank - y.rank)
# pq.push((0,root))
# while pq.size() > 0:
#   let (rank,index) = pq.pop()
#   echo rank," ",index
#   if dp[index] > rank : continue
#   let dst = dsts[index]
#   for d in dst:
#     if dp[d] > rank + 1: continue
#     parents[d] = index
#     if dp[d] == -1: pq.push((rank+1,d))
#     dp[d] = rank + 1
for i in 1..n:
  let p = parents[i]
  if p == -1 : echo 0
  else: echo p