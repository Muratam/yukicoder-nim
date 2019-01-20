import sequtils,strutils,algorithm,math
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let b = get().parseInt().float
let A = get().split().map(parseFloat)
proc integral(a:float):float =
  if abs(1 + a) >= 1e-5 : return 1 / (1 + a) * b.pow(1+a)
  return b.ln()
echo A.mapIt(it * b.pow(it-1)).sum()
echo A.map(integral).sum()