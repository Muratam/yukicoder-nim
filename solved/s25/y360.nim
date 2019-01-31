import sequtils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var D = newSeqWith(7,scan()).sorted(cmp)
proc check(): bool =
  for i in 2..<7:
    if D[i] == D[i-1] : return false
    if D[i-1] == D[i-2] : return false
    if D[i-2] >= D[i] : return false
  return true
while true:
  if check():
    quit "YES",0
  if not D.nextPermutation(): break
echo "NO"