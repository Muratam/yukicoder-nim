import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
template getFactorByProcess(n:int):seq[int] =
  import osproc
  when defined(macosx):
    const factor = "gfactor "
  else :
    const factor = "factor "
  let p = execProcess(factor & $n).strip().split()
  p[1..p.len()-1].map(parseInt)

let n = get().parseInt()
let factors = @[1,n] & n.getFactorByProcess()
var res = initSet[string]()
for f1 in factors:
  let f2 = n div f1
  res.incl fmt"{f1}{f2}"
echo res.card

# 63: 3 3 7
# 1 | 1 3 | 1 3 9 |