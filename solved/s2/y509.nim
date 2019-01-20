import sequtils
const counts = [1,0,0,0,1, 0,1,0,2,1]
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
var cnt = 0
var num = 0
while true:
  var k = getchar_unlocked()
  if k < '0' or k > '9': break
  let n = k.ord - '0'.ord
  cnt += counts[n]
  num += 1
echo 1 + cnt + num + num.min(cnt + 1)
