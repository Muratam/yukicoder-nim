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
for i in a.countdown(0):
  if c * i > b : continue
  if i + c * i > d : continue
  quit $i,0
