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
template `*`[T](a: seq[T], n: Natural): T = a.cycle(b) # @[3] * 100
template sort[T](x: openarray[T]): void = x.sort(cmp[T]) # omit cmp
template sorted[T](x: openarray[T]): auto = x.sorted(cmp[T]) # omit cmp
# newSeqWith(4,rand())
# {key: val}.newOrderedTable.