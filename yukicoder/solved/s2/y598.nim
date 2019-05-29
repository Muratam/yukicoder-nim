
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let bit = scan()
let x = scan()
let a = scan()
let b = scan()
# x-n*a <= 0 :: x <= n*a :: n >= x/a
# x+n*b >= 2^31
var ans = 1 + (x-1) div a
ans .min= 1 + ((1 shl (bit-1)) - x - 1) div b
echo ans