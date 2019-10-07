# `lib/garbase` : 書き捨てたコード.いつか使う時はくるのか...?

暖色になったら使うかもね

- Z-Algorithm : `S と S[i:]` を求めることしかできない. 定数倍とこの目的以外なら SA-IS でよくない
- Link-Cut木 : UnionFind + 木のカットやLCAや...をしたくなったらだけど必要になることある？？必要になったら書きます.
- 遅延セグツリ : つらい.StarrySkyTreeの加算性が無いと困ることあったらそのとき考えよう
- `tree` : std::map で全て事足りるので...
  - パトリシア木: 追加・prefix探索 O(S).  verify(y430)に失敗...
  - パトリシア木 : Nim のやつ.動く. (動的)文字列追加 prefix検索 O(|Q|log|{S}|). prefixの要素を数えることはできないので出番が少ないのではないか.
  - 謎木 / RBST / 赤黒木
  - KDTree: 普通に使いそうだけど書いてる途中で飽きた(wf2016.pdf参照)
- `cpp` : std::vector / std::priority_queue
- timecost : 演算の速度検証
- sparsematrix : 疎行列
- math : フィボナッチ数列の第N項 / 線形回帰(最小二乗法)
- sequence : countContinuity / toCountTable / toTuple / cmp ...
- なんかのパズルのソルバーが欲しい時はZDDを使いそうだけど競技プログラミングだと関係無いね
- そのうち書きたい :: 一筆書き(オイラー路)


# Nim NOTE
- Nim の intsets は競プロ的には完全に罠.全てに於いて使うべきではない.
- ref object を動的に構築するデータ構造は,定数倍がかなり重たい.
- 実は標準ライブラリにリーベンシュタイン距離があったりパトリシア木があったりする.
