import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const MOD = 1_0000_0000_7
type ModInt = object
  v:int # 0~MODに収まる
proc toModInt*(a:int) : ModInt =
  if a < -MOD : result.v = ((a mod MOD) + MOD) mod MOD
  elif a < 0 : result.v = a + MOD
  elif a >= MOD: result.v = a mod MOD
  else: result.v = a
proc `+`*(a,b:ModInt) : ModInt =
  result.v = a.v + b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `*`*(a,b:ModInt) : ModInt =
  result.v = a.v * b.v
  if result.v >= MOD : result.v = result.v mod MOD
proc `^`*(a:ModInt,b:int) : ModInt =
  if b == 0 : return 1.toModInt()
  if b == 1 : return a
  let pow = a^(b div 2)
  if b mod 2 == 0 : return pow * pow
  return pow * pow * a
proc `+`*(a:int,b:ModInt) : ModInt = a.toModInt() + b
proc `+`*(a:ModInt,b:int) : ModInt = a + b.toModInt()
proc `-`*(a:ModInt,b:int) : ModInt = a + (-b)
proc `-`*(a,b:ModInt) : ModInt = a + (-b.v)
proc `-`*(a:int,b:ModInt) : ModInt = a.toModInt() + (-b.v)
proc `*`*(a:int,b:ModInt) : ModInt = a.toModInt() * b
proc `*`*(a:ModInt,b:int) : ModInt = a * b.toModInt()
proc `/`*(a,b:ModInt) : ModInt = a * b^(MOD-2)
proc `$`*(a:ModInt) : string = $a.v

type Fraction = tuple[a,b:ModInt]
proc newFraction(a:int,b:int= 1):Fraction =
  result.a = a.toModInt()
  result.b = b.toModInt()
proc `$`(f:Fraction):string = $f.a & "/" & $f.b
proc `*`(x,y:Fraction):Fraction =
  result.a = x.a * y.a
  result.b = x.b * y.b
proc `+`(x,y:Fraction):Fraction =
  result.a = x.a * y.b + x.b * y.a
  result.b = x.b * y.b

let n = scan()
let m = scan()
let p = scan()
let V = newSeqWith(n,scan()).sorted(cmp,Descending)
let pf = newFraction(100 - p,100)
let p100 = newFraction(p,100)
var pff = pf
var ans = newFraction(0)
var dp = newSeqWith(m,1.newFraction())
for i in 1..<m: dp[i] = dp[i-1] * p100
for v in V:
  let vp = v.newFraction() * pff
  for i in 0..<m:
    ans = ans + vp * ps[i] * dp[i]
  pff = pff * pf
  for i in (m-1).countdown(1):
    dp[i] = dp[i-1] + dp[i]
echo ans.a / ans.b

