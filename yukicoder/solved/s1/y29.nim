import sequtils,strutils,strscans,algorithm,math,future,sets
template get():string = stdin.readLine()
template times(n:Natural,body:untyped): untyped = (for _ in 0..<n: body)
template REP(i:untyped,n:var Natural,body:untyped):untyped =
  block:(var i = 0; while i < n:( body; i += 1))
template each[T](arr:var seq[T],elem,body:untyped):untyped =
  for _ in 0..<arr.len:(proc (elem:var T):auto = body)(arr[_])

###################################################################

let
  N = get().parseInt
var
  cnts = newSeq[int](10)

N.times:
  let indexes = get().split().map(parseInt).map(x => x-1)
  for i in indexes:
    cnts[i] += 1

var res = 0
cnts.each cnt:
  let used = cnt div 2
  res += used
  cnt -= used * 2
res += cnts.sum() div 4
echo res