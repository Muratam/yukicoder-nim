import sequtils,queues
# import algorithm,math,tables
# import sets,intsets,queues,heapqueue,bitops,strutils
# import strutils,strformat,sugar,macros,times
# template stopwatch(body) = (let t1 = cpuTime();body;echo "TIME:",(cpuTime() - t1) * 1000,"ms")
# template `^`(n:int) : int = (1 shl n)
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

template useMaxFlow =
  type Edge = tuple[dst,cap,rev:int]
  type Graph = seq[seq[Edge]]
  proc initFlow(maxSize:int):Graph = newSeqWith(maxSize,newSeq[Edge]())
  proc add(G:var Graph,src,dst,cap:int) =
    G[src] &= (dst,cap,G[dst].len)
    G[dst] &= (src,0,G[src].len - 1)
  # dinic : O(EV^2)
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

let n = scan()
var f = initFlow(n*2+2) # 2*i:行く 2*i+1:行かない,n*2
let src = n*2
let dst = n*2+1
for i in 0..<n:
  let go = scan()
  let no = scan()
  f.add(src,2*i,1e10.int)
  f.add(src,2*i+1,1e10.int)
  f.add(2*i+1,dst,no)
scan().times:
  let a = scan()
  let b = scan()

