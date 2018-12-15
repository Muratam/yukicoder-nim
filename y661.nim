import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let c = get().parseInt()
c.times:
  let N = get().parseInt()
  if N mod 40 == 0 : echo "ikisugi"
  elif N mod 10 == 0 : echo "sugi"
  elif N mod  8 == 0 : echo "iki"
  else: echo N div 3
