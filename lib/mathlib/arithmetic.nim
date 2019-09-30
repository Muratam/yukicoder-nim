# Modなし整数演算 (permutation / combination / power ...)

proc permutation(n,k:int):int = # nPk
  result = 1
  for i in (n-k+1)..n: result = result * i
proc combination(n,k:int):int = # nCk
  result = 1
  let x = k.max(n - k)
  let y = k.min(n - k)
  for i in 1..y: result = result * (n+1-i) div i
proc power(x,n:int): int =
  if n <= 1: return if n == 1: x else: 1
  let pow_2 = power(x,n div 2)
  return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1)
proc roundedDiv(a,b:int) : int = # a / b の四捨五入
  let c = (a * 10) div b
  if c mod 10 >= 5: return 1 + c div 10
  return c div 10
proc sign(n:int):int = (if n < 0 : -1 else: 1)

# 小数点以下p桁で a / b
proc arbitraryPrecisionDiv(a,b,p:int):string =
  result = $(a div b) & "."
  var a = a
  for _ in 0..<p:
    a = a mod b
    a *= 10
    result .add $(a div b)


when isMainModule:
  import unittest
  test "math":
    check:9.permutation(6) == 60480
    check:9.combination(6) == 84
    check:9.power(6) == 531441
    check:9.roundedDiv(2) == 5
    check: -1.sign() == -1
    check: arbitraryPrecisionDiv(  2,7,10) ==  "0.2857142857"
    check: arbitraryPrecisionDiv(200,7,10) == "28.5714285714"
