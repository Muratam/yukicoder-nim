import sequtils,math,times
template times*(n:int,body) = (for _ in 0..<n: body)
template `min=`*(x,y) = x = min(x,y)
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc printf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord
proc printFloat(f:float) =
  if f < 1e-8: printf("0.0\n")
  else: printf("%.9f\n", f)
var x,y:float
var xMin = 500.0.float
var yMin : float

proc scanFloatY105():float =
  let k1 = getchar_unlocked() # - - 0 1
  let k2 = getchar_unlocked() # 0 1 . .
  if k1 == '-':
    let n = - (k2.ord - '0'.ord)
    discard getchar_unlocked()
  else:
    17.times: discard getchar_unlocked()
    17.times: discard getchar_unlocked()

let t = cpuTime()
scan().times:
  for i in 0..<6:
    scanf("%f %f",addr x,addr y)
    if x < xMin :
      xMin = x
      yMin = y
  const toRad = 1.0 / PI * 180.0
  let tMin = -(arctan2(xMin,yMin) * toRad + 30.0) mod 59.9999999999
  printFloat(tMin)
stderr.write $((cpuTime() - t)*1000)