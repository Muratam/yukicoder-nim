import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
let a = scan()
let b = scan()
let c = scan()
var ans = 0
ans += n div a + n div b + n div c
ans -= n div a.lcm(b) + n div b.lcm(c) + n div c.lcm(a)
ans += n div a.lcm(b).lcm(c)
echo ans