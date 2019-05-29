import sequtils,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc solve() : seq[int] =
  # 総和 mod 3 と 3がつくかでわける
  var dp = newSeqWith(20, newSeqWith(3,newSeqWith(2,0)))
  for i in 0..<10:
    let x = i mod 3
    let y = if i == 3 : 1 else: 0
    dp[0][x][y] += 1

  for i in 0..<18:
    for x in 0..<3:
      for y in 0..<3:
        # 既に3がつくものに 1,4,7 | 2 5 8 | 0 3 6 9
        dp[i+1][(x+y) mod 3][1] += [4,3,3][y] * dp[i][x][1]
        # つかないものに 1,4,7 | 2,5,8 | 0,6,9
        dp[i+1][(x+y) mod 3][0] += 3 * dp[i][x][0]
    # つかないものに 3
    dp[i+1][0][1] += dp[i][0][0]
    dp[i+1][1][1] += dp[i][1][0]
    dp[i+1][2][1] += dp[i][2][0]

  return dp.mapIt(it[0][0] + it.mapIt(it[1]).sum() - 1)

const answers = solve()
let n = scan()
echo answers[n - 1]