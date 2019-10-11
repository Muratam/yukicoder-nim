import sequtils
import "../mathlib/random"
import "../datastructure/set/unionfind"
# (双方向の) ランダムな木を生成する. 0..<n
# p : [0.0,1.0] : 新しい点をつなぐ場所が昔のものになるか最近のものになるか.
#   0.0:スターグラフ - 0.5:平衡な木 - 1:直線
proc createRandomTree*(n:int,p:float = 0.5) : seq[seq[int]] =
  echo "SEED:",xorShiftVar
  result = newSeqWith(n,newSeq[int]())
  if n <= 1 : return
  var p = 0.0.max(1.0.min(p))
  let a = if p <= 0.5: 0.0 else:  2 * p - 1.0
  let b = if p >= 0.5: 1.0 else:  2 * p
  var order = toSeq(0..n-1)
  order.shuffle()
  for i in 1..<n: # [0,i) につなぐ.
    let d = (i.float * (b - a)).int.abs().max(1)
    let next = ((i.float * a) + random(d).float).int.min(i-1).max(0)
    result[order[next]].add order[i]
    result[order[i]].add order[next]

# (単方向の) ランダムなDAGを生成する. 0..<n
# p : [0.0,1.0] : 新しい点をつなぐ場所が昔のものになるか最近のものになるか.
# 0.0:スターグラフ的なDAG - 0.5:平衡なDAG - 1.0:直線的なDAG
# q : どのくらいの割合でつなぐか
# 0.0: 1ノード1本の遷移 - 0.5 割とランダムに 1.0:限界まで
import tables
proc createRandomDAG*(n:int,p:float = 0.5,q:float = 0.5): seq[seq[int]] =
  echo "SEED:",xorShiftVar
  result = newSeqWith(n,newSeq[int]())
  if n <= 1 : return
  var p = 0.0.max(1.0.min(p))
  var q = 0.0.max(1.0.min(q))
  let a = if p <= 0.5: 0.0 else:  2 * p - 1.0
  let b = if p >= 0.5: 1.0 else:  2 * p
  var order = toSeq(0..n-1)
  order.shuffle()
  for i in 1..<n: # [0,i) につなぐ.
    # i * q 本つなぐ
    var nexts = initTable[int,bool]()
    for j in 0..(random(i).float*q*2).int:
      let d = (i.float * (b - a)).int.abs().max(1) + j
      let next = ((i.float * a - j.float) + random(d).float).int.min(i-1).max(0)
      nexts[next] = true
    for next,_ in nexts:
      # result[order[next]].add order[i]
      result[order[i]].add order[next]

# ランダムなグラフを生成する. 0..<n
# v: 頂点数
# e: 一つのノードがつながるノード数の平均値. [1..v]
#  : 1だと1ノードから1本しかつながらない, v だとほぼ完全グラフに
# connected: 連結グラフの必要があるか
proc createRandomGraph*(v:int,e:float,connected:bool=true): seq[seq[int]] =
  echo "SEED:",xorShiftVar
  result = newSeqWith(v,newSeq[int]())
  if v <= 1 : return
  var cn = newSeq[Table[int,bool]](v)
  for i in 0..<v:cn[i] = initTable[int,bool]()
  for i in 0..<(v.float*e).int.max(1):
    let src = random(v)
    let dst = random(v)
    if src == dst : continue
    cn[src][dst] = true
  var uf = initUnionFind(v)
  for src in 0..<v:
    for dst,_ in cn[src]:
      result[src].add dst
      uf.merge src,dst
  if not connected: return
  let center = random(v)
  for i in 0..<v:
    if uf.same(center,i): continue
    uf.merge(center,i)
    if random(2) == 0:
      result[i].add center
    else:
      result[center].add i

import os,osproc
proc graphviz*(E:seq[seq[int]],filename:string = "x",layout:string = "dot") =
  var graph = """
    digraph  {
      layout = """" & layout & """";
      overlap = false;
      splines = false;
      node[
        landscape = true,
        fontname = "Helvetica",
        style = "filled",
        fillcolor = "#fafafa",
        shape = box,
        style = "filled, bold, rounded"
      ];
      edge[
        # len = 0.1,
        fontsize = "8",
        fontname = "Helvetica",
        # style = "dashed",
    ];"""
  for src,dsts in E:
    for dst in dsts:
      graph.add "a" & ($src) & " -> a" & ($dst) & ";\n"
  graph.add "}"
  let f = open(filename&".dot",FileMode.fmWrite)
  f.writeLine graph
  f.close()
  discard execProcess("dot -Tpng "&filename&".dot > /tmp/"&filename&".png")
  discard execProcess("open /tmp/"&filename&".png")
  discard execProcess("rm "&filename&".dot")

when isMainModule:
  let E = createRandomTree(10,0.5)
  # createRandomTree(10,0.5).graphviz()
  # createRandomDAG(10,0.5,1.0).graphviz()
  # createRandomGraph(10,3.0).graphviz(layout="neato")
