import sequtils,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let k = scan()
if k == 0 : quit "0",0
var isNotPrimes : array[1000_0010,bool]
var ans = 0
let primeMax = k div (n-1)
for i in countup(3,primeMax.float.sqrt.int,2):
  if isNotPrimes[i] : continue
  for j in countup(i*2,primeMax,i):
    isNotPrimes[j] = true

block:
  let a = 1 + k - 2 * (n-1)
  if a > 0 : ans += a
for i in countup(3,primeMax,2):
  if isNotPrimes[i] : continue
  let a = 1 + k - i * (n-1)
  if a <= 0 : break
  ans += a
echo ans