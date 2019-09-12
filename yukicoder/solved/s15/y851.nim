import sequtils,sets,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0':
      if k == ' ' : quit "\"assert\"",0
      return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = newSeqWith(n,scan())
var ans = initSet[int]()
for i in 0..<n:
  for j in (i+1)..<n:
    ans.incl A[i] + A[j]
echo toSeq(ans.items).sorted(cmp)[^2]
