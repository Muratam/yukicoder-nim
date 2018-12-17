import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b) = get().split().map(parseInt).unpack(2)
var res = initIntSet()
for ai in 0..a:
  for bi in 0..b:
    res.incl(ai + 5 * bi)
res.excl(0)
echo toSeq(res.items).sorted(cmp).join("\n")