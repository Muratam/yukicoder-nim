import sequtils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let X = newSeqWith(n,scan())
let xMax = X.max()
var ans = 0
var already = false
for x in X :
  if not already and x == xMax :
    ans += x
    already = true
  else: ans += x div 2
echo ans