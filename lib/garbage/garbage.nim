# なにもわからないよー
# https://lumakernel.github.io/ecasdqina/graph/DP-all-subtree
# https://ei1333.hateblo.jp/entry/2017/04/10/224413
# 0-indexed. 森でも可能. 事前に両代入して無向グラフにしておくこと.
# るま式全方位木DP. O(KNlogN). (K:DPのステート数)
proc allSubTreeDP[T](
    E:seq[seq[int]],
    apply:proc(x,y:T):T,
    init:proc(i:int):T) : seq[Table[int,T]] =
  var dp = newSeqWith(E.len,initTable[int,T]())
  var initial = true
  proc dfs(src,pre:int) : T {.discardable.} =
    if pre in dp[src]: return dp[src][pre]
    result = init(src)
    if initial or pre == -1:
      for dst in E[src]:
        if dst != pre:
          result = apply(result,dfs(dst,src))
    else:
      dfs(src,-1)
      dfs(pre,src)
    # let deg = E[src].len + (if pre != -1 : -1 else: 0)
    dp[src][pre] = result
  dfs(0,-1)
  initial = false
  for i in 0..<E.len: dfs(i,-1)
  return dp



# セグツリ
# 加算なら
proc findMinKey*[T](self:SegmentTree[T],cond:proc(x:T):bool) : int =
  if not cond(self.data[0]): return -1
# 単純な二部探索を外側に噛ますと O((logN)^2) になるので、セグツリで検索する
# この木の中に解がある.isRightならなるべく右を,isLeftならなるべく左を探す.
proc findSubTree*[T](self:SegmentTree[T],cond:proc(x:T):bool,i:int,v:T,isRight:bool) : int =
  var i = i
  var v = v
  while i < self.n - 1: # 葉に着くまで
    let nextI = (2*i) + (if isRight:2 else:1)
    let next =
      if isRight: self.apply(self.data[nextI],v)
      else: self.apply(v,self.data[nextI])
    if cond(next): i = nextI
    else:
      v = next
      i = (2*i) + (if isRight:1 else:2)
  return i - self.size + 1
# [offset..x] の中で条件を満たす最小のキー
proc findMinKey*[T](self:SegmentTree[T],cond:proc(x:T):bool,offset:int=0) : int =
  var offset = 0.max(offset)
  # 全ての範囲は割とよく探すので特別扱い
  if offset == 0:
    if cond(self.data[0]):
      return self.findSubTree(cond,0,self.unit,false)
    return -1
  offset += self.n-1
  while offset > 0: # 葉から登っていく
    if cond(self.data[offset]):
      return self.findSubTree(cond,offset,self.unit,false)
    offset = (offset-1) shr 1
