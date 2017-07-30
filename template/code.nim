import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
# newSeqWith(4,rand())
# {key: val}.newOrderedTable.
# @[1, 2, 3, 4].mapIt($(4 * it))



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
  template `^=`(x,y:typed):void = x = x ^ y
  template `mod=`(x,y:typed):void = x = x mod y
  template `div=`(x,y:typed):void = x = x div y
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
    let isPrime = getIsPrimes(n)
    result = newSeq[int](0)
    for i,p in isPrime:
      if p : result.add(i)
