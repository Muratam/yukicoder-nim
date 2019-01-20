import sequtils

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = newSeqWith(n-1,scan())
var ans = 0
var x = 0
block:
  let b = scan()
  let c = scan()
  x += c - b
for i in 1..<n:
  let b = scan()
  let c = scan()
  ans += x * A[i-1]
  x += c - b
echo ans