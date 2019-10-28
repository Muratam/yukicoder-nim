# 配列->配列で情報をフィルターする系.

# 重複を取り除く(O(NlogN))
# Nim0.13 の deduplicate はO(n^2)なので注意
import sequtils, algorithm
proc deduplicated*[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a

# 最長{広義,}増加部分列 O(NlogN)
# verify https://chokudai_s001.contest.atcoder.jp/tasks/chokudai_S001_h
import algorithm
when not declared(upperBound) :
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
proc LMIS[T](arr:seq[T]) : seq[T] =
  result = @[] # 広義単調増加を許す
  for a in arr:
    # 自身超過のものを一つ消して入れ替える
    let i = result.upperBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a
proc LIS[T](arr:seq[T]) : seq[T] =
  result = @[] # 単調増加のみ
  for a in arr:
    # 自身以上のものを一つ消して入れ替える
    let i = result.lowerBound(a)
    if i < 0 or i == result.len: result.add a
    else: result[i] = a

# 最長共通部分列(LCS) O(NlogN)
# http://www.prefield.com/algorithm/dp/lcs_hs.html
import tables,algorithm
proc LCS*[T](A,B:seq[T]):seq[T] =
  # B内の文字 -> index
  var BT = initTable[T,seq[int]]()
  for i in (B.len-1).countdown(0):
    if B[i] in BT : BT[B[i]].add i
    else: BT[B[i]] = @[i]
  # LIS
  var A2 = newSeq[int](A.len+1)
  for i in 0..<A2.len: A2[i] = 1e12.int
  A2[0] = -1e12.int
  type Node = ref object
    value:T
    next:Node
  var links = newSeq[Node](A2.len)
  for a in A:
    if a notin BT: continue
    for ib in BT[a]:
      let k = A2.lowerBound(ib)
      A2[k] = ib
      links[k] = Node(value:B[ib],next:links[k-1])
  var p = links[A2.lowerBound(1e12.int-1) - 1]
  result = @[]
  while p != nil:
    result.add p.value
    p = p.next
  return result.reversed()


# 座標圧縮
# 更新位置のみを圧縮. 位置はlowerboundでアクセス.
import algorithm
type CompressedPos*[T] = ref object
  data*: seq[T]
proc len*[T](self:CompressedPos[T]):int = self.data.len
proc newCompressedPos*[T](poses:seq[T]):CompressedPos[T] =
  new(result)
  result.data = @[]
  for p in poses.sorted(cmp[T]):
    if result.data.len > 0 and result.data[^1] == p: continue
    result.data.add p
proc `[]`*[T](self:CompressedPos[T],i:T):int =
  self.data.lowerBound(i)
proc `[]`*[T](self:CompressedPos[T],i:Slice[T]): Slice[int] =
  let ia = self.data.lowerBound(i.a)
  var ib = self.data.lowerBound(i.b) - 1
  if ib + 1 < self.data.len and i.b >= self.data[ib+1]: ib += 1
  return ia..ib
proc `$`*[T](self:CompressedPos[T]): string = $self.data
proc id*[T](x:T):T = x # nim0.13用



when isMainModule:
  import unittest
  test "sequence filter":
    let arr = "iikannji".mapIt(it)
    check: arr.deduplicated() == @['a','i','j','k','n']
  test "LIS / LCS":
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LMIS() == @[1, 2, 3,3,3,3, 4, 5, 7, 12, 15, 66]
    check: @[1,3,13,5,2,3,3,3,3,4,5,7,12,144,15,66].LIS() == @[1, 2, 3, 4, 5, 7, 12, 15, 66]
    check: @[1,2,3,4,5,5,6,3,2,1,2,3,4].mapIt($it).LCS(@[1,3,5,5,3,3,3,2,1,2,3,4].mapIt($it)) == @[1, 3, 5, 5, 3, 2, 1, 2, 3, 4].mapIt($it)
  test "compressed Position":
    let poses = @[1,10,100,1000,10000]
    var T = poses.newCompressedPos()
    check: T[0] == 0 and T[1] == 0
    check: T[2] == 1 and T[9] == 1 and T[10] == 1
    check: T[11] == 2 and T[50] == 2 and T[100] == 2
    check: T[100..999] == 2..2
    check: T[100..1000] == 2..3
    check: T[100..1001] == 2..3
    check: T[99..1001] == 2..3
    check: T[101..1001] == 3..3
    check: T[101..102] == 3..2 # 区間が反転している時は 区間内に存在するものが無かった！
    check: T[id(-100)..1000] == 0..3
