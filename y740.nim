import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

var (n,m,p,q) = get().split().map(parseInt).unpack(4)
var month = 0
var res = 0
while n > 0:
  if month + 1 >= p and month + 1 < p + q : n -= 2 * m
  else: n -= m
  month = (month + 1) mod 12
  res += 1
echo res