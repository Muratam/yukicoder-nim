import sequtils
import "../cpp/multiset"
# 最長広義増加部分列 O(NlogN)
proc LMIS[T](arr:seq[T]) : seq[T] =
  var S = initMultiSet[T]()
  for a in arr:
    var up = S.upper_bound(a)
    if up != S.`end`(): S.erase(*up)
    S.insert a
  return S.mapIt(it)

import "../cpp/set"
# 最長増加部分列 O(NlogN)
proc LIS[T](arr:seq[T]) : seq[T] =
  var S = initSet[T]()
  for a in arr:
    var up = S.upper_bound(a)
    if up != S.`end`(): S.erase(*up)
    S.insert a
  return S.mapIt(it)

when isMainModule:
  import unittest
  test "LIS":
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
