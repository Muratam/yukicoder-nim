proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord.int32 - '0'.ord.int32
let h = scan()
let w = scan()
let n = scan()
var ops: array[1000010,int16]
var isC: array[1000010,bool]
for i in 0..<n:
  isC[i] = getchar_unlocked() == 'C'
  discard getchar_unlocked()
  var k = cast[int16](0)
  while true:
    var c = getchar_unlocked()
    if c < '0': break
    k = cast[int16](10) * k + cast[int16](c) - cast[int16]('0')
  ops[i] = k
var x = 0
var y = 0
for i in 1..n:
  let op = ops[n-i]
  if isC[n-i]:
    if x != op: continue
    if y == 0: y = h - 1
    else: y -= 1
  else:
    if y != op: continue
    if x == 0: x = w - 1
    else: x -= 1

if (x mod 2) == (y mod 2) : echo "white"
else:echo "black"