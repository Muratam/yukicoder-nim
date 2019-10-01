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
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc bitSize(self:BinPatriciaNode):int =
  self.valueOrMask.culonglong.countTrailingZeroBits.int
proc bitSize(self:BinPatricia):int = self.root.bitSize
proc prefix(self:BinPatriciaNode): int = self.valueOrMask and (self.valueOrMask - 1)
proc len*(self:BinPatricia) : int = self.root.count
proc isTo1(self:BinPatriciaNode,n:int):bool{.inline.} =
  (self.valueOrMask and n) == self.valueOrMask # 上位bitは同じはずなので
# multi-set 的な add
proc addMulti*(self:BinPatricia,n:int) =
  var now = self.root
  while true:
    now.count += 1
    proc createNode(target:var BinPatriciaNode) : bool =
      if target != nil:
        if target.isLeaf:
          # 偶然にも同じ場所だった
          if target.valueOrMask == n:
            target.count += 1
            return true
          # 変な所に葉ができていたので中間点を生成
          let cross = target.valueOrMask xor n
          for bit in (now.bitSize() - 1).countdown(0):
            if (cross and (1 shl bit)) == 0 : continue
            var newLeaf = newBinPatriciaNode()
            newLeaf.isLeaf = true
            newLeaf.valueOrMask = n
            newLeaf.count = 1
            var preLeaf = target
            target = newBinPatriciaNode()
            target.isLeaf = false
            target.valueOrMask = now.prefix() or (1 shl bit)
            target.count = newLeaf.count + preLeaf.count
            if target.isTo1(newLeaf.valueOrMask):
              target.to1 = newLeaf
              target.to0 = preLeaf
            else:
              target.to1 = preLeaf
              target.to0 = newLeaf
            return true
          doAssert false, "このメッセージはでないはずだよ"
        # 行こうとした方向に既に枝があった
        # prefix が一致しているのでその子へ
        if (target.prefix() or n) == n :
          now = target
          return false
        doAssert false
      # この先は空なので直接葉を作ってよい
      target = newBinPatriciaNode()
      target.isLeaf = true
      target.valueOrMask = n
      target.count = 1
      return true
    if now.isTo1(n) :
      if now.to1.createNode(): return
    else:
      if now.to0.createNode(): return
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



import strutils
proc dump(self:BinPatriciaNode,indent:int = 0) : string =
  proc binary(x:int,fill:int=0):string = # 二進表示
    if x == 0 : return "0".repeat(fill)
    result = ""
    var x = x
    while x > 0:
      result .add chr('0'.ord + x mod 2)
      x = x div 2
    for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
    return "0".repeat(0.max(fill - result.len)) & result
  result = $self.count
  result .add "\t"
  for i in 0..<indent: result .add "  "
  if self.isLeaf: result.add "_"
  else: result.add "|"
  result .add self.valueOrMask.binary(6) & "\n"
  if self.to0 != nil: result.add self.to0.dump(indent + 1)
  if self.to1 != nil: result.add self.to1.dump(indent + 1)

proc `$`(self:BinPatricia) : string = self.root.dump()
var T = newBinPatricia()
echo T
T.add 0b000100
echo T
T.add 0b010100
echo T
T.add 0b010111
echo T
echo 0b000100 in T
echo 0b010100 in T
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
