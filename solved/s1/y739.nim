import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let s = get()
proc ok():bool=
  if s.len() mod 2 == 1 : return false
  let sl = s.len() div 2
  for i in 0..<sl:
    if s[i] != s[i + sl]: return false
  return true
echo(if ok():"YES" else:"NO")