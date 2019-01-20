import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
let X = newSeqWitH(n,get().parseInt())
if X[0].abs() != 1 :
  echo "F"
  quit(0)
for i in 1..<X.len():
  if abs(X[i] - X[i-1]) != 1 :
    echo "F"
    quit(0)
echo "T"