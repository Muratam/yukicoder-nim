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
# nCk
proc combination(n,k:int) : ModInt =
  result = 1.toModInt()
  let y = k.min(n - k)
  var fact = 1.toModInt()
  for i in 2..y: fact = fact * i
  for i in 1..y: result = result * (n+1-i)
  result = result / fact

# カタラン数
proc catalanNumber(n:int) : ModInt = combination(n*2,n) / (n + 1).toModInt()


when isMainModule:
  import unittest
  import sequtils
  test "modint":
    check: MOD == 1000000007
    check: 9999.toModInt()^9999 == 501911862.toModInt()
    check: 100.combination(50) == 538992043.toModInt()
    for i,c in @[1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862, 16796, 58786, 208012, 742900, 2674440, 9694845]:
      check: i.catalanNumber() == c.toModInt()
