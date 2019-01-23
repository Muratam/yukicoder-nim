proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let h = scan()
let w = scan()
let n = scan()
let k = scan()
let c = 1 + (w + h - 2) mod n
if c == k : echo "YES"
else: echo "NO"