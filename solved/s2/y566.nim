proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord.int32 - '0'.ord.int32
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int32) =
  template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
  template mod10(a:int32) : int32 = a - (a.div10 * 10)
  var n = a
  var rev = a
  var cnt = 0
  while rev.mod10 == 0:
    cnt += 1
    rev = rev.div10
  rev = 0
  while n != 0:
    rev = rev * 10 + n.mod10
    n = n.div10
  while rev != 0:
    putchar_unlocked((rev.mod10 + '0'.ord).chr)
    rev = rev.div10
  while cnt != 0:
    putchar_unlocked('0')
    cnt -= 1

let n = scan()
let max = 1.int32 shl n
let swapped = max div 2 + 1
printInt(swapped)
putchar_unlocked(' ')
for i in (n-2).countdown(0.int32):
  let s = 1.int32 shl i
  for j in countup(s,max,s * 2):
    if j == swapped:
      printint(swapped - 1)
    else:
      printint(j)
    putchar_unlocked(' ')
putchar_unlocked('\n')