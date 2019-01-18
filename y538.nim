import sequtils,strutils,macros
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (b1,b2,b3) = stdin.readLine().split().map(parseInt).unpack(3)
let ans = b3 + (b3-b2)*(b3-b2) div (b2-b1)
echo ans
# b3 = r * b2 + d
# b2 = r * b1 + d
# b3-b2 = r * (b2-b1) => r = (b3-b2)/(b2-b1)
# d = b3 - r*b2

