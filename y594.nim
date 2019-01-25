import sequtils,algorithm,math,tables,sugar
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

proc request(x,y,z:int):int =
  echo "? ",x," ",y," ",z
  return scan()
proc decide(x,y,z:int) =
  echo "! ",x," ",y," ",z
  quit(0)

proc decideVal(request:proc(x:int):int) : int =
  var ax = -150
  var bx = 150
  while true:
    let mx = (ax + bx) div 2
    var ad = request(ax)
    var bd = request(bx)
    let md = request(mx)
    if md < ad :
      ax = mx
      ad = md
    elif md < bd :
      bx = mx
      bd = md
    if bx - ax == 1 and ad < bd: return ax
    if bx - ax <= 1: return bx


var (x,y,z) = (0,0,0)
x = decideVal( x => request(x,y,z))
y = decideVal( y => request(x,y,z))
z = decideVal( z => request(x,y,z))
decide(x,y,z)
