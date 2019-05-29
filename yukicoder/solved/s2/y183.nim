import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template times*(n:int,body) = (for _ in 0..<n: body)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
var A : array[1 shl 15,bool]
A[0] = true
n.times:
  let b = scan()
  for i in 0..<A.len: A[i xor b] = A[i xor b] or A[i]
var ans = 0
for a in A:
  if a: ans += 1
echo ans