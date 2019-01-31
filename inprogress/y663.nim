import sequtils,algorithm,math,tables
import sets,intsets,queues,heapqueue,bitops,strutils
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

var A = @[1,2,3,3,4,5]
var ai = 0
while true:
  ai += 1
  if not A.nextPermutation(): break
var B = @[1,2,3,4,5,6]
var bi = 0
while true:
  bi += 1
  if not B.nextPermutation(): break
echo ai,":",bi
# let n = scan()
# var isZero = newSeqWith(n,true)
# var isOne = newSeqWith(n,true)
# let E = newSeqWith(n,scan())
# for i in 0..<n:
#   let a = E[(i-1+n) mod n]
#   let b = E[i]
#   let c = E[(i+1) mod n]
#   case 4 * a + 2 * b + c:
#   of 0b000:
#   of 0b001:
#   of 0b010:
#   of 0b011:
#   of 0b100:
#   of 0b101:
#   of 0b110:
#   of 0b111:
#   else: discard