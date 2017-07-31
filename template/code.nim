import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
template get():string = stdin.readLine()
template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`(x,y:typed):void = x = max(x,y)
template `min=`(x,y:typed):void = x = min(x,y)
template each[T](arr:var seq[T],a,body:untyped):untyped =
  for i in 0..<arr.len:(var a{.inject.}=arr[i]; body; defer:arr[i]=a)
template each[T](arr:var seq[T],i,a,body:untyped):untyped =
  for i in 0..<arr.len:(var a{.inject.}=arr[i]; body; defer:arr[i]=a)



# future: dump / lc[(x,y,z) | (x <- 1..n, y <- x..n, z <- y..n, x*x + y*y == z*z),tuple[a,b,c: int]]
template assignOperators():untyped =
  template `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y
  template `+=`(x,y:typed):void = x = x + y
  template `-=`(x,y:typed):void = x = x - y
  template `*=`(x,y:typed):void = x = x * y
  template `/=`(x,y:typed):void = x = x / y
  template `^=`(x,y:typed):void = x = x xor y
  template `&=`(x,y:typed):void = x = x and y
  template `|=`(x,y:typed):void = x = x or y
  template `>>=`(x,y:typed):void = x = x shr y
  template `<<=`(x,y:typed):void = x = x shl y
  template `gcd=`(x,y:typed):void = x = gcd(x,y)
  template `lcm=`(x,y:typed):void = x = lcm(x,y)

template iterations():untyped =
  template rep(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template eachIt[T](arr:var seq[T],body:untyped):untyped =
    for i in 0..<arr.len:(var it{.inject.}=arr[i]; body; defer:arr[i]=it)
  template eachIt[T](arr:var seq[T],i,body:untyped):untyped =
    for i in 0..<arr.len:(var it{.inject.}=arr[i]; body; defer:arr[i]=it)
