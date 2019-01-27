import tables
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var dp = newTable[int,int]()
dp[0] = 1
proc solve(n:int):int =
  if n in dp : return dp[n]
  result = solve(n div 3) + solve(n div 5)
  dp[n] = result

echo solve(scan())