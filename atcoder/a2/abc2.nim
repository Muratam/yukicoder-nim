import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (n,k) = get().split().map(parseInt).unpack(2)
let H = newSeqWith(n,get().parseInt()).sorted(cmp)
var res = int.high
for i in 0..(n-k):
  res .min= H[i+k-1] - H[i]
echo res