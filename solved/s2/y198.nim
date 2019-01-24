import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

let my = scan()
let n = scan()
if n == 1 :  quit "0",0
let C0 = newSeqWith(n,scan()).sorted(cmp)
let C = C0.mapIt(it - C0[0])
var ans = int.high

proc calcCost(m:int):int =
  var myLeft = my
  for c in C:
    let diff = c - m
    if diff < 0 : continue
    myLeft += diff
    result += diff
  for c in C:
    let diff = m - c
    if diff < 0 : continue
    myLeft -= diff
    result += diff
    if myLeft < 0 : return int.high
var x = C[0]
var y = C[^1]
while true:
  let m = (x + y) div 2
  let costM = m.calcCost()
  let costX = x.calcCost()
  let costY = y.calcCost()
  # echo "XMY:",[x,m,y]
  # echo "COST:",[costX,costM,costY]
  if m - x <= 1 or y - m <= 1:
    echo toSeq(x..y).mapIt(it.calcCost()).min()
    quit 0
  if costM > costY : x = m
  elif costM > costX : y = m
  elif calcCost((x+m) div 2) > calcCost((m+y) div 2):
    x = (x + m) div 2
  else: y = (y + m) div 2
echo ans