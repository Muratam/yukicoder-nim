import sequtils,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

proc `^`(x:float,n:int): float =
  if n <= 1: return if n == 1: x else: 1.0
  let pow_2 = x^(n div 2)
  return pow_2 * pow_2 * (if n mod 2 == 1: x else: 1.0)

const FINF = 0.2294157338705619

proc F(n:int):float =
  var up = 0.0
  for i in 1..n: up += 0.81^i
  var down = 0.0
  for i in 1..n: down += 0.9^i
  return up.sqrt / down
proc f(n:int):float = 1200.0 * (F(n) - FINF ) / (F(1) - FINF)
proc g(x:float):float = 2.0.pow(x / 800.0)
proc ginv(x:float) : float = 800.0 * log2(x)
proc solve(P:seq[float]) : float =
  var up = 0.0
  for i,p in P: up += g(p) * 0.9^(1+i)
  var down = 0.0
  for i in 1..P.len: down += 0.9^i
  return ginv(up / down) - f(P.len)
let n = scan()
let P = newSeqWith(n,scan().float)
echo (P.solve() + 0.5).int