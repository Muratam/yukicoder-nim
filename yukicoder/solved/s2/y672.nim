proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
var X : array[-200010..200010,int32]
var xi = 1
X[xi] = 1
var ans = 0
for i in 2.int32..<4e6.int32:
  let k = getchar_unlocked()
  if k < 'A' : break
  if k == 'A': xi += 1
  else: xi -= 1
  if X[xi] == 0 : X[xi] = i
  ans .max= i - X[xi]
echo ans