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
const MOD = 1e9.int + 7
var ans = 0
for i in 0..<n:
  var inline = 0
  for j in (i+1)..<n:
    if A[i] > A[j] : inline += 1
  inline = inline mod MOD
  var outline = 0
  for j in 0..<n:
    if A[i] > A[j] : outline += 1
  outline = outline mod MOD
  #
  inline = (inline * k) mod MOD
  outline = (outline * (((k-1) * k div 2) mod MOD)) mod MOD
  ans = (ans + inline) mod MOD
  ans = (ans + outline) mod MOD
echo ans
