import sequtils,strutils,algorithm,math,sugar,macros,strformat
proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
  proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
    result = newSeqWith(n+1,true)
    result[0] = false
    result[1] = false
    for i in 2..n.float.sqrt.int :
      if not result[i]: continue
      for j in countup(i*2,n,i):
        result[j] = false
  let isPrimes = getIsPrimes(n)
  result = @[]
  for i,p in isPrimes:
    if p : result &= i

proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
const primes = getPrimes(1001)
const sumPrimes = primes.foldl(a & (a[^1] + b),@[0])[1..^1]
const answers = toSeq(1..1000).mapIt(primes.upperBound(it,cmp)).mapIt(sumPrimes[max(0,it-1)])
const answerStrs = toSeq(0..1000).mapIt(if it <= 1: "0" else: ($answers[it-1]))
echo answers
# var n:int32
# scanf("%d",addr n)
# printf("%s\n",answerStrs[n])