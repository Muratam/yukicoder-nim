template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

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
proc printInt(a:int,last:char) =
  a.int32.printInt()
  putchar_unlocked(last)



let n = scan()
n.times:
  let S = stdin.readLine()
  var ans = 1e8.int
  for i in 0..S.len-11:
    var costG = 0
    for ii in 0..<4:
      if S[i+ii] != "good"[ii]: costG += 1
    var costP = 1e8.int
    for j in i+4..S.len-7:
      var costPi = 0
      for jj in 0..<7:
        if S[j+jj] != "problem"[jj]: costPi += 1
      costP .min= costPi
    ans .min= costG + costP
  ans.printInt('\n')