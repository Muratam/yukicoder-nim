template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
var A : array[101,int]
n.times: A[scan()] += 1
var ans = n * (n-1) * (n-2) div 6
for a in A:
  if a < 3: continue
  ans -= a * (a-1) * (a-2) div 6
for i in 1..100:
  if A[i] < 1 : continue
  for j in (i+1)..100:
    if A[j] < 1: continue
    if A[i] + A[j] < 3 : continue
    ans -= A[i] * A[j] * (A[j] - 1) div 2
    ans -= A[j] * A[i] * (A[i] - 1) div 2
echo ans mod 10_0000_0007