proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let m = scan()
proc map(a:int) : int =
  var a = a - 1
  a = a mod (2 * m)
  if a >= m : a = 2 * m - a - 1
  return a
let x = scan()
let y = scan()
if map(x) == map(y): echo "YES"
else: echo "NO"