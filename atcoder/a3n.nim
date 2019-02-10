import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord

var k = scan()
let a = scan()
let b = scan()
if b - a <= 2 : # 交換はしないほうがいい
  echo 1 + k
  quit 0
# A枚までは x => x + 1する
# A枚以降は 偶数回 x => x + b - a する
if 1 + k < a:
  echo 1 + k
  quit 0
# a枚はある
var ans = a
k -= a - 1
if k mod 2 == 1 :
  ans += 1
  k -= 1
ans += (b - a) * (k div 2)
echo ans