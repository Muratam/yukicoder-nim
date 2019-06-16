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

let h = scan()
let w = scan()
# is block
var C = newSeqWith(w,newSeqWith(h,false))
for y in 0..<h:
  for x in 0..<w:
    C[x][y] = getchar_unlocked() == '#'
  discard getchar_unlocked()
var X1 = newSeqWith(w,newSeqWith(h,0))
for y in 0..<h:
  var now = 0
  for x in 0..<w:
    if C[x][y] :
      now = 0
      continue
    now += 1
    X1[x][y] = now
for y in 0..<h:
  var now = 0
  for x in (w-1).countdown(0):
    if C[x][y] :
      now = 0
      continue
    now += 1
    X1[x][y] += now - 1

var X2 = newSeqWith(w,newSeqWith(h,0))

for x in 0..<w:
  var now = 0
  for y in 0..<h:
    if C[x][y] :
      now = 0
      continue
    now += 1
    X2[x][y] = now
for x in 0..<w:
  var now = 0
  for y in (h-1).countdown(0):
    if C[x][y] :
      now = 0
      continue
    now += 1
    X2[x][y] += now - 1

var ans = -1
for x in 0..<w:
  for y in 0..<h:
    ans .max= X1[x][y] + X2[x][y] - 1
echo ans
