import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
let A = get().split().map(parseInt).sorted(cmp)
let v = toSeq(A.toCountTable().values).sorted(cmp)
if v.len == 2 and v[0] == 2 and v[1] == 3: echo "FULL HOUSE"
elif v[^1] == 3 : echo "THREE CARD"
elif v.len == 3: echo "TWO PAIR"
elif v.len == 4: echo "ONE PAIR"
else: echo "NO HAND"