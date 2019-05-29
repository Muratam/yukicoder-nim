import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,m) = get().split().map(parseInt).unpack(2)
if m >= n: quit("1",0)
# 連続してはいけない or 全員居る
if n mod 2 == 1 or n div 2 > m : quit("-1",0)
quit("2",0)