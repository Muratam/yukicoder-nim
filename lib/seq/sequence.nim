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
proc deduplicated[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a

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
