template times*(n:int,body) = (for _ in 0..<n: body)
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var t = scan()
var a = scan()
var b = scan()
if t < max(a,b) : quit "NO",0
if a == 0 and b == 0 and t == 1:quit "NO",0
printf("YES\n")
if a == 0 and b == 0 and t mod 2 == 1:
  printf(">\n^\n<v\n")
  t -= 3
let m = max(a,b) + 2
while t >= m:
  printf(">\n<\n")
  t -= 2

if t == max(a,b) + 1:
  # 斜めのところか 上に登るところで一回余裕を挟む
  if a == b :
    printf(">\n^\n")
    a -= 1
    b -= 1
  elif a > b:
    printf("^>\n<\n")
    a -= 1
  else :
    printf("^>\nv\n")
    b -= 1
  t -= 2

min(a,b).times: printf(">^\n")
if a > b:
  (a-b).times: printf("^\n")
elif b > a:
  (b-a).times: printf(">\n")