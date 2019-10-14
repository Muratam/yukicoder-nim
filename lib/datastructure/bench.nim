{.checks:off.}
# if true: quit 0
import algorithm,math,tables,sets,times,sequtils,strutils
import "../mathlib/random"
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
var registArray = newSeq[tuple[str:string,time:int]]()
proc regist(str:string,time:int) =
  registArray.add((str,time))
proc output() =
  registArray = registArray.sortedByIt(it.time)
  for r in registArray:
    echo r.time,"ms\t",r.str
template bench(comment:string, body) =
  block:
    stdout.write 27.chr , "[32m" , comment
    let t1 = cpuTime()
    body
    let t = int((cpuTime() - t1) * 1000)
    let T = $t
    const commentMaxLen = 26
    stdout.write " ".repeat(commentMaxLen - comment.len - T.len)
    stdout.write 27.chr , "[0m" , T , "ms\n"
    regist comment,t
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
import "./string/rollinghash"
bench "Rolling Hash":
  var LH = rollinghash.newRollingHash(str)
  for i in 0..<n-10: dummy += LH.hash(i..i.max(randomBit(bitSize)))[0]
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
bench "seq[int] + sort": # 140ms
  var S = newSeq[int](n)
  for i in 0..<n: S[i] = randomBit(32)
  S.sort(cmp)
  for i in 0..<n: dummy += S[i]
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
  var S = newSeq[int](n)
  for i in 0..<n: S[i] = randomBit(32)
  var A = S.newSparceSegmentTree(proc(x,y:int): int = x + y,0)
  for i in 0..<n: A[S[i]] = randomBit(32)
  for i in 0..<n: dummy += A[0..<i]
  dummy += A[0..<n]
bench "Sort + LowerBound": # 160ms
  var S = newSeq[int](n+1)
  for i in 0..n: S[i] = randomBit(32)
  S.sort(cmp)
  for i in 0..n: dummy += S.lowerBound(randomBit(32))
import "./set/priorityqueue"
bench "Priority Queue":
  var S = newPriorityQueue[int](cmp)
  for _ in 0..n: S.push randomBit(32)
  dummy += S.pop()
  for _ in 0..n-10: S.pop()
  dummy += S.pop()
import "./set/convoqueue"
bench "Convo Queue":
  var S = newMinMaxQueue[int](cmp)
  for _ in 0..n: S.push randomBit(32)
  dummy += S.minPop()
  for _ in 0..(n-10) div 2:
    dummy += S.minPop()
    dummy += S.maxPop()
  dummy += S.minPop()
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
bench "intset": # 600ms 用途少なすぎンゴ
  var S = initIntSet()
  for _ in 0..n: S.incl randomBit(32)
  for i in 0..n:
    if randomBit(32) in S: dummy += 1
# import "./set/stdset"
# bench "std::set":
#   var A = initStdSet[int]()
#   for i in 0..n: A.add randomBit(32)
#   for i in 0..n:
#     if randomBit(32) in A: dummy += 1
# bench "std::multiset":
#   var A = initStdMultiSet[int]()
#   for i in 0..n: A.add randomBit(32)
#   for i in 0..n:
#     if randomBit(32) in A: dummy += 1
import "./set/fuset"
bench "Fixed Universe Set":
  var B = newFUSet(true)
  for i in 0..n: B.add randomBit(30)
  for i in 0..n:
    if randomBit(30) in B: dummy += 1
import "./set/treap"
bench "Treap":
  var A = newTreapSet[int]()
  for i in 0..n: A.add randomBit(32)
  for i in 0..n:
    if randomBit(32) in A: dummy += 1
import "./set/treap"
bench "Perfect Treap": # 2倍くらい速い！
  var B = newSeq[int]()
  for i in 0..n: B.add randomBit(32)
  var A = newTreapSet[int]()
  A.resetWith(B)
  for i in 0..n:
    if randomBit(32) in A: dummy += 1
import "./set/rbst"
bench "RBST":
  var A = newRbst[int]()
  for i in 0..n: A.add randomBit(32)
  for i in 0..n:
    if randomBit(32) in A: dummy += 1
bench "Perfect RBST": # 2倍くらい速い！
  var B = newSeq[int]()
  for i in 0..n: B.add randomBit(32)
  var A = B.buildRBST()
  for i in 0..n:
    if randomBit(32) in A: dummy += 1


echo dummy
output()
