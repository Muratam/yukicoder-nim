import sequtils
import "../datastructure/binaryheap"
const INF = 1e10.int
# 最短経路 O(ElogE) / 負有り:O(EV) / 全:O(V^3)
# ダイクストラ : O(ElogE) コストが負でないときの(startからの)最短路
type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
proc dijkestra(E:seq[seq[Edge]], start:int) :seq[int] =
  var costs = newSeqWith(E.len,INF)
  var opens = newBinaryHeap[Edge](proc(a,b:Edge): int = a.cost - b.cost)
  opens.push((start,0))
  while opens.len() > 0:
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
  while opens.len() > 0:
    let (src,cost) = opens.pop()
    if costs[src] != INF : continue
    costs[src] = cost
    for e in E[src]:
      if costs[e] != INF : continue
      opens.push((e,cost + 1))
  return costs




# SPFA (ベルマンフォード) O(EV) : 二点間の最短路(負の閉路でも動作)
when NimMajor == 0 and NimMinor == 19: import queues
else: import "../datastructure/queue"
# type Edge = tuple[dst,cost:int] # E:隣接リスト(端点とコストのtuple)
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
        result[i][j] = result[i][j].min(result[i][k] + result[k][j])
