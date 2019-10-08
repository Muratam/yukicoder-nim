import algorithm,math,tables,sets,times,sequtils,strutils
import "../mathlib/random"
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

# NOTE: Nim1.0.0 のsort がめちゃくちゃ遅くなってる...
# データ構造ができることは速度とのトレードオフ.
# データ数 1e6,ランダムケース に対して, (Nim 0.13.0 -d:release)
# 各データを約1回ずつ追加 or アクセスする
# ------ O(N) -----------------
#    3ms: データを舐める
#    7ms: seq(一括)
#   20ms: seq(add) / Deque
# ----- Speedy ---------------
#   50ms: Union Find / BIT / RollingHash
#   70ms: SA-IS
# -------O(NlogN) -------------
#  100ms: SegmentTree / LowerBound
#  120ms: HashSet / Priority Queue
#  150ms: seq(sort) / Table
# ------ + RMQ -------
#  700ms: 座標圧縮 SegmentTree
# ------ + min,max,iterate---------
#  800ms: Skew Heap
# 1000ms: std::set
# ------ + RMQ --
# 3000ms: Patricia Segment Tree

# まとめ:
# seq そのまま使えると爆速.
# logN は実質定数で無視できる.
# ただし,動的木系から差を無視できないほど遅くなる.
# - SkewHeap / std::set / Patricia Segment Tree



let n = 1e6.int
var dummy = 0
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
bench "seq": # 20ms
  var S = newSeq[int]()
  for _ in 0..n: S.add randomBit(32)
import "./queue/deques"
bench "Deque":
  var S = initDeque[int]()
  for _ in 0..n div 2:
    S.addLast randomBit(32)
    S.addFirst randomBit(32)
import "./set/unionfind"
bench "UnionFind":
  var S = initUnionFind(n)
  for i in 0..<n div 2:
    S.merge(randomBit(19),randomBit(19))
import "./segmenttree/bit"
bench "Binary Indexed Tree": # 60ms
  var A = newAddBinaryIndexedTree[int](n)
  for i in 0..<n div 2: A.update(i,randomBit(32))
  for i in 0..<n div 2: dummy += A.until(i-1)
import "./segmenttree/segmenttree"
bench "Segment Tree": # 100ms
  var A = newAddSegmentTree[int](n)
  for i in 0..<n div 2: A[i] = randomBit(32)
  for i in 0..<n div 2: dummy += A[0..<i]
bench "Sparse Segment Tree": # 650ms
  var S = newSeq[int](n+1)
  for i in 0..n: S[i] = randomBit(32)
  var A = S.newSparceSegmentTree(proc(x,y:int): int = x + y,0)
  for s in S: A[s] = randomBit(32)
  dummy += A[0..<n]
  # あまり速度が変わらない(-100ms)ので捨てました
  # bench "Sparse Strict Segment Tree":
  #   var S = newSeq[int](n+1)
  #   for i in 0..n: S[i] = randomBit(32)
  #   var A = S.newSparceStrictSegmentTree(proc(x,y:int): int = x + y,0)
  #   for s in S: A[s] = randomBit(32)
  #   dummy += A[0..<n]
bench "seq[int] + sort": # 140ms ~ 280ms
  var S = newSeq[int]()
  for _ in 0..n: S.add randomBit(32)
  S.sort(cmp)
import "./set/priorityqueue"
bench "Priority Queue":
  var S = newPriorityQueue[int](cmp)
  for _ in 0..n div 2: S.push randomBit(32)
  dummy += S.pop()
  for _ in 10..n div 2: S.pop()
  dummy += S.pop()
import "./set/skewheap"
bench "Skew Heap":
  var S = newSkewHeap[int](cmp)
  for _ in 0..n div 2: S.push randomBit(32)
  dummy += S.pop()
  for _ in 10..n div 2: S.pop()
  dummy += S.pop()
bench "HashSet": # 120ms
  var S = initSet[int]()
  for _ in 0..n: S.incl randomBit(32)
bench "Table": # 160ms
  var S = initTable[int,int]()
  for i in 0..n: S[randomBit(32)] = i
bench "LowerBound": # 160ms
  var S = newSeq[int](n+1)
  for i in 0..n: S[i] = randomBit(32)
  for i in 0..n: dummy += S.lowerBound(randomBit(32))
let str = "abcde".repeat(n div 5)
import "./string/loliha"
bench "Loliha":
  var LH = str.newLoliha()
  for i in 0..<n-10: dummy += LH.hash(i..randomBit(15))
import "./string/sais"
bench "SA-IS":
  var SA = str.newSuffixArray()
  dummy += SA.LCP[0]
import intsets
bench "intset": # 600ms クソ雑魚. ランキングに載せるのがはばかられる
  var S = initIntSet()
  for _ in 0..n: S.incl randomBit(32)
import "./set/set"
bench "std::set": # 1000ms
  var S = set.initSet[int]()
  for _ in 0..n: S.add randomBit(32)
import "./segmenttree/patriciasegmenttree"
bench "Patricia Segment Tree":
  var A = newPatriciaSegmentTree(proc(x,y:int):int = x+y,0)
  for i in 0..<n: A[randomBit(32).int] = i
echo dummy
