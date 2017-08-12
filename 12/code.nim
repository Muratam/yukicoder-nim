import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

proc getIsPrimes(n:int) :seq[bool] = # [0...n]
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

proc getPrimes(n:int):seq[int] = # [2,3,5,...n]
  let isPrimes = getIsPrimes(n)
  result = @[]
  for i,p in isPrimes:
    if p : result &= i

proc parseDecimal(n:int) : seq[int] =
  result = @[]; for it in $n: result &= it.ord - '0'.ord
#proc enumerate[T](arr:seq[T]): seq[tuple[i:int,val:T]] =
#  result = @[]; for i,a in arr: result &= (i,a)

const
  N = 500_0000
let
  primes = getPrimes(N)
  _ = get().parseInt()
  A = get().split().map(parseInt).toSet()

proc checkOK(n:int):bool = n.parseDecimal().toSet() <= A
# 全て使われていないといけないのがちょっとめんどいわ…
var
  L = 1
  ans = -1
  preIsOK = false
for p in primes:
  let isOK = checkOK(p)
  if not isOK:
    if preIsOK:
      ans .max= (p-1) - L
    L = p + 1
  else:
    ans .max= (p+1) - L
  preIsOK = isOK
echo ans

# 1 <= [K,L]  <= N を 最大化