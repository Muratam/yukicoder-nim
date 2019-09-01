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

import math,tables,algorithm
# Nim 0.13 の toCountTable はバグがあるので注意
proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
  result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
  for key in items(keys):
    result[key] = 1 + (if key in result : result[key] else: 0)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] =
  let ct = x.toCountTable()
  return toSeq(ct.pairs)

import algorithm
# 重複を取り除く(O(logN))
# Nim0.13 の deduplicate はO(n^2)なので注意
proc deduplicated[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a


import sequtils
proc toArray(s:string) :seq[char]= s.mapIt(it) # string -> seq[char]

# 連続がいくつ続くか
proc countContinuity[T](arr:seq[T]) : seq[tuple[key:T,cnt:int]] =
  if arr.len == 0 : return @[]
  result = @[]
  var pre = arr[0]
  var cnt = 0
  for a in arr:
    if a == pre: cnt += 1
    else:
      result .add( (pre,cnt))
      cnt = 1
      pre = a
  result.add( (pre,cnt))

proc argmin[T](arr:seq[T]): int =
  let minVal = arr.min()
  for i,a in arr:
    if a == minVal: return i
proc argmax[T](arr:seq[T]): int =
  let minVal = arr.max()
  for i,a in arr:
    if a == minVal: return i


iterator reversedIterator[T](arr:openArray[T]) : T =
  for i in (arr.len - 1).countdown(0): yield arr[i]


when isMainModule:
  import unittest
  test "count":
    let arr = "iikannji".toArray()
    check: arr == @['i', 'i', 'k', 'a', 'n', 'n', 'j', 'i']
    check: arr.toCountSeq() == @[('a', 1), ('i', 3), ('j', 1), ('k', 1), ('n', 2)]
    check: arr.deduplicated() == @['a','i','j','k','n']
    check: "aaabii".toArray().countContinuity() == @[('a',3),('b',1),('i',2)]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
