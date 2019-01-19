import sequtils,math,tables
proc toCountSeq[T](x:seq[T]) : seq[int] = toSeq(x.toCountTable().values)
let A = toSeq(stdin.readLine().items).toCountSeq()
var ans = 1
for i in 1..A.sum(): ans *= i
for a in A:
  for i in 1..a: ans = ans div i
echo ans - 1
