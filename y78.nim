import sequtils,strutils,algorithm,math,future,macros
# import sets,queues,tables,nre,pegs,rationals
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)

let
  (N,K) = get().split().map(parseInt).unpack(2)
  S = get().toSeq().mapIt(it.ord-'0'.ord)
proc oneCycle():auto =
  let atariPlus = S.sum() - N

var
  ate = 0
  bought = 0
  atari = 0
  index = 0
while ate < K:
  if atari == 0:
    bought += 1
  else:
    atari -= 1
  atari += S[index]
  index = (index + 1) mod N
  ate += 1
echo bought