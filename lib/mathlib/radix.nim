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
#   popcount :: 100101010 -> 4 (1 is 4)
#   parityBits :: 1001010 -> 1 (1 is odd)
#   fastlog2 :: int -> int
#   countLeadingZeroBits :: <0000>10 -> 4
#   countTrailingZeroBits :: 01<0000> -> 4 (if 0 then 140734606624512)
#   firstSetBit :: countTrailingZeroBits + 1 (if 0 then 0)
#   when unsigned :: rotateLeftBits rotateRightBits
proc `in`(a,b:int) : bool {.inline.}= (((1 shl a) and (1 shl b)) == (1 shl a))
proc factorOf2(n:int):int = n and -n # 80:0101<0000> => 16:2^4
proc binaryToIntSeq(n:int):seq[int] =
  result = @[]
  for i in 0..64:
    if (n and (1 shl i)) > 0: result .add i + 1
    if n < (1 shl (i+1)) : return
proc binary(x:int,fill:int=0):string = # 二進表示
  if x == 0 : return "0".repeat(fill)
  result = ""
  var x = x
  while x > 0:
    result .add chr('0'.ord + x mod 2)
    x = x div 2
  for i in 0..<result.len div 2: swap(result[i],result[result.len-1-i])
  return "0".repeat(0.max(fill - result.len)) & result
