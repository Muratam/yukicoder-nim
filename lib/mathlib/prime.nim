# 素数表生成
import sequtils,math
proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false
# 素数リスト生成
proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
  let isPrimes = getIsPrimes(n)
  result = @[]
  for i,p in isPrimes:
    if p : result .add i
# SFF で素因数分解

proc getFactors(n:int):seq[int]=
  proc powerWhenTooBig(x,n:int,modulo:int = 0): int =
    proc mul(x,n,modulo:int):int =
      if n == 0: return 0
      if n == 1: return x
      result = mul(x,n div 2,modulo) mod modulo
      result = (result * 2) mod modulo
      result = (result + x * (n mod 2 == 1).int) mod modulo
      if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = powerWhenTooBig(x,n div 2,modulo)
      odd = if n mod 2 == 1: x else: 1
    if modulo > 0:
      const maybig = int.high.float.sqrt.int div 2
      if pow_2 > maybig or odd > maybig:
        result = mul(pow_2,pow_2,modulo)
        result = mul(result,odd,modulo)
      else:
        result = (pow_2 * pow_2) mod modulo
        result = (result * odd) mod modulo
    else:
      return pow_2 * pow_2 * odd
  proc millerRabinIsPrime(n:int):bool = # O(log n)
    proc ctz(n:int):int{.importC: "__builtin_ctzll", noDecl .} # 01<0000> -> 4
    proc power(x,n:int,modulo:int = 0): int =
      if n == 0: return 1
      if n == 1: return x
      let pow_2 = power(x,n div 2,modulo)
      result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
      if modulo > 0: result = result mod modulo
    if n <= 1 : return false
    if n == 2 or n == 3 or n == 5: return true
    if n mod 2 == 0: return false
    let
      s = ctz(n - 1)
      d = (n - 1) div (1 shl s)
    var a_list = @[2, 7, 61]
    if n >= 4_759_123_141 and n < 341_550_071_728_321:
      a_list = @[2, 3, 5, 7, 11, 13, 17]
    if n in a_list : return true
    for a in a_list:
      if powerWhenTooBig(a,d,n) == 1 : continue
      let notPrime = (0..<s).allIt(powerWhenTooBig(a,d*(1 shl it),n) != n-1)
      if notPrime : return false
    return true
  proc squareFormFactor(n:int):int =
    if millerRabinIsPrime(n) : return n
    proc check(k:int):int =
      proc √(x:int):int = x.float.sqrt.int
      if n <= 1 : return n
      if n mod 2 == 0 : return 2
      if √(n) * √(n) == n : return √(n)
      let ncb = n.float.cbrt.int
      if ncb * ncb * ncb == n : return ncb
      var P1 = √(k * n)
      var Q2 = 1
      var Q1 = k * n - P1 * P1
      while √(Q1) * √(Q1) != Q1:
        let b = (√(k * n) + P1 ) div Q1
        let ppP = P1
        let pP = b * Q1 - P1
        let ppQ = Q2
        P1 = pP
        Q2 = Q1
        Q1 = ppQ + b * (ppP - pP)
      block:
        if Q1 == 0 : return check(k + 1)
        let
          b = (√(k * n) - P1 ) div Q1
          P0 = b * √(Q1) + P1
          Q0 = √(Q1)
          QX = (k*n - P0 * P0) div Q0
        P1 = P0
        Q1 = QX
        Q2 = Q0
      while true:
        let b = (√(k * n) + P1 ) div Q1
        let ppP = P1
        let pP = b * Q1 - P1
        let ppQ = Q2
        let pQ = Q1
        let q = ppQ + b * (ppP - pP)
        P1 = pP
        Q2 = Q1
        Q1 = q
        if ppP == pP or q == pQ: break
      let f = gcd(n,P1)
      if f != 1 and f != n : return f
      else: return check(k+1)
    return check(1)
  if n == 1 : return @[1]
  if n == 0 : return @[0]
  result = @[]
  var m = n
  while true:
    let p = m.squareFormFactor()
    if p.millerRabinIsPrime(): result .add p
    else: result .add p.getFactors()
    if p == m: return
    m = m div p

# 因数を全て列挙
import intsets,algorithm
proc getAllFactors(n:int):seq[int] =
  let factors = n.getFactors()
  var xs = initIntSet()
  xs.incl 1
  for f in factors:
    for x in toSeq(xs.items):
      xs.incl(x * f)
  return toSeq(xs.items).sorted(cmp)
# 範囲内の全ての素因数を列挙
proc getFactorsInRange(n:int):seq[seq[int]] =
  result = newSeqWith(n+1,newSeq[int]())
  for i in 2..n.float.sqrt.int :
    if result[i].len != 0: continue
    result[i] .add i
    for j in countup(i*2,n,i):
      var x = j
      while x mod i == 0: # その素数で割り切れなくなるまで
        result[j] .add i
        x = x div i
  for i in 2..n:
    var sum = 1
    for x in result[i] : sum *= x
    if sum != i : result[i] .add i div sum

when isMainModule:
  import unittest
  test "prime":
    check:getIsPrimes(4) == @[false, false, true, true, false]
    check:getPrimes(11) == @[2, 3, 5, 7, 11]
    check:getFactors(72) == @[2, 2, 2, 3, 3]
    check:getFactors(97) == @[97]
    check:getAllFactors(72) == @[1, 2, 3, 4, 6, 8, 9, 12, 18, 24, 36, 72]
    check:getAllFactors(97) == @[1, 97]
    check:getFactorsInRange(10) == @[@[], @[], @[2], @[3], @[2, 2], @[5], @[2, 3], @[7], @[2, 2, 2], @[3, 3], @[2, 5]]
