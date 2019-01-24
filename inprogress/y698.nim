import sequtils
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = newSeqWith(n,scan())
if n == 2 :
  echo A[0] xor A[1]
  quit 0
# 14C2 * 12C2 * 10C2 * 8C2 * 6C2 * 4C2 * 2C2
# 高々:1*6*15*28*45*66*91 なので全て列挙
var dp: array[16777216,int]
proc solve(s:int):int =
  if dp[s] > 0 : return dp[s]
  for a in 0..<n:
    if ((1 shl a) and (not s)) > 0 : continue
    for b in (a+1)..<n:
      if ((1 shl b) and s) > 0 : continue
      let s2 = s or (1 shl a) or (1 shl b)
      result .max= solve(s2) + (A[a] xor A[b])
  dp[s] = result
echo solve((1 shl n) - 1)