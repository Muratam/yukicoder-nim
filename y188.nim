import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)


const n = (proc():int =
  const ns = [31,28,31,30,31,30, 31,31,30,31,30,31]
  result = 0
  for i in 0..<12:
    for j in 1..ns[i]:
      if i + 1 == j mod 10 + j div 10:
        result += 1
        echo i+ 1," ",j
)()
echo n