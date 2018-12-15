import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (h,n) = get().split().map(parseInt).unpack(2)
let H = @[h].concat(newSeqWith(n-1,get().parseInt())).sorted(cmp,Descending)
for i,hi in H:
  if hi != h: continue
  let th = i + 1
  case th mod 10:
    of 1: echo fmt"{th}st"
    of 2: echo fmt"{th}nd"
    of 3: echo fmt"{th}rd"
    else: echo fmt"{th}th"
  quit(0)