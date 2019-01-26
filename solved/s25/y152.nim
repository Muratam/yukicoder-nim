import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc solve(n:int):int =
  for x in 1..n:
    for y in (x+1)..n:
      let a = (x * x - y * y).abs
      let b = 2 * x * y
      let c = x * x + y * y
      if a + b + c > n : break
      if a.gcd(b).gcd(c) != 1 : continue
      result += 1
let n = scan() div 4
echo n.solve()