import sequtils
# 2進表示のパトリシア木.
# 本質的には、 multiset と同じく, 追加・削除・極値系全部 ができる
# 更に以下ができる
#   prefixとして k を持つ要素の数取得. BitDPで個数が大事なときとか...?
#   k 番目の最小値
#   x と xor したときの極値系全部

type
  BinPatriciaNode = ref object
    to0,to1 : BinPatriciaNode
    count : int32 # (自身以下の木の)葉の要素数
    isLeaf : bool
    valueOrMask : int # 葉なら value / 枝なら一番下位bitが自身が担当するbit番号.それ以外はprefix
  BinPatricia = ref object
    root : BinPatriciaNode
proc newBinPatriciaNode():BinPatriciaNode =
  new(result)
proc newBinPatricia(bitSize:int = 5):BinPatricia =
  new(result)
  result.root = newBinPatriciaNode()
  result.root.count = 0
  result.root.isLeaf = false
  result.root.valueOrMask = 1 shl bitSize
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)

proc bitSize(self:BinPatriciaNode):int =
  self.valueOrMask.culonglong.countTrailingZeroBits.int
proc len*(self:BinPatricia) : int = self.root.count
proc isTo1(self:BinPatriciaNode,n:int):bool{.inline.} =
  (self.valueOrMask and n) == self.valueOrMask # 上位bitは同じはずなので

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
proc dump(self:BinPatriciaNode,indent:int = 0) : string =
  if self == nil : return ""
  result = ""
  result .add self.valueOrMask.binary(60)
  result .add "\t"
  result .add $self.count
  for i in 0..<indent: result .add "  "
  if self.isLeaf: result.add "_"
  else: result.add "|"
  result = result & "\n"
  if self.isLeaf: return
  if self.to0 != nil: result.add self.to0.dump(indent + 1)
  if self.to1 != nil: result.add self.to1.dump(indent + 1)
proc dump(self:BinPatricia) : string = self.root.dump()


#
# 中間点を生成
proc createInternalNode(now:BinPatriciaNode,preTree:BinPatriciaNode,n:int) : BinPatriciaNode =
  let cross = preTree.valueOrMask xor n
  # 頑張れば bit 演算にできそう.
  for bit in (now.bitSize() - 1).countdown(0):
    if (cross and (1 shl bit)) == 0 : continue
    var newLeaf = newBinPatriciaNode()
    newLeaf.isLeaf = true
    newLeaf.valueOrMask = n
    newLeaf.count = 1
    var created = newBinPatriciaNode()
    created.isLeaf = false
    let n1 = preTree.valueOrMask
    let n2 = newLeaf.valueOrMask
    let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
    created.valueOrMask = (n1 or n2) and (not (n3 - 1))
    created.count = newLeaf.count + preTree.count
    if created.isTo1(newLeaf.valueOrMask):
      created.to1 = newLeaf
      created.to0 = preTree
    else:
      created.to1 = preTree
      created.to0 = newLeaf
    return created
  echo "このメッセージはでないはずだよ"
  echo n.binary(60)
  echo now.dump()
  echo preTree.dump()
  doAssert false

proc createNextNode(now:BinPatriciaNode,target:BinPatriciaNode,n:int) : BinPatriciaNode =
  if target == nil:
    # この先が空なので直接葉を作る
    result = newBinPatriciaNode()
    result.isLeaf = true
    result.valueOrMask = n
    result.count = 1
    return
  if target.isLeaf:
    if target.valueOrMask == n: # 葉があった
      target.count += 1
      return target
    else: # 中間点を作る
      return createInternalNode(now,target,n)
  # prefix が違ったので新しくそこに作る
  let x = target.valueOrMask
  let mask = not(x xor (x - 1))
  if (x and mask) != (n and mask) :
    return createInternalNode(now,target,n)
  # 同じprefix を持つのでそちらに進む
  return nil

# multi-set 的な add
proc addMulti*(self:var BinPatricia,n:int) =
  var now = self.root
  var target : BinPatriciaNode = nil
  while true:
    now.count += 1
    if (now.valueOrMask and n) == now.valueOrMask :
      target = now.to1
      let created = createNextNode(now,target,n)
      if created != nil :
        now.to1 = created
        return
    else:
      target = now.to0
      let created = createNextNode(now,target,n)
      if created != nil :
        now.to0 = created
        return
    now = target

proc `in`*(n:int,self:BinPatricia) : bool =
  var now = self.root
  while not now.isLeaf:
    if now.isTo1(n):
      if now.to1 == nil : return false
      now = now.to1
    else:
      if now.to0 == nil : return false
      now = now.to0
  return now.valueOrMask == n
# multi-set にしたくなければ
proc add*(self:var BinPatricia,n:int) =
  if not (n in self): self.addMulti(n)

# TODO: fastLog2 は (n and -n)で累乗に

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../../mathlib/random"
var T = newBinPatricia()
stopwatch:
  for i in 0..100_0000:
    let r = random(1e9.int)
    T.addMulti r.int
