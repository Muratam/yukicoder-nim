template main(MAIN_BODY:untyped):untyped =
  import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables
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
  template  `%=`(x,y:typed):void = x = x mod y
  template `//=`(x,y:typed):void = x = x div y
  proc popcount(n:int):cint{.importC: "__builtin_popcount", noDecl .} # sum of "1"
  proc clz(n:int):cint{.importC: "__builtin_clz", noDecl .} # <0000>10 -> 4
  proc ctz(n:int):cint{.importC: "__builtin_ctz", noDecl .} # 01<0000> -> 4
  if isMainModule:
    MAIN_BODY

#close = initTable[int,int]() # hash is slow
#if not (succ in close): # hash is slow
#let diff = n.toBin(64).count('1') # string is slow

main:
  let N = get().parseInt
  var
    open = initQueue[int]() # n
    close = newSeqWith(N+1,-1)# depth
    resdepth = 0
  open.add(1)  # 1 *-> N
  close[1] = 1
  while open.len > 0:
    let
      n = open.pop()
      depth = close[n]
    if n == N:
      echo depth
      quit()
    let diff = popcount(n)
    for succ in @[n + diff,n - diff]:
      if succ > N or succ < 1:
        continue
      if close[succ] == -1:
        close[succ] = depth + 1
        open.enqueue(succ)
  echo -1
