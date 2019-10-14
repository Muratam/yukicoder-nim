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
  test "slide min":
    let arr = @[0, 3, 8, 7, 6, 7, 7, 12, 14, 10, 11]
    check: arr.slideMin(4) == @[0, 3, 6, 6, 6, 7, 7, 10]
    check: arr.slideMin(4,true) == @[0, 3, 6, 6, 6, 7, 7, 10, 10, 10, 11]
