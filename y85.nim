proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let m = scan()
if n.min(m) == 1:
  if n.max(m) == 2 : echo "YES"
  else : echo "NO"
elif n mod 2 == 1 and m mod 2 == 1 : echo "NO"
else: echo "YES"