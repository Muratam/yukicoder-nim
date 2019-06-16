import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = newSeqWith(3,scan())
let B = newSeqWith(3,scan())
type AA = tuple[u,d:int,ab:bool]
var R : seq[AA] = @[]
for i in 0..<3:
  if A[i] > B[i]:
    R.add((A[i],B[i],true))
  elif A[i] <= B[i]:
    R.add((B[i],A[i],false))
R = R.sortedByIt(it.ab)
proc solve(r1m,r2m:int):int =
  # 実は貪欲でいける説
  var now = n
  var ans = 0
  # ± 20 くらいを見れば通るんでは??
  block:
    let r = R[0]
    let c = now div r.d - r1m
    if c < 0 : return 0
    now -= c * r.d
    if not r.ab :
      now += c * r.u
    else:
      ans += c * r.u
  block:
    let r = R[1]
    let c = now div r.d - r2m
    if c < 0 : return 0
    now -= c * r.d
    if not r.ab :
      now += c * r.u
    else:
      ans += c * r.u
  block:
    let r = R[2]
    let c = now div r.d
    now -= c * r.d
    ans += c * r.u
  return ans + now
var ans = n
for i in 0..n*2:
  for j in 0..n*2:
    ans .max= solve(i,j)
echo ans
