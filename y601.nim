import sequtils,math
template times*(n:int,body) = (for _ in 0..<n: body)
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int32 =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord.int32 - '0'.ord.int32

let n = scan()
var cnts = newSeq[int](4)
n.times:
  let x = scan()
  let y = scan()
  cnts[(x mod 2) + 2 * (y mod 2)] += 1
if cnts.mapIt(it div 2).sum() mod 2 == 1 : echo "Alice"
else: echo "Bob"