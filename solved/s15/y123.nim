import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  result = 0
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
let n = scan()
let m = scan()
var C = toSeq(1..n)
for _ in 0..<m:
  let a = scan()
  let head = C[a-1]
  for i in (a-1).countdown(1): C[i] = C[i-1]
  C[0] = head
echo C[0]
