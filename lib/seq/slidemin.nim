# スライド最小値
# 固定サイズの最小値を O(1)
import "../datastructure/queue/deques"
import sequtils
proc slideMin[T](arr:seq[T],width:int,paddingLast:bool = false) : seq[T] =
  let size = if paddingLast : arr.len else: arr.len-width+1
  result = newSeqWith(size,-1)
  var deq = initDeque[int]()
  for i in 0..<arr.len:
    while deq.len > 0 and arr[deq.peekLast()] >= arr[i] : deq.popLast() # 最小値の場合
    # while deq.len > 0 and arr[deq.peekLast()] <= arr[i] : deq.popLast() # 最大値の場合
    deq.addLast(i)
    let l = i - width + 1
    if l < 0:continue
    result[l] = arr[deq.peekFirst()]
    if deq.peekFirst() == l: deq.popFirst()
  if not paddingLast : return
  # 後ろに最後の数字を詰めて同じサイズにする
  for i in arr.len-width+1..<arr.len:
    result[i] = arr[deq.peekFirst()]
    if deq.peekFirst() == i: deq.popFirst()

when isMainModule:
  import unittest
  test "slide min":
    let arr = toSeq(0..10).mapIt(it mod 3 + it * it mod 5 + it)
    check: arr == @[0, 3, 8, 7, 6, 7, 7, 12, 14, 10, 11]
    check: arr.slideMin(4) == @[0, 3, 6, 6, 6, 7, 7, 10]
    check: arr.slideMin(4,true) == @[0, 3, 6, 6, 6, 7, 7, 10, 10, 10, 11]
