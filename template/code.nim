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
  template  `+=`(x,y:typed):void = x = x + y
  template  `-=`(x,y:typed):void = x = x - y
  template  `*=`(x,y:typed):void = x = x * y
  template  `/=`(x,y:typed):void = x = x / y
  template  `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y

template bitOperators():untyped =
  proc popcount(n:int):cint{.importC: "__builtin_popcount", noDecl .} # sum of "1"
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4
