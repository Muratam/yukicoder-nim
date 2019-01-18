import sequtils,algorithm,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  var minus = false
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord.int32 - '0'.ord.int32
  if minus: result *= -1
proc getMidium[T](baseArr:var seq[T]): T =
  # [x,y)
  proc impl[T](x,y:int):T =
    let l = y - x

    if l <= 2 : return arr[x]
    if l == 3 :
      if arr[l+0] <= arr[l+1] and arr[l+1] <= arr[l+2] : return arr[l+1]
      if arr[l+1] <= arr[l+0] and arr[l+0] <= arr[l+2] : return arr[l+2]
      return arr[3]
    if l == 4 : discard
    var l5 = l div 5
    var a = impl(   0  ,x+l5  )
    var b = impl(x+l5  ,x+l5*2)
    var c = impl(x+l5*2,x+l5*3)
    var d = impl(x+l5*3,x+l5*4)
    var e = impl(x+l5*4,y)



  return baseArr.impl(0,baseArr.len())

let n = scan()
var Y = newSeqWith(n,scan())
Y.sort(cmp)
let mid = Y[n div 2]
var ans = 0
for y in Y: ans += abs(y-mid)
echo ans