import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

# 揃った数が1~6個の確率 x n
const dp = (proc (n:int):seq[float] =
  var dp = newSeqWith(n+1,newSeq[float](7))
  dp[1][1] = 1.0
  for i in 2..n:
    for j in 1..6:
      dp[i][j] = dp[i-1][j-1] * (7.0 - j.float) / 6.0 + dp[i-1][j] * j.float / 6.0
  return dp.mapIt(it[6])
)(10_0001)
echo dp[scan().min(10_0000)]