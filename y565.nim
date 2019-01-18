import sequtils
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let r = scan()
let k = scan()
let h = scan()
let w = scan()
var C = newSeqWith(h,newSeq[char](w))
for y in 0..<h:
  for x in 0..<w: C[y][x] = getchar_unlocked()
  discard getchar_unlocked()


template print(x,y:int) =
  k.times: putchar_unlocked(C[y][x])
if r in [0,180]:
  for y in 0..<h:
    k.times:
      for x in 0..<w:
        if r == 0:print(x,y)
        else:print(w-x-1,h-y-1)
      putchar_unlocked('\n')
else:
  for x in 0..<w:
    k.times:
      for y in 0..<h:
        if r == 90: print(x,h-y-1)
        else: print(w-x-1,y)
      putchar_unlocked('\n')
