import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# DAGかどうかを判別(= 閉路が存在するか)
proc isNotDAG(E:seq[seq[int]]) : bool =
  var X = newSeq[int](E.len)
  proc visit(src:int) : bool =
    if X[src] != 0: return X[src] == 1
    X[src] = 1
    for dst in E[src]:
      if visit(dst) : return true
    X[src] = 2
  for src in 0..<E.len:
    if X[src] != 0 : continue
    if visit(src): return true


# DAGの隣接リスト([n->[m1,m2,m3], ... ])を トポロジカルソート
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

let n = scan()
let A = newSeqWith(n,newSeqWith(n-1,scan()-1))
var D = newSeq[int]()
for i in 0..<n:
  for j in (i+1)..<n:
    D .add i * n + j
D.sort(cmp)
var toI = initTable[int,int]()
for i,d in D: toI[d] = i
# DAG を作って閉路検出
var E = newSeqWith(D.len,newSeq[int]())
for i in 0..<n:
  var X = newSeq[int]()
  for j in 0..<n-1:
    let a = A[i][j] # i vs a
    let x = i.min(a) * n + i.max(a)
    X .add toI[x]
  for xi in 0..<X.len-1:
    E[X[xi]] .add X[xi + 1]
if E.isNotDAG():
  echo -1
  quit 0

var S = E.topologicalSort().reversed()
var DP = newSeqWith(S.len,0)
for s in S:
  for dst in E[s]:
    DP[dst] .max= DP[s] + 1
echo DP.max() + 1
