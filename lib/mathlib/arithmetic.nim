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

proc sternBrocotTree(maxNum:int): seq[tuple[u,d:int]] =
  # http://mathworld.wolfram.com/Stern-BrocotTree.html
  # 小さい順に既約分数を列挙する. 1/maxNum から maxNum/1 まで
  var tree = newSeq[tuple[u,d:int]]()
  proc impl(au,ad,bu,bd:int) =
    let mu = au + bu
    let md = ad + bd
    if mu > maxNum or md > maxNum : return
    impl(au,ad,mu,md)
    tree.add((mu,md))
    impl(mu,md,bu,bd)
  impl(0,1,1,0)
  return tree

template randomForNim013() =
  # nim 0.13 にはランダムが無いのでコンパイルが通るやつを置いておく
  type
    Rand* = object
      a0, a1: uint64
  var state = Rand(
    a0: 0x69B4C98CB8530805u64,
    a1: 0xFED1DD3004688D67CAu64)
  proc rotl(x, k: uint64): uint64 =
    result = (x shl k) or (x shr ((64).uint64 - k))
  proc next*(r: var Rand): uint64 =
    let s0 = r.a0
    var s1 = r.a1
    result = s0 + s1
    s1 = s1 xor s0
    r.a0 = rotl(s0, 55) xor s1 xor (s1 shl 14) # a, b
    r.a1 = rotl(s1, 36) # c
  proc random*(maxI: uint64): uint64 =
    while true:
      let x = next(state)
      return x mod maxI
  proc shuffle*[T](x: var openArray[T]) =
    for i in countdown(x.high, 1):
      let j = random(i)
      swap(x[i], x[j])


when isMainModule:
  import unittest
  test "math":
    check:9.permutation(6) == 60480
    check:9.combination(6) == 84
    check:9.power(6) == 531441
    check:9.roundedDiv(2) == 5
    check: -1.sign() == -1
    check: sternBrocotTree(3) == @[(1,3),(1,2),(2,3),(1,1),(3,2),(2,1),(3,1)]
