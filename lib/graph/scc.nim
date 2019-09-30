import sequtils,sets
# SCC:強連結成分分解 O(V+E)
# 互いに行き来できるものを同じ集合にする. つまり任意のグラフを DAG にできる。
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
# 外側はトポロジカルソート済み
proc storonglyConnectedComponentDecomposition(
    G:Graph,
    sortInnerIndices:bool = true) : seq[seq[int]] =
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
    order += 1
  if sortInnerIndices:
    # 先頭を基準に順に辿れるように変える
    # 内側は全て辿れるのでこの処理はしなくてもよい
    used = newSeq[bool](G.graph.len)
    var allow = newSeq[bool](G.graph.len)
    for i in 0..<orders.len:
      var next = newSeq[int]()
      for src in orders[i]: allow[src] = true
      proc dfs2(src:int) =
        used[src] = true
        next.add src
        for dst in G.graph[src]:
          if not allow[dst]: continue
          if not used[dst] : dfs2(dst)
      dfs2(orders[i][0])
      orders[i] = next
  return orders

# SCC後の外側の構造も一緒に返す
# 外側はDAGでついでにトポロジカルソート済み。
type SCCOuter = ref object
  nodes: seq[int]
  index: int
proc newSccOuter(nodes:seq[int],index: int) : SCCOuter =
  new(result)
  result.nodes = nodes
  result.index = index
proc `$`(x:SCCOuter) : string = "_" & ($x.index)
proc verposeSCC(G:Graph) : tuple[
    scced:seq[SCCOuter],
    toOuter: seq[SCCOuter], # 元の(内側の)頂点番号からSCC後の(外側の)番号への変換列
    outer:seq[seq[SCCOuter]] # SCC後の(外側の)番号での隣接リスト.DAG.
    ]=
  let sccedRaw = G.storonglyConnectedComponentDecomposition(false)
  var scced = newSeq[SCCOuter](sccedRaw.len)
  for i,nodes in sccedRaw:
    scced[i] = newSccOuter(nodes,i)
  var toOuter = newSeq[SCCOuter](G.graph.len)
  for i,nodes in sccedRaw:
    for node in nodes:
      toOuter[node] = scced[i]
  var outerSets = newSeqWith(scced.len,initSet[int]())
  for src,dsts in G.graph:
    for dst in dsts:
      if toOuter[src].index != toOuter[dst].index:
        outerSets[toOuter[src].index].incl toOuter[dst].index
  var outer = newSeq[seq[SCCOuter]](scced.len)
  for i in 0..<scced.len:
    outer[i] = newSeq[SCCOuter](outerSets[i].card)
    var j = 0
    for k in outerSets[i]:
      outer[i][j] = scced[k]
      j += 1
  return (scced,toOuter,outer)




when isMainModule:
  import unittest
  test "SCC":
    block:
      let E = @[@[1],@[2,6],@[3,0],@[4,12],@[5,7],@[3],@[8,11],@[5,10],@[6,9],@[11],@[9],@[],@[]]
      var G = initGraph(13)
      for src,dsts in E:
        for dst in dsts: G.add(src,dst)
      check: G.storonglyConnectedComponentDecomposition() == @[@[0,1,2],@[6,8],@[3,4,5,7],@[12],@[10],@[9],@[11]]
      let (_,toOuter,outer) = G.verposeSCC()
      check: ($toOuter) == "@[_0, _0, _0, _2, _2, _2, _1, _2, _1, _5, _4, _6, _3]"
      check: ($outer) == "@[@[_1, _2], @[_5, _6], @[_3, _4], @[], @[_5], @[_6], @[]]"
