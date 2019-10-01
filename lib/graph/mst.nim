
import sequtils,algorithm
import "../datastructure/unionfind"
# 最小全域木(無効グラフ) O(ElogV)
# 最小全域木のコスト(max / sum)を返却
#  0..<maxN, E:辺のリスト(コスト順に並び替えるため)
type Edge = tuple[src,dst,cost:int]
proc kruskal(E:seq[Edge],maxN:int) : int =
  var uf = newUnionFind[int](maxN)
  for e in E.sortedByIt(it.cost):
    if uf.same(e.src,e.dst) : continue
    uf.merge(e.src,e.dst)
    result = result.max(e.cost)
    # if uf.same(0,maxN-1): break # 繋げたい点があれば
# Priority Queueで最小辺を更新していく(Prim)方法でも O(ElogV)

# 最小全域有向木 Chu-Liu/Edmond O(ElogV)
# ある頂点から全ての頂点への経路が存在する木のうち最小コストのものを求める
# https://ei1333.github.io/luzhiled/snippets/graph/chu-liu-edmond.html
