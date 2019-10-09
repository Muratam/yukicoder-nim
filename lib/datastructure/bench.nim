import algorithm,math,tables,sets,times,sequtils,strutils
import "../mathlib/random"
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template bench(comment:string, body) =
  block:
    stdout.write 27.chr,"[32m"
    stdout.write comment
    let t1 = cpuTime()
    body
    let T = $ int((cpuTime() - t1) * 1000)
    const commentMaxLen = 26
    stdout.write " ".repeat(commentMaxLen - comment.len - T.len)
    stdout.write 27.chr,"[0m"
    stdout.write  T,"ms\n"

#[
データ構造ができることは速度とのトレードオフ.
データ数 1e6,ランダムケース に対して, (Nim 0.13.0 -d:release)
各データを約1回ずつ追加 or アクセスする
操作の数え方に差があるため, 目安の値. 1/2~2倍は普通にあって,10倍違うことは殆どないくらいの信憑性.
********* 1e8 の壁 **************
   5ms: データを舐める(理論値)
  10ms: seq(一括)
******** 1e7 の壁 ***************
  20ms: seq(add) / Deque
  40ms: RollingHash
  80ms: SA-IS / UnionFind / BIT
********* 1e6 の壁 ***************
 160ms: SegmentTree / sort / HashSet / Table
 320ms: PriorityQueue / sort+LowerBound /
 640ms: 座標圧縮SegmentTree
********** 1e5の壁 *************
1280ms:
2560ms: Skew Heap (マージの代償 : PQ x8倍)
5120ms: PatriciaSegmentTree (生の20~30倍)

まとめ:
seq そのまま使えると爆速. logN は実質定数で無視できる.
ただし,動的木系から差を無視できないほど遅くなる.
=> 大人しく最適なデータ構造を使おう！牛刀割鶏！
また、 1e7 の 64bit で 100MBくらい.
=> この壁がMLEの壁にもなっている
]#


let n = 1e6.int
let bitSize = 19
let R = newSeqWith(n+100,randomBit(32))
{.overflowChecks:off.}
var dummy = 0
# read(n) + write(n) を計測する
bench "only sum": # 0ms
  var S = 0
  for i in 0..n: S += i
  dummy += S
bench "only sum rand" : # 3ms
  var S = 0
  for _ in 0..n: S += randomBit(32)
  dummy += S
bench "seq static store": # 7ms
  var S = newSeq[int](n+1)
  for i in 0..n: S[i] = randomBit(32)
  for i in 0..n: dummy += S[i]
bench "seq": # 20ms
  var S = newSeq[int]()
  for i in 0..n: S.add randomBit(32)
  for i in 0..n: dummy += S[i]
import "./queue/deques"
bench "Deque":
  var S = initDeque[int]()
  for _ in 0..n div 2:
    S.addLast randomBit(32)
    S.addFirst randomBit(32)
  for _ in 0.. n div 2 - 10:
    dummy += S.popFirst()
    dummy += S.popLast()
# 文字列
let str = "abcde".repeat(n div 5)
import "./string/loliha"
bench "Loliha":
  var LH = str.newLoliha()
  for i in 0..<n-10: dummy += LH.hash(i..i.max(randomBit(bitSize)))
import "./string/sais"
bench "SA-IS":
  var SA = str.newSuffixArray()
  for i in 0..<n-10: dummy += SA.LCP[i]
import "./set/unionfind"
bench "UnionFind":
  var S = initUnionFind(n)
  for i in 0..<n:
    S.merge(randomBit(bitSize),randomBit(bitSize))
  for i in 0..<n:
    if S.same(randomBit(bitSize),randomBit(bitSize)):
      dummy += 1
bench "seq[int] + sort": # 140ms ~ 280ms
  var S = newSeq[int]()
  for _ in 0..n: S.add randomBit(32)
  S.sort(cmp)
  for i in 0..n: dummy += S[i]
import "./segmenttree/bit"
bench "Binary Indexed Tree": # 60ms
  var A = newAddBinaryIndexedTree[int](n)
  for i in 0..<n: A.update(i,randomBit(32))
  for i in 0..<n: dummy += A.until(i-1)
import "./segmenttree/segmenttree"
bench "Segment Tree": # 100ms
  var A = newAddSegmentTree[int](n)
  for i in 0..<n: A[i] = randomBit(32)
  for i in 0..<n: dummy += A[0..<i]
bench "Sparse Segment Tree": # 650ms
  var S = newSeq[int](n+1)
  for i in 0..<n: S[i] = randomBit(32)
  var A = S.newSparceSegmentTree(proc(x,y:int): int = x + y,0)
  for i in 0..<n: A[S[i]] = randomBit(32)
  for i in 0..<n: dummy += A[0..<i]
  dummy += A[0..<n]
bench "Sort + LowerBound": # 160ms
  var S = newSeq[int](n+1)
  for i in 0..n: S[i] = randomBit(32)
  S.sort()
  for i in 0..n: dummy += S.lowerBound(randomBit(32))
import "./set/priorityqueue"
bench "Priority Queue":
  var S = newPriorityQueue[int](ascending)
  for _ in 0..n: S.push randomBit(32)
  dummy += S.pop()
  for _ in 0..n-10: S.pop()
  dummy += S.pop()
import "./set/skewheap"
bench "Skew Heap":
  var S = newSkewHeap[int](cmp)
  for _ in 0..n: S.push randomBit(32)
  dummy += S.pop()
  for _ in 0..n-10: S.pop()
  dummy += S.pop()
bench "HashSet": # 120ms
  var S = initSet[int]()
  for _ in 0..n: S.incl randomBit(32)
  for i in 0..n:
    if randomBit(32) in S: dummy += 1
bench "Table": # 160ms
  var S = initTable[int,int]()
  for i in 0..n: S[R[i]] = i
  for i in 0..n: dummy += S[R[i]]
import intsets
bench "intset": # 600ms クソ雑魚. ランキングに載せるのがはばかられる
  var S = initIntSet()
  for _ in 0..n: S.incl randomBit(32)
  for i in 0..n:
    if randomBit(32) in S: dummy += 1
# コピーが走ってつらい
# import "./set/set"
# bench "std::set": # 1000ms
#   var S = initStdSet[int]()
#   for i in 0..n:
#     S.add R[i]
#   for i in 0..n:
#     if i in S : dummy += 1
#     # if S.find(i) != S.`end`(): dummy += 1
# import "./set/treap"
# bench "treap":
#   var A = newTreap[int]()
#   for i in 0..<1e6.int: A.add randomBit(32)
import "./segmenttree/patriciasegmenttree"
bench "Patricia Segment Tree":
  var A = newPatriciaSegmentTree(proc(x,y:int):int = x+y,0)
  for i in 0..n: A[R[i]] = i
  for i in 0..n: dummy += A[R[i]]
echo dummy
