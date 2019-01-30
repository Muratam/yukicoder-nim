import sequtils
template `min=`*(x,y) = x = min(x,y)
template `^`(n:int) : int = (1 shl n)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}

let n = scan().int32
let M = newSeqWith(n,scan().int32)
const INF = 1e10.int32
var ans = INF
var dp : array[^15 + 1,int32]
var T : array[^15 + 1,int32]
for x in 0..(^n): dp[x] = INF
# proc solve(s,total,buyTotal:int) =
#   if s == ^n - 1:
#     ans .min= total
#     return
#   if dp[s] <= total : return
#   dp[s] = total
#   for x in 0..<n:
#     if (^x and s ) > 0 : continue
#     solve(s or ^x,total + (M[x] - (buyTotal mod 1000)).max(0),buyTotal+M[x])
# solve(0,0,0)
proc solve() =
  for x in 0..<(^n - 1):
    for i in 0..<n:
      if (x and ^i) > 0 : continue
      dp[x or ^i] .min= dp[x] + 0.max(M[i] - T[x] mod 1000)
      T[x or ^i] = T[x] + M[i]
dp[0] = 0
solve()
printf("%d\n",dp[^n-1])