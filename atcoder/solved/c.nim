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
let A = newSeqWith(n+1,scan())
let B = newSeqWith(n,scan())
var ans = 0
block:
  var ans1 = 0
  var A1 = A
  var B1 = B
  for i in 0..n:
    if i > 0 :
      var x = A1[i].min(B1[i-1])
      A1[i] -= x
      ans1 += x
    if i < n:
      var x = A1[i].min(B1[i])
      B1[i] -= x
      A1[i] -= x
      ans1 += x
    # echo A1, B1, ans1
  ans = ans1
block:
  var ans1 = 0
  var A1 = A
  var B1 = B
  for i in (n-1).countdown(0):
    if i < n:
      var x = A1[i+1].min(B1[i])
      B1[i] -= x
      A1[i+1] -= x
      ans1 += x
    block:
      var x = A1[i].min(B1[i])
      A1[i] -= x
      ans1 += x
    # echo A1, B1, ans1
  ans .max= ans1
echo ans
