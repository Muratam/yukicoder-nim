# https://topcoder.g.hatena.ne.jp/spaghetti_source/20121216/1355652855
# Fixed Universe Set. 探索木.
# 制約 : 整数のみ.
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
  size : int
proc newFUNode(isLeaf:bool):FUNode = FUNode(isLeaf:isLeaf)
proc getH(self:FUNode,x:int,r:int):int{.inline.} =
  (x shr (r - FUBit)) and ((1 shl FUBit) - 1)
proc add(self:FUNode,x:int,r:int,multi:bool = true) : bool =
  let h = self.getH(x,r)
  self.S = self.S or (1 shl h)
  if r <= FUBit : # 最下層
    result = multi or self.count[h] == 0
    if multi: self.count[h] += 1
    else: self.count[h] = 1
    return
  if self.child[h] == nil:
    self.child[h] = newFUNode(r <= FUBit * 2)
  return self.child[h].add(x,r - FUBit,multi)
proc find(self:FUNode,x:int,r:int) : bool =
  let h = self.getH(x,r)
  if (self.S and (1 shl h)) == 0 : return false
  if r <= FUBit: return true
  return self.child[h].find(x,r-FUBit)
proc del(self:FUNode,x:int,r:int) : bool =
  let h = self.getH(x,r)
  if (self.S and (1 shl h)) == 0 : return false
  if r <= FUBit:  # 最下層
    self.count[h] -= 1
    result = self.count[h] == 0
    if result:
      self.S = self.S and not (1 shl h)
  else:
    result = self.child[h].del(x,r-FUBit)
    if self.child[h].S == 0:
      self.S = self.S and not (1 shl h)
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc min(self:FUNode,r:int) : int =
  let h = cast[culonglong](self.S).countTrailingZeroBits().int
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child[h].min(r-FUBit)
proc max(self:FUNode,r:int) : int =
  let h = 63 - cast[culonglong](self.S).countLeadingZeroBits().int
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child[h].max(r-FUBit)


proc newFUSet*(multi:bool):FUSet =
  new(result)
  result.root = newFUNode(false)
  result.multi = multi
  result.size = 0
proc add*(self:FUSet,x:int) =
  let ok = self.root.add(x + FUOffset,FUMaxBit,self.multi)
  if ok: self.size += 1
proc contains*(self:FUSet,x:int) : bool =
  self.root.find(x + FUOffset,FUMaxBit)
proc del*(self:FUSet,x:int) =
  let ok = self.root.del(x + FUOffset,FUMaxBit)
  if ok: self.size -= 1
proc len*(self:FUSet):int = self.size
proc min*(self:FUSet):int =
  self.root.min(FUMaxBit) - FUOffset
proc max*(self:FUSet):int =
  self.root.max(FUMaxBit) - FUOffset
import times
import "../../mathlib/random"
block:
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  block:
    stopwatch:
      var S = newFUSet(true)
      let n = 1e6.int
      for i in 0..<n: S.add i
  block:
    stopwatch:
      var S = newFUSet(true)
      let n = 1e6.int
      for i in 0..<n: S.add randomBit(30).int
when isMainModule:
  import unittest
  test "FU Bit":
    var S = newFUSet(true)
    echo 100 in S
    for i in 0..<100: S.add i
    echo S.min()
    echo S.max()
    for i in -100..<300: S.add i
    echo S.min()
    echo S.max()
