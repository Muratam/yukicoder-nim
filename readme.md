# Nim の競技プログラミングライブラリ

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master)

- lib/datastructure
  - セグメントツリー / BIT
  - BinaryHeap
  - Union-Find
  - Stack / Deque
  - ロリハ
  - スライド最小値
- lib/mathlib.nim
  - 数学
- lib/functions.nim
  - 便利関数
- lib/geometry.nim
  - 幾何
- lib/graph.nim
  - グラフ
- lib/array.nim
  - 配列
- lib/memo.nim
  - 汎用的ではない関数のメモ用


# MEMO
- std::{ { intset , set(for int8), hashset}  | countTable | table | critbits}
- Sparse Table は 初期化O(nlog(n)) / 探索 O(log(log(n)))
- 多次元のBIT
