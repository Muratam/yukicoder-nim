import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
var A = get().split().map(parseInt)
for i in 0..<n: A[i] -= i + 1
A.sort(cmp)
var result = newSeq[int](n)
block:
  let b = A[0]
  result[0] = 0
  for a in A: result[0] += abs(a - b)
for i,b in A:
  if i == 0 : continue
  let diff = A[i] - A[i-1]
  result[i] = result[i-1] + diff * (i) - diff * (n-i)
echo result.min()


