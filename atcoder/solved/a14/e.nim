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

const MOD = 1e9.int + 7
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
  if a.v == 0 : return 0.toModInt()
  if b == 0 : return 1.toModInt()
  if b == 1 : return a
  if b > MOD: return a^(b mod (MOD-1)) # フェルマーの小定理
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


let L = stdin.readLine()

var dp1 = newSeqWith(L.len + 10,0.toModInt())
var dp2 = newSeqWith(L.len + 10,0.toModInt())
dp1[0] = 2.toModInt()
dp2[0] = 1.toModInt()
for i in 0..<L.len-1:
  if L[i+1] == '0':
    dp1[i+1] = dp1[i]
    dp2[i+1] = dp2[i] * 3
  else:
    dp1[i+1] = dp1[i] * 2
    dp2[i+1] = dp2[i] * 3 + dp1[i]
echo(dp1[L.len-1] + dp2[L.len-1])
