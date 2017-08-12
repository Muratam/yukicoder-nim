import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

proc getIsPrimes(n:int) :seq[bool] =
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

proc getPrimes(n:int):seq[int] = # [2,3,5,...<n]
  let isPrime = getIsPrimes(n)
  result = @[]
  for i,p in isPrime:
    if p : result &= i

proc getFactors(N:int):seq[int] =
  let primes = getPrimes(N.float.sqrt.int + 1)
  var n = N
  result = @[]
  for p in primes:
    if p >= n : break
    while n mod p == 0:
      result &= p
      n = n div p
  if n != 1: result &= n

proc coundDuplicate[T](arr:seq[T]): auto =
  arr.sorted(cmp[T]).foldl(
    if a[^1].key == b:
      a[0..<a.len-1] & (b, a[^1].val+1)
    else:
      a & (b, 1),
    @[ (key:arr[0],val:0) ])


let
  N = get().parseInt()
  factors = getFactors(N).coundDuplicate().mapIt(it.val)
  nimsum = factors.foldl(a xor b)
echo if nimsum != 0: "Alice" else : "Bob"
