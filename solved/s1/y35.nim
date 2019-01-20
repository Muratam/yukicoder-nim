template execIn72Env(ENV72_BODY:untyped):untyped =
  import sequtils,strutils,strscans,algorithm,math,future,sets
  template get():string = stdin.readLine()
  template times(n:int,body:untyped): untyped = (for _ in 0..<n: body)
  template REP(i:untyped,n:int,body:untyped):untyped =
    block:(var i = 0; while i < n:( body; i += 1))
  template each[T](arr:var seq[T],elem,body:untyped):untyped =
    for _ in 0..<arr.len:(proc (elem:var T):auto = body)(arr[_])
  template  `+=`(x,y:typed):void = x = x + y
  template  `-=`(x,y:typed):void = x = x - y
  template  `*=`(x,y:typed):void = x = x * y
  template  `/=`(x,y:typed):void = x = x / y
  template  `%=`(x,y:typed):auto = x = x mod y
  template `//=`(x,y:typed):auto = x = x div y
  ENV72_BODY

execIn72Env:
  let N = get().parseInt
  var length, miss = 0
  N.times:
    let
      line = get().split()
      limit = line[0].parseInt
      str = line[1]
      canType = int(12 * limit / 1000)
    length += min(canType,str.len)
    miss += max(0,str.len - canType)
  echo length, " ", miss