import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

let m = scan()
let n = scan()
let C = newSeqWith(n,scan())
var dp = newSeq[int](m)
proc impl(n,x:int) =
  for c in C:
    if x-c <= 1 : continue
    if dp[x-c] >= n + 1 : continue
    dp[x-c] = n + 1
    impl(n+1,x-c)
impl(0,m)
const isPrimes =  getIsPrimes(10001)
var ans = 0
for i in 2..<m:
  if not isPrimes[i] : continue
  if dp[i] == 0 : continue
  ans += dp[i]
let plus = m div C.min()
echo ans + plus
