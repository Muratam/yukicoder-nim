# [0,100000]
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc printInt(a:int32) =
  if a == 0:
    putchar_unlocked('0')
    return
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


const INF = 100000
echo 0," ",0
let a = scan()
if a == 0 : quit 0
echo 0," ",INF
let b = scan()
if b == 0 : quit 0
let x = (a + b - INF) div 2
let y = (a - b + INF) div 2
echo y," ",x