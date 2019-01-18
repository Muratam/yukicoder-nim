import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan[T](): T =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord.T - '0'.ord.T
let n = scan[int32]()
let k = scan[int]()
var D :array[200_010,int32]
for i in 0..<n:D[i] = scan[int32]()
var swapTime = 0
block:
  var i = 0.int32
  while i < n:
    if D[i]-1 == i : i += 1
    else:
      swap(D[D[i]-1],D[i])
      swapTime += 1
if swapTime > k : echo "NO"
elif (k-swapTime) mod 2 == 0: echo "YES"
else: echo "NO"