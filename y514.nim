# [0,100000]
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

const INF = 1000000000
echo 0," ",0
let a = scan()
if a == 0 : quit 0
echo 0," ",INF
let b = scan()
if b == 0 : quit 0
let x = (a + b - INF) div 2
let y = (a - b + INF) div 2
echo x," ",y