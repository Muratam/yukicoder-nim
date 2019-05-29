import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
let n = scan()
proc solve(x,y:int):int = # x:( , y:)
  if x == n and y == n : return 1
  if x > n or y > n : return 0
  if x < y : return 0
  return solve(x+1,y) + solve(x,y+1)
echo solve(0,0)
