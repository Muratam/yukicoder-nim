import sequtils,algorithm,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

var rgb = @[scan(),scan(),scan()]
var ans = 0
while true:
  rgb = rgb.filterIt(it > 0)
  if rgb.len == 0 : break
  echo rgb,ans
  let x = rgb.max()
  let y = rgb.min()
  if rgb.len == 3: # 3つ
    rgb = rgb.mapIt(it - y)
    ans += y
  elif rgb.len == 2:
    if x <= 2 : break
    ans += 1
    rgb = @[y-1,x-3]
  elif rgb.len == 1:
    ans += x div 5
    break
echo ans