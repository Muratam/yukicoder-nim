import sequtils,math,intsets,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord


# SFF で素因数分解
proc getFactors(n:int):seq[int]=
  const INF = int.high div 4
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
      let notPrime = toSeq(0..<s).allIt(powerWhenTooBig(a,d*(1 shl it),n) != n-1)
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
      var P,Q = newSeq[int]()
      block:
        P &= √(k * n)
        Q &= 1
        Q &= k * n - P[0]*P[0]
      while √(Q[^1]) * √(Q[^1]) != Q[^1]:
        let b = (√(k * n) + P[^1] ) div Q[^1]
        P &= b * Q[^1] - P[^1]
        Q &= Q[^2] + b * (P[^2] - P[^1])
      block:
        if Q[^1] == 0 : return check(k + 1)
        let
          b = (√(k * n) - P[^1] ) div Q[^1]
          P0 = b * √(Q[^1]) + P[^1]
          Q0 = √(Q[^1])
          Q1 = (k*n - P0*P0) div Q0
        (P,Q) = (@[P0], @[ Q0, Q1 ])
      while true:
        let b = (√(k * n) + P[^1] ) div Q[^1]
        P &= b * Q[^1] - P[^1]
        Q &= Q[^2] + b * (P[^2] - P[^1])
        if P[^1] == P[^2] or Q[^1] == Q[^2]: break
      let f = gcd(n,P[^1])
      if f != 1 and f != n : return f
      else: return check(k+1)
    return check(1)
  if n == 1 : return @[1]
  if n == 0 : return @[0]
  result = @[]
  var m = n
  while true:
    let p = m.squareFormFactor()
    if p.millerRabinIsPrime(): result &= p
    else: result &= p.getFactors()
    if p == m: return
    m = m div p
# 因数を全て列挙
proc getAllFactors(n:int):seq[int] =
  let factors = n.getFactors()
  var xs = initIntSet()
  xs.incl 1
  for f in factors:
    for x in toSeq(xs.items):
      xs.incl(x * f)
  return toSeq(xs.items).sorted(cmp)

let a = scan()
let b = scan()
let C = getAllFactors(a+b)
for c in C:
  if c == a or c == b : continue
  if (c + b) mod a != 0 : continue
  if (c + a) mod b != 0 : continue
  echo c
  quit 0
echo -1
