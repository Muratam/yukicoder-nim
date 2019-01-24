import sequtils,algorithm
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  var minus = false
  while true:
    let k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1

let n = scan()
let m = scan()
let D = newSeqWith(m,scan()).sorted(cmp)
if m == 1:
  echo D[0].abs
  quit 0
var ans = int.high
for x in 0..<m:
  let y = x + n - 1
  if y >= m : break
  if D[y] <= 0: ans .min= -D[x]
  elif D[x] >= 0 : ans .min= D[y]
  else:
    ans .min= -D[x] + D[y] * 2
    ans .min= -D[x] * 2 + D[y]
echo ans