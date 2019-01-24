proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int32) =
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template put(n:int32) = putchar_unlocked("0123456789"[n])
  if a < 10:
    put(a)
    return
  if a < 100:
    let a1 = a.div10
    put(a1)
    put(a-a1*10)
    return
  if a < 1000:
    let a1 = a.div10
    let a2 = a1.div10
    put(a2)
    put(a1-a2*10)
    put(a-a1*10)
    return
  if a < 10000:
    let a1 = a.div10
    let a2 = a1.div10
    let a3 = a2.div10
    put(a3)
    put(a2-a3*10)
    put(a1-a2*10)
    put(a-a1*10)
    return

let n = scan().int32
for a in 1..n div 3:
  for b in a..(n-a) shr 1:
    let c = n - a - b
    printInt(a)
    putchar_unlocked(' ')
    printInt(b)
    putchar_unlocked(' ')
    printInt(c)
    putchar_unlocked('\n')
