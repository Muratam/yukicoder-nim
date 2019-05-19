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

let r = scan()
let g = scan()
let b = scan()
let n = scan()
var ans = 0
for ri in 0..(n div r):
  for gi in 0..(n div g):
    let bi = n - ri * r - gi * g
    if bi < 0 : continue
    if bi mod b != 0 : continue
    ans += 1
echo ans
