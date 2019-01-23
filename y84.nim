proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let w = scan()
let h = scan()
let n = w * h
if w == h: echo n div 4 + w mod 2 - 1
else: echo n div 2 + n mod 2 - 1
