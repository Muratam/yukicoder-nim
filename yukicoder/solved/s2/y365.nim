import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let A = newSeqWith(n,scan())
var ans = 0
var maxN = n
for i in countdown(A.len-1,0):
  if A[i] == maxN :
    maxN -= 1
    continue
  ans += 1
echo ans