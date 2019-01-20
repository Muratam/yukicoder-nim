import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

# 15 35 => 50 15*35
# 5*(3 7 => 10 21)
# 6 10 => 2*(3 5) => 2*(8 15*2)
#      => 16 60
# 60 100 => 20*(3 5) => 160 6000 => 8 30
# 21 24 => 3 (7 8) => 3(15 56)
let a = scan()
let b = scan()
let g = a.gcd(b)
let g2 = (g mod 2).gcd(a div g + b div g)
echo g * g2