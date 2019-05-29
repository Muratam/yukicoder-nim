proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
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



let n = scan() # 21
let k = scan()
# 21:[1~3] -> 0 4 8 12 16 20
# 22:[1~3] -> 1 5 9 13 17 21
let s = (n-1) mod (k+1)
let d = k + 1
for i in 0..<n:
  # echo s + d * i
  printInt(int32(s + d * i))
  putchar_unlocked('\n')
  stdout.flushFile()
  let m = scan()
  if m >= n: break