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

when isMainModule:
  import unittest
  test "sequence":
    check: @[1,3,7,-1,10,5,3,10,-1].argMin() == 3
    check: @[1,3,7,-1,10,5,3,10,-1].argMax() == 4
    let arr = "iikannji".mapIt(it)
    check: arr.deduplicated() == @['a','i','j','k','n']
