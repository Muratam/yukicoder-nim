import sequtils,bitops
template times*(n:int,body) = (for _ in 0..<n: body)

# (親も子も同一視して)双方向になっている木を,0 番を根として子のノードだけ持つように変更する
proc deleteParent(E:seq[seq[int]]):seq[seq[int]] =
  var answer = newSeqWith(E.len,newSeq[int]())
  proc impl(pre,now:int) =
    for dst in E[now]:
      if dst == pre : continue
      answer[now] &= dst
      impl(now,dst)
  impl(-1,0)
  return answer
template useLCA() =
  # 最小共通祖先 構築:O(n),探索:O(log(n)) (深さに依存しない)
  type LowestCommonAncestor = ref object
    depth : seq[int]
    parent : seq[seq[int]] # 2^k 回親をたどった時のノード
    n:int
    nlog2 : int
  proc initLowestCommonAnsestor(E:seq[seq[int]],root:int = 0) : LowestCommonAncestor =
    new(result)
    # E:隣接リスト,root:根の番号,(0~E.len-1と仮定)
    # (import bitops)
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


useLCA()


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

# 木を造って根からの距離を保持してLCA分引く
let n = scan()
var E = newSeqWith(n,newSeq[int]())
(n-1).times:
  let u = scan()
  let v = scan()
  E[u] &= v
  E[v] &= u
E = E.deleteParent()
let lca = E.initLowestCommonAnsestor()
let C = newSeqWith(n,scan()) # cost
var C0 = newSeqWith(n,-1) # 0 からのcost
proc fillFrom0(i,c:int) =
  C0[i] = C[i] + c
  for dst in E[i]: fillFrom0(dst,C0[i])
fillFrom0(0,0)
var ans = 0
scan().times:
  let u = scan()
  let v = scan()
  let c = scan()
  let parent = lca.find(u,v)
  ans += (C0[u] + C0[v] - 2 * C0[parent] + C[parent]) * c
echo ans
