import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}

type ModInt = object
  v:int # 0~MODに収まる
const MOD = 129402307

template useModulo() =
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

proc scan(): ModInt =
  result = 0.toModInt()
  block:
    let k1 = getchar_unlocked()
    result = 10 * result + k1.ord - '0'.ord
    let k2 = getchar_unlocked()
    if k2 < '0':
      if k1 == '0' : quit "0",0
      return
    result = 10 * result + k2.ord - '0'.ord
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc scanX(): int =
  const nowMOD = MOD - 1
  result = 0
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
    if result >= nowMOD : result = result mod nowMOD

let n = scan()
if n.v == 0 : # 0^m == 0 | x^0
  if getchar_unlocked() == '0' : echo 1
  else: echo 0
  quit 0
let m = scanX()
echo n^m