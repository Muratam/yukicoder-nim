import sequtils,strutils

let N = stdin.readLine().parseInt()
var dp = newSeqWith(N+1,0)
dp[0] = 1
for i in 0..N:
  dp[i+1] += dp[i]
  dp[i+2] += dp[i]
echo dp[N]