import sequtils
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

# 木を平滑化してその区間を返す。
# そこを根とする部分木(自身を含む)がその区間に対応する。
proc eulerTour(E:seq[seq[int]]):tuple[toured:seq[Slice[int]],rev:seq[int]] =
  var i = 0
  # .a は Treeのindex -> 区間のindex
  var toured = newSeq[Slice[int]](E.len)
  # 区間のindex -> Treeのindex
  var rev = newSeq[int](E.len)
  proc dfs(src:int) =
    let l = i
    i += 1
    for dst in E[src]: dfs(dst)
    toured[src] = l..<i
    rev[l] = src
  dfs(0)
  return (toured,rev)

# 最小共通祖先 構築:O(n),探索:O(log(n)) (深さに依存しない)
when NimMajor * 100 + NimMinor >= 18:import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc fastLog2(x:int):cint = 63 - countLeadingZeroBits(x.culonglong)
import math
type LowestCommonAncestor = ref object
  depth : seq[int]
  parent : seq[seq[int]] # 2^k 回親をたどった時のノード
  n:int
  nlog2 : int
proc newLowestCommonAnsestor(E:seq[seq[int]],root:int = 0) : LowestCommonAncestor =
  new(result)
  # E:隣接リスト,root:根の番号,(0~E.len-1と仮定)
  # 予め木を整形(= E[i]で親と子の区別を行う)する必要はない
  let n = E.len
  let nlog2 = E.len.fastLog2() + 1
  var depth = newSeq[int](n)
  var parent = newSeqWith(nlog2,newSeq[int](E.len))
  proc fill0thParent(src,pre,currentDepth:int) =
    parent[0][src] = pre
    depth[src] = currentDepth
    for dst in E[src]:
      if dst != pre : fill0thParent(dst,src,currentDepth+1)
  fill0thParent(root,-1,0)
  for k in 0..<nlog2-1:
    for v in 0..<n:
      if parent[k][v] < 0 : parent[k+1][v] = -1
      else: parent[k+1][v] = parent[k][parent[k][v]]
  result.depth = depth
  result.parent = parent
  result.n = n
  result.nlog2 = nlog2
proc find(self:LowestCommonAncestor,u,v:int):int =
  var (u,v) = (u,v)
  if self.depth[u] > self.depth[v] : swap(u,v)
  for k in 0..<self.nlog2:
    if (((self.depth[v] - self.depth[u]) shr k) and 1) != 0 :
      v = self.parent[k][v]
  if u == v : return u
  for k in (self.nlog2-1).countdown(0):
    if self.parent[k][u] == self.parent[k][v] : continue
    u = self.parent[k][u]
    v = self.parent[k][v]
  return self.parent[0][u]

when isMainModule:
  import unittest
  test "tree":
    let E = @[@[1,2],@[0,3],@[0],@[1]]
    check: E.asTree == @[@[1, 2], @[3], @[], @[]]
    check: E.asTree.eulerTour().toured == @[(0..<4),(1..<3),(3..<4),(2..<3)]
    check: E.asTree.eulerTour().rev == @[0,1,3,2]
    let lca = E.newLowestCommonAnsestor()
    check: lca.find(1,3) == 1
    check: lca.find(0,3) == 0
    check: lca.find(1,2) == 0
