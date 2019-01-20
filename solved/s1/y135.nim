import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
let X = get().split().map(parseInt).sorted(cmp)
if X.len() < 2:
  echo 0
  quit(0)
var res = X[^1] - X[0]
for i in 1..<n:
  let x = X[i] - X[i-1]
  if x == 0 : continue
  res .min= x
echo res