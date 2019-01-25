# 素数 / 因数列挙
template usePrimeFactor() =
  proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false
  proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
    let isPrimes = getIsPrimes(n)
    result = @[]
    for i,p in isPrimes:
      if p : result &= i
  template getFactorByProcess(n:int):seq[int] =
    import osproc
    when defined(macosx):
      const factor = "gfactor "
    else :
      const factor = "factor "
    let p = execProcess(factor & $n ).strip().split()
    p[1..p.len()-1].map(parseInt)

  proc getAllFactors(n:int):seq[int] =
    let factors = n.getFactors()
    var xs = initIntSet()
    xs.incl 1
    for f in factors:
      for x in toSeq(xs.items):
        xs.incl(x * f)
    return toSeq(xs.items).sorted(cmp)

  proc rhoFactor(n:int):int = # (O(n/4)),1~0.1%で失敗
    proc f(x:int):int = (2 + x * x) mod n
    var (x,y,d) = (2,2,1)
    while d == 1:
      x = f(x)
      y = f(f(y))
      d = gcd(abs(x-y),n)
    if d == n : return 0
    else : return d

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

# 整数 の数学関数
template useNaturalMath() =
  proc permutation(n,k:int):int = # nPk をすばやく誤差なく計算
    result = 1
    for i in (n-k+1)..n: result = result * i
  proc combination(n,k:int):int = # nCk
    result = 1
    let x = k.max(n - k)
    let y = k.min(n - k)
    for i in 1..y: result = result * (n+1-i) div i
  proc combinationWithMod(n,k:int,MOD:int):int = # nCk を剰余ありで
    result = 1
    let x = k.max(n - k)
    let y = k.min(n - k)
    var req = 1
    for i in 1..y: req *= i
    for i in 1..y:
      var m = n+1-i
      let g = m.gcd(req)
      m = m div g
      req = req div g
      result = (result * m) mod MOD

  proc roundedDiv(a,b:int) : int = # a / b の四捨五入
    let c = (a * 10) div b
    if c mod 10 >= 5: return 1 + c div 10
    return c div 10
  proc sign(n:int):int = (if n < 0 : -1 else: 1)

# mod
template useModulo() =
  const MOD = 1000000007
  type ModInt = object
    v:int # 0~MODに収まる
  proc toModInt*(a:int) : ModInt =
    if a < -MOD : result.v = ((a mod MOD) + MOD) mod MOD
    elif a < 0 : result.v = a + MOD
    elif a >= MOD: result.v = a mod MOD
    else: result.v = a
  proc `+`*(a,b:ModInt) : ModInt =
    result.v = a.v + b.v
    if result.v >= MOD : result.v = result.v mod MOD
  proc `*`*(a,b:ModInt) : ModInt =
    result.v = a.v * b.v
    if result.v >= MOD : result.v = result.v mod MOD
  proc `^`*(a:ModInt,b:int) : ModInt =
    if b == 0 : return 1.toModInt()
    if b == 1 : return a
    let pow = a^(b div 2)
    if b mod 2 == 0 : return pow * pow
    return pow * pow * a
  proc `+`*(a:int,b:ModInt) : ModInt = a.toModInt() + b
  proc `+`*(a:ModInt,b:int) : ModInt = a + b.toModInt()
  proc `-`*(a:ModInt,b:int) : ModInt = a + (-b)
  proc `-`*(a,b:ModInt) : ModInt = a + (-b.v)
  proc `-`*(a:int,b:ModInt) : ModInt = a.toModInt() + (-b.v)
  proc `*`*(a:int,b:ModInt) : ModInt = a.toModInt() * b
  proc `*`*(a:ModInt,b:int) : ModInt = a * b.toModInt()
  proc `/`*(a,b:ModInt) : ModInt = a * b^(MOD-2)
  proc `$`*(a:ModInt) : string = $a.v

template useFixed() = # 10桁精度で計算
  proc scanFixed(): tuple[a,b:int64] =
    var minus = false
    var now = 0
    var isA = true
    var bcnt = 10_0000_00000
    while true:
      let k = getchar_unlocked()
      if k == '-' : minus = true
      elif k == '.':
        if minus : now *= -1
        result.a = now
        now = 0
        isA = false
      elif k < '0':
        if minus : now *= -1
        if isA : result.a = now
        else: result.b = now * bcnt
        return
      else:
        now = 10 * now + k.ord - '0'.ord
        if not isA: bcnt = bcnt div 10

  proc printFixed(x:tuple[a,b:int64]) =
    var a = x.a + x.b div 10_0000_00000
    var b = x.b mod 10_0000_00000
    if (a < 0) xor (b < 0) :
      var minus = a <= 0
      if minus :
        stdout.write "-"
        a *= -1
        b *= -1
      if b mod 10_0000_00000 != 0:
        a -= 1
        b += 10_0000_00000
      if ($(b.abs)).len >= 11:
        a += 1
        b -= 10_0000_00000
    let B = "0".repeat(10 - ($(b.abs)).len) & ($b.abs)
    echo a,".",B


# x^a
template usePower() =
  proc power(x,n:int): int =
    if n == 0: return 1
    if n == 1: return x
    let pow_2 = power(x,n div 2)
    return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)

  proc power(x,n:int,modulo:int = 0): int =
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
      odd = if n mod 2 == 1: x else: 1
    if modulo > 0:
      result = (pow_2 * odd) mod modulo
      result = (result * pow_2) mod modulo
    else :
      result = pow_2 * pow_2 * odd

  proc bigPower(x,n:int,modulo:int = 0): int =
    proc mul(x,n,modulo:int):int =
      if n == 0: return 0
      if n == 1: return x
      result = mul(x,n div 2,modulo) mod modulo
      result = (result * 2) mod modulo
      result = (result + x * (n mod 2 == 1).int) mod modulo
      if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = bigPower(x,n div 2,modulo)
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
