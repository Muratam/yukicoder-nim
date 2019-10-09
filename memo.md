# 競プロ で Nim を使うことについて
Nimめっちゃ大好きなのでまとめました.

# 競プロ で Nim を使う利点
Nimは(C++並みの)速さと書きやすさを備えた最強の言語で競プロ向きです.
1. 速いので安心. 富豪的な書き方をしても間に合う.
1. 静的型付け. 知ってますか,Compile Error は Runtime Error ではないのでペナルティはありません.
1. 変数を dump しやすい. `std::vector` を `cout` するのはダルいが,Nimなら `echo @[1,2,3]` が動く.
1. 即時 named tuple が作れる. `let a = (x:100,y:100)` みたいな.
1. 実行時に落ちても落ちた場所を教えてくれる. C++だと `segmentation fault` とか出てつらいよね.
1. メソッドチェーン！ `newSeqWith(n,(x:scan(),y:scan())).sortedByIt(it.y).mapIt(it.x*it.x+it.y*it.y)` (ベクトル(x,y)を取得してyの順にソートして絶対値に変える例)
1. `lowerBound` とか `nextPermutation` とか競プロ的に欲しい関数がちゃんとある.(例:D言語にはindexを取れるlowerBoundが無い)
1. `const auto` が `let` で書ける. 不変性が簡潔に書けて便利.

# 競プロ で Nim を書く時に気をつけるべきこと
Nimは最強の言語ですが、罠が無いわけではありません.

## 1. コンテストとローカルのNimのバージョンを合わせる
- Nimは互換性を気にしないタイプの言語なので,思わぬバグが発生しがち。
  - 慣れないと毎コンテストで(バージョンに起因する)バグを踏むことが普通に起こるので必ず合わせるべき.
- 2019/10/8 時点で AtCoder:0.13.0 / YukiCoder:0.20.99
- Nimのバージョン変更自体は `choosenim` コマンドで簡単にできる。
  - [Nim 0.13.0 は古いので自分でビルドする必要がある](https://qiita.com/sessions/items/561f8a3aa6eba6d4d7a9).
  - ビルドを終えたらディレクトリ一式を `~/.choosenim/toolchains/nim-0.13.0/` に入れると使えるようになる.

## 2. AtCoder の Nim0.13.0 でのみ気をつけるべきこと
以下は 最新のNim(>=0.20.0) では修正されている.
- `toSeq(0..<10)` とは書けない.
  - o : `toSeq(0..10-1)`
- `sequtils.deduplicate` は O(N^2) かかる.
  - o : [ソートして自分で deduplicate. ](./lib/seq/sequence.nim)
- `random` (疑似乱数)モジュールが無い.
  - o : [自分で書く](./lib/mathlib/random.nim)
- `heapqueue`(優先度付きキュー) モジュールが無い.
  - o : [自分で書く](./lib/datastructure/set/priorityqueue.nim)

## 3. その他
- `sequtils.newSeqWith` は便利だが配列のコピーが余分に発生する.
  - およそ1e6以上の個数を扱うなら `newSeq` して代入の方が安心.
- C++のSTLとの連携は可能だがサポートは弱い.
  - 例えば, `std::map` にカスタムの比較関数を入れられない.
- `intsets` モジュールは競プロ的には完全に罠.全てに於いて使うべきではない.
  - まず `HashSet[int]` を使った方が速い. マージも O(N) で結局他のデータ構造を使うため.
- `algorithm.sort` は quick sort ではなく merge sort.
- ref object を動的に構築するデータ構造は,C++の同様のものに比べて定数倍がかなり重たい.つらい.
