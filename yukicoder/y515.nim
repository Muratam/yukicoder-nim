import sequtils,algorithm,math,tables,sets,strutils,times
template time*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord
# proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
# proc scan(): int = scanf("%lld\n",addr result)
let n = scan()
var S = newSeq[string](n)
for i in 0..<S.len: S[i] = stdin.readLine()
let m = scan()
var x = scan()
var d = scan()
proc nextQuery() : tuple[qi,qj:int]=
  var qi = (x div (n - 1)) + 1
  var qj = (x mod (n - 1)) + 1
  if qi > qj : swap qi ,qj
  else: qj += 1
  x = (x + d) mod (n * (n - 1))
  return (qi,qj)
m.time:
  let (qi,qj) = nextQuery()
  echo @[qi,qj]
