import sequtils,algorithm,math,tables,sugar
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
  # let a = (x:37,y: -150,z:40)
  # return (a.x-x)*(a.x-x)+(a.y-y)*(a.y-y)+(a.z-z)*(a.z-z) * 5 + 10
  return scan()
proc decide(x,y,z:int) =
  echo "! ",x," ",y," ",z
  quit(0)

proc decideVal(request:proc(x:int):int) : int =
  var ax = -150
  var bx = 150
  var answers = newTable[int,int]()
  proc req(x:int) :int =
    if x in answers : return answers[x]
    answers[x] = request(x)
    return answers[x]
  while true:
    let m1x = (2 * ax + bx) div 3
    let m2x = (ax + 2 * bx) div 3
    let ad = req(ax)
    let m1d = req(m1x)
    let m2d = req(m2x)
    let bd = req(bx)
    if m1d > m2d : ax = m1x
    else : bx = m2x
    if bx - ax == 0 : return ax
    if bx - ax <= 3:
      let A = toSeq(ax..bx).mapIt((it,req(it)))
      let dMin = A.mapIt(it[1]).min()
      for a in A:
        if a[1] == dMin: return a[0]

var (x,y,z) = (0,0,0)
x = decideVal( x => request(x,y,z))
y = decideVal( y => request(x,y,z))
z = decideVal( z => request(x,y,z))
decide(x,y,z)
