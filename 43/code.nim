import sequtils,strutils,strscans,algorithm,math,future,macros
#import sets,queues,tables,nre,pegs
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine() #.strip()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)

let
  N = get().parseInt()
  S = newSeqWith(N,get().toSeq())
  won = S.mapIt(it.foldl(a + (b == 'o').int,0))
  yet = S.mapIt(it.foldl(a + (b == '-').int,0))
  lost = S.mapIt(it.foldl(a + (b == 'x').int,0))
# 0番目の最高順位
# 空きは全て勝利でよい
echo S
echo won
echo lost
echo yet
