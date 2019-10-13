import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)

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
  E[u] .add v
  E[v] .add u
let lca = E.LCA(0)
let ER = E.toRootedTree(0)
let C = newSeqWith(n,scan()) # cost
var C0 = newSeqWith(n,-1) # 0 からのcost
block:
  var stack = newSeq[tuple[i,c:int]]()
  stack.add((0,0))
  while stack.len > 0:
    let(i,c) = stack.pop()
    C0[i] = C[i] + c
    for dst in ER[i]: stack.add((dst,C0[i]))
var ans = 0
scan().times:
  let u = scan()
  let v = scan()
  let c = scan()
  let parent = lca.trace(u,v).i
  ans += (C0[u] + C0[v] - 2 * C0[parent] + C[parent]) * c
echo ans
