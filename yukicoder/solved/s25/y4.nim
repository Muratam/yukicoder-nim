import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
var W : array[101,int]
var dp : array[10001,bool]
var wSum = 0
for i in 0..<n:
  W[i] = scan()
  wSum += W[i]
if wSum mod 2 == 1 : quit "impossible",0
let m = wSum div 2
dp[0] = true
for wi in 0..<n:
  let w = W[wi]
  for i in countdown(m-w,0):
    if dp[i] : dp[i + w] = true
  if dp[m] : quit "possible",0
quit "impossible",0