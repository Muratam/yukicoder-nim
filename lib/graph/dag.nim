import sequtils
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


when isMainModule:
  import unittest
  test "DAG":
    let F = @[@[1,2,3],@[6,2],@[4],@[5,1,2],@[],@[],@[]]
    check: F.topologicalSort() == @[6, 4, 2, 1, 5, 3, 0]
