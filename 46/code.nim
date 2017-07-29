template main(MAIN_BODY:untyped):untyped =
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
  template `*`[T](a: seq[T], n: Natural): T = a.cycle(b)
  template sort[T](x: openarray[T]): void = x.sort(cmp[T])
  template sorted[T](x: openarray[T]): auto = x.sorted(cmp[T])
  MAIN_BODY
main:
  var a,b = 0
  (a,b) = get().split().map(parseInt)
  echo(ceil(b / a).int)