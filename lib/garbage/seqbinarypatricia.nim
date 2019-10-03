import sequtils,nimprof

# 普通の2進表示のパトリシア木.
# 葉同士がリンクし合うのと余分なノードはスキップするのとで高速.

var to0s = newSeq[int32]()
var to1s = newSeq[int32]()
var counts = newSeq[int32]()
var isLeafs = newSeq[bool]()
var valueOrMasks = newSeq[int]()
const NilIndex = -1
proc newBinPatriciaNode(): int32 =
  result = to0s.len.int32
  to0s.add NilIndex
  to1s.add NilIndex
  counts.add 1
  isLeafs.add false
  valueOrMasks.add 0
proc newBinPatricia(bitSize:int = 60): int32 =
  result = to0s.len.int32
  to0s.add NilIndex
  to1s.add NilIndex
  counts.add 0
  isLeafs.add false
  valueOrMasks.add 1 shl bitSize
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)

proc bitSize(self:int32):int =
  valueOrMasks[self].culonglong.countTrailingZeroBits.int
proc len*(self:int32) : int = counts[self]
proc isTo1(self:int32,n:int):bool{.inline.} =
  (valueOrMasks[self] and n) == valueOrMasks[self] # 上位bitは同じはずなので

# デバッグ用
import strutils
proc binary(x:int,fill:int=0):string = # 二進表示
  if x == 0 : return "0".repeat(fill)
  if x < 0  : return binary(int.high+x+1,fill)
  result = ""
  var x = x
  while x > 0:
    result .add chr('0'.ord + x mod 2)
    x = x div 2
  for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
  if result.len >= fill: return result[^fill..^1]
  return "0".repeat(0.max(fill - result.len)) & result
proc dump(self:int32,indent:int = 0) : string =
  if self == NilIndex : return ""
  result = ""
  result .add valueOrMasks[self].binary(60)
  result .add "\t"
  result .add $counts[self]
  for i in 0..<indent: result .add "  "
  if isLeafs[self]: result.add "_"
  else: result.add "|"
  result = result & "\n"
  if isLeafs[self]: return
  if to0s[self] != NilIndex: result.add to0s[self].dump(indent + 1)
  if to1s[self] != NilIndex: result.add to1s[self].dump(indent + 1)

# 中間点を生成
proc createInternalNode(now:int32,preTree:int32,n:int) : int32 =
  let cross = valueOrMasks[preTree] xor n
  # 頑張れば bit 演算にできそう.
  for bit in (now.bitSize() - 1).countdown(0):
    if (cross and (1 shl bit)) == 0 : continue
    var newLeaf = newBinPatriciaNode()
    isLeafs[newLeaf] = true
    valueOrMasks[newLeaf] = n
    counts[newLeaf] = 1
    var created = newBinPatriciaNode()
    isLeafs[created] = false
    let n1 = valueOrMasks[preTree]
    let n2 = valueOrMasks[newLeaf]
    let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
    valueOrMasks[created] = (n1 or n2) and (not (n3 - 1))
    counts[created] = counts[newLeaf] + counts[preTree]
    if created.isTo1(valueOrMasks[newLeaf]):
      to1s[created] = newLeaf
      to0s[created] = preTree
    else:
      to1s[created] = preTree
      to0s[created] = newLeaf
    return created
  echo "このメッセージはでないはずだよ"
  echo n.binary(60)
  echo now.dump()
  echo preTree.dump()
  doAssert false

proc createNextNode(now:int32,target:int32,n:int) : int32 =
  if target == NilIndex:
    # この先が空なので直接葉を作る
    result = newBinPatriciaNode()
    isLeafs[result] = true
    valueOrMasks[result] = n
    counts[result] = 1
    return
  if isLeafs[target]:
    if valueOrMasks[target] == n: # 葉があった
      counts[target] += 1
      return target
    else: # 中間点を作る
      return createInternalNode(now,target,n)
  # prefix が違ったので新しくそこに作る
  let x = valueOrMasks[target]
  let mask = not(x xor (x - 1))
  if (x and mask) != (n and mask) :
    return createInternalNode(now,target,n)
  # 同じprefix を持つのでそちらに進む
  return NilIndex

# multi-set 的な add
var trailCount = 0
# 18859845
#  1000000
# 18倍の回数呼ばれる
#   262144
proc addMulti*(self:int32,n:int) =
  var now = self
  var target : int32 = NilIndex
  while true:
    trailCount += 1
    counts[now] += 1
    target = to0s[now]
    let to1IsTarget = (valueOrMasks[now] and n) == valueOrMasks[now]
    if to1IsTarget : target = to1s[now]
    let created = createNextNode(now,target,n)
    if created != NilIndex :
      if to1IsTarget: to1s[now] = created
      else: to0s[now] = created
      return
    now = target

proc `in`*(n:int,self:int32) : bool =
  var now = self
  while not isLeafs[now]:
    if now.isTo1(n):
      if to1s[now] == NilIndex : return false
      now = to1s[now]
    else:
      if to0s[now] == NilIndex : return false
      now = to0s[now]
  return valueOrMasks[now] == n
# multi-set にしたくなければ
proc add*(self: int32,n:int) =
  if not (n in self): self.addMulti(n)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../../mathlib/random"
var T = newBinPatricia()
stopwatch:
  for i in 0..10:
    let r = random(1e9.int)
    T.addMulti r.int
  # echo T.dump()
  for i in 0..100_0000:
    let r = random(1e9.int)
    T.addMulti r.int
  echo trailCount
