import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc getTotals(n:int) :seq[int] = # [0...n] O(n loglog n)
  var isPrimes = newSeqWith(n+1,true)
  var totals = newSeqWith(n+1,0)
  for i in 2..n.float.sqrt.int :
    if not isPrimes[i]: continue
    totals[i] += 1
    for j in countup(i*2,n,i):
      isPrimes[j] = false
      totals[j] += 1
  for i in 2..n:
    if totals[i] == 0 : totals[i] = 1
  return totals
let totals = getTotals(1000)#(200_0010)
# let n = scan()
# let k = scan()
var ans = 0
for i in 2..1000:
  if totals[i] >= 4: ans += 1
echo ans