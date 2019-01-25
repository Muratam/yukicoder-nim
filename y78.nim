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

let n = scan()
let k = scan()
var a0 = 0
var a1 = 0
var a2 = 0
n.times:
  let k = getchar_unlocked()
  if k == '0' : a0 += 1
  elif k == '1' : a1 += 1
  elif k == '2' : a2 += 1

block:
  var ans = 0
  var left = 0
  # 2本当たりから購入
  ans += a2
  left