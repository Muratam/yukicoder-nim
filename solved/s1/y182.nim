import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()

let n = get().parseInt()
let A = get().split().map(parseInt).sorted(cmp)
echo toSeq(A.toCountTable().values).sorted(cmp).filterIt(it == 1).sum()
