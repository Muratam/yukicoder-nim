import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

# 重複を取り除く(O(logN))
# Nim0.13 の deduplicate はO(n^2)なので注意
proc deduplicated[T](arr: seq[T]): seq[T] =
  result = @[]
  for a in arr.sorted(cmp[T]):
    if result.len > 0 and result[^1] == a : continue
    result.add a


let n = scan()
type XYDType = tuple[x,y,d:int]
var XYD = newSeq[XYDType](n)
for i in 0..<n: # 45度回転して√2倍
  let x = scan()
  let y = scan()
  let d = scan()
  let x2 = x - y
  let y2 = x + y
  XYD[i] = (x2,y2,d)
# X 座標圧縮
var xTable = initTable[int,int]()
var X = newSeq[int](n)
for i in 0..<n: X[i] = XYD[i].x
X = X.deduplicated()
for i,x in X: xTable[x] = i
# Y 座標圧縮
var yTable = initTable[int,int]()
var Y = newSeq[int](n)
for i in 0..<n: Y[i] = XYD[i].y
Y = Y.deduplicated()
for i,y in Y: yTable[y] = i
var map = newSeqWith(X.len(),newSeq[int](Y.len()))
for xyd in XYD:
  let x = xTable[xyd.x]
  let y = yTable[xyd.y]
  map[x][y] += 1
for x in 1..<X.len:
  for y in 0..<Y.len:
    map[x][y] += map[x-1][y]
for x in 0..<X.len:
  for y in 1..<Y.len:
    map[x][y] += map[x][y-1]
# upperBound して

echo XYD
