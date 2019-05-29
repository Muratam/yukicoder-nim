import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let m = scan()
let n = scan()
var ans = 0
var (a,b) = (m div m.gcd(n),n div m.gcd(n))
while not (a == b and a == 1):
  (a,b) = (a div a.gcd(b),b div a.gcd(b))
  if a > b :
    let t = if b == 1 : a - 1 else: a div b
    ans += t
    a -= b * t
  else:
    ans += 1
    (a,b) = (b,a)
echo ans