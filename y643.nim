import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])
let (x,y) = get().split().map(parseInt).unpack(2)
# y = 0 にする必要
# 0 y -> y 0 以外では -a a -> 0 2a の必要
if x == y : quit "0",0
if y == 0 : quit "1",0
if x == 0 : quit "2",0
if x == -y : quit "3",0
quit "-1",0