import sequtils,strutils,algorithm,math,future,macros
# import sets,queues,tables,nre,pegs,rationals
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

let
  (KR,KB) = get().split().map(parseInt).unpack(2)
  S = get().parseInt # < 30
# RRRRRRRRRRWWWWWWWWWWBBBBBBBBBB
#   R***r***R*B*b*B***
# R か B を抜く
# 30 > 29 > 28