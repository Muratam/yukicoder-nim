import sequtils,algorithm
# 条件を満たす index を全探索
proc argMin[T](arr:seq[T]): int =
  let minVal = arr.min()
  for i,a in arr:
    if a == minVal: return i
proc argMax[T](arr:seq[T]): int =
  let minVal = arr.max()
  for i,a in arr:
    if a == minVal: return i

# 重複を取り除く(O(NlogN))
# Nim0.13 の deduplicate はO(n^2)なので注意
import sequtils, algorithm
proc deduplicated*[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a

# 区間を指定してクイックソート
# Nim0.13.0 だと同等以上の速度で, Nim0.20.0 だと2倍くらい速い.
# `<` 関数を使ってソートするので定義すること.ソート順は最後の引数で指定.
import "../mathlib/random"
proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc quickSortAt*[T](arr:var seq[T], at:Slice[int],isDescending:bool = false) =
  if arr.len <= 1 : return
  var l = at.a
  var r = at.b
  let d = r - l + 1
  let ctlz = cast[culonglong](d).countTrailingZeroBits()
  if d > 16: #
    # random() の mod が激遅なのでそれは辞める
    # length が 0b10101001 なら
    # 前と後ろを 0b10000000 回やる
    # 範囲がちょっと被るけどそんなに困らない
    var s = 1 shl ctlz
    let l2 = 0.max(l + (r - s))
    while s >= d: s = s shr 1
    for i in s.countdown(0):
      swap arr[l+i], arr[l+randomBit(ctlz)]
    for i in s.countdown(0):
      swap arr[l2+i], arr[l2+randomBit(ctlz)]
  var ls = newSeq[int](ctlz+50)
  var rs = newSeq[int](ctlz+50)
  ls[0] = 0
  rs[0] = arr.len - 1
  var p = 1
  while p > 0:
    p -= 1
    var pl = ls[p]
    var pr = rs[p]
    var x = arr[(pl+pr) shr 1] # pivot
    l = pl
    r = pr
    var once = true
    while pl <= pr or once:
      while arr[pl] < x : pl += 1 # cmp
      while x < arr[pr] : pr -= 1 # cmp
      if pl <= pr:
        if pl < pr:
          swap arr[pl],arr[pr]
        pl += 1
        pr -= 1
      once = false
    if l < pr:
      ls[p] = l
      rs[p] = pr
      p += 1
    if pl < r:
      ls[p] = pl
      rs[p] = r
      p += 1
  if isDescending:
    for i in 0..<arr.len shr 1:
      swap arr[i] , arr[arr.len-1-i]
proc quickSort*[T](arr:var seq[T],isDescending:bool = false) =
  arr.quickSortAt(0..<arr.len,isDescending)
# 10進数 <=> seq[int]
import algorithm
proc splitAsDecimal*(n:int) : seq[int] =
  if n == 0 : return @[0]
  result = @[]
  var n = n
  while n > 0:
    result .add n mod 10
    n = n div 10
  return result.reversed()
proc joinAsDecimal*(A:seq[int]):int =(for a in A: result = result * 10 + a)


when isMainModule:
  import unittest
  test "sequence":
    check: @[1,3,7,-1,10,5,3,10,-1].argMin() == 3
    check: @[1,3,7,-1,10,5,3,10,-1].argMax() == 4
    let arr = "iikannji".mapIt(it)
    check: arr.deduplicated() == @['a','i','j','k','n']
  test "decimal":
    check:31415.splitAsDecimal() == @[3, 1, 4, 1, 5]
    check: @[3,1,2,5,6].joinAsDecimal() == 31256
  test "sort":
    for n in 1..<1000:
      let S1 = newSeqWith(n,randomBit(50))
      var pre = 0
      block:
        var T1 = S1
        T1.sort(cmp)
        pre = T1[n shr 1]
      block:
        var T1 = S1
        T1.quickSort()
        let pro = T1[n shr 1]
        check: pre == pro
        T1.reverse()
        var T2 = T1
        T2.quickSort(true)
        check: T1 == T2

  import times
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  proc cmp1(x,y:int):int {.noSideEffect.}= x - y
  if true:
    # ソートのベンチ
    # Nim 0.13.0 だと 1.5倍くらい,
    # Nim 1.0.0 だと 2倍くらい 速い.
    let n = 1e6.int
    let S1 = newSeqWith(n,randomBit(50))
    var pre = 0
    block:
      var T1 = S1
      stopwatch:
        T1.sort(cmp1)
      pre = T1[n shr 1]
    block:
      var T1 = S1
      stopwatch:
        T1.quickSort()
      let pro = T1[n shr 1]
      if pre != pro:
        echo "SORT MISS!!"
