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

  proc rhoFactor(n:int):int = # (O(n/4)),1~0.1%で失敗
    proc f(x:int):int = (2 + x * x) mod n
    var (x,y,d) = (2,2,1)
    while d == 1:
      x = f(x)
      y = f(f(y))
      d = gcd(abs(x-y),n)
    if d == n : return 0
    else : return d


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
    if a.v == 0 : return 0.toModInt()
    if b == 0 : return 1.toModInt()
    if b == 1 : return a
    if b > MOD: return a^(b mod (MOD-1)) # フェルマーの小定理
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

  # 剰余が必要な大きな計算
  # nCk
  proc combination(n,k:int) : ModInt =
    result = 1.toModInt()
    let x = k.max(n - k)
    let y = k.min(n - k)
    var fact = 1.toModInt()
    for i in 2..y: fact = fact * i
    for i in 1..y: result = result * (n+1-i)
    result = result / fact
  # フィボナッチ数列の第n項
  proc calcFib(n:int) : tuple[x:ModInt,y:ModInt] =
    if n == 0 : return (0.toModInt(),1.toModInt())
    let (fn,fn1) = calcFib(n div 2)
    let fnx1 = fn1 - fn
    let f2n = (fn1 + fnx1) * fn
    let f2nx1 = fn * fn + fnx1 * fnx1
    let f2n1 = f2n + f2nx1
    if n mod 2 == 0 : return (f2n,f2n1)
    else: return (f2n1,f2n1 + f2n)





# 行列
template useMatrix =
  type Matrix[T] = ref object
    w,h:int
    data: seq[T]
  proc `[]`[T](m:Matrix[T],x,y:int):T = m.data[x + y * m.w]
  proc `[]=`[T](m:var Matrix[T],x,y:int,val:T) = m.data[x + y * m.w] = val
  proc newMatrix[T](w,h:int):Matrix[T] =
    new(result)
    result.w = w
    result.h = h
    result.data = newSeq[T](w * h)
  proc identityMatrix[T](n:int):Matrix[T] =
    result = newMatrix[T](n,n)
    for i in 0..<n: result[i,i] = 1
  proc newMatrix[T](arr:seq[seq[T]]):Matrix[T] =
    new(result)
    result.w = arr[0].len
    result.h = arr.len
    result.data = newSeq[T](result.w * result.h)
    for x in 0..<result.w:
      for y in 0..<result.h:
        result[x,y] = arr[y][x]
  proc `*`[T](a,b:Matrix[T]): Matrix[T] =
    assert a.w == b.h
    result = newMatrix[T](a.h,b.w)
    for y in 0..<a.h:
      for x in 0..<b.w:
        var n : T
        for k in 0..<a.w:
          n += a[k,y] * b[x,k]
        result[x,y] = n
  proc `^`[T](m:Matrix[T],n:int) : Matrix[T] =
    assert m.w == m.h
    if n <= 0 : return identityMatrix[T](m.w)
    if n == 1 : return m
    let m2 = m^(n div 2)
    if n mod 2 == 0 : return m2 * m2
    return m2 * m2 * m
  proc `$`[T](m:Matrix[T]) : string =
    result = ""
    for y in 0..<m.h:
      result &= "["
      for x in 0..<m.w:
        result &= $m[x,y]
        if x != m.w - 1 : result &= ","
      result &= "]"
      if y != m.h - 1 : result &= "\n"
    result &= "\n"

  proc `*`[T](a:Matrix,b:seq[T]):seq[T] =
    assert a.w == b.len
    result = newSeq[T](b.len)
    for x in 0..<a.h:
      var n : T
      for k in 0..<a.w:
        n += a[k,x] * b[k]
      result[x] = n
  proc `+`[T](a,b:Matrix[T]): Matrix[T] =
    assert a.w == b.w and a.h == b.h
    result = newMatrix[T](a.w,a.h)
    for y in 0..<a.h:
      for x in 0..<b.w:
        result[x,y] = a[x,y] + b[x,y]
  proc transpose[T](a:Matrix[T]): Matrix[T] =
    result = newMatrix[T](a.h,a.w)
    for y in 0..<a.h:
      for x in 0..<b.w:
        result[x,y] = a[y,x]



  # CSR 実装
  # let M = newMatrix(@[@[1,2,3,0],@[0,0,0,1],@[2,0,0,2],@[0,0,0,1]])
  type SparseMatrix[T] = ref object
    w,h:int
    data: seq[T]
    row: seq[int]
    col: seq[int]
  proc newSparseMatrix[T](m:Matrix[T]):SparseMatrix[T] =
    new(result)
    result.w = m.w
    result.h = m.h
    for y in 0..<m.h:
      result.col &= result.data.len
      for x in 0..<m.w:
        if m[x,y] <= T(0) : continue
        result.data &= m[x,y]
        result.row &= x
    result.col &= result.data.len
  proc newSparseMatrix[T](m:seq[seq[T]]):SparseMatrix[T] =
    new(result)
    result.w = m.len()
    result.h = m[0].len
    for y in 0..<result.h:
      result.col &= result.data.len
      for x in 0..<result.w:
        if m[x][y] <= T(0) : continue
        result.data &= m[x][y]
        result.row &= x
    result.col &= result.data.len
  proc newSparseMatrix[T](w,h:int):SparseMatrix[T] =
    new(result)
    result.w = w
    result.h = h
    result.data = @[]
    result.col = @[]
    result.row = @[]
  proc `*`[T](m:SparseMatrix[T],v:seq[T]):seq[T] =
    result = newSeq[T](m.h)
    for y in 0..<m.h:
      var n : T
      for x in m.col[y]..<m.col[y+1]:
        n += m.data[x] * v[m.row[x]]
      result[y] = n
  proc `*`[T](m1,m2:SparseMatrix[T]) : SparseMatrix[T] =
    var R = newSeqWith(m2.w,newSeq[T](m2.h))
    for y in 0..<m2.h:
      for x in m2.col[y]..<m2.col[y+1]:
        R[m2.row[x]][y] = m2.data[x]
    for x in 0..<m2.w: R[x] = m1 * R[x]
    return newSparseMatrix(R)
  proc `^`[T](m:SparseMatrix[T],n:int) : SparseMatrix[T] =
    assert m.w == m.h
    if n <= 0 : return identityMatrix[T](m.w).newSparseMatrix()
    if n == 1 : return m
    let m2 = m^(n div 2)
    if n mod 2 == 0 : return m2 * m2
    return m2 * m2 * m
  proc `$`[T](m:SparseMatrix[T]):string =
    result = ""
    for y in 0..<m.h:
      result &= "["
      for x in m.col[y]..<m.col[y+1]:
        result &= $m.data[x] & "(" & $m.row[x] & ") "
      result &= "]\n"
    result &= "\n"

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



# 整数 の数学関数(剰余無しver)
template useNaturalMath() =
  proc permutation(n,k:int):int = # nPk
    result = 1
    for i in (n-k+1)..n: result = result * i
  proc combination(n,k:int):int = # nCk
    result = 1
    let x = k.max(n - k)
    let y = k.min(n - k)
    for i in 1..y: result = result * (n+1-i) div i
  proc power(x,n:int): int =
    if n <= 1: return if n == 1: x else: 1
    let pow_2 = power(x,n div 2)
    return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
  proc roundedDiv(a,b:int) : int = # a / b の四捨五入
    let c = (a * 10) div b
    if c mod 10 >= 5: return 1 + c div 10
    return c div 10
  proc sign(n:int):int = (if n < 0 : -1 else: 1)

# 統計
template statistics() =
  # 線形回帰(最小二乗法) f(x) = ax + b
  proc leastSquares(X,Y:seq[float]):tuple[a,b,err:float] =
    assert X.len == Y.len
    let n = X.len.float
    let XY = toSeq(0..<X.len).mapIt(X[it] * Y[it]).sum()
    let XX = X.mapIt(it*it).sum()
    let XS = X.sum()
    let YS = Y.sum()
    let d = n * XX - XS * XS
    let a = (n * XY - XS * YS) / d
    let b = (XX * YS - XY * XS) / d
    let err = toSeq(0..<X.len)
      .mapIt((let e = X[it] * a + b - Y[it];e*e))
      .sum()
    return (a ,b,err)
