import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let S = get()
var state = 0
var start = 0
var res = newSeq[int]()
for i,s in S:
  if state <= 1 :
    if s == 'c':
      state = 1
      start = i
  elif state == 1:
    if s == 'w':
      state = 2
  elif state == 2:
    if s == 'w':
      res &= i - start + 1
      quit(0)
echo -1