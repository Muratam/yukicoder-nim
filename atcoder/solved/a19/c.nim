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

proc toCountTable*[A](keys: openArray[A]): CountTable[A] =
  result = initCountTable[A](nextPowerOfTwo(keys.len * 3 div 2 + 4))
  for key in items(keys):
    result[key] = 1 + (if key in result : result[key] else: 0)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] =
  let ct = x.toCountTable()
  return toSeq(ct.pairs)


let n = scan()
let S = newSeqWith(n,stdin.readLine().sorted(cmp).mapIt($it).join(""))
  .sorted(cmp).toCountSeq().mapIt(it.v)
var ans = 0
for s in S:
  if s <= 1 : continue
  ans += s * (s-1) div 2
echo ans
