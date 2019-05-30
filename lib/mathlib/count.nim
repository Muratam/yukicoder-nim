import sequtils,tables
proc toArray(s:string) :seq[char]= toSeq(s.items) # string -> seq[char]

import math
proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
  result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
  for key in items(keys):
    result[key] = 1 + (if key in result : result[key] else: 0)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] =
  toSeq(x.toCountTable().pairs)

import algorithm
proc deduplicated[T](arr: seq[T]): seq[T] = # Nim標準 の deduplicate はO(n^2)なので注意
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a
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


when isMainModule:
  import unittest
  test "count":
    let arr = "iikannji".toArray()
    check: arr == @['i', 'i', 'k', 'a', 'n', 'n', 'j', 'i']
    check: arr.toCountSeq() == @[('a', 1), ('i', 3), ('j', 1), ('k', 1), ('n', 2)]
    check: arr.deduplicated() == @['a','i','j','k','n']
    check: "aaabii".toArray().countContinuity() == @[('a',3),('b',1),('i',2)]
