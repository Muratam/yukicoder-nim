import sequtils,algorithm


proc argMin[T](arr:seq[T]): int =
  let minVal = arr.min()
  for i,a in arr:
    if a == minVal: return i
proc argMax[T](arr:seq[T]): int =
  let minVal = arr.max()
  for i,a in arr:
    if a == minVal: return i

# 連続がいくつ続くか
proc countContinuity[T](arr:seq[T]) : seq[tuple[key:T,cnt:int]] =
  if arr.len == 0 : return @[]
  result = @[]
  var pre = arr[0]
  var cnt = 0
  for a in arr:
    if a == pre: cnt += 1
    else:
      result .add((pre,cnt))
      cnt = 1
      pre = a
  result.add((pre,cnt))


# Nim 0.13 の toCountTable はバグがあるので注意
import math,tables,algorithm,sequtils
proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
  result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
  for key in items(keys):
    result[key] = 1 + (if key in result : result[key] else: 0)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] =
  let ct = x.toCountTable()
  return toSeq(ct.pairs)

# string -> seq[char]
import sequtils
proc toArray(s:string) :seq[char]= s.mapIt(it)

# 重複を取り除く(O(NlogN))
# Nim0.13 の deduplicate はO(n^2)なので注意
import sequtils, algorithm
proc deduplicated[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a


# ラグランジュ補間
# N次多項式 f(x) と既知の f(0) .. f(N) から f(t) を復元可能。
# https://ei1333.github.io/luzhiled/snippets/math/lagrange-polynomial.html


when isMainModule:
  import unittest
  test "sequence":
    check: @[1,3,7,-1,10,5,3,10,-1].argMin() == 3
    check: @[1,3,7,-1,10,5,3,10,-1].argMax() == 4
    check: "aaabii".mapIt(it).countContinuity() == @[('a',3),('b',1),('i',2)]
  test "Nim 0.13 Compatibility":
    let arr = "iikannji".toArray()
    check: arr == @['i', 'i', 'k', 'a', 'n', 'n', 'j', 'i']
    check: arr.toCountSeq() == @[('a', 1), ('i', 3), ('j', 1), ('k', 1), ('n', 2)]
    check: arr.deduplicated() == @['a','i','j','k','n']
