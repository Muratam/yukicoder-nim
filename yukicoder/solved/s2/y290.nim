proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
let n = scan()
# 010[101101][101101]101101 ?
if n > 3: echo "YES"
elif n == 1 : echo "NO"
elif n == 3:
  let a = getchar_unlocked()
  let b = getchar_unlocked()
  let c = getchar_unlocked()
  if a == c and a != b : echo "NO"
  else: echo "YES"
else:
  let a = getchar_unlocked()
  let b = getchar_unlocked()
  if a == b : echo "YES"
  else: echo "NO"
# [0][0]0 [0][0]1 010 0[1][1]