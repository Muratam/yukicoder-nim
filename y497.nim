import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

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


let n = scan()
let B = newSeqWith(n,(x:scan(),y:scan(),z:scan()))
proc isSmall(a,b:tuple[x,y,z:int]): bool =
  var an = @[a.x,a.y,a.z].sorted(cmp)
  while true:
    if an[0] < b.x and an[1] < b.y and an[2] < b.z : return true
    if not an.nextPermutation() : return false
var E = newSeqWith(n,newSeq[int]())
for i in 0..<n:
  for j in 0..<n:
    if isSmall(B[i],B[j]) : E[j] &= i
var dp = newSeq[int](n)
let TS = E.topologicalSort(true).reversed()
for e in TS :
  for dst in E[e]:
    dp[dst] .max= dp[e] + 1
echo dp.max() + 1