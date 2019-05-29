import sequtils,algorithm
# import ,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

# SCC:強連結成分分解 O(V+E)
type Graph = object
  graph : seq[seq[int]] # 隣接リスト
  rev : seq[seq[int]] # 逆
proc initGraph(maxSize:int):Graph =
  result.graph = newSeqWith(maxSize,newSeq[int]())
  result.rev = newSeqWith(maxSize,newSeq[int]())
proc add(G:var Graph,src,dst:int) =
  G.graph[src] &= dst
  G.rev[dst] &= src
# 属する強連結成分のトポロジカル順の頂点番号を返却(サイクル順)
proc storonglyConnectedComponentDecomposition(G:Graph) : seq[seq[int]] =
  var used = newSeq[bool](G.graph.len)
  var postOrders = newSeq[int]() # 帰りがけ順
  var orders = newSeq[seq[int]]()
  proc dfs(src:int) =
    used[src] = true
    for dst in G.graph[src]:
      if not used[dst] : dfs(dst)
    postOrders &= src
  proc rdfs(src,k:int) =
    used[src] = true
    orders[^1] &= src
    for dst in G.rev[src]:
      if not used[dst] : rdfs(dst,k)
  for v in 0..<G.graph.len:
    if not used[v] : dfs(v)
  used = newSeq[bool](G.graph.len)
  var order = 0
  for i in (postOrders.len()-1).countdown(0):
    if used[postOrders[i]] : continue
    orders &= @[]
    rdfs(postOrders[i],order)
    orders[^1].reverse()
    order += 1
  return orders



proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let h = scan()
let w = scan()
var SAT = initTwoSAT(h*w)
for x in 0..<w:
  SAT.add((l,true) -> (r,true))
for y in 0..<h:
  let l = scan()
  let r = scan()
  SAT.add((l,true) -> (r,true))
