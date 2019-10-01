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

# 最大クリーク  O(N * 2^{√2M})
# =   グラフ中の完全グラフの中で最大のもの
# cf: 補グラフの最大クリークは最大独立集合(頂点間に枝が存在しない最大のもの).
# proc maximumClique(M:seq[seq[bool]]) : seq[int] =

# 彩色数 O(2^N N)
# 隣接する頂点が異なる色として必要な最小の色数
# proc chromaticNumber(M:seq[seq[int]]) : int =
