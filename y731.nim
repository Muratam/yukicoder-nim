import sequtils,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

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
  let err = toSeq(0..<X.len)
    .mapIt((let e = X[it] * a + b - Y[it];e*e))
    .sum()
  return (a ,b,err)

let n = scan()
let A = newSeqWith(n,scan().float)
let (d,b,err) = leastSquares(toSeq(0..<n).mapIt(it.float),A)
echo b," ",d
echo err