import sequtils

# 普通の2進表示のパトリシア木.
# 葉同士がリンクし合うのと余分なノードはスキップするのとで高速.

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

# multi-set 的な add
proc addMulti*(self:BinPatricia,n:int) =
  var now = self.root
  # 中間点を生成
  proc createInternalNode(target:var BinPatriciaNode) =
    let cross = target.valueOrMask xor n
    # 頑張れば bit 演算にできそう.
    for bit in (now.bitSize() - 1).countdown(0):
      if (cross and (1 shl bit)) == 0 : continue
      var newLeaf = newBinPatriciaNode()
      newLeaf.isLeaf = true
      newLeaf.valueOrMask = n
      newLeaf.count = 1
      var pre = target
      target = newBinPatriciaNode()
      target.isLeaf = false
      let n1 = pre.valueOrMask
      let n2 = newLeaf.valueOrMask
      let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
      target.valueOrMask = (n1 or n2) and (not (n3 - 1))
      target.count = newLeaf.count + pre.count
      if target.isTo1(newLeaf.valueOrMask):
        target.to1 = newLeaf
        target.to0 = pre
      else:
        target.to1 = pre
        target.to0 = newLeaf
      return
    echo "このメッセージはでないはずだよ"
    echo n.binary(6)
    echo now.dump()
    echo target.dump()
    doAssert false

  proc goNextNode(target:var BinPatriciaNode) : bool =
    if target == nil:
      # この先が空なので直接葉を作る
      target = newBinPatriciaNode()
      target.isLeaf = true
      target.valueOrMask = n
      target.count = 1
      return
    if target.isLeaf:
      if target.valueOrMask == n: # 葉があった
        target.count += 1
      else: # 中間点を作る
        target.createInternalNode()
      return
    # prefix が違ったので新しくそこに作る
    let x = target.valueOrMask
    let mask = not(x xor (x - 1))
    if (x and mask) != (n and mask) :
      target.createInternalNode()
      return
    # 同じprefix を持つのでそちらに進む
    return true

  while true:
    now.count += 1
    if now.isTo1(n) :
      if not now.to1.goNextNode(): return
      now = now.to1
    else:
      if not now.to0.goNextNode(): return
      now = now.to0

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
proc add*(self:BinPatricia,n:int) =
  if not (n in self): self.addMulti(n)




import "../mathlib/random"
var T = newBinPatricia()
for i in 0..100:
  let r = random(1e9.uint)
  T.addMulti r.int
echo T.dump()
  # echo T.dump()
# echo T.dump()
# T.add 0b000100
# echo T.dump()
# T.add 0b010100
# echo T.dump()
# T.add 0b010111
# echo T.dump()
# echo 0b000100 in T
# echo 0b010100 in T
# # 削除. multi のときでも一括削除可能
# proc delete*(self:BinPatricia,n:int,multiAll:bool = false) =
#   var now = self.root
#   var lastBranch = now
#   var lastIs0 = false
#   for bit in (self.bitSize - 1).countdown(0):
#     if (n and (1 shl bit)) > 0 : # 1
#       if now.to1 == nil: return
#       if now.to0 != nil:
#         lastBranch = now
#         lastIs0 = false
#       now = now.to1
#     else:
#       if now.to0 == nil: return
#       if now.to1 != nil:
#         lastBranch = now
#         lastIs0 = true
#       now = now.to0
#   if multiAll: now.count = 0
#   now.count -= 1
#   if now.count > 0: return
#   self.card -= 1
# せっかく木を作ったのでdeleteはしない.
# そんなにメモリ困らないはず。困ったら消す.
