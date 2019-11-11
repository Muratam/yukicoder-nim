{.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

var xorShiftVar* = 88172645463325252.uint64
xorShiftVar = cast[uint64](cpuTime()) # 初期値を固定しない場合
proc xorShift() : uint64 =
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 13)
  xorShiftVar = xorShiftVar xor (xorShiftVar shr 7)
  xorShiftVar = xorShiftVar xor (xorShiftVar shl 17)
  return xorShiftVar
proc random*(maxIndex: int): int =
  cast[int](xorShift() mod maxIndex.uint64)

let startTime = cpuTime()
let n = scan() # 1e5
type LRType = tuple[L,R:int]
proc update(x,y:LRType):LRType =
  (x.L.max(y.L),x.R.min(y.R))
proc rangeLen(x:LRType):int = (x.R - x.L + 1).max(0)
let LRBase = newSeqWith(n,(L:scan(),R:scan()))
# 上位2つ
proc argMax2[T](arr:seq[T]): (int,int) =
  var x1 = 0
  var x2 = 1
  if arr[x1] < arr[x2]: swap x1,x2
  for i in 2..<arr.len:
    if arr[i] <= arr[x2]: continue
    if arr[i] >= arr[x1]:
      x2 = x1
      x1 = i
      continue
    x2 = i
  return (x1,x2)
proc shuffleAt*[T](x: var openArray[T],at:Slice[int]) =
  let d = at.b - at.a + 1
  for i in at.b.countdown(at.a):
    swap(x[i], x[at.a+random(d)])
proc tryRandom():int =
  var ans = 0
  # 最初は一番範囲の大きいもの上位2つから始める
  let (i1,i2) = LRBase.mapIt(it.rangeLen).argMax2()
  var LR = LRBase
  swap LR[0],LR[i1]
  swap LR[1],LR[i2]
  # ほかはどうでもいいのでランダムにしておく
  LR.shuffleAt(2..<LR.len)
  while cpuTime() - startTime < 1.95:
    var A = LR[0]
    var B = LR[1]
    for i in 2..<LR.len:
      let lr = LR[i]
      let al = A.update(lr).rangeLen + B.rangeLen
      let bl = B.update(lr).rangeLen + A.rangeLen
      if bl < al:  A = A.update(lr)
      else: B = B.update(lr)
    ans .max= A.rangeLen + B.rangeLen
    # A と B が本当は同一集合だった場合困るので適当なものと交換
    # https://atcoder.jp/contests/agc040/submissions/8282249
    swap LR[1],LR[random(LR.len-1)+1]
  return ans

var ans = LRBase.mapIt(it.rangeLen).max()
ans .max= tryRandom()
echo ans
