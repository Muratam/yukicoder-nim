import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
proc toCountSeq[T](x:seq[T]) : seq[int] = toSeq(x.toCountTable().keys)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

let n = scan()
var A = initIntSet()
A.incl 0
n.times: A.incl scan()
var preLen = A.card
while true:
  let A1 = A
  let A2 = A
  for a in A1:
    for b in A2:
      A.incl a xor b
  if A.card == preLen: break
  preLen = A.card
echo A.card