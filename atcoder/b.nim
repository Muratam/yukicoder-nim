import sequtils,strutils,algorithm,math,macros
import sets,tables,intsets,queues
# heapqueue,bitops,strformat,sugar cannot use
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc scanf(formatstr: cstring){.header: "<stdio.h>", varargs.}
proc scan(): int = scanf("%lld\n",addr result)

let n = scan()
let d = scan()
let X = newSeqWith(n,newSeqWith(d,scan()))
# echo X
var ans = 0
for i in 0..<n:
  for j in (i+1)..<n:
    var s = 0
    for k in 0..<d:
      let x = X[i][k] - X[j][k]
      s += x * x
    let ss = s.float.sqrt.int
    # echo s
    if ss * ss == s:
      ans += 1
echo ans
