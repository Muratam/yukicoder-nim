import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

var (xa,ya) = get().split().map(parseFloat).unpack(2)
var (xb,yb) = get().split().map(parseFloat).unpack(2)
xa *= -1
if ya == yb : quit $ya,0
echo(ya - (ya-yb) / (xa-xb)*xa)