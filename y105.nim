import sequtils,algorithm,math,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
proc printFloat(f:float) =
  if f < 1e-8: echo 0.0
  else: echo f
scan().times:
  discard stdin.readLine()
  let XY = newSeqWith(6,stdin.readLine().split().map(parseFloat))
  let T = XY.mapIt(arctan2(it[0],it[1]) / PI * 180.0).sorted(cmp)
  if T[0] < -150.0:  printFloat( -T[0] - 150.0)
  else: printFloat((210.0-T[^1]) mod 59.9999999999)
