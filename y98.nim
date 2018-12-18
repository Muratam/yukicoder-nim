import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (x,y) = get().split().map(parseInt).mapIt(it.abs()).unpack(2)
echo((sqrt((x * x + y * y).float) * 2 + 1).int)