import sequtils,strutils,strscans,algorithm,math,future,sets,queues,tables,macros
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

proc `+=`[T](x:var set[T],y:T):void = x.incl(y)
proc `-=`[T](x:var set[T],y:T):void = x.excl(y)
proc `+=`[T](x:var set[T],y:set[T]):void = x = x.union(y)
proc `*=`[T](x:var set[T],y:set[T]):void = x = x.intersection(y)
proc `-=`[T](x:var set[T],y:set[T]):void = x = x.difference(y)
converter toInt8(x:int) : int8 = x.toU8()

proc parseDecimal(n:int) : auto = ($n).mapIt(it.ord - '0'.ord)
proc getIsPrimes(n:int) :seq[bool] = # [0...n]
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

proc getPrimes(n:int,start:int = 0):seq[int] = # [2,3,5,...n]
  const isPrime = getIsPrimes(200_000) # WARN: コンパイル時計算
  result = @[]
  for i,p in isPrime:
    if i < start: continue
    if i > n :break
    if p : result &= i

proc hash(n:int) : int =
  result = ($n).mapIt(it.ord - '0'.ord).sum()
  if result > 9:
    result = hash(result)

# hash は 0,3,6,9にならない (3は一度だけ) => 124578の6が最大だが、大きい方を優先するので途中でbreakはできない

if false: # 愚直な実装
  let
    K = get().parseInt
    N = get().parseInt
    primes = getPrimes(N,start=K)
  var
    L = 0
    hashes : set[int8] = {}
    ans = (prime:0, card:0)
  for p in primes:
    let h = hash(p)
    if h in hashes:
      while h in hashes:
        hashes -= hash(primes[L])
        L += 1
    hashes += h
    if hashes.card >= ans.card:
      ans.prime = primes[L]
      ans.card = hashes.card
  echo ans.prime

else: # WARN: 最適化
  let
    K = get().parseInt
    N = get().parseInt
  if K <= 3:
    if N <= 3:# 12 13 23
      if K == 1: echo N
      else: echo 3
    else:
      if N < 11: echo 2
      else: echo 3
    quit()
  let
    # WARN: どうせ最後の方にしかないのである程度大きければ探索範囲を縮めて良い
    start = if N > 30000: max(K, (N.float * 0.98).int) else: K
    primes = getPrimes(N,start)
  var
    R = primes.len() - 1
    hashes : set[int8] = {}
    ans = (prime:0, card:0)
  for p in primes.reversed():
    let h = hash(p)
    if h in hashes:
      while h in hashes:
        hashes -= hash(primes[R])
        R -= 1
    hashes += h
    if hashes.card >= ans.card:
      ans.prime = p
      ans.card = hashes.card
      if ans.card == 6:
        break
  echo ans.prime