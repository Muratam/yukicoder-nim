import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
import queues

template useMaxFlow =
  # fordFullkerson : 最大流/最小カット O(FE) (F:最大流の流量)
  type Edge = tuple[dst,cap,rev:int]
  type Graph = seq[seq[Edge]]
  proc initFlow(maxSize:int):Graph = newSeqWith(maxSize,newSeq[Edge]())
  proc add(G:var Graph,src,dst,cap:int) =
    G[src] &= (dst,cap,G[dst].len)
    G[dst] &= (src,0,G[src].len - 1)
  proc fordFullkerson(G:var Graph,src,dst:int) : int =
    var used : seq[bool]
    proc dfs(G:var Graph,src,dst,flow:int) : int =
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
  # O(EV^2)
  proc dinic(G:var Graph,src,dst:int) : int =
    var level = newSeq[int](G.len)
    var iter : seq[int]
    # src からの最短距離を探索
    proc bfs(G:var Graph,src:int) =
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
    proc dfs(G:var Graph,src,dst,flow:int):int =
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

useMaxFlow()

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let w = scan()
let n = scan()
let J = newSeqWith(n,scan())
let m = scan()
let C = newSeqWith(m,scan())

var f = initFlow(n+m+2) # J:0..<n | C:n+0..<n+m | n+m -> n+m+1
let src = n + m
let dst = n + m + 1
for i,j in J: f.add(src,i,j)
for i,c in C: f.add(n+i,dst,c)
for c in n..<n+m:
  let q = scan()
  let X = newSeqWith(q,scan()-1)
  let OK = toSeq(0..<n).filterIt(it notin X)
  for j in OK:
    f.add(j,c,1e10.int)
if f.dinic(src,dst) < w : echo "BANSAKUTSUKITA"
else: echo "SHIROBAKO"