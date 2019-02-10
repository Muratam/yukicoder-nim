import sequtils
setStdIoUnbuffered()
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var dp = newSeq[int](n+1)
dp[0] = 1
dp[1] = 1
for i in 2..n:
  dp[i] += dp[i-2]
  dp[i] += dp[i-1]
echo dp[n]