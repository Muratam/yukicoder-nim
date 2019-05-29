template times*(n:int,body) = (for _ in 0..<n: body)
proc putchar_unlocked(c:char){.header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
let n = scan()
let k = scan()
let a = n - k
const vars = ['3','7','4','6']
for i in 0..<a:
  putchar_unlocked(vars[i mod 4])
  putchar_unlocked(' ')
(n-a).times:
  putchar_unlocked(vars[(a-1) mod 4])
  putchar_unlocked(' ')
