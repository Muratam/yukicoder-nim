import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
import times
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
# template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)


let (y,m,d) = get().split().map(parseInt).unpack(3)
proc toDate(s:string) : DateTime = s.parse("yyyy-MM-dd")
let dt = fmt"{y:4d}-{m:02d}-{d:02d}".toDate()
if dt >= "1989-01-08".toDate() and dt <= "2019-04-30".toDate():
  echo "Yes"
else: echo "No"