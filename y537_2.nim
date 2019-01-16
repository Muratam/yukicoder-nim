import sequtils,strutils,algorithm,math,sugar,macros,strformat
import sets,tables,intsets,queues,heapqueue,bitops
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)
proc getIsPrimes(n:int) :seq[bool] = # [0...n] O(n loglog n)
  result = newSeqWith(n+1,true)
  result[0] = false
  result[1] = false
  for i in 2..n.float.sqrt.int :
    if not result[i]: continue
    for j in countup(i*2,n,i):
      result[j] = false

import osproc
template getFactorByProcess(n:int):seq[int] =
  when defined(macosx):
    const factor = "gfactor "
  else :
    const factor = "factor "
  let p = execProcess(factor & $n ).strip().split()
  p[1..p.len()-1].map(parseInt)


# let n = get().parseInt()
let isPrimes = getIsPrimes(1e6.int + 10)
var ans = newSeq[int]()
for n in 1e11.int..(1e11.int+1000):
  ans &= n.getFactorByProcess[0]
echo ans
# for i in
# let factorCounts = n.getFactorByProcess().toCountTable()
# let factors = toSeq(factorCounts.values)
# echo factors.mapIt(it + 1).foldl(a * b,1)
