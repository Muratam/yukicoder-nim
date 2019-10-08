
# Nimで競プロ！

[![CircleCI](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master.svg?style=svg)](https://circleci.com/gh/Muratam/yukicoder-nim/tree/master) (Nim 0.20 & Nim 0.13)

ライブラリはご自由にお使いください
- lib/template.nim :: 競プロテンプレート
- `lib/datastructure` :: データ構造
  - `queue/` : Deque, Queue, Stack : 末尾・先頭への追加削除 O(1)
  - `segmenttree/` :: 区間モノイドクエリ O(logN).
    - セグメントツリー{1D,2D} : 一点更新, 区間取得
    - StarrySkyTree: 区間更新(可換モノイド演算), 区間取得
    - PatriciaSegmentTree : 2進パトリシア木(キー)+セグツリ(値).
      - キー : 最大,最小,検索,要素数,{以上,以下}列挙,k番目,xor
      - 値　 : 一点更新, 区間取得
    - セグメントツリー亜種
      - BIT : 制限が多いが速い. 一点更新, 区間[**0**,T]の取得.
      - Sparse*: 更新点を先読みして座標圧縮.
      - Mapped*: T(生値)->R(集約値=モノイド)
  - `set/` :: 集合. 動的に要素を追加・削除可能
    - std::{set,multiset} :: 追加・削除・検索・最{小,大}値・{以上,以下}列挙 O(logN)
    - UnionFind : 森のマージ・根の取得 O(1)
    - bitset : ビット演算の集合.
    - PriorityQueue : 最小値検索 O(1), 追加・最小値削除　O(logN)
    - SkewHeap : ↑ + マージ O(logN)
  - `string/` :: 構築 O(S). 文字列用.
    - ロリハ(通常/軽量) : 部分文字列同一判定 O(1)
    - SA-IS : prefix検索(個数,{上,下}界) O(PlogS)
- `lib/mathlib` :: 数学
  - matrix :: 行列(転置,乗算,累乗,加算,単位行列)
  - modint :: ModInt (累乗,除算)
  - prime :: 素数(SFF,素数表,素数リスト)
  - arith :: 算術(順列,組み合わせ,累乗,四捨五入)
  - count :: 数え上げ(nCk,カタラン数,第2種スターリング数,x:ベル数,sternBrocotTree(有理数列挙))
  - random :: 乱数(xorShift)
  - geometry :: 二次元(複素数)幾何
- `lib/graph` :: グラフ理論
  - Tree :: 入力を木に,オイラーツアー,最小共通祖先(LCA:探索O(log(n)))
  - DAG :: トポロジカルソート,DAG判定, 強連結成分分解(SCC:O(V+E))
  - MST :: 最小全域木 O(ElogV)
  - ShortestPath :: 最短経路 [ O(ElogE), 負有り:O(EV), 全:O(V^3) ]
  - Flow :: 最小費用流 [ O(FElogV) , 最大流/最小カット O(FE),O(EV^2) , 二部グラフの最大マッチング O(E) ]
  - Link :: 橋,関節点
  - AdjMatrix :: 隣接行列, 補グラフ | 彩色数 O(2^N N) | 最大{クリーク,独立集合} O(N * √2^N)
- `lib/seq/` :: seqを操作
  - search : {二,三}分探索 / lowerBound <-> `< <= > >=`  / 座標圧縮
  - LIS : 最長増加部分列
  - slidemin : スライド最小値
  - sequence : arg{min,max} / deduplicate / 10進数と配列変換
  - iteration : 順列 / ペア順列 / 階段

# MEMO
- Nim 0.13: https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9
- with C++: https://qiita.com/sessions/items/96c57a4dad9246d2cd59
- introduction : https://chy72.hatenablog.com/entry/2017/12/16/214708
- AtCoder Beginners Selection : https://chy72.hatenablog.com/entry/2019/07/10/212911
- [競プロでNimを書く時に気をつけるべきこと](./memo.md)

# 個人的 Nim 競プロ用テンプレート
```nim
import sequtils,algorithm,math,tables,sets,strutils,times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template time(n:int,body) = (for _ in 0..<n: body)
template `max=`(x,y) = x = max(x,y)
template `min=`(x,y) = x = min(x,y)
proc getchar():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)
#
let n = scan()
let A = newSeqWith(n,scan())
```
- `import` : 競プロでよく使うのはこの7つ. 特に以下は頻出.
  - `sequtils` : `newSeqWith`,`toSeq`,`.mapIt`
  - `algorithm`: `sorted(cmp)`,`sortedByIt`,`lowerBound`,`reversed`,`nextPermutation`
  - `math` : `n.float.sqrt.int`,`gcd`,`lcm`
  - `tables`,`sets`: `Table[K,V]`,`HashSet[K]`
- また,何も import しなくても以下の便利機能が使える
  - `seq`: `newSeq[T](n)`,`.len`,`.add`,`&`,`x[a..b]`,`.pop`,`in`,`@[1,2]`
  - iterator : `a..b`, `a..<b`, `(n-1).countdown(0)`
  - 型変換 : `.int`,`.ord`,`.chr`,`$`,`cast[T](x)`
  - ほか : `max`,`min`,`abs`,`cmp`,`1e12.int`,`quit`
- また,以下の関数を定義しています
  - `stopwatch: ...` で時間を計測できる.結果は標準エラー出力に流れるのでそのまま提出してもAC可能.スコープも変わらないので元のコードから単純にインデントを深くするだけでよい.
  - `n.time: ...` で n回ループを回せる.forループに比べてループ変数が増えないため,i番目であるという情報が不要ということが把握しやすい.
  - `.max=`,`.min=` : `dp[i][k] = max(dp[i][k],dp[i][j])` が,`dp[i][k] .max= dp[i][j]` として書ける. 必須.
  - `getchar` : 一文字だけ入力を進めたいとき. グリッド上の探索系の問題とか
  - `scanf`と`scan`: intを一つ入力から取る. 例えば配列の入力を受け取る際に普通に書くと `stdin.readLine.split().map(parseInt)` か `newSeqWith(n,stdin.readLine.parseInt)` のように書かなければいけないのが, どちらも `newSeqWith(n,scan())` と書けて便利.
    - 例えば三次元の入力でも `newSeqWith(n,(x:scan(),y:scan(),z:scan()))` と臨機応変に書けてお得.

# Nimの実行スクリプト
`nim c -r hoge.nim` でもいいですが,以下を .bashrc にでも書いておくと幸せになれます.
```bash
nimcompile() { nim cpp --hints:off --verbosity:0 $@ ; }
nimr() { # 実行後に邪魔な実行可能ファイルを消してくれる
  exename="$(echo $1 | sed 's/\.[^\.]*$//')"
  nimcompile $NIMR_COMPILE_FLAG -r $@
  [[ -f $exename ]] && rm $exename
}
nimrr() { NIMR_COMPILE_FLAG="-d:release" nimr $@ ; }
```
- 普通に即実行(落ちるとスタックトレースを表示してくれる) : `nimr hoge.nim`
- デバッグ情報を消して最適化して実行 : `nimrr hoge.nim`
