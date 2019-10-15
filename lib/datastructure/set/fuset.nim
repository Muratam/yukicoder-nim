# {.checks:off.}
# Fixed Universe Set.
# 整数のトライ木. 爆速. 値同士が近いと更に爆速.
# https://topcoder.g.hatena.ne.jp/spaghetti_source/20121216/1355652855
# verify : https://atcoder.jp/contests/abc140/tasks/abc140_f
#
# ベンチではめちゃくちゃ速いのになぜかTreapに負けている.
# 理由が分からないので今後そういう問題が出たら考える.
# ベンチ的には std::set よりも速いのでかなり嬉しいんだけどなー.短いし.
const FU64Bit = false
when FU64Bit: # 範囲が1e9以内ならfalse
  const FUBit = 4 # (64bit => 上限:6)
  const FUMaxBit = 64
  const FUOffset = 1 shl 62
else: # 1073741824 == 1 shl 30 ≒ 1e9 より、 32bitあれば十分
  const FUBit = 4
  const FUMaxBit = 32
  const FUOffset = 1e9.int + 10
# int32(4Byte)の個数. 100MBくらい.
const poolMaxNum = 100_000_000 div ((1 shl FUBit) + 2)
var npool : array[poolMaxNum shl FUBit,int32] # count or child
var spool : array[poolMaxNum,int] # S
var poolHead = 1.int32
const NilIndex = 0
type FUSet = ref object
  root : int32
  multi: bool
  size : int
proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
proc newFUNode():int32 = result = poolHead; poolHead += 1
proc getH(x:int,r:int):int{.inline.} = (x shr (r - FUBit)) and ((1 shl FUBit) - 1)
proc maxBit(x:int):int {.inline.}= 63 - cast[culonglong](x).countLeadingZeroBits().int
proc minBit(x:int):int {.inline.}= cast[culonglong](x).countTrailingZeroBits().int
proc child(x:int32,i:int):var int32 {.inline.} = npool[x shl FUBit + i]
proc add(self:int32,x:int,r:int,multi:bool = true) : bool =
  let h = x.getH(r)
  spool[self] = spool[self] or (1 shl h)
  if r <= FUBit : # 最下層
    result = multi or self.child(h) == 0
    if multi: self.child(h) += 1
    else: self.child(h) = 1
    return
  if self.child(h) == NilIndex:
    self.child(h) = newFUNode()
  return self.child(h).add(x,r - FUBit,multi)
proc find(self:int32,x:int,r:int) : bool =
  let h = x.getH(r)
  if (spool[self] and (1 shl h)) == 0 : return false
  if r <= FUBit: return true
  return self.child(h).find(x,r-FUBit)
proc del(self:int32,x:int,r:int) : bool =
  let h = x.getH(r)
  if (spool[self] and (1 shl h)) == 0 : return false
  if r <= FUBit:  # 最下層
    self.child(h) -= 1
    result = self.child(h) == 0
    if result:
      spool[self] = spool[self] and not (1 shl h)
  else:
    result = self.child(h).del(x,r-FUBit)
    if spool[self.child(h)] == 0:
      spool[self] = spool[self] and not (1 shl h)
proc min(self:int32,r:int) : int =
  let h = spool[self].minBit()
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child(h).min(r-FUBit)
proc max(self:int32,r:int) : int =
  let h = spool[self].maxBit()
  if r <= FUBit: return h
  return (h shl (r - FUBit)) + self.child(h).max(r-FUBit)
proc findGreater(self:int32,x:int,r:int,including:bool,sameH:bool=true) : tuple[ok:bool,v:int] =
  var h = if sameH : x.getH(r) else: spool[self].minBit()
  var S = if sameH : spool[self] and not ((1 shl h) - 1) else: spool[self]
  var i = h
  while S != 0:
    defer:
      S = S and (not (1 shl i))
      if S > 0: i = S.minBit()
    if (spool[self] and (1 shl i)) == 0 : continue
    if r <= FUBit:
      if sameH and not including and i == h: continue
      return (true,i)
    let (ok,v) = self.child(i).findGreater(x,r-FUBit,including,sameH and i == h)
    if ok: return (true, (i shl (r - FUBit)) + v)
  return (false,-1)
proc findLess(self:int32,x:int,r:int,including:bool,sameH:bool=true) : tuple[ok:bool,v:int] =
  var h = if sameH : x.getH(r) else: spool[self].maxBit()
  var S = if sameH : spool[self] and ((2 shl h) - 1) else: spool[self]
  var i = h
  while S != 0:
    defer:
      S = S and (not (1 shl i))
      if S > 0: i = S.maxBit()
    if (spool[self] and (1 shl i)) == 0 : continue
    if r <= FUBit:
      if sameH and not including and i == h: continue
      return (true,i)
    let (ok,v) = self.child(i).findLess(x,r-FUBit,including,sameH and i == h)
    if ok: return (true, (i shl (r - FUBit)) + v)
  return (false,-1)
# Root
proc newFUSet*(multi:bool):FUSet =
  new(result)
  result.root = newFUNode()
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
  let n = 1e6.int
  block:
    stopwatch:
      var S = newFUSet(true)
      for i in 0..<n: S.add i
  block:
    stopwatch:
      var S = newFUSet(true)
      for i in 0..<n: S.add randomBit(30).int
  block:
    var S = newFUSet(false)
    for i in @[100,300,200,210,205,201,200,202]:
      S.add i
    echo S.max()
    echo S.min()
    # for i in 0..<300:
    #   echo
