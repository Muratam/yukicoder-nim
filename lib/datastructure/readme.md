# データ構造の定数倍の比較

## TLDR;
- データ構造ができることは速度とのトレードオフ.牛刀割鶏！
- seq は爆速. logN は実質定数. 動的木は遅い.
- MLEの壁は1e7の64bitで100MBです.

## 実験条件
データ数 1e6,ランダムケース に対して, (Nim 0.13.0 -d:release)
各データを1回ずつ(自身が通常使われる方法で)追加・アクセスする.
操作の数え方に差があるため, 目安の値.
1/2~2倍は普通にあって,10倍違うことは殆どないくらいの信憑性.

## 結果
```
0ms     only sum
3ms     only sum rand
8ms     seq static store
15ms    Deque
23ms    seq
70ms    Binary Indexed Tree
80ms    SA-IS
90ms    Loliha
142ms   Rolling Hash
150ms   UnionFind
151ms   seq[int] + sort
167ms   Segment Tree
197ms   Table
210ms   HashSet
282ms   Priority Queue
440ms   Sort + LowerBound
527ms   Convo Queue
595ms   intset
898ms   Sparse Segment Tree
1182ms  Perfect Treap
2231ms  Skew Heap
3194ms  Treap
4738ms  RBST
```
