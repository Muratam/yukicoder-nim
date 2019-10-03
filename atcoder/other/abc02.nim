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
  result = a.toBoolSeq().reversed().mapIt($it.int).join("")
  result = result[(64-maxKey)..^1]
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
proc onlyMinKeySet*(a:BitSet):BitSet = a and (-a) # 意味的には factorOf2
proc onlyMaxKeySet*(a:BitSet):BitSet =
  if a == 0 : return 0
  return 1 shl a.maxKey() # 意味的には NextPowerOf2
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
# bitDP用
proc powerOf2*(i:range[0..63]):int = 1 shl i
iterator allState*(maxSize:int): BitSet =
  for a in 0..<(1 shl maxSize): yield a

import sequtils

# 隣接リスト => 隣接行列
# 有向グラフ(E[src][dst] => M[src][dst])
proc toMatrix(E:seq[seq[int]]):seq[seq[bool]] =
  result = newSeqWith(E.len,newSeq[bool](E.len))
  for src, dsts in E:
    for dst in dsts:
      result[src][dst] = true
proc fromMatrix(M:seq[seq[bool]]):seq[seq[int]] =
  result = newSeqWith(M.len,newSeq[int]())
  for src in 0..<M.len:
    for dst in 0..<M.len:
      if M[src][dst] : result[src].add dst
proc coGraph(M:seq[seq[bool]]):seq[seq[bool]] =
  result = newSeqWith(M.len,newSeq[bool](M.len))
  for src in 0..<M.len:
    for dst in 0..<M.len:
      result[src][dst] = not M[src][dst]
proc coGraph(E:seq[seq[int]]):seq[seq[int]] =
  E.toMatrix().coGraph().fromMatrix()

import math
proc maximumIndependentSet(M:seq[seq[bool]]) : seq[int] =
  let n = M.len
  var G = newSeq[BitSet](n)
  var usable = 0
  for i in 0..<M.len:
    G[i] = M[i].fromBoolSeq()
    usable[i] = true
  proc impl(usable:BitSet): seq[int] =
    var v = -1
    var usable = usable
    result = @[]
    for i in 0..<n:
      if not usable[i] : continue
      let neighbor = (usable and G[i]).len
      if neighbor > 1: v = i
      else:
        usable[i] = false
        usable = usable and not G[i]
        result.add i
    if v < 0 : return result
    usable[v] = false
    var res1 = impl(usable and not G[v])
    res1.add v
    var res2 = impl(usable)
    if res1.len > res2.len: result.add res1
    else: result.add res2
  return impl(usable)
proc maximumClique(M:seq[seq[bool]]):seq[int] =
  M.coGraph.maximumIndependentSet()



import sequtils,algorithm,math,strutils,tables,sets
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
# proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
# proc scan(): int = scanf("%lld\n",addr result)


let n = scan()
let m = scan()
var M = newSeqWith(n,newSeq[bool](n))
m.times:
  let x = scan() - 1
  let y = scan() - 1
  M[x][y] = true
  M[y][x] = true
echo M.maximumClique().len
