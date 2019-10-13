import sequtils

# 根付き木にする
# (親も子も同一視して)双方向になっている木を,(0 番を)根として子のノードだけ持つように変更する
proc toRootedTree*(E:seq[seq[int]],root:int = 0):seq[seq[int]] =
  var answer = newSeq[seq[int]](E.len)
  for i in 0..<E.len: answer[i] = newSeq[int]()
  var stack = newSeq[tuple[pre,now:int]]()
  stack.add((-1,root))
  while stack.len > 0:
    let(pre,now) = stack.pop()
    for dst in E[now]:
      if dst == pre : continue
      answer[now].add(dst)
      stack.add((now,dst))
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

# 木のダブリング. 構築 O(NlogN) 探索:O(logN)
# どんな木でも、頂点πから頂点へのパス上のクエリを O(logN) で処理できる.
# verify: https://yukicoder.me/problems/no/386
type DoublingTree[T] = ref object
  n : int
  root : int # 根の番号[0,n)
  ranks: seq[int] # 各頂点の根からの深さ
  values: seq[T] # 自身の値
  traces: seq[seq[T]] # それぞれの 2^k 回親をたどった時の値
  parents: seq[seq[int]] # それぞれ 2^k 回親を辿ったときのindex
  apply: proc(x,y:T):T # 辺上を辿ったときの可換半群
  init : proc(i,rank:int):T # 初期化関数
proc newDoublingTree[T](E:seq[seq[int]],root:int = 0,apply:proc(x,y:T):T,init:proc(i,rank:int):T) : DoublingTree[T] =
  new(result)
  let n = E.len
  var ranks = newSeq[int](n)
  var values = newSeq[T](n)
  var traces = newSeq[seq[T]](n)
  var parents = newSeq[seq[int]](n)
  for i in 0..<n:
    traces[i] = @[]
    parents[i] = @[]
  # ひとつ上の親を辿った際の値を一度求める.
  var maxRank = 0
  var stack = newSeq[tuple[src,pre,rank:int]]()
  stack.add((root,-1,0))
  while stack.len > 0:
    let(src,pre,rank) = stack.pop()
    values[src] = init(src,rank)
    ranks[src] = rank
    if pre >= 0:
      traces[src] = @[values[src]]
      parents[src] = @[pre]
    for dst in E[src]:
      if dst != pre :
        stack.add((dst,src,rank+1))
  for i in 1..<1e12.int:
    var dirty = false
    for src in 0..<n:
      if i-1 >= parents[src].len: continue
      let mid = parents[src][i-1]
      if i-1 >= parents[mid].len: continue
      parents[src].add parents[mid][i-1]
      traces[src].add apply(traces[src][i-1],traces[mid][i-1])
      dirty = true
    if not dirty : break
  result.n = n
  result.root = root
  result.ranks = ranks
  result.values = values
  result.traces = traces
  result.parents = parents
  result.apply = apply
  result.init = init
proc trace[T](self:DoublingTree[T],u,v:int):T =
  if u == v : return self.init(u,self.ranks[u])
  var u = u
  var v = v
  # rankを揃える.
  if self.ranks[u] < self.ranks[v]: swap(u,v)
  let s1 = u
  let s2 = v
  result = self.init(v,self.ranks[v])
  while self.ranks[u] != self.ranks[v]:
    for pi in (self.parents[u].len-1).countdown(0):
      let parent = self.parents[u][pi]
      if self.ranks[parent] >= self.ranks[v]:
        result = self.apply(result,self.traces[u][pi])
        u = parent
        break
  var s3 = u
  if u != s2:
    result = self.apply(result,self.init(u,self.ranks[u]))
  while u != v :
    u = self.parents[u][0]
    v = self.parents[v][0]
    if u == v : break
    result = self.apply(result,self.traces[u][0])
    result = self.apply(result,self.traces[v][0])
    for i in (self.parents[u].len-1)..0:
      if self.parents[u][i] == self.parents[v][i]: continue
      result = self.apply(result,self.traces[u][i])
      result = self.apply(result,self.traces[v][i])
      u = self.parents[u][i]
      v = self.parents[v][i]
  if u != s1 and u != s2 and u != s3:
    result = self.apply(result,self.init(u,self.ranks[u]))
# 最小共通祖先(LCA) with ダブリング
# 祖先のindexとそのrankが得られる.
type IndexAndRank = tuple[i,rank:int]
proc LCA(E:seq[seq[int]],root:int = 0) : DoublingTree[IndexAndRank] =
  # パス上でrankが低いものを保持.
  E.newDoublingTree(root
    ,proc(x,y:IndexAndRank):IndexAndRank =
      if x.rank < y.rank: return x
      return y
    ,proc(i,rank:int):IndexAndRank = (i,rank)
  )

# パスの長さ with ダブリング
proc pathLength(E:seq[seq[int]],root:int = 0) : DoublingTree[int] =
  # 1 大きいので trace値-1 すること
  E.newDoublingTree(root
  ,proc(x,y:int):int = x + y
  ,proc(i,rank:int):int = 1)

# 全方位木DP. 0-indexed. 可換モノイド.
# Eは事前に両方向に代入して無向グラフにしておくこと.
# O(KNlogN).(K:DPの状態数)
# 普通は K < N だが, (入出力がいっぱいなので)スターグラフで死ぬ.
import sets,tables
proc allTreeDP[T](
    E:seq[seq[int]],
    apply:proc(x,y:T):T,
    init:proc(i:int):T,
    final:proc(i:int,sum:T):T) : seq[T] =
  var dp = newSeq[Table[int,T]](E.len)
  for i in 0..<E.len: dp[i] = initTable[int,T]()
  proc dfs(src,pre:int) : T =
    if pre in dp[src]: return dp[src][pre]
    result = init(src)
    for dst in E[src]:
      if dst != pre:
        result = apply(result,dfs(dst,src))
    result = final(src,result)
    dp[src][pre] = result
  result = newSeq[T](E.len)
  for i in 0..<E.len: result[i] = dfs(i,-1)

# 1頂点の木のDP. 0-indexed. 可換モノイド.
proc treeDP[T](
    E:seq[seq[int]],
    root:int,
    apply:proc(x,y:T):T,
    init:proc(i:int):T) : seq[T] =
  var E = E.toRootedTree(root)
  var dp = newSeq[T](E.len)
  proc dfs(src:int) : T  =
    result = init(src)
    for dst in E[src]:
      result = apply(result,dfs(dst))
  discard dfs(root)
  return dp


# 適当な s から最も遠い u を求め, uから最も遠い v を求めるとそれが 最遠頂点 のペアとなり長さlも求まる.
# 離心数 : 最遠頂点までの距離
# 直径 : 離心数の最大値
# 半径 : 離心数の最小値
# 中心 : 離心数が最小となる頂点
# 木の直径と端点 O(N)
proc diameter(E:seq[seq[int]]): tuple[l,u,v:int] = 
  proc impl(pre,src:int) : tuple[l,u:int] =
    result = (0,src)
    for dst in E[src]:
      if dst == pre : continue
      var t = impl(src,dst)
      t.l += 1
      if t.l > result.l: result = t
  let r = impl(-1,0)
  let t = impl(-1,r.u)
  return (t.l,t.u,r.u)
# 木の中心と半径 O(NlogN)
proc center(E:seq[seq[int]]): tuple[l,c:int] = 
  # 全頂点から最も遠い位置までの距離を全方位木DPして最小値を取る
  type WithIndex[T] = tuple[i:int,val:T]
  let dp = E.allTreeDP(
    proc(x,y:WithIndex[int]):WithIndex[int] =
      if x.val > y.val : return  x
      return  y
    ,
    proc(i:int):WithIndex[int] = (i,-1),
    proc(i:int,sum:WithIndex[int]):WithIndex[int] = (sum.i,sum.val+1),
  )
  result = (1e12.int,1e12.int)
  for src,d in dp:
    let(dst,length) = d
    if length < result.l:
      result.l = length
      result.c = src 





when isMainModule:
  import unittest,times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")  
  # import "./testgraph"
  block:
    # let E = createRandomTree(1e4.int,1.0)
    # E.graphviz()
    # stopwatch:echo E.center()
    # stopwatch: echo E.diameter()
    # let lca = E.pathLength(0)
    # echo E.diameter()
    # import strutils
    # E.graphviz(labels=lca.traces.mapIt(($it).replace("\"","")))
    # E.graphviz(labels=toSeq(0..9).mapIt($it))
    # for i in 0..<10:
    #   for j in 0..<10:
    #     echo i,":",j,":",lca.trace(i,j)
    discard
  test "tree":
    let E = @[@[1,2],@[0,3],@[0],@[1]]
    check: E.toRootedTree == @[@[1, 2], @[3], @[], @[]]
    check: E.toRootedTree.eulerTour().toured == @[(0..<4),(1..<3),(3..<4),(2..<3)]
    check: E.toRootedTree.eulerTour().rev == @[0,1,3,2]
    let lca = E.LCA()
    check: lca.trace(1,3).i == 1
    check: lca.trace(0,3).i == 0
    check: lca.trace(1,2).i == 0
  test "alltreedp":
    # 例: 全頂点から最も遠い位置(同じ場合はindexが小さい方)までの距離
    let E = @[@[1], @[0, 2, 3], @[1], @[1]]
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
