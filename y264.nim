import sequtils,strutils,algorithm,math,sugar,macros,strformat
template get*():string = stdin.readLine().strip()
macro unpack*(arr: auto,cnt: static[int]): auto =
  let t = genSym(); result = quote do:(let `t` = `arr`;())
  for i in 0..<cnt: result[1].add(quote do:`t`[`i`])

let (n,k) = get().split().map(parseInt).unpack(2)
case (n - k + 3) mod 3:
  of 0: echo "Drew"
  of 1: echo "Lost"
  of 2: echo "Won"
  else:discard