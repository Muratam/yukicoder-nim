import sequtils,strutils,algorithm,math,sugar,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body:untyped): untyped = (for _ in 0..<n: body)

proc getchar():char {. importc:"getchar",header: "<stdio.h>" .}
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
template scan1[T](thread_safe:bool): T =
  var minus = false
  var result : T = 0
  while true:
    when thread_safe:(var k = getchar())
    else:( var k = getchar_unlocked())
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
  result
macro scanints(cnt:static[int]): auto =
  result = nnkBracket.newNimNode
  for i in 0..<cnt: result.add(quote do: scan1[int](false))

# N,K<1e6  |X,Y|,W,H<=500  HP,D<1e5 | [X,X+W] [Y,Y+W] に D | 倒れていない敵の体力の合計

template imosReduce2(field:typed):void =
  for x in field.low + 1 .. field.high:
    for y in field[x].low .. field[x].high:
      field[x][y] += field[x-1][y]
  for x in field.low .. field.high:
    for y in field[x].low + 1 .. field[x].high:
      field[x][y] += field[x][y-1]

template imosRegist2(field:typed,x1,y1,x2,y2:int,val:typed):void =
  field[x1][y1] += val
  field[x1][y2+1] -= val
  field[x2+1][y1] -= val
  field[x2+1][y2+1] += val


var field : array[-501..501,array[-501..501,int]]
let
  (N,K) = get().split().map(parseInt).unpack(2)
  ene_XYHP = newSeqWith(N,scanints(3))
  my_XYWHD = newSeqWith(K,scanints(5))
for xywhd in my_XYWHD:
   let (x,y,w,h,d) = xywhd.unpack(5)
   field.imosRegist2(x,y,min(500,x+w),min(500,y+h),d)
field.imosReduce2()
var damageSum = 0
for xyhp in ene_XYHP:
  let (x,y,hp) = xyhp.unpack(3)
  damageSum += max(0, hp - field[x][y])
echo damageSum