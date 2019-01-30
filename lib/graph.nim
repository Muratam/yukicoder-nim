import sequtils

# トポロジカルソート
template useTrimingGraph =
  # 隣接リスト([n->[m1,m2,m3], ... ])を トポロジカルソート
  proc topologicalSort(E:seq[seq[int]],deleteIsolated:bool = false) : seq[int] =
    var visited = newSeq[int](E.len)
    var answer = newSeq[int]()
    proc visit(src:int) =
      visited[src] += 1
      if visited[src] > 1: return
      for dst in E[src]: visit(dst)
      answer &= src # 葉から順に追加される
    for src in 0..<E.len: visit(src)
    if deleteIsolated: # 孤立点の除去
      return answer.filterIt(visited[it] > 1 or E[it].len > 0)
    return answer

# 最大流/最小カット
template useMaxFlow =
  # fordFullkerson : 最大流/最小カット O(FE) (F:最大流の流量)
  type Edge = tuple[dst,cap,rev:int]
  type Flow = seq[seq[Edge]]
  proc initFlow(maxSize:int):Flow = newSeqWith(maxSize,newSeq[Edge]())
  proc add(F:var Flow,src,dst,cap:int) =
    F[src] &= (dst,cap,F[dst].len)
    F[dst] &= (src,0,F[src].len - 1)
  proc fordFullkerson(F:var Flow,src,dst:int) : int =
    var used : seq[bool]
    proc dfs(F:var Flow,src,dst,flow:int) : int =
      if src == dst : return flow
      used[src] = true
      for i,e in F[src]:
        if used[e.dst] or e.cap <= 0 : continue
        let d = F.dfs(e.dst,dst,flow.min(e.cap))
        if d <= 0 : continue
        F[src][i].cap -= d
        F[e.dst][e.rev].cap += d
        return d
    while true:
      used = newSeq[bool](F.len)
      const INF = 1e10.int
      let flow = F.dfs(src,dst,INF)
      if flow == 0 : return
      result += flow

# 二部グラフの最大マッチング
template useBiparticeMatching =
  # 二部グラフの最大マッチング O(E)
  type BipartiteMatch = seq[seq[int]]
  proc initBipartiteMatch(maxSize:int): BipartiteMatch = newSeqWith(maxSize,newSeq[int]())
  proc add(B:var BipartiteMatch,src,dst:int) = (B[dst] &= src;B[src] &= dst)
  proc bipartiteMatching(B:BipartiteMatch) : int =
    var match = newSeqWith(B.len,-1)
    var used : seq[bool]
    proc dfs(src:int) : bool =
      # 交互にペアを結んでいく
      used[src] = true
      for dst in B[src]:
        if match[dst] >= 0 :
          if used[match[dst]] : continue
          if not dfs(match[dst]) : continue
        match[src] = dst
        match[dst] = src
        return true
      return false
    for src in 0..<B.len:
      if match[src] >= 0 : continue
      used = newSeq[false](B.len)
      if dfs(src) : result += 1

# 最小全域木
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

# 最短経路
template useShortestPath =
  # ダイクストラ : O(ElogV) コストが負でないときの(startからの)最短路
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
  # ワーシャルフロイド O(V^3) : 全ての頂点の間の最短路を見つける(負でも)
  # E:隣接行列(非連結時cost:=INF)
  proc warshallFroyd(E:seq[seq[int]]) : seq[seq[int]] =
    result = E
    let n = E.len
    for k in 0..<n:
      for i in 0..<n:
        for j in 0..<n:
          result[i][j] .min= result[i][k] + result[k][j]

# ベルマンフォード O(EV) : 二点間の最短路(負の閉路でも動作)
# 経路復元
# 最小全域木(Prim)
# 最大流 Dinic(O(EV^2)) / det
# マッチング / 辺カバー / 安定集合 / 点カバー / 最小費用流
# 強連結成分(SCC)分解 O(V+E) / DAG / 2-SAT
# LCA