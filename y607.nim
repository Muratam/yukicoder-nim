import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
template times*(n:int,body) = (for _ in 0..<n: body)

let n = scan()
let m = scan()
var A = newSeq[int](n)
m.times:
  var xa = -1
  var ya = -1
  for i in 0..<n:
    A[i] += scan()
    if A[i] <= 777:
      if xa < 0 : xa = i
      ya = i
  if xa < 0 : continue
  var x = xa
  var sum = 0 # [x,y]
  for y in xa..ya:
    sum += A[y]
    while sum > 777 :
      sum -= A[x]
      x += 1
    if sum == 777: quit "YES",0

echo "NO"
