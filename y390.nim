import sequtils
template `max=`*(x,y) = x = max(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10.int32 * result + k.ord.int32 - '0'.ord.int32
var dp : array[1_00_0010,int32]
let n = scan()
var xMax = 0
for i in 0..<n:
  let a = scan()
  xMax .max= a
  dp[a] = 1
var ans = 1.int32
for i in 1..xMax:
  if dp[i] == 0 : continue
  let x2 = dp[i] + 1
  for j in countup(2*i,xMax,i):
    if dp[j] == 0 : continue
    dp[j] .max= x2
    ans .max= x2
echo ans