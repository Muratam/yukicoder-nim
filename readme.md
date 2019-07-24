
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.20 & Nim 0.13)

ライブラリはご自由にお使いください
- lib/datastructure
  - セグメントツリー , BIT , BinaryHeap , UnionFind , Stack , Deque , ロリハ , スライド最小値
- lib/cpp
  - std::{set,multiset} (min / max / >= がO(log(N)))
  - std::vector / std::priority_queue : 互換性のため
- lib/mathlib
  - matrix : 行列(転置,乗算,累乗,加算,単位行列)
  - modint : ModInt (nCk,累乗,除算)
  - prime : 素数(SFF,素数表,素数リスト)
  - search : 二分探索 / 三分探索
  - arith : 算術(順列,組み合わせ,累乗,四捨五入)
  - radix : 基数(2進数,10進数,ビット演算)
  - sequence : LIS(最長増加部分列) / counttable(0.13でのバグ無しver) / deduplicate
- lib/graph
  - Normalize(強連結成分分解 O(V+E), 重軽分解)
  - Tree(入力を木に,LCA(最小共通祖先 構築:O(n),探索:O(log(n)) (深さに依存しない)))
  - DAG(トポロジカルソート)
  - MST(最小全域木 O(ElogV))
  - ShortestPath( O(ElogE) | 負有り:O(EV) | 全:O(V^3))
  - Flow(最小費用流 O(FElogV) | 最大流/最小カット O(FE) / O(EV^2) | 二部グラフの最大マッチング O(E))
- lib/functions.nim (いつもの IO , Pos4)
- lib/no_test (未テスト段階)
  - sparsematrix.nim : 疎行列
  - geometry.nim : 幾何
  - array.nim : 配列
  - memo.nim
    - ガウスの掃き出し法(only for bool)
    - フィボナッチ数列の第N項

# MEMO
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9

# TODO
- lib/graph は問題によって正しさを証明したい
