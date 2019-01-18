import sequtils,strutils,algorithm,math,sugar,macros,strformat
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0' or k > '9': break
    else: result = 10 * result + k.ord - '0'.ord

proc getNeignborDiff[T](arr:seq[T]) : seq[T] =
  if arr.len == 0 : return @[]
  result = newSeq[T](arr.len()-1)
  for i in 1..<arr.len(): result[i-1] = arr[i] - arr[i-1]

let n = scan()
let k = scan()
let A = newSeqWith(n,scan()).sorted(cmp)
let B = A.getNeignborDiff().sorted(cmp)
echo B[0..<(n-k)].sum()