import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

proc getFib(n,m:int): int =
  var (a,b,c) = (0,0,1)
  for _ in 3..n:
    (a,b,c) = (b,c,(b+c) mod m)
  return c
let (n,m) = get().split().map(parseInt).unpack(2)
echo getFib(n,m)