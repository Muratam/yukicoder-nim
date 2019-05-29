import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (aw,ab) = get().split().map(parseInt).unpack(2)
let (bw,bb) = get().split().map(parseInt).unpack(2)
let (c,d) = get().split().map(parseInt).unpack(2)
# awを最大に
let a2b = 0.max(c - ab)
echo(aw-a2b+d - 0.max(d-(bw+a2b)))