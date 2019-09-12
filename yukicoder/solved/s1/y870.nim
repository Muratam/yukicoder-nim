import sequtils
proc gc():char {. importc:"getchar_unlocked",header: "<stdio.h>",discardable .}
proc scan(): int =
  while true:
    var k = gc()
    if k < '0' or k > '9': break
    result = 10 * result + k.ord - '0'.ord
proc scanK(): int =
  var k1 = gc()
  discard gc()
  var k2 = gc()
  discard gc()
  return (k1.ord - '0'.ord) * 10 + (k2.ord - '0'.ord)

let n = scan()
var poses = @[28,39,79]
for _ in 0..<n:
  let a = scanK()
  let b = scanK()
  for i in 0..<3:
    if poses[i] == a:
      poses[i] = b
      break
if poses == @[58,48,68]:echo "YES"
else: echo "NO"
