import sequtils

# 隣接リスト => 隣接行列
# 有向グラフ(E[src][dst] => M[src][dst])
proc toMatrix(E:seq[seq[int]]):seq[seq[bool]] =
  result = newSeqWith(E.len,newSeq[bool](E.len))
  for src, dsts in E:
    for dst in dsts:
      result[src][dst] = true
proc fromMatrix(M:seq[seq[bool]]):seq[seq[int]] =
  result = newSeqWith(M.len,newSeq[int]())
  for src in 0..<M.len:
    for dst in 0..<M.len:
      if M[src][dst] : result[src].add dst
proc coGraph(M:seq[seq[bool]]):seq[seq[bool]] =
  result = newSeqWith(M.len,newSeq[bool](M.len))
  for src in 0..<M.len:
    for dst in 0..<M.len:
      result[src][dst] = not M[src][dst]
proc coGraph(E:seq[seq[int]]):seq[seq[int]] =
  E.toMatrix().coGraph().fromMatrix()

# 最大クリーク / 最大独立集合 O(N * √2^N)
# 最大クリーク : グラフ中の完全グラフの中で最大のもの
# 最大独立集合 : 互いに辺が存在しないグラフの中で最大のもの
import math
import "../datastructure/set/bitset"
proc maximumIndependentSet(M:seq[seq[bool]]) : seq[int] =
  let n = M.len
  var G = newSeq[BitSet](n)
  var usable = 0
  for i in 0..<M.len:
    G[i] = M[i].fromBoolSeq()
    usable[i] = true
  proc impl(usable:BitSet): seq[int] =
    var v = -1
    var usable = usable
    result = @[]
    for i in 0..<n:
      if not usable[i] : continue
      let neighbor = (usable and G[i]).len
      if neighbor > 1: v = i
      else:
        usable[i] = false
        usable = usable and not G[i]
        result.add i
    if v < 0 : return result
    usable[v] = false
    var res1 = impl(usable and not G[v])
    res1.add v
    var res2 = impl(usable)
    if res1.len > res2.len: result.add res1
    else: result.add res2
  return impl(usable)
proc maximumClique(M:seq[seq[bool]]):seq[int] =
  M.coGraph.maximumIndependentSet()


# 彩色数 O(2^N N)
# 隣接する頂点が異なる色として必要な最小の色数
# https://ei1333.github.io/luzhiled/snippets/graph/chromatic-number.html
# テストしてないので...
proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc chromaticNumber(M:seq[seq[bool]]) : int =
  let n = M.len
  var E = newSeq[int](n)
  for src in 0..<n:
    for dst in 0..<n:
      E[src] = E[src] or (M[src][dst].int shl dst)
  result = n
  for d in [7,11,21]:
    let MOD = 1e9.int + d
    var ind = newSeq[int](1 shl n)
    var aux = newSeqWith(1 shl n,1)
    ind[0] = 1
    for s in 1..<1 shl n:
      let u = cast[culonglong](s).countTrailingZeroBits()
      ind[s] = ind[s xor (1 shl u)] + ind[(s xor (1 shl u)) and (not E[u])]
    for i in 1..<result:
      var all = 0
      for j in 0..<1 shl n:
        let s = j xor (j shr 1)
        aux[s] = (aux[s] * ind[s]) mod MOD
        if (j and 1) != 0: all += aux[s]
        else: all += MOD - aux[s]
      if 0 != all mod MOD :
        result = i

when isMainModule:
  import sequtils
  import unittest
  test "AdjMatrix":
    var M = @[@[1,1,1,0],@[1,1,1,1],@[1,1,1,1],@[1,1,1,1]].mapIt(it.mapIt(it.bool))
    check: 3 == M.chromaticNumber()
