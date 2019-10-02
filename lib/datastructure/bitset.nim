import sequtils,strutils,algorithm
# int を bool の 集合として扱って64個まで爆速
# 基本的には seq[bool], keys は true のもののみを列挙
# 多分動くけどキー「63」はちょっと怪しいかも
type BitSet = int
# 基本演算
proc `[]=`(a:var BitSet,i:range[0..63],exists:bool) =
  if exists : a = a or (1 shl i)
  else: a = a and (not (1 shl i))
proc `[]`(a:BitSet,i:range[0..63]) : bool = (a and (1 shl i)) != 0
proc flipAt(a:var BitSet,i:range[0..63]) = a = a xor (1 shl i)
proc clear(a:var BitSet) = a = 0
proc fill(a:var BitSet) = a = -1
proc flipped(a:BitSet): BitSet = not a
proc merge(a,b: BitSet):BitSet = a or b
proc common(a,b:BitSet):BitSet = a and b
proc diff(a,b:BitSet):BitSet = a xor b
proc isSubset(a,b:BitSet):bool = (a and b) == a
proc sub(a,b:BitSet):BitSet = a - (a and b) # aからbの要素を抜く

# 型変換
proc toBoolSeq(a:BitSet): seq[bool] =
  result = newSeq[bool](64)
  for i in 0..<64: result[i] = a[i]
proc fromBoolSeq(a:seq[bool]) : BitSet =
  for i in 0..<a.len: result[i] = a[i]
proc keys(a:BitSet): seq[int] =
  result = @[]
  for i in 0..<64:
    if a[i] : result.add i
proc fromKeys(keys:seq[int]): BitSet =
  for k in keys: result[k] = true
proc toBinStr(a:BitSet,maxKey:int=64):string =
  result = a.toBoolSeq().reversed().mapIt($it.int).join("")
  result = result[(64-maxKey)..^1]
proc fromBinStr(S:string):BitSet =
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
proc len(a:BitSet) :int = cast[culonglong](a).popcount()
proc lenIsOdd(a:BitSet) : int = cast[culonglong](a).parityBits()
proc lenIs1(a:BitSet): bool =  (a > 0) and ((a and (a - 1)) == 0)
proc maxKey(a:BitSet):int = 64 - cast[culonglong](a).countLeadingZeroBits()
proc minKey(a:BitSet):int = cast[culonglong](a).countTrailingZeroBits()
# {範囲外は消して/mod 64 の中で}キー全体に加算・減算
proc plusAllKeys(a:BitSet,x:range[-64..64]) : BitSet =
  if x >= 0 : return a shl x
  else: return a shr x
proc plusAllKeysMod64(a:BitSet,x:range[-64..64]) : BitSet =
  if x >= 0 : return cast[int](cast[uint64](a).rotateLeftBits(x))
  return cast[int](cast[uint64](a).rotateRightBits(-x))
proc onlyMaxKey(a:BitSet):BitSet = a and (-a)
proc onlyMinKey(a:BitSet):BitSet = (not a) and (a + 1)
proc allSmallerThanMinKey(a:BitSet):BitSet = a.onlyMinKey() - 1
proc allGreaterThanMaxKey(a:BitSet):BitSet = -2 * a.onlyMaxKey()

# bitDP用
# math.nextPowerOfTwo も使える
proc factorOf2(n:int):int = n and -n # 48 -> 16
proc powerOf2(i:range[0..63]):int = 1 shl i
iterator allState(maxKey:int): BitSet =
  for a in 0..<(1 shl maxKey): yield a

# 中間点
# let n3 = 1 shl (n1 xor n2).culonglong.fastLog2()
# created.valueOrMask = (n1 or n2) and (not (n3 - 1))

# prefix
# let mask = not(x xor (x - 1))
# if (x and mask) != (n and mask) :
# TODO: check -1,0,1,2^63
# {.inline.,noSideEffect} をつけると速くなるかも？
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
    n.clear()
    check:n.keys() == newSeq[int]()
    n.fill()
    check:n.flipped().keys() == newSeq[int]()
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
