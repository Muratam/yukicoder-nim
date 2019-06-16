import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
let A = newSeqWith(m,scan())
const MOD = 1000000007
var dp = newSeq[int](n+10)
for a in A: dp[a] = -1
dp[0] = 1
for i in 0..n:
  if dp[i] < 0 : continue
  if dp[i + 2] >= 0 :
    dp[i + 2] = (dp[i + 2] + dp[i]) mod MOD
  if dp[i + 1] >= 0:
    dp[i + 1] = (dp[i + 1] + dp[i]) mod MOD
echo dp[n]
