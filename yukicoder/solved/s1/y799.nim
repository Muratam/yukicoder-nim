proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let a = scan()
let b = scan()
let c = scan()
let d = scan()
echo (b-a+1)*(d-c+1)-0.max(b.min(d)-a.max(c)+1)
