import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
proc toCountSeq[T](x:seq[T]) : seq[tuple[k:T,v:int]] = toSeq(x.toCountTable().pairs)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
var wants = newSeqWith(21,initTable[string,int]())
n.times:
  let codes = get().split()
  case codes[0].parseInt():
  of 0:
    let index = codes[1].parseInt()
    for code in codes[3..^1]:
      wants[index][code] = wants[index].mgetOrPut(code,0) + 1
  of 1:
    let code = codes[1]
    var ok = false
    for i in 1..20:
      if code notin wants[i]:continue
      if wants[i][code] == 0:continue
      wants[i][code] -= 1
      echo i
      ok = true
      break
    if not ok: echo -1
  else:
    let index = codes[1].parseInt()
    wants[index] = initTable[string,int]()
