import sequtils,strutils,algorithm
{.overflowChecks:off.}
# int を bool の 集合として扱って64個まで爆速
# 基本的には seq[bool], keys は true のもののみを列挙
type BitSet* = int
# 基本演算
proc `[]=`*(a:var BitSet,i:range[0..63],exists:bool) =
  if exists : a = a or (1 shl i)
  else: a = a and (not (1 shl i))
proc `[]`*(a:BitSet,i:range[0..63]) : bool = (a and (1 shl i)) != 0
proc flipAt*(a:var BitSet,i:range[0..63]) = a = a xor (1 shl i)
proc zerosBitSet*():BitSet = 0
proc onesBitSet*():BitSet = -1
proc flip*(a:BitSet): BitSet = not a
proc merge*(a,b: BitSet):BitSet = a or b
proc common*(a,b:BitSet):BitSet = a and b
proc diff*(a,b:BitSet):BitSet = a xor b
proc isSubset*(a,b:BitSet):bool = (a and b) == a
proc sub*(a,b:BitSet):BitSet = a - (a and b) # aからbの要素を抜く

# 型変換
proc toBoolSeq*(a:BitSet): seq[bool] =
  result = newSeq[bool](64)
  for i in 0..<64: result[i] = a[i]
proc fromBoolSeq*(a:seq[bool]) : BitSet =
  for i in 0..<a.len: result[i] = a[i]
proc keys*(a:BitSet): seq[int] =
  result = @[]
  for i in 0..<64:
    if a[i] : result.add i
proc fromKeys*(keys:seq[int]): BitSet =
  for k in keys: result[k] = true
proc toBinStr*(a:BitSet,maxKey:int=64):string =
  var S = newSeq[string](64)
  for i in 0..<64: S[63 - i] = $(((a and (1 shl i)) != 0).int)
  return S.join("")[(64-maxKey)..^1]
proc fromBinStr*(S:string):BitSet =
  let sLen = 64.min(S.len())
  for i in 0..<sLen:
    if S[i] == '1':
      result[sLen-i-1] = true

# 高度な演算
when NimMajor * 100 + NimMinor >= 18: import bitops
else:
  proc popcount(x: culonglong): cint {.importc: "__builtin_popcountll", cdecl.}
  proc parityBits(x: culonglong): cint {.importc: "__builtin_parityll", cdecl.}
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc reverseBits(n:int): int64 =
    result = (((0x0000ffff0000ffff) and result) shl 16) or(((0xffff0000ffff0000) and result) shr 16)
    result = (result shl 32) or (result shr 32)
  proc rotateRightBits*(value: uint64, amount: range[0..64]): uint64 =
    let amount = amount and 63
    result = (value shr amount) or (value shl ( (-amount) and 63))
  proc rotateLeftBits*(value: uint64,amount: range[0..64]): uint64 =
    let amount = amount and 63
    result = (value shl amount) or (value shr ( (-amount) and 63))
  # math.nextPowerOfTwo() (0->1, 5->8, 16->16)

# 要素数
proc len*(a:BitSet) :int = cast[culonglong](a).popcount()
proc lenIsOdd*(a:BitSet) : bool = 1 == cast[culonglong](a).parityBits()
proc lenIs1*(a:BitSet): bool =  (a > 0) and ((a and (a - 1)) == 0)
# キーの抽出/マスク
proc maxKey*(a:BitSet):int = 63 - cast[culonglong](a).countLeadingZeroBits()
proc minKey*(a:BitSet):int = cast[culonglong](a).countTrailingZeroBits()
proc onlyMaxKeySet*(a:BitSet):BitSet =
  if a == 0 : return 0
  return 1 shl a.maxKey() # 意味的には NextPowerOf2
proc onlyMinKeySet*(a:BitSet):BitSet = a and (-a) # 意味的には factorOf2
proc allGreaterThanMaxKeySet*(a:BitSet):BitSet =
  if a == 0 : return -1
  let maxKey = a.onlyMaxKeySet()
  return (not(maxKey - 1)) xor maxKey
proc allSmallerThanMinKeySet*(a:BitSet):BitSet =
  if a == 0 : return 0
  else: return a.onlyMinKeySet() - 1
proc at*(a:BitSet,slice:Slice[int]):BitSet =
  let minMask = (1 shl slice.a) - 1
  let maxMask = (2 shl slice.b) - 1
  return a and (maxMask - minMask)
# キー全体に加減算　{範囲外削除 / mod 64 内}
proc plusAllKeys*(a:BitSet,x:range[-64..64]) : BitSet =
  if x >= 0 : return a shl x
  else: return cast[int](cast[uint64](a) shr (-x).uint64) # Nim 0.19.0 から 負のshrがrollingに
proc plusAllKeysMod64*(a:BitSet,x:range[-64..64]) : BitSet =
  if x >= 0 : return cast[int](cast[uint64](a).rotateLeftBits(x))
  return cast[int](cast[uint64](a).rotateRightBits(-x))

# 全状態を舐める: O(2^n) 例: n=5 で 0b0000 ~ 0b1111.
iterator allState*(n:int): int =
  for i in 0..<(1 shl n): yield i
# 全状態とその部分集合を舐める: O(3^n)
# 例: 0101 -> [0101,0100,0001,0000]
iterator allSubState*(n:int): tuple[i,j:int] =
  yield (0,0)
  for i in 1..<(1 shl n):
    var j = i
    while j > 0 :
      yield (i,j)
      j = (j - 1) and i
    yield (i,j)
# 全状態とそのsupersetを全て舐める: O(3^n)
# 例: 100 -> [100,101,110,111]
iterator allSuperState*(n:int): tuple[i,j:int] =
  let n2 = 1 shl n
  yield (n2 - 1,n2 - 1)
  for i in (n2 - 2).countdown(0):
    var j = i
    while j < n2 :
      yield (i,j)
      j = (j + 1) or i

# 一応ね
proc powerOf2*(x:range[0..63]):int = 1 shl x
proc fastLog2*(x:int):int = 63 - cast[culonglong](x).countLeadingZeroBits()

# {.inline,noSideEffect.} をつけてもそんなに変わらない.見にくくなるだけ損
when isMainModule:
  import unittest
  test "bitset":
    var n = 0b110101
    check:n.toBinStr(6) == "110101"
    check:n.keys() == @[0,2,4,5]
    n[63] = true
    check:n.keys() == @[0,2,4,5,63]
    check:n[2]
    check:(not n[1])
    n[1] = true
    n[2] = false
    check:n.keys() == @[0,1,4,5,63]
    n.flipAt(2)
    check:n.keys() == @[0,1,2,4,5,63]
    n.flipAt(0)
    check:n.keys() == @[1,2,4,5,63]
    n = zerosBitSet()
    check:n.keys() == newSeq[int]()
    n = onesBitSet()
    check:n.flip().keys() == newSeq[int]()
    var m = 0
    n =   "110001".fromBinStr()
    m =   "101011".fromBinStr()
    check:"111011" == n.merge(m).toBinStr(6)
    check:"100001" == n.common(m).toBinStr(6)
    check:"011010" == n.diff(m).toBinStr(6)
    check:"010000" == n.sub(m).toBinStr(6)
    check:"100001".fromBinStr().isSubSet(m)
    check:"101011" == m.toBinStr(6)
    let ordinal = toSeq(0..63)
    check:((-1).keys() == ordinal)
    n = @[0,1,3,9,63].fromKeys()
    check:n.keys() == @[0,1,3,9,63]
    check: @[true,false,true].fromBoolSeq().keys() == @[0,2]
    check: n.keys().len == 5
    check: n.len == 5
    check: n.lenIsOdd()
    check: 64.lenIs1
    check: not 52.lenIs1
    n = @[0,1,3,9,63].fromKeys()
    m = @[11,25,26,27,38].fromKeys()
    check: n.maxKey() == 63
    check: m.maxKey() == 38
    check: n.minKey() == 0
    check: m.minKey() == 11
    check: n.plusAllKeys(3).keys() == @[3, 4, 6, 12]
    check: n.plusAllKeys(-3).keys() == @[0, 6, 60]
    check: m.plusAllKeys(3).keys() == @[14, 28, 29, 30, 41]
    check: m.plusAllKeys(-3).keys() == @[8, 22, 23, 24, 35]
    check: n.plusAllKeysMod64(3).keys() == @[2, 3, 4, 6, 12]
    check: n.plusAllKeysMod64(-3).keys() == @[0, 6, 60, 61, 62]
    check: m.plusAllKeysMod64(3).keys() == @[14, 28, 29, 30, 41]
    check: m.plusAllKeysMod64(-3).keys() == @[8, 22, 23, 24, 35]
    check: n.onlyMinKeySet().keys() == @[0]
    check: m.onlyMinKeySet().keys() == @[11]
    check: n.allSmallerThanMinKeySet().keys() == newSeq[int]()
    check: m.allSmallerThanMinKeySet().keys() == toSeq(0..10)
    check: n.onlyMaxKeySet().keys() == @[63]
    check: m.onlyMaxKeySet().keys() == @[38]
    check: n.allGreaterThanMaxKeySet().keys() == newSeq[int]()
    check: m.allGreaterThanMaxKeySet().keys() == toSeq(39..63)
    check: 0.onlyMaxKeySet().keys() == newSeq[int]()
    check: 0.onlyMinKeySet().keys() == newSeq[int]()
    check: 0.allSmallerThanMinKeySet().keys() == newSeq[int]()
    check: 0.allGreaterThanMaxKeySet().keys() == toSeq(0..63)
    check: onesBitSet().onlyMaxKeySet().keys() == @[63]
    check: onesBitSet().onlyMinKeySet().keys() == @[0]
    check: onesBitSet().allSmallerThanMinKeySet().keys() == newSeq[int]()
    check: onesBitSet().allGreaterThanMaxKeySet().keys() == newSeq[int]()
    check: @[0,1,3,4,5,7,11,15,29,30,31,32,33,63].fromKeys().at(4..32).keys() == @[4,5,7,11,15,29,30,31,32]
    check: @[0,1,62,63].fromKeys().at(0..63).keys() == @[0,1,62,63]
    check: @[0,1,62,63].fromKeys().at(1..<63).keys() == @[1,62]
    check: 48.onlyMinKeySet() == 16
    check: 1.powerOf2() == 2
    block:
      for s in 3.allState():
        check: s.keys() == @[@[],@[0],@[1],@[0, 1],@[2],@[0, 2],@[1, 2],@[0, 1, 2]][s]
