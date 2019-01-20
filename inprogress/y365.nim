proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
var ans = 0
var pre = scan()
for _ in 0..<n-1:
  let now = scan()
  if pre > now: ans += 1
  pre = now
echo ans