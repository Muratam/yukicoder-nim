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


let n = scan()
let A = -1 & newSeqWith(n,scan())
var fixed = A
var B = A # newSeqWith(n + 1,-1)
B[0] = -1000
# WARN 0 ばん
for z in 2..n:
  # echo "z:",z
  for i in (n div (z + 1) + 1)..(n div z):
    # echo "i:",i
    var tmp = A[i]
    for x in 2..z:
       tmp = tmp xor B[i * x]
    B[i] = tmp

# block:
#   var tmp = 0
#   for j in 2..n:
#     tmp = tmp xor B[j]
#   B[1] = tmp xor A[1]
var ans = newSeq[int]()
for i in 1..n:
  if B[i] == 1 :
    ans .add i


if ans.len == 0 : echo 0
else: echo ans.len(),"\n",ans.mapIt($it).join(" ")


# for i in 1..n:
#   var t = 0
#   for j in countup(i,n,i):
#     t = t xor B[j]
#   echo i,":",t,"-",A[i]
