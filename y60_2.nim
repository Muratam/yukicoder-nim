import sequtils,strutils,algorithm,math,sugar,macros
template get*():string = stdin.readLine() #.strip()
macro unpack*(arr: auto,cnt: static[int32]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int32,body:untyped): untyped = (for _ in 0..<n: body)

template useScan =
  proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
  proc scan(): int32 =
    result = 0
    var minus = false
    while true:
      var k = getchar_unlocked()
      if k == '-' : minus = true
      elif k < '0' or k > '9': break
      else: result = 10.int32 * result + k.ord.int32 - '0'.ord.int32
    if minus: result *= -1

useScan()

# N,K<1e6  |X,Y|,W,H<=500  HP,D<1e5 | [X,X+W] [Y,Y+W] に D | 倒れていない敵の体力の合計

template imosReduce2(field:typed) =
  for x in field.low + 1 .. field.high:
    for y in field[x].low .. field[x].high:
      field[x][y] += field[x-1][y]
  for x in field.low .. field.high:
    for y in field[x].low + 1 .. field[x].high:
      field[x][y] += field[x][y-1]

template imosRegist2(field:typed,x1,y1,x2,y2:int32,val:typed) =
  field[x1][y1] += val
  field[x1][y2+1] -= val
  field[x2+1][y1] -= val
  field[x2+1][y2+1] += val


var field : array[-501..501,array[-501..501,int32]]
let n = scan()
let k = scan()
var xyh : array[30_0002,int32]
for i in 0..<n:
  xyh[3*i+0] = scan()
  xyh[3*i+1] = scan()
  xyh[3*i+2] = scan()
k.times:
  let (x,y,w,h,d) = (scan(),scan(),scan(),scan(),scan())
  field.imosRegist2(x,y,min(500,x+w),min(500,y+h),d)
field.imosReduce2()
var damageSum = 0
for i in 0..<n:
  let (x,y,hp) = (xyh[3*i+0],xyh[3*i+1],xyh[3*i+2])
  damageSum += max(0, hp - field[x][y])
echo damageSum