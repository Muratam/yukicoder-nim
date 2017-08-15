import sequtils,strutils,strscans,algorithm,math,future,macros
# import sets,queues,tables,nre,pegs,rationals
template get*():string = stdin.readLine() #.strip()
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

let
  (N,K) = get().split().map(parseInt).unpack(2)
  W = newSeqWith(N,get().parseInt())

# |W| を積む/下ろす :: |W|>= がK個以上あると詰めない 下ろす必要は