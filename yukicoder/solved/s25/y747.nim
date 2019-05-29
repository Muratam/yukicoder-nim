proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scanMod6(): int =
  while true:
    let c = getchar_unlocked()
    if c < '0': return result mod 6
    result = result * 10 + c.ord - '0'.ord
    if result > 94967296 : result = result mod 6

proc scanIsMod2():bool =
  var k : char
  while true:
    let c = getchar_unlocked()
    if c < '0': return (k.ord - '0'.ord) mod 2 == 0
    k = c

const resStr = "428571"
let n = scanMod6()
if n in [0,1,3,4] : echo resStr[n]
else:
  let m = scanIsMod2()
  if n == 5: echo resStr[if m : 1 else: 5]
  else: echo resStr[if m : 4 else : 2]
