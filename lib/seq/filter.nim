# 配列->配列で情報をフィルターする系.

# 重複を取り除く(O(NlogN))
# Nim0.13 の deduplicate はO(n^2)なので注意
import sequtils, algorithm
proc deduplicated*[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a

# 最長{広義,}増加部分列 O(NlogN)
# verify https://chokudai_s001.contest.atcoder.jp/tasks/chokudai_S001_h
import algorithm
when not defined(upperBound) :
  proc upperBound[T](a: openArray[T], key: T): int =
    result = a.low
    var count = a.high - a.low + 1
    var step, pos: int
    while count != 0:
      step = count shr 1
      pos = result + step
      if cmp(a[pos], key) <= 0:
        result = pos + 1
        count -= step + 1
      else:
        count = step
proc LMIS[T](arr:seq[T]) : seq[T] =
  result = @[] # 広義単調増加を許す
  for a in arr:
    # 自身超過のものを一つ消して入れ替える
    let i = result.upperBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a
proc LIS[T](arr:seq[T]) : seq[T] =
  result = @[] # 単調増加のみ
  for a in arr:
    # 自身以上のものを一つ消して入れ替える
    let i = result.lowerBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a

# (更新位置のみを)座標圧縮(位置はlowerboundでアクセス).
import algorithm
type CompressedPos*[T] = ref object
  data*: seq[T]
proc len*[T](self:CompressedPos[T]):int = self.data.len
proc newCompressedPos*[T](poses:seq[T]):CompressedPos[T] =
  new(result)
  result.data = @[]
  for p in poses.sorted(cmp[T]):
    if result.data.len > 0 and result.data[^1] == p: continue
    result.data.add p
proc `[]`*[T](self:CompressedPos[T],i:T):int =
  self.data.lowerBound(i)
proc `[]`*[T](self:CompressedPos[T],i:Slice[T]): Slice[int] =
  let ia = self.data.lowerBound(i.a)
  var ib = self.data.lowerBound(i.b) - 1
  if ib + 1 < self.data.len and i.b >= self.data[ib+1]: ib += 1
  return ia..ib
proc `$`*[T](self:CompressedPos[T]): string = $self.data
proc id*[T](x:T):T = x # nim0.13用

# スライド最小値
# 幅wの窓をずらしていって得られる範囲の最小値列 構築O(N)
# [0 3 8 7 6 7 7 ...
#  !]
#  3 !]
#  8 8 8]
#  7 7 7 7]
#   [6 ! ! !] ...
import "../datastructure/queue/deques"
import sequtils
proc slideMin[T](arr:seq[T],width:int,paddingLast:bool = false) : seq[T] =
  let size = if paddingLast : arr.len else: arr.len-width+1
  result = newSeqWith(size,-1)
  # arr[deq_i]はソートされた配列になっている. deq_i はindexを格納している.
  # arr[deq[0]] は目的(最小値)のもので,残りは順に arr[l] 以下まで
  var deq = initDeque[int]()
  for i in 0..<arr.len:
    # 次に arr[i] が来るので,それ以上の不要なものは後ろから消していく.
    while deq.len > 0 and arr[deq.peekLast()] >= arr[i] : deq.popLast() # 最小値の場合
    # while deq.len > 0 and arr[deq.peekLast()] <= arr[i] : deq.popLast() # 最大値の場合
    deq.addLast(i)
    let l = i - width + 1
    if l < 0:continue
    result[l] = arr[deq.peekFirst()]
    if deq.peekFirst() == l: deq.popFirst()
  if not paddingLast : return
  # 後ろに最後の数字を詰めて同じサイズにする
  # paddingFirstが無くて非対称なのは面倒だったから
  for i in arr.len-width+1..<arr.len:
    result[i] = arr[deq.peekFirst()]
    if deq.peekFirst() == i: deq.popFirst()


when isMainModule:
  import unittest
  test "sequence filter":
    let arr = "iikannji".mapIt(it)
    check: arr.deduplicated() == @['a','i','j','k','n']
  test "LIS":
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
  test "compressed Position":
    let poses = @[1,10,100,1000,10000]
    var T = poses.newCompressedPos()
    check: T[0] == 0 and T[1] == 0
    check: T[2] == 1 and T[9] == 1 and T[10] == 1
    check: T[11] == 2 and T[50] == 2 and T[100] == 2
    check: T[100..999] == 2..2
    check: T[100..1000] == 2..3
    check: T[100..1001] == 2..3
    check: T[99..1001] == 2..3
    check: T[101..1001] == 3..3
    check: T[101..102] == 3..2 # 区間が反転している時は 区間内に存在するものが無かった！
    check: T[id(-100)..1000] == 0..3
  test "slide min":
    let arr = @[0, 3, 8, 7, 6, 7, 7, 12, 14, 10, 11]
    check: arr.slideMin(4) == @[0, 3, 6, 6, 6, 7, 7, 10]
    check: arr.slideMin(4,true) == @[0, 3, 6, 6, 6, 7, 7, 10, 10, 10, 11]
