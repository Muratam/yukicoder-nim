proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let v1 = scan()
let v2 = scan()
let d = scan()
let w = scan()
echo d * w / (v1 + v2)