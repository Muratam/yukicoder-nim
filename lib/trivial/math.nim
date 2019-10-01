import sequtils,algorithm
# ラグランジュ補間
# N次多項式 f(x) と既知の f(0) .. f(N) から f(t) を復元可能。
# https://ei1333.github.io/luzhiled/snippets/math/lagrange-polynomial.html

# 一度実装したが用途がかなり限定的な数学関数
# フィボナッチ数列の第n項
proc calcFib(n:int) : tuple[x:ModInt,y:ModInt] =
  if n == 0 : return (0.toModInt(),1.toModInt())
  let (fn,fn1) = calcFib(n div 2)
  let fnx1 = fn1 - fn
  let f2n = (fn1 + fnx1) * fn
  let f2nx1 = fn * fn + fnx1 * fnx1
  let f2n1 = f2n + f2nx1
  if n mod 2 == 0 : return (f2n,f2n1)
  else: return (f2n1,f2n1 + f2n)

# 線形回帰(最小二乗法) f(x) = ax + b
import math,sequtils
proc leastSquares(X,Y:seq[float]):tuple[a,b,err:float] =
  assert X.len == Y.len
  let n = X.len.float
  let XY = toSeq(0..<X.len).mapIt(X[it] * Y[it]).sum()
  let XX = X.mapIt(it*it).sum()
  let XS = X.sum()
  let YS = Y.sum()
  let d = n * XX - XS * XS
  let a = (n * XY - XS * YS) / d
  let b = (XX * YS - XY * XS) / d
  let err = toSeq(0..X.len-1)
    .mapIt((let e = X[it] * a + b - Y[it];e*e))
    .sum()
  return (a ,b,err)
