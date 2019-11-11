import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues,times
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)
type Pos = tuple[x,y:int]
proc abs(p:Pos):int = p.x*p.x+p.y*p.y
proc `+`(a,b:Pos):Pos = (a.x+b.x,a.y+b.y)

# 速度重視で乱択する場合用の Xor-Shift
var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc random*(maxIndex: int): int =
  cast[int](xorShift() mod maxIndex.uint64)
proc randomBit*(maxBit:int):uint64 = # mod が遅い場合
  xorShift() and cast[uint64]((1 shl maxBit) - 1)
proc shuffle*[T](x: var openArray[T]) =
  for i in countdown(x.high, 1):
    swap(x[i], x[random(i)])

# 時間ギリギリまでサーチ.
import times
template timeUpSearch(milliSec:int,body) =
  # 時間計測は 1e5 回で100ms.
  # この回数以上探索するなら, for i in 0..<100: body にする
  let startTime = cpuTime()
  while (cpuTime() - startTime) * 1000 < milliSec:
    body

let n = scan()
let XY = newSeqWith(n,(x:scan(),y:scan()))
var ans = 0
var S = toSeq(0..n-1)
timeUpSearch(800):
  shuffle(S)
  for i in 0..<n:
    var tmp : Pos = XY[S[i]]
    for j in (i+1)..<n:
      if tmp.abs < (tmp+XY[S[j]]).abs:
        tmp = tmp + XY[S[j]]
    ans .max= tmp.abs
echo ans.float.sqrt()
