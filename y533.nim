proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const MOD = 1000000007
var dp1 : array[1000001,int]
var dp2 : array[1000001,int]
var dp3 : array[1000001,int]
dp1[1] = 1
dp2[2] = 1
dp1[3] = 1
dp2[3] = 1
dp3[3] = 1
proc calc(n:int,startIndex:int=4) : int =
  for i in startIndex..n:
    dp1[i] = (dp1[i] + dp2[i-1] + dp3[i-1]) mod MOD
    dp2[i] = (dp2[i] + dp1[i-2] + dp3[i-2]) mod MOD
    dp3[i] = (dp3[i] + dp2[i-3] + dp1[i-3]) mod MOD
  return (dp1[n] + dp2[n] + dp3[n]) mod MOD
let n = scan()
echo calc(n)