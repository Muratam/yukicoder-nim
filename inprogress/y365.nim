import sequtils
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let A = newSeqWith(n,scan())
var maxA = n
var ans = 0
var used = newSeqWith(n+1,false)
for i in (n-1).countdown(0):
  let a = A[i]
  if a < maxA:
    used[a] = true
    ans += 1
    continue
  # a == maxA
  for j in (maxA-1).countdown(1):
    if used[j] :
      ans += 1
      continue
    maxA = j
    break
echo ans