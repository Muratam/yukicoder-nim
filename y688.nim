import sequtils,strutils,algorithm,math,bitops

# a:0 b:1 で合計が2となるのがちょうどK通り
# 2^a * bC2 == k なる aとbを求める :: bC2 = b!/2!/(b-2)! = b*(b-1)/2
let k = stdin.readLine().parseInt()
proc factorOf2(n:int):int = n and -n
let maxA = k.factorOf2().countTrailingZeroBits()
for a in 0..maxA:
  let c = k div (1 shl a)
  let d = 1 + 8 * c
  let dsqrt = d.float.sqrt.int
  if dsqrt * dsqrt != d : continue
  if (1 + dsqrt) mod 2 == 1 : continue
  let b = (1 + dsqrt) div 2
  if a + b > 30 : continue
  echo a + b
  echo ("0".repeat(a) & "1".repeat(b)).join(" ")
  quit(0)
