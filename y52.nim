import sequtils,strutils,strscans,algorithm,math,future,macros
#import sets,queues,tables,nre,pegs
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine() #.strip()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

proc coundDuplicate[T](arr:seq[T]): auto =
  arr.sorted(cmp[T]).foldl(
    if a[^1].key == b:
      a[0..<a.len-1] & (b, a[^1].val+1)
    else:
      a & (b, 1),
    @[ (key:arr[0],val:1) ])
proc toSeq(str:string):seq[char] = result = @[];(for s in str: result &= s)

let
  S = get()
  props = newSeq[string]()
  now = S

props &= S
