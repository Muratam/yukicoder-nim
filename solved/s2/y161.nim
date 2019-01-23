proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var xgcp = @[scan(),scan(),scan()]
var ygcp = @[0,0,0]
while true:
  let k = getchar_unlocked()
  if k < '0': break
  if k == 'G' : ygcp[0] += 1
  if k == 'C' : ygcp[1] += 1
  if k == 'P' : ygcp[2] += 1

var ans = 0
for i in 0..<3:
  let x = i
  let y = (i+1) mod 3
  let d = xgcp[x].min(ygcp[y])
  xgcp[x] -= d
  ygcp[y] -= d
  ans += d * 3
for i in 0..<3:
  let d = xgcp[i].min(ygcp[i])
  xgcp[i] -= d
  ygcp[i] -= d
  ans += d

echo ans