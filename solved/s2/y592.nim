import sequtils,strutils,algorithm,math

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
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
var A : array[200010,int32]
var s : array[100010,int32]
var si = 0

for i in 1.int32 .. n.int32:
  if getchar_unlocked() == '(':
    s[si] = i
    si += 1
  else:
    A[i] = s[si-1]
    A[A[i]] = i
    si -= 1
for i in 1..n:
  A[i].printInt()
  putchar_unlocked('\n')