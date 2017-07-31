import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
# future: dump / lc[(x,y,z) | (x <- 1..n, y <- x..n, z <- y..n, x*x + y*y == z*z),tuple[a,b,c: int]]
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
  template `>>=`(x,y:typed):void = x = x shr y
  template `<<=`(x,y:typed):void = x = x shl y
  template `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y
  template `max=`(x,y:typed):void = x = max(x,y)
  template `min=`(x,y:typed):void = x = min(x,y)
  template `gcd=`(x,y:typed):void = x = gcd(x,y)
  template `lcm=`(x,y:typed):void = x = lcm(x,y)
