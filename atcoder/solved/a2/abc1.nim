import sequtils,strutils,algorithm,math,future,macros,sets,tables,intsets,queues
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[0][1].add(quote do:`t`[`i`])
template times*(n:int,body) = (for _ in 0..<n: body)
template `max=`*(x,y) = x = max(x,y)
template `min=`*(x,y) = x = min(x,y)

let n = get().parseInt()
if n == 25 : echo "Christmas"
elif n == 24: echo "Christmas Eve"
elif n == 23: echo "Christmas Eve Eve"
elif n == 22: echo "Christmas Eve Eve Eve"
