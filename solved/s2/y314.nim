proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
if n <= 4:
  echo [0,1,2,2,3][n]
  quit 0
var aa = 1
var ba = 1
var ab = 1
for i in 5..n: (aa,ba,ab) = (ba,ab,(aa+ba) mod 10_0000_0007)
echo (aa + ba + ab) mod 10_0000_0007