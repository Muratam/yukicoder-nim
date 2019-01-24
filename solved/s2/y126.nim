proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let a = scan()
let b = scan()
let s = scan()
var ans = 0
if s == 1 or abs(s-a) <= abs(s-b) :
  ans = abs(s-a) + s
elif b > a : # Aの階へ下る
  if a > 0 : ans = abs(s-b) + abs(s-a) + a
  else: ans = abs(s-b) + s + 1
else: # Aの階へ登る or 1Fへいく
  ans = min(
    abs(s-b) + abs(s-a) + a,
    abs(s-b) + (s - 1) + abs(a - 1) + 1
  )
echo ans