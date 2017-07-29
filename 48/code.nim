template main(MAIN_BODY:untyped):untyped =
  import sequtils,strutils,strscans,algorithm,math,future,sets
  template get():string = stdin.readLine()
  template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
  template rep(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template each[T](arr:var seq[T],elem,body:untyped):untyped =
    for _ in 0..<arr.len:(proc (elem:var T):auto = body)(arr[_])
  template  `+=`(x,y:typed):void = x = x + y
  template  `-=`(x,y:typed):void = x = x - y
  template  `*=`(x,y:typed):void = x = x * y
  template  `/=`(x,y:typed):void = x = x / y
  template  `%=`(x,y:typed):auto = x = x mod y
  template `//=`(x,y:typed):auto = x = x div y
  if isMainModule:
    MAIN_BODY
main:
  let
    X = get().parseInt
    Y = get().parseInt
    L = get().parseInt
  # X > 0 & Y > 0 => 1
  # X < 0 & Y > 0 => 1
  # X > 0 & Y < 0 => 2
  # X < 0 & Y < 0 => 2
  # X == 0 & Y < 0 => 2
  var res = 0
  res += ceil(Y.abs/L).int
  res += ceil(X.abs/L).int
  if X != 0:
    res += 1
    if Y < 0 :
      res += 1
  elif Y < 0:
    res += 2
  echo res