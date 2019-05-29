import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let X = get().split().map(parseInt).sorted(cmp)
let uX = X.toSet().toSeq()
if X.len() == uX.len():
  let c = X[1] - X[0]
  for i in 2..<X.len():
    if X[i] - X[i-1] != c :
      echo "NO"
      quit(0)
  echo "YES"
else:
  echo "NO"