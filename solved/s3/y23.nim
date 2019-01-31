import sequtils
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let h = scan()
let a = scan()
let d = scan()
var ans = 1e10
for i in 0..<h: # i 回通常攻撃
  if h - a * i <= 0 :
    ans .min= ((h-1) div a + 1).float
    break
  ans .min= i.float + ((h - a * i - 1) div d + 1).float * 1.5
echo ans
