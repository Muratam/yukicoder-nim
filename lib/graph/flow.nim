import "../datastructure/binaryheap"
import sequtils
when NimMajor * 100 + NimMinor < 19:import queues
else: import "../datastructure/queue"

# 最大流/最小カット O(FE) / O(EV^2)
template useMaxFlow =
  type Edge = tuple[dst,cap,rev:int]
  proc initFlow(maxSize:int):seq[seq[Edge]] = newSeqWith(maxSize,newSeq[Edge]())
  proc add(G:var seq[seq[Edge]],src,dst,cap:int) =
    G[src].add((dst,cap,G[dst].len))
    G[dst].add((src,0,G[src].len - 1))
  # fordFullkerson : 最大流/最小カット O(FE) (F:最大流の流量)
  proc fordFullkerson(G:var seq[seq[Edge]],src,dst:int) : int =
    var used : seq[bool]
    proc dfs(G:var seq[seq[Edge]],src,dst,flow:int) : int =
      if src == dst : return flow
      used[src] = true
      for i,e in G[src]:
        if used[e.dst] or e.cap <= 0 : continue
        let d = G.dfs(e.dst,dst,flow.min(e.cap))
        if d <= 0 : continue
        G[src][i].cap -= d
        G[e.dst][e.rev].cap += d
        return d
    while true:
      used = newSeq[bool](G.len)
      const INF = 1e10.int
      let flow = G.dfs(src,dst,INF)
      if flow == 0 : return
      result += flow
  # dinic : O(EV^2)
  proc dinic(G:var seq[seq[Edge]],src,dst:int) : int =
    var level = newSeq[int](G.len)
    var iter : seq[int]
    # src からの最短距離を探索
    proc bfs(G:var seq[seq[Edge]],src:int) =
      level = newSeqWith(G.len,-1)
      var q = initQueue[int]()
      level[src] = 0
      q.enqueue(src)
      while q.len > 0:
        let v = q.dequeue()
        for e in G[v]:
          if e.cap <= 0 : continue
          if level[e.dst] >= 0 : continue
          level[e.dst] = level[v] + 1
          q.enqueue(e.dst)
    # 増加パスを探索
    proc dfs(G:var seq[seq[Edge]],src,dst,flow:int):int =
      if src == dst : return flow
      for i in iter[src]..<G[src].len:
        let e = G[src][i]
        if e.cap <= 0 : continue
        if level[src] >= level[e.dst] : continue
        let d = G.dfs(e.dst,dst,flow.min(e.cap))
        if d <= 0 : continue
        G[src][i].cap -= d
        G[e.dst][e.rev].cap += d
        return d
      return 0
    while true:
      G.bfs(src)
      if level[dst] < 0 : return
      iter = newSeq[int](G.len)
      while true:
        let f = G.dfs(src,dst,1e10.int)
        if f <= 0 : break
        result += f
# 二部グラフの最大マッチング O(E)
template useBiparticeMatching =
  type BipartiteMatch = seq[seq[int]]
  proc initBipartiteMatch(maxSize:int): BipartiteMatch = newSeqWith(maxSize,newSeq[int]())
  proc add(B:var BipartiteMatch,src,dst:int) = (B[dst].add(src);B[src].add(dst))
  proc bipartiteMatching(B:var BipartiteMatch) : int =
    var match = newSeqWith(B.len,-1) # マッチ結果がほしければこれを返却
    var used : seq[bool]
    proc dfs(B:var BipartiteMatch,src:int) : bool =
      # 交互にペアを結んでいく
      used[src] = true
      for dst in B[src]:
        if match[dst] >= 0 :
          if used[match[dst]] : continue
          if not B.dfs(match[dst]) : continue
        match[src] = dst
        match[dst] = src
        return true
      return false
    for src in 0..<B.len:
      if match[src] >= 0 : continue
      used = newSeq[bool](B.len)
      if B.dfs(src) : result += 1
# 最小費用流 O(FElogV)
template useMinCostFlow =
  type Edge = tuple[dst,cap,cost,rev:int]
  proc initFlow(maxSize:int):seq[seq[Edge]] = newSeqWith(maxSize,newSeq[Edge]())
  proc add(G:var seq[seq[Edge]],src,dst,cap,cost:int) =
    G[src].add((dst,cap,cost,G[dst].len))
    G[dst].add((src,0,-cost,G[src].len - 1))
  proc minCostFlow(E:var seq[seq[Edge]],start,goal,flowbase:int): int = # O(FElogV)
    # start -> goal へ flow 流した時の最小費用流
    # 最短経路を求め,最短経路に目一杯流す
    # 注意 : ダイクストラなので負の閉路があった場合は不可能
    const INF = 1e10.int
    var flow = flowbase
    var prev = newSeq[tuple[src,index:int]](E.len) # 直前の辺
    var H = newSeq[int](E.len) # ポテンシャル
    proc dijkestra(E:var seq[seq[Edge]]): seq[int] =
      type P = tuple[len,src:int] # 最短距離と頂点番号
      result = newSeqWith(E.len,INF)
      var pq = newBinaryHeap[P](
        proc(x,y:P):int = (if x.len != y.len : x.len - y.len else: x.src - y.src))
      pq.push((0,start))
      result[start] = 0
      while pq.len > 0:
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

# 2-SAT (強連結成分) (未完成)
template useTwoSAT =
  type TwoSAT = ref object
    graph:Graph
  proc initTwoSAT(maxSize:int) : TwoSAT = result.graph = initGraph(maxSize * 2)
  proc `->`(x,y:(int,bool)) : tuple[src,dst:int] =
    result.src = if x[1] : x[0] else: x[0] * 2
    result.dst = if y[1] : y[0] else: y[0] * 2
  proc add(SAT:var TwoSAT,E:tuple[src,dst:int]) = SAT.graph.add(E.src,E.dst)
  proc solve(SAT:var TwoSAT) : bool =
    # 同じ強連結成分内にxと!xがあれば不可能
    let scc = SAT.graph.storonglyConnectedComponentDecomposition()
    for nodes in scc:
      let nodes = nodes.mapIt(if it mod 2 == 0 : it div 2 else: it).sorted(cmp)
      for i in 1..<nodes.len:
        if nodes[i] == nodes[i-1] : return false
    return true

block: useMaxFlow()
block: useBiparticeMatching()
block: useMinCostFlow()
