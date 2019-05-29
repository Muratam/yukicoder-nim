import sequtils,algorithm,strutils,math
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
const INF = int.high div 4
proc powerWhenTooBig(x,n:int,modulo:int = 0): int =
  proc mul(x,n,modulo:int):int =
    if n == 0: return 0
    if n == 1: return x
    result = mul(x,n div 2,modulo) mod modulo
    result = (result * 2) mod modulo
    result = (result + x * (n mod 2 == 1).int) mod modulo
    if n == 0: return 1
  if n == 1: return x
  let
    pow_2 = powerWhenTooBig(x,n div 2,modulo)
    odd = if n mod 2 == 1: x else: 1
  if modulo > 0:
    const maybig = int.high.float.sqrt.int div 2
    if pow_2 > maybig or odd > maybig:
      result = mul(pow_2,pow_2,modulo)
      result = mul(result,odd,modulo)
    else:
      result = (pow_2 * pow_2) mod modulo
      result = (result * odd) mod modulo
  else:
    return pow_2 * pow_2 * odd
proc millerRabinIsPrime(n:int):bool = # O(log n)
  proc ctz(n:int):int{.importC: "__builtin_ctzll", noDecl .} # 01<0000> -> 4
  proc power(x,n:int,modulo:int = 0): int =
    if n == 0: return 1
    if n == 1: return x
    let pow_2 = power(x,n div 2,modulo)
    result = pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
    if modulo > 0: result = result mod modulo
  if n <= 1 : return false
  if n == 2 or n == 3 or n == 5: return true
  if n mod 2 == 0: return false
  let
    s = ctz(n - 1)
    d = (n - 1) div (1 shl s)
  var a_list = @[2, 7, 61]
  if n >= 4_759_123_141 and n < 341_550_071_728_321:
    a_list = @[2, 3, 5, 7, 11, 13, 17]
  if n in a_list : return true
  for a in a_list:
    if powerWhenTooBig(a,d,n) == 1 : continue
    let notPrime = toSeq(0..<s).allIt(powerWhenTooBig(a,d*(1 shl it),n) != n-1)
    if notPrime : return false
  return true


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc decode(A:var seq[int]): int =
  for a in A:
    if a < 10: result = 10 * result + a
    else:result = 100 * result + a
let n = scan()
var A = newSeqWith(n,scan()).sorted(cmp)
var ans = -1
while true:
  let p = A.decode()
  if ans < p and p.millerRabinIsPrime(): ans = p
  if not A.nextPermutation() : break
echo ans
