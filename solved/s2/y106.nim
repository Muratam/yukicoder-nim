import sequtils,math
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let k = scan()
if k == 1:
  echo n - 1
  quit 0
if k >= 8: quit "0",0
const F_from_0_to_100_000 = (proc():seq[int] =
  var F = newSeq[int](2_000_001)
  for i in 2..<100_000:
    if F[i] > 0: return
    for j in countup(i*2,2_000_000,i): F[j] += 1
    F[i] = 1
  return F
)()
const F_from_0_to_100_0002 = (proc():seq[int] =
  var F = newSeq[int](2_000_001)
  for i in 100_000..200_000 :
    if F[i] > 0 or F_from_0_to_100_000[i] > 0: continue
    for j in countup(i*2,900_000,i): F[j] += 1
    F[i] = 1
  return F
)()

var F : array[2_000_010,int8]
var ans = 0
for i in 2..n div k:
  if F[i] > 0: continue
  for j in countup(i*2,n,i):
    F[j] += 1
    if F[j] == k : ans += 1
  F[i] = 1
echo ans