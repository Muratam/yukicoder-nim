template times*(n:int,body) = (for _ in 0..<n: body)
proc putchar_unlocked(c:char){. importc:"putchar_unlocked",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
# n 文字で穴の和がdの最小
let n = scan()
let d = scan()
# n <  d : (1+1+1+1+1..) + (B+...)
if n == d:
  d.times: putchar_unlocked('A')
elif n > d:
  d.times: putchar_unlocked('A')
  (n-d).times: putchar_unlocked('C')
else:
  (n-(d-n)).times: putchar_unlocked('A')
  (d-n).times: putchar_unlocked('B')
putchar_unlocked('\n')
