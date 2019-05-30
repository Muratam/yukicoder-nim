import sequtils

import sequtils,algorithm
# SCC:強連結成分分解 O(V+E)
type Graph = ref object
  graph : seq[seq[int]] # 隣接リスト
  rev : seq[seq[int]] # 逆
proc initGraph(maxSize:int):Graph =
  new(result)
  result.graph = newSeqWith(maxSize,newSeq[int]())
  result.rev = newSeqWith(maxSize,newSeq[int]())
proc add(G:var Graph,src,dst:int) =
  G.graph[src].add(dst)
  G.rev[dst].add(src)
# 属する強連結成分のトポロジカル順の頂点番号を返却(サイクル順)
proc storonglyConnectedComponentDecomposition(G:Graph) : seq[seq[int]] =
  var used = newSeq[bool](G.graph.len)
  var postOrders = newSeq[int]() # 帰りがけ順
  var orders = newSeq[seq[int]]()
  proc dfs(src:int) =
    used[src] = true
    for dst in G.graph[src]:
      if not used[dst] : dfs(dst)
    postOrders.add(src)
  proc rdfs(src,k:int) =
    used[src] = true
    orders[^1].add(src)
    for dst in G.rev[src]:
      if not used[dst] : rdfs(dst,k)
  for v in 0..<G.graph.len:
    if not used[v] : dfs(v)
  used = newSeq[bool](G.graph.len)
  var order = 0
  for i in (postOrders.len()-1).countdown(0):
    if used[postOrders[i]] : continue
    orders.add(@[])
    rdfs(postOrders[i],order)
    orders[^1].reverse()
    order += 1
  return orders

# 重軽分解 (未完成)
template useHeavyLightDecomposition() =
  # 最も部分木のサイズの大きい物1つをHeavy・他はLightとして分割
  # Heavyを一つにまとめると全頂点の深さが O(log(N)) になる.
  # 各部分木に関しては配列に使えるデータ構造(BIT/セグツリ)が使える
  type
    Node = tuple[number,parentIndex:int]
    Chain = ref object
      depth : int
      parent : Node
      child : seq[Node]
      mapFrom : seq[int]
    HeavyLightDecomposition = ref object
      baseGraph : seq[seq[int]]
      chains : seq[Chain]
      mapTo : seq[Node] # raw index -> chain
      mapFrom: seq[seq[int]] # chain -> raw index


when isMainModule:
  import unittest
  test "normalize":
    let E = @[@[1,2],@[0,3],@[0],@[1]]
    check: E.asTree == @[@[1, 2], @[3], @[], @[]]
    let F = @[@[1,2,3],@[6,2],@[4],@[5,1,2],@[],@[],@[]]
    check: F.topologicalSort() == @[6, 4, 2, 1, 5, 3, 0]
