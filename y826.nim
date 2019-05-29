import sequtils,math
# 偶数だけにすると高速
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
proc getIsNotPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
  result = newSeq[bool](n+1)
  result[0] = true
  result[1] = true
  # 偶数は無視
  for i in countup(3,n.float.sqrt.int,2):
    if result[i]: continue
    for j in countup(i*3,n,i*2):
      result[j] = true
let isNotPrimes = getIsNotPrimes(1000_010)
template isPrime(x:int):bool = x == 2 or (x mod 2 != 0 and not isNotPrimes[x])
let n = scan()
let p = scan()
if p == 1 : quit "1",0
if p >= n div 2 and isPrime(p): quit "1",0
var ans = n div 2 - 1
for i in countup(n div 2 + 1,n):
  if isPrime(i) : ans += 1
echo ans
