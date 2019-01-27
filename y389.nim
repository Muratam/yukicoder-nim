import sequtils,algorithm,math,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

template useModulo() =
  const MOD = 1_000_000_007
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

  proc combination(n,k:int) : ModInt = # nCk を剰余ありで
    result = 1.toModInt()
    let x = k.max(n - k)
    let y = k.min(n - k)
    var fact = 1.toModInt()
    for i in 2..y: fact = fact * i
    for i in 1..y: result = result * (n+1-i)
    result = result / fact
useModulo()

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc scanH(): tuple[sum,size:int] =
  result = (0,0)
  while true:
    var now = 0
    while true:
      let k = getchar_unlocked()
      if k < '0':
        result.size += 1
        result.sum += now
        if k == '\n': return
        break
      now = 10 * now + k.ord - '0'.ord

let m = scan()
let (hSum,hLen) = scanH()
if hLen == 1 :
  if hSum == 0: quit "1",0
let n = m - (hSum - hLen)
let h = hLen
let k = n - (h + h - 1)
if k < 0: quit "NA",0
if k == 0 : quit "1",0
# h箇所にk個入れる組み合わせ
echo (h+k).combination(h)
