import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

let
  N = get().parseInt() # < 100
  M = get().parseInt() # < 1500
  PQR = newSeqWith(M,get().split().map(parseInt)) # P,R<N  Q<100
  # PをQ個でRができる

# 末端ノードがいくら必要か ? && 全て使う :: DAGらしい :: トポロジカルソート :: O(V+E) == O(N+M)
proc topologicalSort(edges:seq[seq[int]]) : seq[int] =
  # edges : n -> m の隣接リスト
  var visited = newSeqWith(edges.len,0)
  var tsorted = newSeq[int]()
  proc visit(node:int) =
    visited[node] += 1
    if visited[node] > 1: return
    for edge in edges[node]: visit(edge)
    tsorted &= node
  for n in 0..<edges.len: # 孤立点除去 ?
    visit(n)
  return tsorted.filterIt(visited[it] > 1 or edges[it].len > 0)

var succEdges = newSeqWith(N+1,newSeq[int]())
var backWords = newSeqWith(N+1,newSeq[tuple[back,cost:int]]())
for pqr in PQR:
  let (p,q,r) = pqr.unpack(3)
  succEdges[p] &= r
  backWords[r] &= (p,q)
let tsorted = topologicalSort(succEdges)
var ans = newSeqWith(N+1,0)
ans[N] = 1
for n in tsorted:
  for bc in backWords[n]:
    let (back,cost) = bc
    ans[back] += ans[n] * cost
for i,n in ans[1..^2]:
  if backWords[i+1].len == 0: echo n
  else: echo 0