# https://topcoder.g.hatena.ne.jp/spaghetti_source/20121216/1355652855
# Fixed Universe Set
# 爆速な std::set.
# 制約 : 整数のみしか扱えない.
# 特徴 : 爆速. 値同士が近いと更に爆速.
const FU64Bit = true
when FU64Bit: # 範囲が1e9以内ならfalse (ほんのり速い)
  const FUBit = 4
  const FUMaxBit = 64
  const FUOffset = 1 shl 62
else: # 1073741824 == 1 shl 30 ≒ 1e9 より、 32bitあれば十分
  const FUBit = 4
  const FUMaxBit = 32
  const FUOffset = 1e9.int + 10
type FUNode = ref object
  S:int # 1つ以上あるならそのBitはtrue
  case isLeaf: bool
  of false: child: array[1 shl FUBit,FUNode]
  of true: count: array[1 shl FUBit,int32]
type FUSet = ref object
  root : FUNode
  multi: bool
proc newFUNode(isLeaf:bool):FUNode = FUNode(isLeaf:isLeaf)
proc getH(self:FUNode,x:int,r:int):int{.inline.} =
  (x shr (r - FUBit)) and ((1 shl FUBit) - 1)
proc addImpl(self:FUNode,x:int,r:int,multi:bool = true) =
  let h = self.getH(x,r)
  self.S = self.S or (1 shl h)
  if r <= FUBit : # 最下層
    if multi: self.count[h] += 1
    else: self.count[h] = 1
    return
  if self.child[h] == nil:
    self.child[h] = newFUNode(r <= FUBit * 2)
  self.child[h].addImpl(x,r - FUBit,multi)
proc findImpl(self:FUNode,x:int,r:int) : bool =
  let h = self.getH(x,r)
  if (self.S and (1 shl h)) == 0 : return false
  if r <= FUBit: return true
  return self.child[h].findImpl(x,r-FUBit)
proc delImpl(self:FUNode,x:int,r:int) =
  let h = self.getH(x,r)
  if (self.S and (1 shl h)) == 0 : return
  if r <= FUBit:  # 最下層
    self.count[h] -= 1
    if self.count[h] == 0:
      self.S = self.S and not (1 shl h)
  else:
    self.child[h].delImpl(x,r-FUBit)
    if self.child[h].S == 0:
      self.S = self.S and not (1 shl h)
# proc getAllImpl(self:FUNode): seq[int] =


proc newFUSet*(multi:bool):FUSet =
  new(result)
  result.root = newFUNode(false)
  result.multi = multi
proc add*(self:FUSet,x:int) =
  self.root.addImpl(x + FUOffset,FUMaxBit,self.multi)
proc contains*(self:FUSet,x:int) : bool =
  self.root.findImpl(x + FUOffset,FUMaxBit)
proc del*(self:FUSet,x:int) : bool =
  self.root.delImpl(x + FUOffset,FUMaxBit)


import times
import "../../mathlib/random"
# block:
#   template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
#   block:
#     stopwatch:
#       var S = newFUSet()
#       let n = 1e6.int
#       for i in 0..<n: S.add i
#   block:
#     stopwatch:
#       var S = newFUSet()
#       let n = 1e6.int
#       for i in 0..<n: S.add randomBit(30).int
when isMainModule:
  import unittest
  test "FU Bit":
    var S = newFUSet(true)
    echo 100 in S
    for i in 0..<100: S.add i
    # for i in 0..<110: echo i in S
