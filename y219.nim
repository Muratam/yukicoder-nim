import math,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord


template div10(a:int32) : int32 = cast[int32]((0x1999999A * cast[int64](a)) shr 32)
template put(n:int) = putchar_unlocked("0123456789"[n])
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc printInt(a:int) =
  if a == 0:
    putchar_unlocked('0')
    return
  var n = a
  var rev = a
  var cnt = 0
  while rev mod 10 == 0:
    cnt += 1
    rev = rev div 10
  rev = 0
  while n != 0:
    rev = rev * 10 + n mod 10
    n = n div 10
  while rev != 0:
    putchar_unlocked((rev mod 10 + '0'.ord).chr)
    rev = rev div 10
  while cnt != 0:
    putchar_unlocked('0')
    cnt -= 1

var P = newSeq[float](101)
for i in 10..100: P[i] = log10(i.float / 10.0)
scan().times:
  let a = scan()
  let b = scan()
  let xyz = b.float * log10(a.float)
  let z = xyz.int
  let p = xyz - z.float # 10^p == A => p*log10 = logA
  let i = cast[int32](P.upperBound(p) - 1)
  let x = i.div10
  let y = i - (x * 10)
  put(x)
  putchar_unlocked(' ')
  put(y)
  putchar_unlocked(' ')
  printInt(z)
  putchar_unlocked('\n')
  # b*(log(a)) == z * log10 + log(XY)