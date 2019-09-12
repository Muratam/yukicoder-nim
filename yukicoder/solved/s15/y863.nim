proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let a = scan() # 5000
let b = scan() # 200_000
# x40
if b < a * 100: echo 1
else: echo 2
