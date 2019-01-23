import sequtils,algorithm
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

proc find*[T](arr: seq[T],item: T,start,fin:int): int {.inline.}=
  for i in start..<fin:
    if arr[i] == item : return i
  return -1

let n = scan()
let k = scan()
var A = newSeqWith(n,scan())
var ans = 0
let B = A.sorted(cmp)
for i,b in B:
  if A[i] == b : continue
  var p = A.find(b,i+1,n)
  while A[i] != b:
    if p - k < 0 : quit "-1",0
    swap(A[p],A[p-k])
    p -= k
    ans += 1
echo ans