import sequtils#,nimprof

# 普通の2進表示のパトリシア木.
# 葉同士がリンクし合うのと余分なノードはスキップするのとで高速.

type
  BinPatriciaNode = object
    to0,to1 : int # NOTE: int32 というてもある
    count : int32 # (自身以下の木の)葉の要素数
    isLeaf : bool
    valueOrMask : int # 葉なら value / 枝なら一番下位bitが自身が担当するbit番号.それ以外はprefix
  BinPatricia = ref object
    nodes : seq[BinPatriciaNode]
proc newBinPatriciaNode(self:var BinPatricia):int =
  var node :BinPatriciaNode
  self.nodes.add node # NOTE: cap すればもうちょっとはやい
  return self.nodes.len - 1
proc registNode(self:var BinPatricia,node:BinPatriciaNode):int =
  self.nodes.add node
  return self.nodes.len - 1
proc newBinPatricia(bitSize:int = 60):BinPatricia =
  new(result)
  var root :BinPatriciaNode
  root.count = 0
  root.isLeaf = false
  root.valueOrMask = 1 shl bitSize
  result.nodes = @[root]
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)

proc bitSize(x:int):int = x.culonglong.countTrailingZeroBits.int
proc len*(self:BinPatricia) : int = self.nodes[0].count
proc isTo1(x,n:int):bool{.inline.} = (x and n) == x # 上位bitは同じはずなので軽い
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
proc dump(self:BinPatricia) : string =
  proc dumpNode(i:int,indent:int = 0) : string =
    let node = self.nodes[i]
    result = ""
    result .add node.valueOrMask.binary(60)
    result .add "\t"
    result .add $node.count
    for i in 0..<indent: result .add "  "
    if node.isLeaf: result.add "_"
    else: result.add "|"
    result = result & "\n"
    if node.isLeaf: return
    if node.to0 != 0: result.add node.to0.dumpNode(indent + 1)
    if node.to1 != 0: result.add node.to1.dumpNode(indent + 1)
  return dumpNode(0)


#
# 中間点を生成
proc createInternalNode(self:var BinPatricia,nowIndex,preTreeIndex,n:int) : int =
  let preTree = self.nodes[preTreeIndex]
  let cross = preTree.valueOrMask xor n
  # 頑張れば bit 演算にできそう.
  let nowBit = self.nodes[nowIndex].valueOrMask.bitSize()
  for bit in (nowBit - 1).countdown(0):
    if (cross and (1 shl bit)) == 0 : continue
    var newLeaf :BinPatriciaNode
    newLeaf.isLeaf = true
    newLeaf.valueOrMask = n
    newLeaf.count = 1
    var created : BinPatriciaNode
    created.isLeaf = false
    let newLeafIndex = self.registNode(newLeaf)
    let n1 = preTree.valueOrMask
    let n2 = newLeaf.valueOrMask
    let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
    created.valueOrMask = (n1 or n2) and (not (n3 - 1))
    created.count = newLeaf.count + preTree.count
    if created.valueOrMask.isTo1(newLeaf.valueOrMask):
      created.to1 = newLeafIndex
      created.to0 = preTreeIndex
    else:
      created.to1 = preTreeIndex
      created.to0 = newLeafIndex
    return self.registNode(created)
  echo "このメッセージはでないはずだよ"
  # echo n.binary(60)
  # echo now.dump()
  # echo preTree.dump()
  doAssert false

proc createNextNode(self:var BinPatricia,nowIndex,targetIndex,n:int) : int =
  if targetIndex == 0:
    # この先が空なので直接葉を作る
    var leaf : BinPatriciaNode
    leaf.isLeaf = true
    leaf.valueOrMask = n
    leaf.count = 1
    return self.registNode(leaf)
  let x = self.nodes[targetIndex].valueOrMask
  if self.nodes[targetIndex].isLeaf:
    if x == n: # 葉があった
      self.nodes[targetIndex].count += 1
      return targetIndex
    else: # 中間点を作る
      return self.createInternalNode(nowIndex,targetIndex,n)
  # prefix が違ったので新しくそこに作る
  let mask = not(x xor (x - 1))
  if (x and mask) != (n and mask) :
    return self.createInternalNode(nowIndex,targetIndex,n)
  # 同じprefix を持つのでそちらに進む
  return 0

# multi-set 的な add
proc addMulti*(self:var BinPatricia,n:int) =
  var nowIndex = 0
  while true:
    self.nodes[nowIndex].count += 1
    var targetIndex = 0
    let now = self.nodes[nowIndex]
    if now.valueOrMask.isTo1(n) :
      targetIndex = now.to1
      let createdIndex = self.createNextNode(nowIndex,targetIndex,n)
      if createdIndex != 0 :
        self.nodes[nowIndex].to1 = createdIndex
        return
    else:
      targetIndex = now.to0
      let createdIndex = self.createNextNode(nowIndex,targetIndex,n)
      if createdIndex != 0 :
        self.nodes[nowIndex].to0 = createdIndex
        return
    nowIndex = targetIndex

proc `in`*(n:int,self:BinPatricia) : bool =
  var now = self.nodes[0]
  while not now.isLeaf:
    if now.valueOrMask.isTo1(n):
      if now.to1 == 0 : return false
      now = self.nodes[now.to1]
    else:
      if now.to0 == 0 : return false
      now = self.nodes[now.to0]
  return now.valueOrMask == n
# multi-set にしたくなければ
proc add*(self:var BinPatricia,n:int) =
  if not (n in self): self.addMulti(n)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../mathlib/random"
var T = newBinPatricia()
stopwatch:
  for i in 0..1000000:
    let r = random(1e9.uint)
    T.addMulti r.int
