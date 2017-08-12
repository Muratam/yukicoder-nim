import sequtils,strutils,strscans,algorithm,math,future,macros
#import sets,queues,tables,nre,pegs
macro unpack*(rhs: seq,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `rhs`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template get*():string = stdin.readLine() #.strip()
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)
template `max=`*(x,y:typed):void = x = max(x,y)
template `min=`*(x,y:typed):void = x = min(x,y)

type Vec2 = object
  x,y: int
proc `+`(p,v:Vec2):Vec2 = result.x = p.x+v.x; result.y = p.y+v.y
proc `-`(p,v:Vec2):Vec2 = result.x = p.x-v.x; result.y = p.y-v.y
proc `*`(p,v:Vec2):int = p.x * v.x + p.y * v.y
proc sqlen(p:Vec2):int = p.x * p.x + p.y * p.y


let
  (x1,y1,x2,y2,x3,y3) = get().split().map(parseInt).unpack(6)
  z = @[(x1,y1),(x2,y2),(x3,y3),(x1,y1)].mapIt(Vec2(x:it[0],y:it[1]))
for i in 0..<3:
  let
    z1 = z[(i+0) mod 3]
    z2 = z[(i+1) mod 3]
    z3 = z[(i+2) mod 3]
    z12 = z2 - z1
    z13 = z3 - z1
  if z12 * z13 == 0 and z12.sqlen == z13.sqlen:
    let z4 = z3 + z12
    echo z4.x," ",z4.y
    quit()
echo -1