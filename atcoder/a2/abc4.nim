import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let (n,x) = get().split().map(parseInt).unpack(2)
const maxN = 51
var ps = newSeq[int](maxN)
ps[0] = 1
for i in 1..<maxN: ps[i] = 1 + 2 * ps[i-1]
var pbs = newSeq[int](maxN)
pbs[0] = 1
for i in 1..<maxN: pbs[i] = 3 + 2 * pbs[i-1]
proc getP(n,x:int):int =
  if x <= 0 : return 0
  if pbs[n] <= x : return ps[n]
  if pbs[n] < x * 2 - 1:
    return ps[n-1] + 1 + getP(n-1,x-pbs[n-1]-2)
  elif pbs[n] == x * 2 - 1: return 1 + getP(n-1,x-2)
  else: return getP(n-1,x-1)

echo getP(n,x)