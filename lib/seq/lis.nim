# verify https://chokudai_s001.contest.atcoder.jp/tasks/chokudai_S001_h

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

# 最長広義増加部分列 O(NlogN)
import algorithm
proc LMIS[T](arr:seq[T]) : seq[T] =
  result = @[]
  for a in arr:
    # 自身超過のものを一つ消して入れ替える
    let i = result.upperBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a
# 最長増加部分列 O(NlogN)
proc LIS[T](arr:seq[T]) : seq[T] =
  result = @[]
  for a in arr:
    # 自身以上のものを一つ消して入れ替える
    let i = result.lowerBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a

when isMainModule:
  import unittest
  test "LIS":
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
