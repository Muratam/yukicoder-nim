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
###################################################################

let
  c100 = get().parseInt
  c25 = get().parseInt
  c1 = get().parseInt
var
  money = c100 * 100 + c25 * 25 + c1 * 1
  res = 0
money %= 1000
res += money div 100
money %= 100
res += money div 25
money %= 25
res += money
echo res