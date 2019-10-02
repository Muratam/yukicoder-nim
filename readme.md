
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.20 & Nim 0.13)

ライブラリはご自由にお使いください
- lib/datastructure
  - UnionFind
  - `queue/` :: Stack, Queue, Deque
  - `segmenttree/` :: クエリが O(logN) 以下
    - セグメントツリー{1D,2D} :: 一点更新, 区間取得
    - BIT :: 一点更新, 区間和
    - StarrySkyTree :: 区間更新(加算),区間取得
  - `heap/`　:: 追加・削除 O(logN) 以下
    - BinaryHeap : 最小値 O(1)
    - SkewHeap : ↑ + マージ O(1)
    - TODO: 二進パトリシア木
  - `string/`
    - ロリハ(通常/軽量) :
    - SA-IS: 接尾辞配列 O(S)
    - Z-algorithm: 最長共通接頭辞 O(S)
    - TODO: トライ木
  - `seq/`
    - search : 二分探索 / 三分探索 / lowerBoundの `< <= > >=` 表記
    - LIS : 最長増加部分列
    - slidemin : スライド最小値
    - sequence : arg{min,max} / deduplicate
    - iteration : 順列 / ペア順列 / 階段 / bitDP
  - `cpp/`
    - std::{set,multiset} (min / max / >= がO(log(N)))
    - std::vector / std::priority_queue : 互換性のため
- lib/mathlib
  - matrix : 行列(転置,乗算,累乗,加算,単位行列)
  - modint : ModInt (累乗,除算)
  - prime : 素数(SFF,素数表,素数リスト)
  - arith : 算術(順列,組み合わせ,累乗,四捨五入)
  - radix : 基数(2進数,10進数,ビット演算)
  - count : 数え上げ(nCk,カタラン数,第2種スターリング数,x:ベル数,sternBrocotTree(有理数列挙))
  - random : 乱数(Nim0.13用,時間制限まで乱択)
- lib/graph
  - Tree :: 入力を木に,オイラーツアー,最小共通祖先(LCA:探索O(log(n)))
  - DAG :: トポロジカルソート,DAG判定, 強連結成分分解(SCC:O(V+E))
  - MST :: 最小全域木 O(ElogV)
  - ShortestPath :: 最短経路 , O(ElogE) | 負有り:O(EV) | 全:O(V^3)
  - Flow :: 最小費用流 , O(FElogV) | 最大流/最小カット O(FE),O(EV^2) | 二部グラフの最大マッチング O(E)
  - Link :: 橋,関節点 ,x:一筆書き(オイラー路)
  - TODO: AdjMatrix(隣接行列: 補グラフ/変換/最大クリーク(最大独立集合)/(最小)彩色数)
  - TODO: Testgraph(テストケース)
- lib/geometry
  - geometry(二次元幾何(複素数))
  - pos(二次元座標,dxdy4,dxdy8,Pos)
- lib/functions.nim (いつもの + IO)
- lib/garbase : 書き捨てたコード
  - sparsematrix : 疎行列
  - math : フィボナッチ数列の第N項 / 線形回帰(最小二乗法)
  - sequence : countContinuity / toCountTable / toTuple / cmp ...

# MEMO
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9
- with C++: https://qiita.com/sessions/items/96c57a4dad9246d2cd59
- introduction : https://chy72.hatenablog.com/entry/2017/12/16/214708
- AtCoder Beginners Selection : https://chy72.hatenablog.com/entry/2019/07/10/212911

# TODO
- lib/graph は問題によって正しさを証明したい
