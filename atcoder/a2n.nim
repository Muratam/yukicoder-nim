import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let A = stdin.readLine()
let B = stdin.readLine()
let C = stdin.readLine()
var ans = 0
for i in 0..<n:
  let a = A[i]
  let b = B[i]
  let c = C[i]
  if a == b and b == c : continue
  elif a != b and b != c and c != a : ans += 2
  else: ans += 1
echo ans