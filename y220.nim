import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
# 10^i 以下で 該当する数の内,桁の和が j
var dp = newSeqWith(n+1,newSeqWith(3,0))
dp[1][0] = 3
for i in 2..n:
  dp[i][0] = 3 * dp[i-1][2] + 3 * dp[i-1][1] + 3 * dp[i-1][0]
