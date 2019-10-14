# https://topcoder.g.hatena.ne.jp/spaghetti_source/20121216/1355652855
# Fixed Universe Set. 探索木.
# 制約 : 整数のみ.
# 特徴 : 爆速. 値同士が近いと更に爆速.
const FU64Bit = false
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
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc newFUNode(isLeaf:bool):FUNode = FUNode(isLeaf:isLeaf)
proc getH(self:FUNode,x:int,r:int):int{.inline.} =
  (x shr (r - FUBit)) and ((1 shl FUBit) - 1)
proc maxBit(x:int):int {.inline.}=
  63 - cast[culonglong](x).countLeadingZeroBits().int
proc minBit(x:int):int {.inline.}=
  cast[culonglong](x).countTrailingZeroBits().int
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
proc min(self:FUNode,r:int) : int =
  let h = self.S.minBit()
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child[h].min(r-FUBit)
proc max(self:FUNode,r:int) : int =
  let h = self.S.maxBit()
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child[h].max(r-FUBit)
# TODO:
# iterator items(self:FUNode,r:int):int =
  # type WithRank = tuple[node:FUNode,r:int]
  # var nodes : seq[WithRank] = @[(self,r)]
  # var chunks : seq[WithRank] = newSeq[]()
  # while treaps.len > 0:
  #   let now = treaps.pop()
  #   if now == nil : continue
  #   if now.right != nil:
  #     treaps.add now.right
  #   if now.left != nil:
  #     treaps.add now.left
  #   while chunks.len > 0 and now.key > chunks[^1].key:
  #     yield chunks.pop()
  #   chunks.add now
  # while chunks.len > 0:
  #   yield chunks.pop()
# iterator revItems(self:FUNode,r:int):int =
# iterator greater(self:FUNode,x:int,r:int,including:bool):int =
# iterator less(self:FUNode,x:int,r:int,including:bool):int =
proc findGreater(self:FUNode,x:int,r:int,including:bool,sameH:bool=true) : tuple[ok:bool,v:int] =
  var h = if sameH : self.getH(x,r) else: self.S.minBit()
  var S = if sameH : self.S and not ((1 shl h) - 1) else: self.S
  var i = h
  while S > 0:
    defer:
      S = S and (not (1 shl i))
      if S > 0: i = S.minBit()
    if (self.S and (1 shl i)) == 0 : continue
    if r <= FUBit:
      if sameH and not including and i == h: continue
      return (true,i)
    let (ok,v) = self.child[i].findGreater(x,r-FUBit,including,sameH and i == h)
    if ok: return (true, (i shl (r - FUBit)) + v)
  return (false,-1)
proc findLess(self:FUNode,x:int,r:int,including:bool,sameH:bool=true) : tuple[ok:bool,v:int] =
  var h = if sameH : self.getH(x,r) else: self.S.maxBit()
  var S = if sameH : self.S and ((2 shl h) - 1) else: self.S
  var i = h
  while S > 0:
    defer:
      S = S and (not (1 shl i))
      if S > 0: i = S.maxBit()
    if (self.S and (1 shl i)) == 0 : continue
    if r <= FUBit:
      if sameH and not including and i == h: continue
      return (true,i)
    let (ok,v) = self.child[i].findLess(x,r-FUBit,including,sameH and i == h)
    if ok: return (true, (i shl (r - FUBit)) + v)
  return (false,-1)

# Root
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
proc findLess*(self:FUSet,x:int,including:bool): tuple[ok:bool,v:int] =
  let (ok,v) = self.root.findLess(x + FUOffset,FUMaxBit,including)
  if not ok: return (false,-1)
  return (true,v - FUOffset)
proc findGreater*(self:FUSet,x:int,including:bool): tuple[ok:bool,v:int] =
  let (ok,v) = self.root.findGreater(x + FUOffset,FUMaxBit,including)
  if not ok: return (false,-1)
  return (true,v - FUOffset)

when isMainModule:
  import unittest
  import times
  import "../../mathlib/random"
  template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
  import strutils
  proc toBinStr*(a:int,maxKey:int=64):string =
    var S = newSeq[string](64)
    for i in 0..<64: S[63 - i] = $(((a and (1 shl i)) != 0).int)
    return S.join("")[(64-maxKey)..^1]
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
  test "FU Bit":
    var S = newFUSet(false)
    for i in @[100,300,200,210,205,201,200,202]:
      S.add i
    # for i in 310.countdown(90):
    #   echo i,"LT:",S.findLess(i,false),S.findLess(i,true)
    #   echo i,"GT:",S.findGreater(i,false),S.findGreater(i,true)
    # echo 100 in S
    # for i in 0..<100: S.add i
    # echo S.min()
    # echo S.max()
    # for i in -100..<300: S.add i
    # echo S.min()
    # echo S.max()
    # echo S.len
