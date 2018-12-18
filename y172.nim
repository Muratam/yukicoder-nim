import sequtils,strutils,math,macros
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (x,y,r) = stdin.readLine().split().mapIt(it.parseInt().abs()).unpack(3)
echo(x + y + 1 + (r.float * 2.0.sqrt).int)