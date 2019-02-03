import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let k = scan()
var ans = 0
n.times:
  let a = scan()
  ans = ans xor (a mod (k + 1))
if ans == 0 : echo "NO"
else: echo "YES"