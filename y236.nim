import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (a,b,x,y) = get().split().map(parseInt).unpack(4)
if x * b <= y * a: echo x * (a + b) / a
else: echo y * (a + b) / b
# 600 800