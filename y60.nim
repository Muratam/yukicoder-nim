import sequtils,strutils,algorithm,math,future,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])


proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan1[T](): T =
  var minus = false
  result = 0
  while true:
    var k = getchar_unlocked()
    if k == '-' : minus = true
    elif k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord
  if minus: result *= -1
macro scanints(cnt:static[int]): auto =
  result = nnkBracket.newNimNode
  for i in 0..<cnt: result.add(quote do: scan1[int]())

# N,K<1e6  |X,Y|,W,H<=500  HP,D<1e5 | [X,X+W] [Y,Y+W] に D | 倒れていない敵の体力の合計

# var field : array[-501..501,array[-501..501,int]] などが可能...
# range :: [x1..x2][y1..y2]
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
for k in 0..<K :
  let (x,y,w,h,d) = scanints(5).unpack(5)
  field.imosRegist2(x,y,min(500,x+w),min(500,y+h),d)
field.imosReduce2()
var damageSum = 0
for n in 0..<N:
  let (x,y,hp) = ene_XYHP[n].unpack(3)
  damageSum += 0.max(hp-field[x][y])
echo damageSum


#[
let
  (N,K) = get().split().map(parseInt).unpack(2)
  ene_XYHP = newSeqWith(N,get().split().map(parseInt))
  my_XYWHD = newSeqWith(K,get().split().map(parseInt))
var field : array[-501..501,array[-501..501,int]]
#################### 2-imos ######################
for XYWHD in my_XYWHD:
  let # [X,X+W] [Y,Y+W] に
    (X,Y,W,H,D) = XYWHD.unpack(5)
    x1 = X
    y1 = Y
    x2 = min(500,X+W)
    y2 = min(500,Y+H)
  field.imosRegist2(x1,y1,x2,y2,D)
field.imosReduce2()

var damageSum = 0
for XYHP in ene_XYHP:
  let (X,Y,HP) = XYHP.unpack(3)
  damageSum += max(0,HP - field[X][Y])
echo damageSum
]#
