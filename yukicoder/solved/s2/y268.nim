import sequtils,algorithm
template `min=`(x,y) = x = min(x,y)

proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    let k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord

template permutationIter[T](arr:seq[T],arrRef,body) =
  var arrRef{.inject.} = arr
  while true:
    body
    if not arrRef.nextPermutation() : break

let L = newSeqWith(3,scan())
let L2 = @[L[0]+L[1],L[1]+L[2],L[2]+L[0]]
var R = newSeqWith(3,scan())
var ans = int.high
toSeq(0..<3).permutationIter(P):
  var v = 0
  for i in 0..<3: v += R[P[i]]*L2[i]
  ans .min= v
echo ans * 2