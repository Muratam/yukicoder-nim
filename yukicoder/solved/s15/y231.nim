import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
let n = get().parseInt()
let GD = newSeqWith(n,get().split().map(parseInt).unpack(2))
let E = toSeq(0..<n).mapIt((i:it+1,ex:GD[it][0] - 30000 * GD[it][1]))
        .filterIt(it.ex * 6 >= 3000000)
if E.len == 0 : quit("NO",0)
echo "YES"
6.times: echo E[0].i