import sequtils,algorithm
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord.int32 - '0'.ord.int32

let n = scan()
let m = scan()
var N = newSeqWith(n,newSeq[int32](n))
m.times:
  let (i1,i2,s) = (scan(),scan(),scan())
  N[i1][i2] = s
var p = toSeq(0.int32..<n)
var ans = 0
while p.nextPermutation():
  var x = 0
  for i in 0..<n:
    for j in (i+1)..<n:
      x += N[p[i]][p[j]]
  ans .max= x
echo ans