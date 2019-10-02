import sequtils#,nimprof

# 普通の2進表示のトライ木。
# パトリシア木より3倍くらい遅いので価値なし.
type
  BinTrieNode = object
    to0,to1 : int32
    count : int32 # (自身以下の木の)葉の要素数
    value : int
  BinTrieTree = ref object
    nodes : seq[BinTrieNode]
    bitSize : int
    rank : int
proc newBinTrieNode(self:var BinTrieTree):int =
  var node :BinTrieNode
  self.nodes.add node # NOTE: cap すればもうちょっとはやい
  return self.nodes.len - 1
proc registNode(self:var BinTrieTree,node:BinTrieNode):int =
  self.nodes.add node
  return self.nodes.len - 1
proc newBinTree(bitSize:int = 60):BinTrieTree =
  new(result)
  var root :BinTrieNode
  result.nodes = @[root]
  result.rank = bitSize

proc len*(self:BinTrieTree) : int = self.nodes[0].count
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
proc dump(self:BinTrieTree) : string =
  proc dumpNode(i:int,indent:int = 0) : string =
    let node = self.nodes[i]
    if node.to0 == 0 and node.to1 == 0:
      for i in 0..<indent: result .add "  "
      result .add node.value.binary(60)
      result .add "\t"
      result .add $node.count
      result = result & "\n"
    else:
      if node.to0 != 0: result.add node.to0.dumpNode(indent + 1)
      if node.to1 != 0: result.add node.to1.dumpNode(indent + 1)
  return dumpNode(0)

# multi-set 的な add
proc addMulti*(self:var BinTrieTree,n:int) =
  var nowIndex = 0
  for i in self.rank.countdown(0):
    self.nodes[nowIndex].count += 1
    var nextIndex = self.nodes[nowIndex].to0
    let nextIs1 = (n and (1 shl i)) > 0
    if nextIs1 : nextIndex = self.nodes[nowIndex].to1
    if nextIndex == 0: nextIndex = self.newBinTrieNode().int32
    if nextIs1: self.nodes[nowIndex].to1 = nextIndex
    else: self.nodes[nowIndex].to0 = nextIndex
    nowIndex = nextIndex
    if i != 0 : continue
    self.nodes[nowIndex].count = 1
    self.nodes[nowIndex].value = n
    return

# proc `in`*(n:int,self:BinTrieTree) : bool =
#   var now = self.nodes[0]
#   while not now.isLeaf:
#     if now.valueOrMask.isTo1(n):
#       if now.to1 == 0 : return false
#       now = self.nodes[now.to1]
#     else:
#       if now.to0 == 0 : return false
#       now = self.nodes[now.to0]
#   return now.valueOrMask == n
# multi-set にしたくなければ
# proc add*(self:var BinTrieTree,n:int) =
#   if not (n in self): self.addMulti(n)

import times
template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
import "../mathlib/random"
var T = newBinTree()
# 1e5 が限界
stopwatch:
  for i in 0..100000:
    let r = random(1e9.uint)
    T.addMulti r.int
