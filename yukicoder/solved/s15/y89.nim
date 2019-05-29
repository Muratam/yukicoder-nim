import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let c = get().parseInt()
let (rin,rout) = get().split().map(parseInt).unpack(2)
let R = (rin + rout) / 2
let r = (rout - rin).abs() / 2
echo 2 * PI * PI * r * r * R * c.float
# 2 Pi Pi r r R