
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.19 & Nim 0.13)

ライブラリはご自由にお使いください

- lib/datastructure
  - セグメントツリー , BIT , BinaryHeap , UnionFind , Stack , Deque , ロリハ , スライド最小値
- lib/mathlib.nim
  - 行列(転置,乗算,累乗,加算,単位行列)
  - ModInt(nCk,累乗,除算)
  - 素数(SFF,素数表,素数リスト)
  - 算術(順列,組み合わせ,累乗,四捨五入)
- lib/functions.nim
  - 便利関数
- lib/geometry.nim
  - 幾何
- lib/graph.nim
  - グラフ
- lib/array.nim
  - 配列
-  lib/advanced.nim
  - 疎行列
  - memo.nim
    - ガウスの掃き出し法(only for bool)

# MEMO
- std::{ { intset , set(for int8), hashset}  | countTable | table | critbits}
- Sparse Table は 初期化O(nlog(n)) , 探索 O(log(log(n)))
- 多次元のBIT
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9
