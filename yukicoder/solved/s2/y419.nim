import math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let a = scan()
let b = scan()
if a == b: echo a.float * 2.float.sqrt
else: echo (a * a - b * b).abs.float.sqrt
