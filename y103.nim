import sequtils,math,tables
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc toCountSeq[T](x:seq[T]) : seq[int] = toSeq(x.toCountTable().values)

proc getFactorsAllRange(n:int):seq[seq[int]] =
  # 1 ~ n まで
  result = newSeqWith(n+1,newSeq[int]())
  for i in 2..n.float.sqrt.int :
    if result[i].len != 0: continue
    for j in countup(i*2,n,i):
      result[j] &= i

const factors = getFactorsAllRange(10000)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

let n = scan()
let M = newSeqWith(n,scan().getFactors().toCountSeq())
var ans = 0
for m in M:
  for mm in m:
    ans = ans xor (mm mod 3)
if ans != 0 : echo "Alice"
else: echo "Bob"