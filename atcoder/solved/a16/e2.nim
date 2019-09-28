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

# RHの数を増やす
const MOD = 1e9.int+7
var n = scan()
var m = scan()
var S = newSeqWith(n,scan())
var T = newSeqWith(m,scan())
if S.len < T.len:
  (S,T) = (T,S)
  (n,m) = (m,n)
var ans = 0
for ti in 0..<T.len:
  for si in 0..<S.len:
    if S[si] != T[ti] : continue
    var now = 0
