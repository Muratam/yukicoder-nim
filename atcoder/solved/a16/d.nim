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
let k = scan()
let A = newSeqWith(n,scan())
var ans = 0
# [x,y)
var x = 0
var y = 1 # warn y
var total = A[0]
while true:
  # echo "total:",total,",x:",x,",:y",y,",ans:",ans
  if total < k:
    if y >= n : break
    total += A[y]
    y += 1
    continue
  ans += n - y + 1
  total -= A[x]
  x += 1
echo ans
# try: n == 1
# check: x >= y
