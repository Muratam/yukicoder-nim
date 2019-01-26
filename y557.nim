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

template useModulo() =
  const MOD = 1000000007
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

useModulo()
let n = scan()
if n == 1 : echo 2
elif n mod 2 == 1: echo 3 * 4.toModInt()^(n div 2)
else: echo 4.toModInt()^(n div 2)