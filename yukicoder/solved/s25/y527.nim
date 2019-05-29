import sequtils,math,algorithm
template `max=`*(x,y) = x = max(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord


let n = scan()
let A = newSeqWith(n,(v:scan(),w:scan()))
let v = scan()
let wMax = A.mapIt(it.w).sum()
if A.mapIt(it.v).sum() == v:
  echo wMax
  quit "inf",0
var dp = newSeqWith(wMax+1,0)
for a in A:
  let start = 0.max((dp.upperBound(v+1)-1).min(wMax - a.w - 1))
  for i in start.countdown(0):
    dp[i+a.w] .max= dp[i] + a.v
echo dp.lowerBound(v).max(1)
echo dp.upperBound(v) - 1
