# 無向グラフの関節点/橋を探す.取り除くと非連結になるもの
# O(V)
proc lowLink(E:seq[seq[int]]): tuple[
      lowV:seq[int], #[ 関節点 ]#
      lowE:seq[tuple[src,dst:int]]] #[ 橋 ]# =
  var lowV = newSeq[int]()
  var lowE = newSeq[tuple[src,dst:int]]()
  var used = newSeq[bool](E.len)
  var ords = newSeq[int](E.len)
  var lows = newSeq[int](E.len)
  var k = 0
  proc dfs(src,pre:int)  =
    used[src] = true
    ords[src] = k
    lows[src] = k
    k += 1
    var isLowV = false
    var cnt = 0
    for dst in E[src]:
      if not used[dst]:
        cnt += 1
        dfs(dst,src)
        lows[src] = lows[src].min(lows[dst])
        # -pre = 1
        if not isLowV :
          isLowV = (pre != -1) and (lows[dst] >= ords[src])
        if ords[src] < lows[dst] :
          if src < dst : lowE.add((src,dst))
          else: lowE.add((dst,src))
      elif dst != pre:
        lows[src] = lows[src].min(ords[dst])
    if not isLowV : isLowV = pre == -1 and cnt > 1
    if isLowV : lowV.add src
  for i in 0..<E.len:
    if not used[i] : dfs(i,-1)
  return (lowV,lowE)

# 二重辺連結成分分解
# 1個の辺を取り除いても連結な部分グラフ
# https://ei1333.github.io/luzhiled/snippets/graph/two-edge-connected-components.html

# 二重頂点連結成分分解
# 1個の頂点を取り除いても連結な部分グラフ
# https://ei1333.github.io/luzhiled/snippets/graph/bi-connected-components.html

# オイラー路.いわゆる一筆書き. O(E)
# {有向,無向} グラフの全ての辺をちょうど1回ずつ通る路
# https://ei1333.github.io/luzhiled/snippets/graph/eulerian-trail.html

when isMainModule:
  import unittest
  import sequtils
  test "Low Link":
    var E = newSeqWith(7,newSeq[int]())
    for xy in @[(0,1),(1,2),(2,0),(0,3),(0,4),(3,4),(4,5),(5,6)]:
      E[xy[1]].add xy[0]
      E[xy[0]].add xy[1]
    let (lowV,lowE) = E.lowLink()
    check: lowV == @[5, 4, 0]
    check: lowE == @[(5,6),(4,5)]
