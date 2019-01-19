import sequtils,strutils,algorithm,math,sugar,macros,strformat
proc getchar_unlocked():char {. importc:"getchar_unlocked",header: "<stdio.h>" .}
proc scan(): int =
  while true:
    var k = getchar_unlocked()
    if k < '0': break
    result = 10 * result + k.ord - '0'.ord
let n = scan()
let A = newSeqWith(n,scan())
proc trySort(B:seq[int]) : seq[(int,int)] =
  var C = A
  for i in 0..<n:
    if C[i] == B[i]: continue
    for j in i+1..<n:
      if C[j] != B[i]: continue
      swap(C[i],C[j])
      result &= (i,j)

let r1 = A.sorted(cmp,Descending).trySort()
let r2 = A.sorted(cmp,Ascending).trySort()
let results = (if r1.len > r2.len: r2 else:r1)
echo results.len()
for rs in results: echo rs[0]," ",rs[1]
discard stdin.readLine()