import sequtils

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

# 最小全域木のコスト(max / sum)を返却
type Edge = tuple[cost,src,dst:int]
proc kruskal(E:seq[Edge],maxN:int) : int = #  0..<maxN
  var uf = initUnionFind[int](maxN)
  for e in E.sortedByIt(it.cost):
    if uf.same(e.src,e.dst) : continue
    uf.merge(e.src,e.dst)
    result .max= e.cost
    # if uf.same(0,maxN-1): break # 繋げたい点があれば

# ダイクストラ : O(ElogV) 負でないときの(sx,syからの)最短路
proc dijkestra(L:seq[seq[int]], sx,sy:int) :seq[seq[int]] =
  type Field = tuple[x,y,v:int]
  let (W,H) = (L.len,L[0].len)
  const INF = int.high div 4
  const dxdy :seq[tuple[x,y:int]] = @[(0,1),(1,0),(0,-1),(-1,0)]
  var cost = newSeqWith(W,newSeqWith(H,INF))
  var opens = newBinaryHeap[Field](proc(a,b:Field): int = a.v - b.v)
  opens.push((sx,sy,0))
  while opens.size() > 0:
    let (x,y,v) = opens.pop()
    if cost[x][y] != INF : continue
    cost[x][y] = v
    for d in dxdy:
      let (nx,ny) = (d.x + x,d.y + y)
      if nx < 0 or ny < 0 or nx >= W or ny >= H : continue
      var n_v = v + L[nx][ny]
      if cost[nx][ny] == INF :
        opens.push((nx,ny,n_v))
  return cost

# ダイクストラ
# ベルマンフォード O(EV) : 二点間の最短路(負の閉路でも動作)
# ワーシャルフロイド O(V^3) : 全ての頂点の間の最短路を見つける(負でも) http://dai1741.github.io/maximum-algo-2012/docs/shortest-path/
# 経路復元
# 最小全域木(MST Kruskal , Prim)
# 最大流 (Ford-Fulkerson O(FE)) => Dinic(O(EV^2)) / 二部マッチング / det
# 最小カット
# マッチング / 辺カバー / 安定集合 / 点カバー / 最小費用流
# 強連結成分(SCC)分解 O(V+E) / DAG / 2-SAT
# LCA

