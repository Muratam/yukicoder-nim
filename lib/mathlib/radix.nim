# 基数(2,10,...)
# 10進数 <=> seq[int]
import algorithm
proc splitAsDecimal*(n:int) : seq[int] =
  if n == 0 : return @[0]
  result = @[]
  var n = n
  while n > 0:
    result .add n mod 10
    n = n div 10
  return result.reversed()
proc joinAsDecimal*(A:seq[int]):int =(for a in A: result = result * 10 + a)

import sequtils,strutils,math
# 二進表現
# @math :: nextPowerOfTwo,isPowerOfTwo
# @bitops
#   popcount :: 100101010 -> 4
#   parityBits :: 1001010 -> 1 (1 is odd)
#   fastlog2 :: int -> int
#   countLeadingZeroBits :: <0000>10 -> 4
#   countTrailingZeroBits :: 01<0000> -> 4 (if 0 then 140734606624512)
#   firstSetBit :: countTrailingZeroBits + 1 (if 0 then 0)
#   when unsigned :: rotateLeftBits rotateRightBits
proc `in`(a,b:int) : bool {.inline.} = (a and b) == a
proc factorOf2(n:int):int = n and -n # 80:0101<0000> => 16:2^4
proc binaryToIntSeq(n:int):seq[int] =
  result = @[]
  for i in 0..64:
    if (n and (1 shl i)) > 0: result .add i
    if n < (1 shl (i+1)) : return
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

when NimMajor * 100 + NimMinor >= 18:
  import bitops
else:
  proc popcount(x: culonglong): cint {.importc: "__builtin_popcountll", cdecl.}
  proc parityBits(x: culonglong): cint {.importc: "__builtin_parityll", cdecl.}
  proc countLeadingZeroBits(x: culonglong): cint {.importc: "__builtin_clzll", cdecl.}
  proc countTrailingZeroBits(x: culonglong): cint {.importc: "__builtin_ctzll", cdecl.}
  proc fastLog2(x:culonglong):cint = 63 - countLeadingZeroBits(x)


when isMainModule:
  import unittest
  test "radix":
    check:31415.splitAsDecimal() == @[3, 1, 4, 1, 5]
    check: @[3,1,2,5,6].joinAsDecimal() == 31256
    check:0b01001 in 0b11101
    check:48.factorOf2() == 16
    check:19.binaryToIntSeq() == @[0, 1, 4]
    check:35.binary() == "100011"
    # bitops
    check:0b100101010.popcount() == 4 # 1 が 4 つ
    check:0b1001010.parityBits() == 1 # 1 が奇数
    check:90.fastlog2() == 6
    check:0b10000.countTrailingZeroBits() == 4 # 4つ最後に0が続く
    check:50.countLeadingZeroBits() == 58 # 最初に0が58個
