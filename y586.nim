import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let p1 = get().parseInt()
let p2 = get().parseInt()

let p = p1 + p2
let n = get().parseInt()
let R = newSeqWith(n,get().parseInt()).sorted(cmp)
var res = 0
for i in 1..<R.len():
  if R[i] == R[i-1] : res += p
echo res