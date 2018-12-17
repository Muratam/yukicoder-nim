import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let S = toSeq(newSeqWith(n,get().len()-2).toCountTable().pairs).sorted((a,b) => (if b[1] != a[1] : b[1] - a[1] else: b[0] - a[0]))
echo S[0][0]