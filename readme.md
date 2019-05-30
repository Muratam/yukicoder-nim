
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.19 & Nim 0.13)

ライブラリはご自由にお使いください

- lib/datastructure
  - セグメントツリー , BIT , BinaryHeap , UnionFind , Stack , Deque , ロリハ , スライド最小値
- lib/mathlib
  - 行列(転置,乗算,累乗,加算,単位行列)
  - ModInt(nCk,累乗,除算)
  - 素数(SFF,素数表,素数リスト)
  - 算術(順列,組み合わせ,累乗,四捨五入)
  - 基数(2進数,10進数)
  - カウント()
- lib/graph.nim
  - 正規化(トポロジカルソート,入力を木に)
- lib/functions.nim (いつもの IO , Pos4)
- lib/no_test (未テスト段階)
  - sparsematrix.nim : 疎行列
  - geometry.nim : 幾何
  - array.nim : 配列
  - memo.nim
    - ガウスの掃き出し法(only for bool)
    - フィボナッチ数列の第N項

- no_test:
  - lib/graph*
  - lib/mathlib/radix.nim
  - lib/mathlib/count.nim
  - lib/functions.nim
  - lib/no_test/*

# MEMO
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9
