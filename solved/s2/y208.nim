proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
let x = scan()
let y = scan()
let x2 = scan()
let y2 = scan()
if x == 0 and y == 0 : quit "0",0
if x == 0 : quit $y,0
if y == 0 : quit $x,0
if x == y and x2 == y2 and x2 < x : quit $(x+1),0
echo x.min(y) + abs(x-y)