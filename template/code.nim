import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
# {key: val}.newOrderedTable.

template main(MAIN_BODY:untyped):untyped =
  if isMainModule:
    MAIN_BODY

template iterations():untyped =
  template rep(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template each[T](arr:var seq[T],elem,body:untyped):untyped =
    for _ in 0..<arr.len:(proc (elem:var T):auto = body)(arr[_])


template assignOperators():untyped =
  template `+=`(x,y:typed):void = x = x + y
  template `-=`(x,y:typed):void = x = x - y
  template `*=`(x,y:typed):void = x = x * y
  template `/=`(x,y:typed):void = x = x / y
  template `^=`(x,y:typed):void = x = x xor y
  template `&=`(x,y:typed):void = x = x and y
  template `|=`(x,y:typed):void = x = x or y
  template `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y
  template `max=`(x,y:typed):void = x = max(x,y)
  template `min=`(x,y:typed):void = x = min(x,y)
  template `gcd=`(x,y:typed):void = x = gcd(x,y)
  template `lcm=`(x,y:typed):void = x = lcm(x,y)


template bitOperators():untyped =
  # countBits32 / isPowerOfTwo / nextPowerOfTwo
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4

template mathUtils():untyped =
  proc getIsPrimes(n:int) :seq[bool] =
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false
  proc getPrimes(n:int):seq[int] =
    # [2,3,5,...<n]
    let isPrime = getIsPrimes(n)
    result = newSeq[int](0)
    for i,p in isPrime:
      if p : result.add(i)
  proc power(x,n:int,modulo:int = 0): int =
    #繰り返し二乗法での x ** n
    if n == 0: return 1
    if n == 1: return x
    let
      pow_2 = power(x,n div 2,modulo)
    result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
    if modulo > 0: result = result mod modulo
