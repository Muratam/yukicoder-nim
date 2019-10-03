
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.20 & Nim 0.13)

ライブラリはご自由にお使いください
- `lib/datastructure` :: データ構造
  - UnionFind : 森のマージ・根の取得 O(1)
  - bitset : ビット演算の集合.
  - `queue/` :
    - Deque, Queue, Stack : 末尾・先頭への追加削除 O(1)
    - PriorityQueue : 最小値検索 O(1), 追加・最小値削除　O(logN)
    - SkewHeap : ↑ + マージ O(logN)
  - `segmenttree/` :: 区間クエリ O(logN)
    - セグメントツリー{1D,2D} : 一点更新, 区間取得
    - BIT : 一点更新, 区間和
    - StarrySkyTree : 区間更新(加算),区間取得
  - `tree/`　:: 追加・削除・クエリ O(logN)
    - kd木
    - TODO: トライ木
  - `string/` :: 構築 O(S). 文字列検索用.
    - ロリハ(通常/軽量) : 部分文字列同一判定 O(1)
    - SA-IS : 文字列全検索 O(MlogS)
    - Z-algorithm: S と S[i:] の 同一prefix長 O(1)
  - `seq/`
    - search : 二分探索 / 三分探索 / lowerBoundの `< <= > >=` 表記
    - LIS : 最長増加部分列
    - slidemin : スライド最小値
    - sequence : arg{min,max} / deduplicate / 10進数と配列変換
    - iteration : 順列 / ペア順列 / 階段
  - `cpp/`
    - std::{set,multiset} (min / max / >= がO(log(N)))
    - std::vector / std::priority_queue : 互換性のため
- `lib/mathlib` :: 数学
  - matrix :: 行列(転置,乗算,累乗,加算,単位行列)
  - modint :: ModInt (累乗,除算)
  - prime :: 素数(SFF,素数表,素数リスト)
  - arith :: 算術(順列,組み合わせ,累乗,四捨五入)
  - count :: 数え上げ(nCk,カタラン数,第2種スターリング数,x:ベル数,sternBrocotTree(有理数列挙))
  - random :: 乱数(xorShift,時間制限内乱択)
  - geometry :: 二次元(複素数)幾何
- `lib/graph` :: グラフ理論
  - Tree :: 入力を木に,オイラーツアー,最小共通祖先(LCA:探索O(log(n)))
  - DAG :: トポロジカルソート,DAG判定, 強連結成分分解(SCC:O(V+E))
  - MST :: 最小全域木 O(ElogV)
  - ShortestPath :: 最短経路 , O(ElogE) | 負有り:O(EV) | 全:O(V^3)
  - Flow :: 最小費用流 , O(FElogV) | 最大流/最小カット O(FE),O(EV^2) | 二部グラフの最大マッチング O(E)
  - Link :: 橋,関節点 ,x:一筆書き(オイラー路)
  - TODO: AdjMatrix(隣接行列: 補グラフ/変換/最大クリーク(最大独立集合)/(最小)彩色数)
  - TODO: Testgraph(テストケース)
- lib/functions.nim (いつもの / IO / Pos)
- lib/garbase : 書き捨てたコード.いつか使う時はくるのか...?
  - 二進パトリシア木 : k番目の最小値が取れるheap
  - timecost : 演算の速度検証
  - sparsematrix : 疎行列
  - math : フィボナッチ数列の第N項 / 線形回帰(最小二乗法)
  - sequence : countContinuity / toCountTable / toTuple / cmp ...

# MEMO
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9
- with C++: https://qiita.com/sessions/items/96c57a4dad9246d2cd59
- introduction : https://chy72.hatenablog.com/entry/2017/12/16/214708
- AtCoder Beginners Selection : https://chy72.hatenablog.com/entry/2019/07/10/212911
