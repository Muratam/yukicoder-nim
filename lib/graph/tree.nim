import sequtils
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

# (親も子も同一視して)双方向になっている木を,(0 番を)根として子のノードだけ持つように変更する
proc asTree(E:seq[seq[int]],root:int = 0):seq[seq[int]] =
  var answer = newSeq[seq[int]](E.len)
  for i in 0..<E.len: answer[i] = newSeq[int]()
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst == pre : continue
      answer[now].add(dst)
      impl(now,dst)
  impl(-1,root)
  return answer
# 全方位木DP. 0-indexed. 可換モノイド.
# Eは事前に両方向に代入して無向グラフにしておくこと.
import sets,tables
proc allTreeDP[T](
    E:seq[seq[int]],
    apply:proc(x,y:T):T,
    init:proc(i:int):T,
    final:proc(i:int,sum:T):T) : seq[T] =
  var dp = newSeqWith(E.len,initTable[int,T]())
  proc dfs(src,pre:int) : T {.discardable.} =
    if pre in dp[src]: return dp[src][pre]
    result = init(src)
    for dst in E[src]:
      if dst != pre:
        result = apply(result,dfs(dst,src))
    result = final(src,result)
    dp[src][pre] = result
  result = newSeq[T](E.len)
  for i in 0..<E.len: result[i] = dfs(i,-1)
# 1頂点の木DP. 0-indexed. 可換モノイド.
proc treeDP[T](
    E:seq[seq[int]],
    root:int,
    apply:proc(x,y:T):T,
    init:proc(i:int):T) : seq[T] =
  var E = E.asTree(root)
  var dp = newSeq[T](E.len)
  proc dfs(src:int) : T {.discardable.} =
    result = init(src)
    for dst in E[src]:
      result = apply(result,dfs(dst,src))
  dfs(root)
  return dp

# 最小共通祖先(LCA)
# 構築:O(n),探索:O(log(n)) (深さに依存しない)
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
  test "alltreedp":
    let E = @[@[1], @[0, 2, 3], @[1], @[1]]
    # 例: 全頂点から最も遠い位置(同じ場合はindexが小さい方)までの距離
    type WithIndex[T] = tuple[i:int,val:T]
    let dp = E.allTreeDP(
      proc(x,y:WithIndex[int]):WithIndex[int] =
        if x.val == y.val :
          if x.i < y.i: return x
          return  y
        if x.val > y.val : return  x
        return  y
      ,
      proc(i:int):WithIndex[int] = (i,-1),
      proc(i:int,sum:WithIndex[int]):WithIndex[int] = (sum.i,sum.val+1),
    )
    let correct : seq[WithIndex[int]] = @[(2,2),(0,1),(0,2),(0,2)]
    check: dp == correct
