import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
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
let S = stdin.readLine()
var oks = newSeqWith(n,true)
var seats = newSeqWith(n,true)
var li = 0
var ri = n - 1
var allBad = false

proc seat(x:int) : bool =
  if not oks[x]:
    return false
  oks[x] = false
  seats[x] = false
  if x - 1 >= 0 : oks[x-1] = false
  if x + 1 < n  : oks[x+1] = false
  echo x + 1
  return true

proc seatForce(x:int) : bool =
  if not seats[x]:
    return false
  seats[x] = false
  echo x + 1
  return true

for s in S:
  if s == 'L':
    if not allBad:
      while not seat(li):
        li += 1
        if li < n: continue
        allBad = true
        li = 0
        ri = n - 1
        break
    if allBad:
      while not seatForce(li):
        li += 1
  else:
    if not allBad:
      while not seat(ri):
        ri -= 1
        if ri >= 0: continue
        allBad = true
        li = 0
        ri = n - 1
        break
    if allBad:
      while not seatForce(ri):
        ri -= 1
