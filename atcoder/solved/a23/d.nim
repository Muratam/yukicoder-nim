# {.checks:off.}
import sequtils,algorithm,math,tables,sets,strutils,times


#     > <=           >=  <
#  ... [lowerBound ... ][upperBound ...
#  ... [x:         ... ][succ(x):   ...
import algorithm
when not defined(upperBound) : # Nim0.13.0には無いため
  proc upperBound[T](a: openArray[T], key: T): int =
    result = a.low
    var count = a.high - a.low + 1
    var step, pos: int
    while count != 0:
      step = count shr 1
      pos = result + step
      if cmp(a[pos], key) <= 0:
        result = pos + 1
        count -= step + 1
      else:
        count = step
# 指定キー{以上,超過}のうちの最小のindex(満たすものがなければarr.lenになる)
proc greater[T](arr:seq[T],key:T,including:bool): int =
  if including : arr.lowerBound(key)
  else: arr.upperBound(key)
# 指定キー{未満,以下}のうちの最大のindex(無い時は-1)
proc less[T](arr:seq[T],key:T,including:bool): int =
  if including : arr.upperBound(key) - 1
  else: arr.lowerBound(key) - 1


template stopwatch(body) = (let t1 = cpuTime();body;stderr.writeLine "TIME:",(cpuTime() - t1) * 1000,"ms")
template loop*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" ,discardable.}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0' or k > '9': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let L = newSeqWith(n,scan()).sorted(cmp)
var ans = 0
for i in 0..<n:
  for j in (i+1)..<n:
    let ab1 = abs(L[j] - L[i])
    let ab2 = L[i] + L[j]
    let x1 = L.greater(ab1,false)
    let x2 = L.less(ab2,false)
    if x2 <= j : continue
    ans += (x2 - j.max(x1).max(i))
    # echo @[L[i],L[j],ab1,ab2,x1,x2,i,j]
echo ans
