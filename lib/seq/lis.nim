import sequtils
import "../datastructure/set/treap"
# verify https://chokudai_s001.contest.atcoder.jp/tasks/chokudai_S001_h
# std::map
# 最長広義増加部分列 O(NlogN)
proc longestIncreasingSubsequence[T](arr:seq[T],multi:bool) : seq[T] =
  var S = newTreapSet[T](true)
  for a in arr:
    # a より大きいものを一つ削除する
    let (ok,value) = S.findGreater(a,not multi)
    if ok: S.erase value
    S.add a
  result = newSeq[T](S.len)
  var i = 0
  for x in S.items:
    result[i] = x
    i += 1
proc LMIS[T](arr:seq[T]) : seq[T] =
  arr.longestIncreasingSubsequence(true)
proc LIS[T](arr:seq[T]) : seq[T] =
  arr.longestIncreasingSubsequence(false)


when isMainModule:
  import unittest
  test "LIS":
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
