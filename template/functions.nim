template bitOperators():untyped =
  # countBits32 / isPowerOfTwo / nextPowerOfTwo
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4

template mathUtils():untyped =
  proc getIsPrimes(n:int) :seq[bool] = # [0...n]
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false

  proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
    let isPrime = getIsPrimes(n)
    result = @[]
    for i,p in isPrime:
      if p : result &= i

  proc getFactors(N:int):seq[int] =
    let primes = getPrimes(N.float.sqrt.int + 1)
    var n = N
    result = @[]
    for p in primes:
      if p >= n : break
      while n mod p == 0:
        result &= p
        n = n div p
    if n != 1:
      result &= n

  proc coundDuplicate[T](arr:seq[T]): auto =
    arr.sorted(cmp[T]).foldl(
      if a[^1].key == b:
        a[0..<a.len-1] & (b, a[^1].val+1)
      else:
        a & (b, 1),
      @[ (key:arr[0],val:0) ])

  proc power(x,n:int,modulo:int = 0): int =
    #繰り返し二乗法での x ** n
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
    result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
    if modulo > 0: result = result mod modulo

  proc parseDecimal(n:int) : auto = ($n).mapIt(it.ord - '0'.ord)


