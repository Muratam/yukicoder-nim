import sequtils,algorithm,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let C = newSeqWith(n,scan()).sorted(cmp).filterIt(it>0)
proc isAWin():bool =
  if C.len == 0: return false
  if C.len == 1: return C[0] == 1
  if C[^1] >= 2: return C[^2] == 1 and C[^1] == 2 and C.len mod 2 == 0
  return C.len mod 2 == 1
if isAwin(): echo "A"
else: echo "B"