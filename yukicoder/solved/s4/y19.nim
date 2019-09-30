import sequtils,algorithm

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

proc argMin[T](arr:seq[T]):int =
  result = 0
  var val = arr[0]
  for i,a in arr:
    if a >= val: continue
    val = a
    result = i

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var G = initGraph(n)
var S = newSeq[int](n)
var req = newSeq[int](n)
for i in 1..n:
  S[i-1] = scan()
  let pre = scan()-1
  G.add(pre,i-1)
  req[i-1] = pre
var ans = 0.0
var cleared = newSeq[bool](n)
for nodes in G.storonglyConnectedComponentDecomposition():
  # 一番簡単なものから順にサイクル
  let firstNode = nodes.mapIt(S[it]).argMin()
  for i in 0..<nodes.len:
    let node = nodes[(i + firstNode) mod nodes.len]
    if cleared[req[node]] : ans += S[node] / 2
    else: ans += S[node].float
    cleared[node] = true
echo ans
