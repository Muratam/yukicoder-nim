import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
let n = get().parseInt()
let A = get().split().map(parseInt)
let B = get().split().map(parseInt)
var S = newSeqWith(110,0)
for i in 0..<n: S[B[i]] += A[i]
let me = S[0]
if me >= S.sorted(cmp)[^1]: echo "YES"
else: echo "NO"