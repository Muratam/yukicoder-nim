import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc `^`(n:int) : int{.inline.} = (1 shl n)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': return
    result = 10 * result + k.ord - '0'.ord


let m = scan()
let k = scan()
if k >= ^m: quit "-1",0
if m == 1 and k == 1 : quit "-1",0
var bits = newSeq[int]()
var used = newSeq[bool](^(m+1))
block:
  var i = 0
  while ^i < k:
    if (k and ^i) > 0:
      bits.add ^i
    used[^i] = true
    i += 1
var A = newSeq[int]()
for i in 0..<(^m):
  if not used[i] and i != k: A.add i
for b in bits: A.add b
A.add k
for b in bits.reversed(): A.add b
A.add k
for i in (^m-1).countdown(0):
  if not used[i] and i != k: A.add i
echo A.mapIt($it).join(" ")
