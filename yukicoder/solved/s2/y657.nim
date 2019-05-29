proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
template times*(n:int,body) = (for _ in 0..<n: body)
proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc printInt(a:int,skipLeavingZeros:bool = false) =
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
    rev = (rev shl 3) + (rev shl 1) + n mod 10
    n = n div 10
  while rev != 0:
    putchar_unlocked((rev mod 10 + '0'.ord).chr)
    rev = rev div 10
  if not skipLeavingZeros:
    while cnt != 0:
      putchar_unlocked('0')
      cnt -= 1


const ts = (proc() : seq[int]=
  var (a,b,c,d) = (0,0,0,1)
  var n = 0
  var ts = @[0,0,0,0,1]
  while true:
    (a,b,c,d) = (b,c,d,(a+b+c+d) mod 17)
    if a == 0 and b == 0 and c == 0 and d == 1 : break
    n += 1
    ts &= d
  return ts
)()
proc getTet(n:int):int =
  if n < ts.len  : return ts[n]
  return ts[4 + (n-4) mod (ts.len - 4)]

let q = scan()
q.times: #echo scan().getTet()
  printInt(scan().getTet())
  putchar_unlocked('\n')