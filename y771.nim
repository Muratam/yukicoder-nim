import sequtils,algorithm
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template `^`(n:int) : int = (1 shl n)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let AB = newSeqWith(n,(a:scan(),b:scan())).sortedByIt(-it.a)
let L = AB.mapIt(it.a)
let R = AB.mapIt(it.b-it.a)
const INF = 1e10.int
var dp = newSeqWith(^n,INF)
var ans = INF
proc solve(s:int,r:int,cost:int) =
  if s == ^n - 1 :
    ans .min= cost
    return
  if dp[s] <= cost : return
  dp[s] .min= cost
  for x in 0..<n:
    if (s and ^x) > 0 : continue
    if s == 0 : solve(s or ^x,R[x],0)
    else: solve(s or ^x,R[x],cost.max(L[x]+r))
solve(0,0,0)
echo ans