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
# (親も子も同一視して)双方向になっている木を,0 番を根として子のノードだけ持つように変更する
proc asTree(E:seq[seq[int]]):seq[seq[int]] =
  var answer = newSeqWith(E.len,newSeq[int]())
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst == pre : continue
      answer[now].add(dst)
      impl(now,dst)
  impl(-1,0)
  return answer

when isMainModule:
  import unittest
  test "normalize":
    let E = @[@[1,2],@[0,3],@[0],@[1]]
    check: E.asTree == @[@[1, 2], @[3], @[], @[]]
    let F = @[@[1,2,3],@[6,2],@[4],@[5,1,2],@[],@[],@[]]
    check: F.topologicalSort() == @[6, 4, 2, 1, 5, 3, 0]
