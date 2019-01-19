proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let x = scan()
let y = scan()
let d = scan()
if x + y < d: echo 0
elif d == 0 : echo 1
else: echo 1 + d - 0.max(d-y) - 0.max(d-x)