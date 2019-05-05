import sequtils
# トポロジカルソート O(E+V) / 木の分離
template useTrimingGraph =
  # 隣接リスト([n->[m1,m2,m3], ... ])を トポロジカルソート
  proc topologicalSort(E:seq[seq[int]],deleteIsolated:bool = false) : seq[int] =
    var visited = newSeq[int](E.len)
    var answer = newSeq[int]()
    proc visit(src:int) =
      visited[src] += 1
      if visited[src] > 1: return
      for dst in E[src]: visit(dst)
      answer.add(src) # 葉から順に追加される
    for src in 0..<E.len: visit(src)
    if deleteIsolated: # 孤立点の除去
      return answer.filterIt(visited[it] > 1 or E[it].len > 0)
    return answer

  # (親も子も同一視して)双方向になっている木を,0 番を根として子のノードだけ持つように変更する
  proc deleteParent(E:seq[seq[int]]):seq[seq[int]] =
    var answer = newSeqWith(E.len,newSeq[int]())
    proc impl(pre,now:int) =
      for dst in E[now]:
        if dst == pre : continue
        answer[now].add(dst)
        impl(now,dst)
    impl(-1,0)
    return answer
  # (親も子も同一視して)双方向になっている木を,0 番を根として親のノードだけにする
  proc getParentList(E:seq[seq[int]]):seq[int] =
    var answer = newSeqWith(E.len,-1)
    proc impl(pre,now:int) =
      for dst in E[now]:
        if dst == pre : continue
        answer[dst] = now
        impl(now,dst)
    impl(-1,0)
    return answer
# SCC:強連結成分分解 O(V+E)
template useSCC =
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
# 最小共通祖先 構築:O(n),探索:O(log(n)) (深さに依存しない)
template useLCA =
  type LowestCommonAncestor = ref object
    depth : seq[int]
    parent : seq[seq[int]] # 2^k 回親をたどった時のノード
    n:int
    nlog2 : int
  proc initLowestCommonAnsestor(E:seq[seq[int]],root:int = 0) : LowestCommonAncestor =
    new(result)
    # E:隣接リスト,root:根の番号,(0~E.len-1と仮定)
    # (import bitops)
    # 予め木を整形(= E[i]で親と子の区別を行う)する必要はない
    let n = E.len
    let nlog2 = E.len.fastLog2() + 1
    var depth = newSeq[int](n)
    var parent = newSeqWith(nlog2,newSeq[int](E.len))
    proc fill0thParent(src,pre,currentDepth:int) =
      parent[0][src] = pre
      depth[src] = currentDepth
      for dst in E[src]:
        if dst != pre : fill0thParent(dst,src,currentDepth+1)
    fill0thParent(root,-1,0)
    for k in 0..<nlog2-1:
      for v in 0..<n:
        if parent[k][v] < 0 : parent[k+1][v] = -1
        else: parent[k+1][v] = parent[k][parent[k][v]]
    result.depth = depth
    result.parent = parent
    result.n = n
    result.nlog2 = nlog2
  proc find(self:LowestCommonAncestor,u,v:int):int =
    var (u,v) = (u,v)
    if self.depth[u] > self.depth[v] : swap(u,v)
    for k in 0..<self.nlog2:
      if (((self.depth[v] - self.depth[u]) shr k) and 1) != 0 :
        v = self.parent[k][v]
    if u == v : return u
    for k in (self.nlog2-1).countdown(0):
      if self.parent[k][u] == self.parent[k][v] : continue
      u = self.parent[k][u]
      v = self.parent[k][v]
    return self.parent[0][u]
# 最小全域木 O(ElogV)
template useMinimumSpanningTree =
  # 最小全域木のコスト(max / sum)を返却
  #  0..<maxN, E:辺のリスト(コスト順に並び替えるため)
  type Edge = tuple[src,dst,cost:int]
  proc kruskal(E:seq[Edge],maxN:int) : int =
    var uf = initUnionFind[int](maxN)
    for e in E.sortedByIt(it.cost):
      if uf.same(e.src,e.dst) : continue
      uf.merge(e.src,e.dst)
      result .max= e.cost
      # if uf.same(0,maxN-1): break # 繋げたい点があれば
  #
  # Priority Queueで最小辺を更新していく(Prim)方法でも O(ElogV)
# 最短経路 O(ElogE) / 負有り:O(EV) / 全:O(V^3)
template useShortestPath =
  # ダイクストラ : O(ElogE) コストが負でないときの(startからの)最短路
  type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
  proc dijkestra(E:seq[seq[Edge]], start:int) :seq[int] =
    var costs = newSeqWith(E.len,INF)
    var opens = newBinaryHeap[Edge](proc(a,b:Edge): int = a.cost - b.cost)
    opens.push((start,0))
    while opens.size() > 0:
      let (src,cost) = opens.pop()
      if costs[src] != INF : continue
      costs[src] = cost
      for e in E[src]:
        if costs[e.dst] != INF : continue
        opens.push((e.dst,cost + e.cost))
    return costs
  # ダイクストラ (cost == 1版)
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
  # SPFA (ベルマンフォード) O(EV) : 二点間の最短路(負の閉路でも動作)
  type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
  proc SPFA(E:seq[seq[Edge]],start:int): seq[int] =
    # import queues
    # 負の閉路検出が可能な単一始点最短路 : O(EV)
    result = newSeqWith(E.len,INF)
    var P = newSeq[bool](E.len)
    var C = newSeq[int](E.len)
    var q = initQueue[int]()
    q.enqueue(start)
    result[start] = 0
    P[start] = true
    C[start] += 1
    while q.len > 0:
      let src = q.pop()
      P[src] = false
      for e in E[src]:
        if result[src] + e.cost >= result[e.dst] : continue
        result[e.dst] = result[src] + e.cost
        if P[e.dst] : continue
        if C[e.dst] >= E.len : return @[] # 負の閉路があるときは空を返す
        C[e.dst] += 1
        P[e.dst] = true
        q.enqueue(e.dst)
  # ワーシャルフロイド O(V^3) : 全ての頂点の間の最短路を見つける(負でも)
  # E:隣接行列(非連結時cost:=INF)
  proc warshallFroyd(E:seq[seq[int]]) : seq[seq[int]] =
    result = E
    let n = E.len
    for k in 0..<n:
      for i in 0..<n:
        for j in 0..<n:
          result[i][j] .min= result[i][k] + result[k][j]
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
