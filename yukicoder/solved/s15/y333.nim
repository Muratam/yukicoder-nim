import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
# 1 < 2000000000
let (a,b) = get().split().map(parseInt).unpack(2)
if a > b: # [b + 1,2000000000]
  echo 2000000000 - b - 1
else: # [1,b-1]
  echo b - 2